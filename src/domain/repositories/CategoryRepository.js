const pool = require('../../../config/database');

class CategoryRepository {
  async getAllCategories(type = null, includeInactive = false) {
    let query = `
      SELECT 
        id,
        category_name,
        subcategories,
        benefits,
        type,
        is_active,
        created_at,
        updated_at
      FROM categories
    `;
    
    const conditions = [];
    const params = [];
    let paramIndex = 1;

    if (type) {
      conditions.push(`type = $${paramIndex}`);
      params.push(type);
      paramIndex++;
    }

    if (!includeInactive) {
      conditions.push(`is_active = $${paramIndex}`);
      params.push(true);
      paramIndex++;
    }

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }

    query += ` ORDER BY category_name ASC`;

    const result = await pool.query(query, params);
    return result.rows;
  }

  async getCategoriesByType(type, includeInactive = false) {
    return this.getAllCategories(type, includeInactive);
  }

  async getFormattedCategories(includeInactive = false) {
    const categories = await this.getAllCategories(null, includeInactive);
    
    const formatted = {
      homestayGrades: [],
      marketplace: [],
      tourism: []
    };

    categories.forEach(category => {
      if (category.type === 'homestay') {
        formatted.homestayGrades = category.subcategories || [];
      } else if (category.type === 'marketplace') {
        formatted.marketplace = category.subcategories || [];
      } else if (category.type === 'tourism') {
        if (!formatted.tourism.find(item => item.category === category.category_name)) {
          formatted.tourism.push({
            category: category.category_name,
            subcategories: category.subcategories || [],
            benefits: category.benefits
          });
        }
      }
    });

    return formatted;
  }

  async getCategoryById(id) {
    const query = `
      SELECT 
        id,
        category_name,
        subcategories,
        benefits,
        type,
        is_active,
        created_at,
        updated_at
      FROM categories
      WHERE id = $1
    `;

    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }
}

module.exports = CategoryRepository;