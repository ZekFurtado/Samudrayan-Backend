-- Step-by-step SQL Script to Update Tourist Locations Firebase Storage Images
-- This approach breaks down the process into manageable steps
-- Run each section separately to avoid issues

-- STEP 1: Structure Changes
-- ======================
BEGIN;

-- Add temporary JSON column
ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_json JSON;

COMMIT;

-- Verify structure change
\d tourist_locations

-- STEP 2: Data Updates (Run this separately)
-- ==================
-- Copy and paste these UPDATE statements in smaller batches

BEGIN;

-- First 5 locations
UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105022.png?alt=media&token=d43b0073-4f02-4677-b9d4-f0473a58ea9b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105031.png?alt=media&token=8c532feb-a409-432d-9a5f-1f0df70c2325", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105120.png?alt=media&token=fd201e18-4b4c-4de9-9d27-6b013ce3ac73", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105201.png?alt=media&token=6cc3b989-e30c-4bab-a8c7-3b3f1ff006b7", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105352.png?alt=media&token=44291c9c-b2bc-4c7d-b284-e26d743b532c"]'::JSON 
WHERE place_name = 'Ganpatipule Beach & Ganpati Mandir';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105502.png?alt=media&token=bcbd1294-976b-4fae-ae45-e9ef7ca8d29c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105518.png?alt=media&token=378e5ad2-945b-4ea5-b8c5-a7563cba12da", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105543.png?alt=media&token=779eabf7-9a96-4a4b-a515-3b64520681ed", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105617.png?alt=media&token=65eb9979-0b66-46b8-a344-f5f83d3ef016", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105856.png?alt=media&token=5272ee21-addf-48bc-adab-6868a5bdfbab"]'::JSON 
WHERE place_name = 'Ratnadurg Fort (Bhagwati Fort)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20105731.png?alt=media&token=5bc2b43f-4bf3-45d3-bf1b-6a5f477ddb04", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110100.png?alt=media&token=d6ec672d-3bcc-4638-afb4-c4af9fc6db2d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110116.png?alt=media&token=24b376ce-d160-4de8-a510-9ae70829e30c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110310.png?alt=media&token=8aa492c1-ead4-4057-ae9d-17c4bbf32c23", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110431.png?alt=media&token=9135fb0f-d23f-49be-bdd8-838d170fcf81"]'::JSON 
WHERE place_name = 'Thiba Palace';

-- Check progress
SELECT COUNT(*) as updated_so_far FROM tourist_locations WHERE firebase_storage_images_json IS NOT NULL;

COMMIT;

-- STEP 3: Complete Column Replacement (Run after all updates)
-- ========================================================
BEGIN;

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

-- STEP 4: Verification
-- ===================
SELECT 
    place_name, 
    json_array_length(firebase_storage_images) as image_count
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL
ORDER BY place_name
LIMIT 5;

-- Count total
SELECT COUNT(*) as total_with_images 
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL;