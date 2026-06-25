#!/usr/bin/env python3
"""
Generate UPDATE statements for tourist locations firebase images
This script creates clean SQL files to avoid escaping issues
"""

import json
import os

def generate_update_sql():
    # Read the JSON file
    json_path = '../specs/tourist_attractions.json'
    
    if not os.path.exists(json_path):
        print(f"Error: {json_path} not found")
        return
    
    with open(json_path, 'r') as f:
        attractions = json.load(f)
    
    # Generate structure change script
    structure_sql = """-- Structure Changes for Tourist Locations Firebase Images
-- Run this first

BEGIN;

ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_json JSON;

COMMIT;

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tourist_locations' 
AND column_name LIKE '%firebase%';
"""
    
    # Generate update statements
    updates_sql = """-- Update Statements for Tourist Locations Firebase Images  
-- Run this after the structure changes

BEGIN;

"""
    
    batch_size = 10
    for i, attraction in enumerate(attractions):
        place_name = attraction['name'].replace("'", "''")  # Escape quotes
        
        # Create a clean JSON array string
        images_array = ', '.join([f'"{url}"' for url in attraction['images']])
        images_json = f'[{images_array}]'
        
        updates_sql += f"""UPDATE tourist_locations 
SET firebase_storage_images_json = '{images_json}'::JSON 
WHERE place_name = '{place_name}';

"""
        
        # Add commit/begin every batch_size updates
        if (i + 1) % batch_size == 0:
            updates_sql += f"""COMMIT;
-- Batch {(i + 1) // batch_size} completed ({i + 1} locations updated)

BEGIN;

"""
    
    updates_sql += """COMMIT;

-- Verify updates
SELECT COUNT(*) as total_updated 
FROM tourist_locations 
WHERE firebase_storage_images_json IS NOT NULL;
"""
    
    # Generate finalization script
    finalize_sql = """-- Finalize Tourist Locations Firebase Images Update
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
"""
    
    # Write the files
    with open('01-structure-changes.sql', 'w') as f:
        f.write(structure_sql)
    
    with open('02-update-data.sql', 'w') as f:
        f.write(updates_sql)
    
    with open('03-finalize-changes.sql', 'w') as f:
        f.write(finalize_sql)
    
    print(f"Generated SQL files for {len(attractions)} tourist locations:")
    print("1. 01-structure-changes.sql - Run first")
    print("2. 02-update-data.sql - Run second") 
    print("3. 03-finalize-changes.sql - Run last")
    print("\nRun them in order:")
    print("psql -d your_database -f 01-structure-changes.sql")
    print("psql -d your_database -f 02-update-data.sql") 
    print("psql -d your_database -f 03-finalize-changes.sql")

if __name__ == "__main__":
    generate_update_sql()