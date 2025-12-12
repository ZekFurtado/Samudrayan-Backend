-- Update Zek Furtado's user type from 'tourist' to 'admin'
UPDATE users 
SET user_type = 'admin', 
    updated_at = NOW()
WHERE firebase_uid = 'J5TROvXYTahgnB0hywjDOOsTYYi2';

-- Verify the update
SELECT firebase_uid, full_name, email, user_type, status, is_verified
FROM users 
WHERE firebase_uid = 'J5TROvXYTahgnB0hywjDOOsTYYi2';