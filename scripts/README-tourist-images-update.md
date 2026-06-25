# Tourist Locations Firebase Images Update

This directory contains SQL scripts to update the `tourist_locations` table by changing the `firebase_storage_images` column from `TEXT` to `JSON` datatype and populating it with image URLs from the tourist attractions JSON file.

## Files

### 1. `update-tourist-locations-images-complete-fixed.sql` ✅ **RECOMMENDED**
**Complete fixed script with all 133 location updates**
- ✅ Fixes PostgreSQL compatibility issues
- ✅ Proper JSON function usage
- ✅ Compatible index creation
- ✅ Contains all 133 UPDATE statements
- ✅ Comprehensive verification queries

### 2. `update-tourist-locations-images.sql` ⚠️ **HAS ISSUES**
**Original script with PostgreSQL compatibility problems**
- ❌ GIN index issues on JSON datatype
- ❌ Incorrect JSON function calls
- Use the "complete-fixed" version instead

### 3. `rollback-tourist-images-update.sql`
**Rollback script for emergency cleanup**
- Reverts changes if something goes wrong
- Converts JSON back to TEXT
- Cleans up temporary columns and constraints

### 4. `update-tourist-images-efficient.sql` 
**Sample efficient approach using CTE**
- Demonstrates CTE approach (sample data only)
- Use for understanding, not production

## Usage

### Prerequisites
- PostgreSQL database with existing `tourist_locations` table
- Backup your database before running these scripts
- Ensure you have the required permissions to ALTER tables

### Steps

1. **Backup your database first:**
   ```sql
   pg_dump -h your-host -U your-user -d your-database > backup_before_images_update.sql
   ```

2. **Run the complete script:**
   ```bash
   psql -h your-host -U your-user -d your-database -f update-tourist-locations-images.sql
   ```

   Or connect to your database and execute:
   ```sql
   \i update-tourist-locations-images.sql
   ```

### What the Script Does

1. **Adds temporary JSON column**: `firebase_storage_images_json JSON`
2. **Updates all 133 locations** with their firebase storage image arrays
3. **Drops old TEXT column**: `firebase_storage_images`
4. **Renames new column** to original name
5. **Adds JSON validation constraint**
6. **Creates GIN index** for efficient JSON queries
7. **Provides verification queries**

### Post-Update Verification

After running the script, verify the changes:

```sql
-- Check column datatype
\d tourist_locations

-- Count locations with images
SELECT COUNT(*) as total_with_images 
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL;

-- Sample the data
SELECT 
    place_name, 
    JSON_ARRAY_LENGTH(firebase_storage_images) as image_count,
    firebase_storage_images->0 as first_image
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL
LIMIT 5;

-- Test JSON queries
SELECT place_name, image_url
FROM tourist_locations,
     JSON_ARRAY_ELEMENTS_TEXT(firebase_storage_images) as image_url
WHERE place_name = 'Ganpatipule Beach & Ganpati Mandir';
```

### Rollback Instructions

If you need to rollback the changes:

```sql
BEGIN;

-- Add back the TEXT column
ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_text TEXT;

-- Convert JSON back to TEXT (if needed)
UPDATE tourist_locations 
SET firebase_storage_images_text = firebase_storage_images::text
WHERE firebase_storage_images IS NOT NULL;

-- Drop JSON column and constraints
ALTER TABLE tourist_locations DROP CONSTRAINT IF EXISTS firebase_images_valid_json;
DROP INDEX IF EXISTS idx_tourist_locations_firebase_images_gin;
ALTER TABLE tourist_locations DROP COLUMN firebase_storage_images;

-- Rename text column back
ALTER TABLE tourist_locations RENAME COLUMN firebase_storage_images_text TO firebase_storage_images;

COMMIT;
```

## Data Source

The image URLs are sourced from `specs/tourist_attractions.json` which contains 133 tourist locations with their corresponding firebase storage image arrays.

Each location in the JSON has:
- `id`: Unique identifier (a1, a2, etc.)
- `name`: Place name (used to match with database records)
- `images`: Array of firebase storage URLs

## Database Compatibility

- **PostgreSQL 10+**: Full compatibility
- **PostgreSQL 9.x**: Remove the JSON validation constraint
- **Other databases**: Modify JSON datatype and functions accordingly

## Troubleshooting

### Common Issues:

1. **Place name mismatch**: If UPDATE statements don't match records, check for exact name matching between JSON and database

2. **JSON validation errors**: Ensure all image URLs are properly escaped in the JSON arrays

3. **Permission errors**: Ensure your database user has ALTER TABLE privileges

4. **Large transaction**: The script uses a single transaction. For very large datasets, consider breaking it into smaller batches

### Specific Error Solutions:

**Error: "data type json has no default operator class for access method gin"**
- **Solution**: Use the fixed script `update-tourist-locations-images-complete-fixed.sql`
- **Cause**: JSON datatype doesn't support GIN indexes directly in older PostgreSQL versions
- **Fix**: Script now uses BTREE expression index instead

**Error: "function json_array_length(text) does not exist"**  
- **Solution**: Use the fixed script with proper JSON function calls
- **Cause**: Function expects JSON type, not TEXT type
- **Fix**: Script now uses correct `json_array_length(JSON_COLUMN)` syntax

**If you already ran the broken script:**
1. Run `rollback-tourist-images-update.sql` to clean up
2. Then run `update-tourist-locations-images-complete-fixed.sql`

### Getting Help:

Check the verification queries at the end of the script to ensure all data was updated correctly. The script should update exactly 133 locations with their firebase storage images.