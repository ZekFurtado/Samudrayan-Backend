-- Finalize Tourist Locations Firebase Images Update
-- Run this last, after all updates are complete

BEGIN;

-- Verify all data is updated before proceeding
DO $$
DECLARE
    update_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO update_count 
    FROM tourist_locations 
    WHERE firebase_storage_images_json IS NOT NULL;
    
    IF update_count < 100 THEN
        RAISE EXCEPTION 'Only % locations updated. Expected at least 100. Please check updates first.', update_count;
    END IF;
    
    RAISE NOTICE 'Found % updated locations. Proceeding with finalization.', update_count;
END $$;

-- Drop old column
ALTER TABLE tourist_locations DROP COLUMN firebase_storage_images;

-- Rename new column
ALTER TABLE tourist_locations RENAME COLUMN firebase_storage_images_json TO firebase_storage_images;

-- Add constraint
ALTER TABLE tourist_locations ADD CONSTRAINT firebase_images_valid_json 
  CHECK (firebase_storage_images IS NULL OR firebase_storage_images::text != 'null');

-- Create index
CREATE INDEX IF NOT EXISTS idx_tourist_locations_firebase_images_expr
  ON tourist_locations USING BTREE ((firebase_storage_images::text));

COMMIT;

-- Final verification
SELECT 
    COUNT(*) as total_locations_with_images,
    AVG(json_array_length(firebase_storage_images)) as avg_images_per_location
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL;

-- Sample data check
SELECT 
    place_name, 
    json_array_length(firebase_storage_images) as image_count,
    firebase_storage_images->0 as first_image
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL
ORDER BY place_name
LIMIT 5;
