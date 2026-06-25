-- Structure Changes for Tourist Locations Firebase Images
-- Run this first

BEGIN;

ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_json JSON;

COMMIT;

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tourist_locations' 
AND column_name LIKE '%firebase%';
