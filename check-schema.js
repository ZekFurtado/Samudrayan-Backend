const pool = require('./config/database');
require('dotenv').config();

const checkSchema = async () => {
  try {
    console.log('🔍 Checking database schema...');
    
    // Check verification columns in users table
    const columnsQuery = `
      SELECT column_name, data_type, character_maximum_length, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'users' AND column_name LIKE '%verification%' 
      ORDER BY column_name;
    `;
    
    const columnsResult = await pool.query(columnsQuery);
    console.log('\n📊 Users table verification columns:');
    console.table(columnsResult.rows);
    
    // Check if aadhar_verification_logs table exists
    const tableQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_name = 'aadhar_verification_logs';
    `;
    
    const tableResult = await pool.query(tableQuery);
    console.log('\n📋 Aadhar verification logs table exists:', tableResult.rows.length > 0);
    
    if (tableResult.rows.length > 0) {
      const logsColumnsQuery = `
        SELECT column_name, data_type, character_maximum_length 
        FROM information_schema.columns 
        WHERE table_name = 'aadhar_verification_logs' 
        ORDER BY column_name;
      `;
      
      const logsColumnsResult = await pool.query(logsColumnsQuery);
      console.log('\n📊 Aadhar verification logs table columns:');
      console.table(logsColumnsResult.rows);
    }
    
    // Check for any existing users to see actual data types
    const usersQuery = `
      SELECT id, firebase_uid, aadhar_verification_status 
      FROM users 
      LIMIT 5;
    `;
    
    const usersResult = await pool.query(usersQuery);
    console.log('\n👥 Sample users data:');
    console.table(usersResult.rows);
    
  } catch (error) {
    console.error('❌ Error checking schema:', error);
  } finally {
    await pool.end();
  }
};

checkSchema();