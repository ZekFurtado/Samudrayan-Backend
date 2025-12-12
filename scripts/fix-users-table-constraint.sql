-- Fix the CHECK constraint in users table
-- Drop the existing constraint if it exists
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- Add the corrected CHECK constraint
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN (
    'admin', 'district-admin', 'taluka-admin', 'homestay-owner', 
    'fisherfolk', 'artisan', 'ngo', 'investor', 'tourist', 'trainer'
));

-- Drop old index if it exists and create new one
DROP INDEX IF EXISTS idx_users_user_type;
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);