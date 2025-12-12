require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

async function setupDatabase() {
  try {
    console.log('🔌 Connecting to database...');
    
    // Test connection
    const client = await pool.connect();
    console.log('✅ Database connection successful');
    
    // Read and execute SQL script
    const sqlPath = path.join(__dirname, 'create-homestay-tables.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('📝 Creating homestay tables...');
    await client.query(sql);
    console.log('✅ Homestay tables created successfully');
    
    // Test table creation
    const result = await client.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      AND tablename IN ('homestays', 'homestay_rooms')
    `);
    
    console.log('📋 Tables created:', result.rows.map(row => row.tablename));
    
    client.release();
    console.log('🎉 Database setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

setupDatabase();