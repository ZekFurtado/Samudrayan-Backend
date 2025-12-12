const pool = require('../../../config/database');

class LocationRepository {
  async getAllLocations(includeInactive = false) {
    const activeFilter = includeInactive ? '' : 'WHERE d.is_active = true AND t.is_active = true';
    
    const query = `
      SELECT 
        d.id as district_id,
        d.name as district,
        d.district_code,
        ARRAY_AGG(
          JSON_BUILD_OBJECT(
            'id', t.id,
            'name', t.name,
            'code', t.taluka_code
          ) ORDER BY t.name
        ) as talukas
      FROM districts d
      INNER JOIN talukas t ON d.id = t.district_id
      ${activeFilter}
      GROUP BY d.id, d.name, d.district_code
      ORDER BY d.name
    `;
    
    const result = await pool.query(query);
    return result.rows;
  }

  async getLocationHierarchy(districtName = null, includeInactive = false) {
    const activeFilter = includeInactive ? '' : 'AND d.is_active = true AND t.is_active = true';
    const districtFilter = districtName ? 'AND d.name = $1' : '';
    
    const query = `
      SELECT 
        d.id as district_id,
        d.name as district,
        d.district_code,
        t.id as taluka_id,
        t.name as taluka,
        t.taluka_code,
        
        -- Cities in this taluka
        COALESCE(
          (SELECT JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', c.id,
              'name', c.name,
              'type', c.city_type,
              'population', c.population
            ) ORDER BY c.name
          )
          FROM cities c 
          WHERE c.taluka_id = t.id AND c.is_active = true), 
          '[]'::json
        ) as cities,
        
        -- Villages in this taluka
        COALESCE(
          (SELECT JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', v.id,
              'name', v.name,
              'code', v.village_code,
              'is_coastal', v.is_coastal,
              'population', v.population
            ) ORDER BY v.name
          )
          FROM villages v 
          WHERE v.taluka_id = t.id AND v.is_active = true), 
          '[]'::json
        ) as villages,
        
        -- Blocks in this taluka
        COALESCE(
          (SELECT JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', b.id,
              'name', b.name,
              'code', b.block_code
            ) ORDER BY b.name
          )
          FROM blocks b 
          WHERE b.taluka_id = t.id AND b.is_active = true), 
          '[]'::json
        ) as blocks
        
      FROM districts d
      INNER JOIN talukas t ON d.id = t.district_id
      WHERE 1=1 ${activeFilter} ${districtFilter}
      ORDER BY d.name, t.name
    `;
    
    const params = districtName ? [districtName] : [];
    const result = await pool.query(query, params);
    
    // Group by district
    const districts = {};
    result.rows.forEach(row => {
      if (!districts[row.district]) {
        districts[row.district] = {
          id: row.district_id,
          name: row.district,
          code: row.district_code,
          talukas: []
        };
      }
      
      districts[row.district].talukas.push({
        id: row.taluka_id,
        name: row.taluka,
        code: row.taluka_code,
        cities: row.cities,
        villages: row.villages,
        blocks: row.blocks
      });
    });
    
    return Object.values(districts);
  }

  async getDistrictByName(name) {
    const query = 'SELECT * FROM districts WHERE name = $1';
    const result = await pool.query(query, [name]);
    return result.rows[0];
  }

  async getTalukasByDistrict(districtName, includeInactive = false) {
    const activeFilter = includeInactive ? '' : 'AND t.is_active = true';
    
    const query = `
      SELECT t.*
      FROM talukas t
      INNER JOIN districts d ON t.district_id = d.id
      WHERE d.name = $1 ${activeFilter}
      ORDER BY t.name
    `;
    
    const result = await pool.query(query, [districtName]);
    return result.rows;
  }

  async addDistrict(name) {
    const query = `
      INSERT INTO districts (name)
      VALUES ($1)
      RETURNING *
    `;
    
    const result = await pool.query(query, [name]);
    return result.rows[0];
  }

  async addTaluka(districtName, talukaName) {
    const query = `
      INSERT INTO talukas (district_id, name)
      SELECT d.id, $2
      FROM districts d
      WHERE d.name = $1
      RETURNING *
    `;
    
    const result = await pool.query(query, [districtName, talukaName]);
    return result.rows[0];
  }

  async updateLocationStatus(type, id, isActive) {
    const validTypes = ['district', 'taluka', 'block', 'city', 'village', 'gram_panchayat'];
    if (!validTypes.includes(type)) {
      throw new Error(`Invalid location type: ${type}`);
    }
    
    const tableMap = {
      'district': 'districts',
      'taluka': 'talukas', 
      'block': 'blocks',
      'city': 'cities',
      'village': 'villages',
      'gram_panchayat': 'gram_panchayats'
    };
    
    const table = tableMap[type];
    const query = `
      UPDATE ${table}
      SET is_active = $2, updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `;
    
    const result = await pool.query(query, [id, isActive]);
    return result.rows[0];
  }

  async getCoastalVillages(districtName = null) {
    let query = `
      SELECT 
        d.name as district,
        t.name as taluka,
        v.id,
        v.name,
        v.village_code,
        v.population
      FROM villages v
      INNER JOIN talukas t ON v.taluka_id = t.id
      INNER JOIN districts d ON t.district_id = d.id
      WHERE v.is_coastal = true AND v.is_active = true
    `;
    
    const params = [];
    if (districtName) {
      query += ' AND d.name = $1';
      params.push(districtName);
    }
    
    query += ' ORDER BY d.name, t.name, v.name';
    
    const result = await pool.query(query, params);
    return result.rows;
  }

  async getGramPanchayatsByBlock(blockId) {
    const query = `
      SELECT 
        gp.id,
        gp.name,
        gp.gp_code,
        gp.headquarters_village,
        b.name as block_name,
        t.name as taluka_name,
        d.name as district_name
      FROM gram_panchayats gp
      INNER JOIN blocks b ON gp.block_id = b.id
      INNER JOIN talukas t ON b.taluka_id = t.id
      INNER JOIN districts d ON t.district_id = d.id
      WHERE gp.block_id = $1 AND gp.is_active = true
      ORDER BY gp.name
    `;
    
    const result = await pool.query(query, [blockId]);
    return result.rows;
  }

  async searchLocations(searchTerm, locationType = null) {
    const validTypes = ['district', 'taluka', 'block', 'city', 'village'];
    
    let queries = [];
    
    if (!locationType || locationType === 'district') {
      queries.push(`
        SELECT 'district' as type, id, name, name as display_name, NULL as parent_info
        FROM districts 
        WHERE name ILIKE $1 AND is_active = true
      `);
    }
    
    if (!locationType || locationType === 'taluka') {
      queries.push(`
        SELECT 'taluka' as type, t.id, t.name, 
               t.name || ', ' || d.name as display_name,
               d.name as parent_info
        FROM talukas t
        INNER JOIN districts d ON t.district_id = d.id
        WHERE t.name ILIKE $1 AND t.is_active = true AND d.is_active = true
      `);
    }
    
    if (!locationType || locationType === 'village') {
      queries.push(`
        SELECT 'village' as type, v.id, v.name,
               v.name || ', ' || t.name || ', ' || d.name as display_name,
               t.name || ', ' || d.name as parent_info
        FROM villages v
        INNER JOIN talukas t ON v.taluka_id = t.id
        INNER JOIN districts d ON t.district_id = d.id
        WHERE v.name ILIKE $1 AND v.is_active = true AND t.is_active = true AND d.is_active = true
      `);
    }
    
    const query = queries.join(' UNION ALL ') + ' ORDER BY type, name LIMIT 50';
    const result = await pool.query(query, [`%${searchTerm}%`]);
    return result.rows;
  }
}

module.exports = LocationRepository;