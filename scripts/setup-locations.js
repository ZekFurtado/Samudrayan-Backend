require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

async function setupLocations() {
  try {
    console.log('🔌 Connecting to database...');
    
    // Test connection
    const client = await pool.connect();
    console.log('✅ Database connection successful');
    
    // Read and execute SQL script for locations
    const sqlPath = path.join(__dirname, 'create-locations-table.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('📝 Creating locations tables...');
    await client.query(sql);
    console.log('✅ Locations tables created successfully');
    
    // Test table creation
    const result = await client.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      AND tablename IN ('districts', 'talukas', 'villages')
    `);
    
    console.log('📋 Tables created:', result.rows.map(row => row.tablename));
    
    // Test data insertion
    const dataResult = await client.query(`
      SELECT d.name as district, COUNT(t.id) as taluka_count
      FROM districts d
      LEFT JOIN talukas t ON d.id = t.district_id
      GROUP BY d.name
      ORDER BY d.name
    `);
    
    console.log('📊 Data inserted:', dataResult.rows);
    
    client.release();
    console.log('🎉 Locations setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Locations setup failed:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

setupLocations();