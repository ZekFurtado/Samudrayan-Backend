-- Rollback Script for Tourist Locations Firebase Images Update
-- Use this script if you need to rollback the changes from the update script

BEGIN;

-- Check current state
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tourist_locations' 
  AND column_name LIKE '%firebase_storage_images%';

-- If the update was partially completed, this script will clean up

-- Drop any indexes created
DROP INDEX IF EXISTS idx_tourist_locations_firebase_images_gin;
DROP INDEX IF EXISTS idx_tourist_locations_firebase_images_expr;

-- Drop any constraints added
ALTER TABLE tourist_locations DROP CONSTRAINT IF EXISTS firebase_images_valid_json;

-- If there's a JSON column, convert it back to TEXT
DO $$
BEGIN
    -- Check if JSON column exists
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tourist_locations' 
          AND column_name = 'firebase_storage_images' 
          AND data_type = 'json'
    ) THEN
        -- Add a temporary TEXT column
        ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_text TEXT;
        
        -- Convert JSON to TEXT (if you want to keep the data)
        UPDATE tourist_locations 
        SET firebase_storage_images_text = firebase_storage_images::text
        WHERE firebase_storage_images IS NOT NULL;
        
        -- Drop JSON column
        ALTER TABLE tourist_locations DROP COLUMN firebase_storage_images;
        
        -- Rename TEXT column back
        ALTER TABLE tourist_locations RENAME COLUMN firebase_storage_images_text TO firebase_storage_images;
        
        RAISE NOTICE 'Converted firebase_storage_images from JSON back to TEXT';
    END IF;

    -- Clean up any temporary columns that might exist
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tourist_locations' 
          AND column_name = 'firebase_storage_images_json'
    ) THEN
        ALTER TABLE tourist_locations DROP COLUMN firebase_storage_images_json;
        RAISE NOTICE 'Dropped temporary firebase_storage_images_json column';
    END IF;
END $$;

-- Verify final state
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'tourist_locations' 
  AND column_name LIKE '%firebase%'
ORDER BY column_name;

COMMIT;

-- Final verification
SELECT 'Rollback completed. firebase_storage_images is now TEXT datatype' as status;