-- Add Aadhar verification fields to users table
-- Run this script to enable Aadhar card verification for homestay owners

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

-- Create indexes for better performance on verification queries
CREATE INDEX IF NOT EXISTS idx_users_aadhar_verification_status 
    ON users(aadhar_verification_status);
CREATE INDEX IF NOT EXISTS idx_users_verification_method 
    ON users(verification_method);
CREATE INDEX IF NOT EXISTS idx_users_verification_reference_id 
    ON users(verification_reference_id);

-- Create Aadhar verification logs table for audit trail
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

-- Create indexes for verification logs
CREATE INDEX IF NOT EXISTS idx_aadhar_logs_user_id 
    ON aadhar_verification_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_aadhar_logs_status 
    ON aadhar_verification_logs(status);
CREATE INDEX IF NOT EXISTS idx_aadhar_logs_created_at 
    ON aadhar_verification_logs(created_at);

-- Add trigger to update updated_at timestamp on users table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Ensure trigger exists for users table
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample verification types for reference
INSERT INTO verification_logs (message) VALUES 
    ('Aadhar verification fields added to users table'),
    ('Aadhar verification logs table created'),
    ('Indexes created for Aadhar verification optimization')
ON CONFLICT DO NOTHING;

COMMENT ON COLUMN users.aadhar_number_encrypted IS 'Encrypted Aadhar number for security';
COMMENT ON COLUMN users.aadhar_verification_status IS 'Current status of Aadhar verification process';
COMMENT ON COLUMN users.verification_method IS 'Method used for verification (UIDAI/DigiLocker/Manual)';
COMMENT ON COLUMN users.verification_reference_id IS 'External reference ID from verification service';
COMMENT ON TABLE aadhar_verification_logs IS 'Audit trail for all Aadhar verification attempts';