-- Update verification logs table to support temporary submission type
-- This allows temporary Aadhar submissions for admin approval

-- Drop existing constraint and recreate with new verification type
ALTER TABLE aadhar_verification_logs 
DROP CONSTRAINT IF EXISTS aadhar_verification_logs_verification_type_check;

ALTER TABLE aadhar_verification_logs 
ADD CONSTRAINT aadhar_verification_logs_verification_type_check 
CHECK (verification_type IN ('uidai', 'digilocker', 'manual', 'temporary_submission'));

-- Also update the status constraint to include 'pending'
ALTER TABLE aadhar_verification_logs 
DROP CONSTRAINT IF EXISTS aadhar_verification_logs_status_check;

ALTER TABLE aadhar_verification_logs 
ADD CONSTRAINT aadhar_verification_logs_status_check 
CHECK (status IN ('initiated', 'success', 'failed', 'error', 'pending'));

COMMENT ON COLUMN aadhar_verification_logs.verification_type IS 'Method used for verification (UIDAI/DigiLocker/Manual/Temporary Submission)';
COMMENT ON COLUMN aadhar_verification_logs.status IS 'Status of verification attempt (initiated/success/failed/error/pending)';