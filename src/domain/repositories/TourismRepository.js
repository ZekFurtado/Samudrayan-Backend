const pool = require('../../../config/database');

class TourismRepository {
  // Tourist Locations methods
  async getAllTouristLocations(filters = {}) {
    let query = `
      SELECT 
        id,
        sr_no,
        place_name,
        taluka,
        location,
        latitude_longitude,
        video_link,
        description,
        famous_for,
        best_time_to_visit,
        ideal_duration,
        images_drive_link,
        firebase_storage_images,
        is_active,
        created_at,
        updated_at
      FROM tourist_locations
      WHERE is_active = TRUE
    `;
    
    const params = [];
    let paramCount = 0;

    // Add filters
    if (filters.taluka) {
      paramCount++;
      query += ` AND taluka ILIKE $${paramCount}`;
      params.push(`%${filters.taluka}%`);
    }

    if (filters.search) {
      paramCount++;
      query += ` AND (place_name ILIKE $${paramCount} OR description ILIKE $${paramCount} OR famous_for ILIKE $${paramCount})`;
      params.push(`%${filters.search}%`);
    }

    query += ` ORDER BY sr_no ASC`;

    const result = await pool.query(query, params);
    return result.rows;
  }

  async getTouristLocationById(id) {
    const query = `
      SELECT 
        id,
        sr_no,
        place_name,
        taluka,
        location,
        latitude_longitude,
        video_link,
        description,
        famous_for,
        best_time_to_visit,
        ideal_duration,
        images_drive_link,
        firebase_storage_images,
        is_active,
        created_at,
        updated_at
      FROM tourist_locations
      WHERE id = $1 AND is_active = TRUE
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  async getTouristLocationsByTaluka(taluka) {
    const query = `
      SELECT 
        id,
        sr_no,
        place_name,
        taluka,
        location,
        latitude_longitude,
        video_link,
        description,
        famous_for,
        best_time_to_visit,
        ideal_duration,
        images_drive_link,
        firebase_storage_images,
        is_active,
        created_at,
        updated_at
      FROM tourist_locations
      WHERE taluka ILIKE $1 AND is_active = TRUE
      ORDER BY sr_no ASC
    `;
    
    const result = await pool.query(query, [`%${taluka}%`]);
    return result.rows;
  }

  async searchTouristLocations(searchTerm) {
    const query = `
      SELECT 
        id,
        sr_no,
        place_name,
        taluka,
        location,
        latitude_longitude,
        video_link,
        description,
        famous_for,
        best_time_to_visit,
        ideal_duration,
        images_drive_link,
        firebase_storage_images,
        is_active,
        created_at,
        updated_at
      FROM tourist_locations
      WHERE is_active = TRUE 
        AND (place_name ILIKE $1 OR description ILIKE $1 OR famous_for ILIKE $1 OR location ILIKE $1)
      ORDER BY sr_no ASC
    `;
    
    const result = await pool.query(query, [`%${searchTerm}%`]);
    return result.rows;
  }

  async createTouristLocation(locationData) {
    const {
      sr_no,
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    } = locationData;
    
    const query = `
      INSERT INTO tourist_locations (
        sr_no, place_name, taluka, location, latitude_longitude,
        video_link, description, famous_for, best_time_to_visit,
        ideal_duration, images_drive_link, firebase_storage_images
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;
    
    const result = await pool.query(query, [
      sr_no, place_name, taluka, location, latitude_longitude,
      video_link, description, famous_for, best_time_to_visit,
      ideal_duration, images_drive_link, firebase_storage_images
    ]);
    
    return result.rows[0];
  }

  async updateTouristLocation(id, locationData) {
    const {
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    } = locationData;
    
    const query = `
      UPDATE tourist_locations 
      SET 
        place_name = $2,
        taluka = $3,
        location = $4,
        latitude_longitude = $5,
        video_link = $6,
        description = $7,
        famous_for = $8,
        best_time_to_visit = $9,
        ideal_duration = $10,
        images_drive_link = $11,
        firebase_storage_images = $12,
        updated_at = NOW()
      WHERE id = $1 AND is_active = TRUE
      RETURNING *
    `;
    
    const result = await pool.query(query, [
      id, place_name, taluka, location, latitude_longitude,
      video_link, description, famous_for, best_time_to_visit,
      ideal_duration, images_drive_link, firebase_storage_images
    ]);
    
    return result.rows[0];
  }

  async deleteTouristLocation(id) {
    // Soft delete by setting is_active to false
    const query = `
      UPDATE tourist_locations 
      SET is_active = FALSE, updated_at = NOW()
      WHERE id = $1 
      RETURNING *
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  async getTouristLocationStatistics() {
    const query = `
      SELECT 
        COUNT(*) as total_locations,
        COUNT(DISTINCT taluka) as total_talukas,
        COUNT(CASE WHEN video_link IS NOT NULL AND video_link != '' THEN 1 END) as locations_with_video,
        COUNT(CASE WHEN firebase_storage_images IS NOT NULL AND firebase_storage_images != '' THEN 1 END) as locations_with_images
      FROM tourist_locations
      WHERE is_active = TRUE
    `;
    
    const result = await pool.query(query);
    return result.rows[0];
  }

  // Experiences methods
  async getAllExperiences(includeInactive = false) {
    const query = `
      SELECT 
        e.id,
        e.title,
        e.description,
        e.price,
        COUNT(pe.property_id) as property_count
      FROM experiences e
      LEFT JOIN property_experiences pe ON e.id = pe.experience_id
      GROUP BY e.id, e.title, e.description, e.price
      ORDER BY e.title
    `;
    
    const result = await pool.query(query);
    return result.rows;
  }

  async getExperienceById(id) {
    const query = `
      SELECT 
        e.id,
        e.title,
        e.description,
        e.price,
        COUNT(pe.property_id) as property_count
      FROM experiences e
      LEFT JOIN property_experiences pe ON e.id = pe.experience_id
      WHERE e.id = $1
      GROUP BY e.id, e.title, e.description, e.price
    `;
    
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  async createExperience(experienceData) {
    const { title, description, price } = experienceData;
    
    const query = `
      INSERT INTO experiences (id, title, description, price)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    
    const id = `exp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const result = await pool.query(query, [id, title, description, price]);
    return result.rows[0];
  }

  async updateExperience(id, experienceData) {
    const { title, description, price } = experienceData;
    
    const query = `
      UPDATE experiences 
      SET title = $2, description = $3, price = $4
      WHERE id = $1
      RETURNING *
    `;
    
    const result = await pool.query(query, [id, title, description, price]);
    return result.rows[0];
  }

  async deleteExperience(id) {
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      
      // First, remove all property associations
      await client.query('DELETE FROM property_experiences WHERE experience_id = $1', [id]);
      
      // Then delete the experience
      const result = await client.query('DELETE FROM experiences WHERE id = $1 RETURNING *', [id]);
      
      await client.query('COMMIT');
      return result.rows[0];
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getExperiencesByLocation(districtName, talukaName = null) {
    let query = `
      SELECT DISTINCT
        e.id,
        e.title,
        e.description,
        e.price,
        COUNT(pe.property_id) as property_count
      FROM experiences e
      INNER JOIN property_experiences pe ON e.id = pe.experience_id
      INNER JOIN homestays h ON pe.property_id = h.id
      INNER JOIN talukas t ON h.taluka_id = t.id
      INNER JOIN districts d ON t.district_id = d.id
      WHERE d.name = $1
    `;
    
    const params = [districtName];
    
    if (talukaName) {
      query += ' AND t.name = $2';
      params.push(talukaName);
    }
    
    query += `
      GROUP BY e.id, e.title, e.description, e.price
      ORDER BY e.title
    `;
    
    const result = await pool.query(query, params);
    return result.rows;
  }

  async getPopularExperiences(limit = 10) {
    const query = `
      SELECT 
        e.id,
        e.title,
        e.description,
        e.price,
        COUNT(pe.property_id) as property_count
      FROM experiences e
      LEFT JOIN property_experiences pe ON e.id = pe.experience_id
      GROUP BY e.id, e.title, e.description, e.price
      ORDER BY property_count DESC, e.title
      LIMIT $1
    `;
    
    const result = await pool.query(query, [limit]);
    return result.rows;
  }

  async searchExperiences(searchTerm) {
    const query = `
      SELECT 
        e.id,
        e.title,
        e.description,
        e.price,
        COUNT(pe.property_id) as property_count
      FROM experiences e
      LEFT JOIN property_experiences pe ON e.id = pe.experience_id
      WHERE e.title ILIKE $1 OR e.description ILIKE $1
      GROUP BY e.id, e.title, e.description, e.price
      ORDER BY e.title
    `;
    
    const result = await pool.query(query, [`%${searchTerm}%`]);
    return result.rows;
  }

  async getExperienceStatistics() {
    const query = `
      SELECT 
        COUNT(*) as total_experiences,
        AVG(price) as average_price,
        MIN(price) as min_price,
        MAX(price) as max_price,
        COUNT(DISTINCT pe.property_id) as properties_with_experiences
      FROM experiences e
      LEFT JOIN property_experiences pe ON e.id = pe.experience_id
    `;
    
    const result = await pool.query(query);
    return result.rows[0];
  }

  async addExperienceToProperty(experienceId, propertyId) {
    const query = `
      INSERT INTO property_experiences (experience_id, property_id)
      VALUES ($1, $2)
      ON CONFLICT (experience_id, property_id) DO NOTHING
      RETURNING *
    `;
    
    const result = await pool.query(query, [experienceId, propertyId]);
    return result.rows[0];
  }

  async removeExperienceFromProperty(experienceId, propertyId) {
    const query = `
      DELETE FROM property_experiences 
      WHERE experience_id = $1 AND property_id = $2
      RETURNING *
    `;
    
    const result = await pool.query(query, [experienceId, propertyId]);
    return result.rows[0];
  }
}

module.exports = TourismRepository;