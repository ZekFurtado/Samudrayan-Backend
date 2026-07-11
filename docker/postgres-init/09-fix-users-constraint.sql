-- Fix the CHECK constraint in users table
-- Drop the existing constraint if it exists
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- Add the corrected CHECK constraint.
-- NOTE: the original scripts/fix-users-table-constraint.sql's role list here was
-- stale — it ran (in this init order) *after* 05-restaurants.sql, which
-- conditionally widens this same constraint to include 'restaurant-owner' and
-- 'verified-reporter', and clobbered that widening by recreating the constraint
-- without them. Updated here to match the fuller list from
-- scripts/create-restaurant-tables.sql (and auth.js's validateRegister allow-list,
-- which already accepts 'restaurant-owner').
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN (
    'admin', 'district-admin', 'taluka-admin', 'homestay-owner',
    'fisherfolk', 'artisan', 'ngo', 'investor', 'tourist', 'trainer',
    'verified-reporter', 'restaurant-owner'
));

-- Drop old index if it exists and create new one
DROP INDEX IF EXISTS idx_users_user_type;
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);