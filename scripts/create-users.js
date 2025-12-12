const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

require('dotenv').config();

async function createUsersTable() {
  try {
    console.log('🔌 Connecting to database...');
    
    // Read the SQL file
    const sqlPath = path.join(__dirname, 'create-users-table.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('📝 Creating users table...');
    await pool.query(sql);
    
    console.log('✅ Users table created successfully!');
  } catch (error) {
    if (error.message.includes('already exists')) {
      console.log('✅ Users table already exists!');
    } else {
      console.error('❌ Users table creation failed:', error.message);
      throw error;
    }
  } finally {
    await pool.end();
  }
}

createUsersTable()
  .then(() => {
    console.log('🎉 Users table setup complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Setup failed:', error);
    process.exit(1);
  });