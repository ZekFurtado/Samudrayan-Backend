const pool = require('@samudrayan/shared').db.getPool();

class UserRepository {
  async findByFirebaseUid(firebaseUid) {
    const query = 'SELECT * FROM users WHERE firebase_uid = $1';
    const result = await pool.query(query, [firebaseUid]);
    return result.rows[0];
  }

  async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0];
  }

  async findByPhone(phone) {
    const query = 'SELECT * FROM users WHERE phone = $1';
    const result = await pool.query(query, [phone]);
    return result.rows[0];
  }

  async create(userData) {
    const {
      firebaseUid,
      fullName,
      email,
      phone,
      userType,
      district,
      taluka
    } = userData;

    const query = `
      INSERT INTO users (firebase_uid, full_name, email, phone, role, district, taluka)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;
    
    const values = [firebaseUid, fullName, email, phone, userType, district, taluka];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async update(firebaseUid, updateData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(updateData).forEach(key => {
      if (updateData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        values.push(updateData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(firebaseUid);
    const query = `
      UPDATE users 
      SET ${fields.join(', ')}, updated_at = NOW()
      WHERE firebase_uid = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async verifyUser(firebaseUid) {
    const query = `
      UPDATE users 
      SET is_verified = true, status = 'active', updated_at = NOW()
      WHERE firebase_uid = $1
      RETURNING *
    `;
    
    const result = await pool.query(query, [firebaseUid]);
    return result.rows[0];
  }

  async updateStatus(firebaseUid, status) {
    const query = `
      UPDATE users
      SET status = $1, updated_at = NOW()
      WHERE firebase_uid = $2
      RETURNING *
    `;

    const result = await pool.query(query, [status, firebaseUid]);
    return result.rows[0];
  }

  // Atomically reserves the next sequence number for a given (year, category
  // code) pair, backing the human-readable partner_id format
  // 'SAM-{year}-{categoryCode}-{sequence}'.
  async getNextPartnerIdSequence(categoryCode) {
    const year = new Date().getFullYear();
    const query = `
      INSERT INTO partner_id_sequences (year, category_code, last_value)
      VALUES ($1, $2, 1)
      ON CONFLICT (year, category_code)
      DO UPDATE SET last_value = partner_id_sequences.last_value + 1
      RETURNING last_value
    `;
    const result = await pool.query(query, [year, categoryCode]);
    return { year, sequence: result.rows[0].last_value };
  }

  async createPartnerCategory(userId, categoryId, status) {
    const query = `
      INSERT INTO partner_categories (user_id, category_id, status)
      VALUES ($1, $2, $3)
      ON CONFLICT (user_id, category_id) DO NOTHING
      RETURNING *
    `;
    const result = await pool.query(query, [userId, categoryId, status]);
    return result.rows[0];
  }
}

module.exports = UserRepository;