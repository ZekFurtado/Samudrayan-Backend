const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false
  },
  max: 20,
  idleTimeoutMillis: 60000,
  connectionTimeoutMillis: 10000,
  acquireTimeoutMillis: 10000,
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000,
});

const createVerificationTables = async () => {
  try {
    console.log('🔧 Setting up Aadhar verification tables...');
    
    // Add Aadhar verification fields to users table
    const userFieldsQuery = `
      -- Add new columns for Aadhar verification
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS aadhar_number_encrypted TEXT,
      ADD COLUMN IF NOT EXISTS aadhar_verification_status VARCHAR(20) DEFAULT 'pending' 
          CHECK (aadhar_verification_status IN ('pending', 'in_progress', 'verified', 'failed', 'rejected')),
      ADD COLUMN IF NOT EXISTS aadhar_verified_at TIMESTAMP WITH TIME ZONE,
      ADD COLUMN IF NOT EXISTS verification_method VARCHAR(20) 
          CHECK (verification_method IN ('uidai', 'digilocker', 'manual')),
      ADD COLUMN IF NOT EXISTS verification_reference_id VARCHAR(255),
      ADD COLUMN IF NOT EXISTS verification_attempts INTEGER DEFAULT 0,
      ADD COLUMN IF NOT EXISTS verification_failure_reason TEXT,
      ADD COLUMN IF NOT EXISTS aadhar_document_url TEXT,
      ADD COLUMN IF NOT EXISTS last_verification_attempt TIMESTAMP WITH TIME ZONE;
    `;
    
    console.log('📝 Adding Aadhar verification fields to users table...');
    await pool.query(userFieldsQuery);
    
    // Create indexes for better performance on verification queries
    const userIndexesQuery = `
      CREATE INDEX IF NOT EXISTS idx_users_aadhar_verification_status 
          ON users(aadhar_verification_status);
      CREATE INDEX IF NOT EXISTS idx_users_verification_method 
          ON users(verification_method);
      CREATE INDEX IF NOT EXISTS idx_users_verification_reference_id 
          ON users(verification_reference_id);
    `;
    
    console.log('📊 Creating indexes for users table...');
    await pool.query(userIndexesQuery);
    
    // Create Aadhar verification logs table for audit trail
    const logsTableQuery = `
      CREATE TABLE IF NOT EXISTS aadhar_verification_logs (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(id) ON DELETE CASCADE,
          verification_type VARCHAR(20) NOT NULL CHECK (verification_type IN ('uidai', 'digilocker', 'manual')),
          request_data JSONB,
          response_data JSONB,
          status VARCHAR(20) NOT NULL CHECK (status IN ('initiated', 'success', 'failed', 'error')),
          error_message TEXT,
          ip_address INET,
          user_agent TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `;
    
    console.log('📋 Creating aadhar_verification_logs table...');
    await pool.query(logsTableQuery);
    
    // Create indexes for verification logs
    const logsIndexesQuery = `
      CREATE INDEX IF NOT EXISTS idx_aadhar_logs_user_id 
          ON aadhar_verification_logs(user_id);
      CREATE INDEX IF NOT EXISTS idx_aadhar_logs_status 
          ON aadhar_verification_logs(status);
      CREATE INDEX IF NOT EXISTS idx_aadhar_logs_created_at 
          ON aadhar_verification_logs(created_at);
    `;
    
    console.log('📊 Creating indexes for verification logs...');
    await pool.query(logsIndexesQuery);
    
    // Create or update the trigger function
    const triggerFunctionQuery = `
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = NOW();
          RETURN NEW;
      END;
      $$ language 'plpgsql';
    `;
    
    console.log('⚙️ Creating trigger function...');
    await pool.query(triggerFunctionQuery);
    
    // Ensure trigger exists for users table
    const triggerQuery = `
      DROP TRIGGER IF EXISTS update_users_updated_at ON users;
      CREATE TRIGGER update_users_updated_at 
          BEFORE UPDATE ON users 
          FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `;
    
    console.log('🔄 Setting up update trigger...');
    await pool.query(triggerQuery);
    
    // Add comments for documentation
    const commentsQuery = `
      COMMENT ON COLUMN users.aadhar_number_encrypted IS 'Encrypted Aadhar number for security';
      COMMENT ON COLUMN users.aadhar_verification_status IS 'Current status of Aadhar verification process';
      COMMENT ON COLUMN users.verification_method IS 'Method used for verification (UIDAI/DigiLocker/Manual)';
      COMMENT ON COLUMN users.verification_reference_id IS 'External reference ID from verification service';
      COMMENT ON TABLE aadhar_verification_logs IS 'Audit trail for all Aadhar verification attempts';
    `;
    
    console.log('📄 Adding table documentation...');
    await pool.query(commentsQuery);
    
    console.log('✅ Aadhar verification tables setup completed successfully!');
    console.log('\n📋 Created/Updated:');
    console.log('- Added Aadhar verification fields to users table');
    console.log('- Created aadhar_verification_logs table');
    console.log('- Created necessary indexes for performance');
    console.log('- Set up update triggers');
    console.log('- Added table documentation');
    
  } catch (error) {
    console.error('❌ Error setting up verification tables:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

// Run the setup if this script is called directly
if (require.main === module) {
  createVerificationTables()
    .then(() => {
      console.log('\n🎉 Database setup complete! Verification endpoints should now work.');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n💥 Database setup failed:', error.message);
      process.exit(1);
    });
}

module.exports = { createVerificationTables };