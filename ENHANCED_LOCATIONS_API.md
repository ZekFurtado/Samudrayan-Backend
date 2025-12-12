# Enhanced Locations Master Data API

## Overview

The enhanced locations system provides a comprehensive administrative hierarchy for the Konkan coastal region of Maharashtra, covering all levels from districts down to gram panchayats and villages. This system is specifically designed to support the Samudrayan platform's focus on coastal economic development.

## Database Schema

### Administrative Hierarchy

```
Districts (6)
├── Talukas/Sub-districts
│   ├── Blocks (Development Blocks/Panchayat Samitis)
│   │   └── Gram Panchayats
│   ├── Cities (Urban Areas)
│   └── Villages (Rural Areas)
```

### Tables Structure

#### 1. Districts Table
```sql
districts (
    id UUID PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    state VARCHAR(50) DEFAULT 'Maharashtra',
    district_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP
)
```

#### 2. Talukas Table
```sql
talukas (
    id UUID PRIMARY KEY,
    district_id UUID REFERENCES districts(id),
    name VARCHAR(100),
    taluka_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP,
    UNIQUE(district_id, name)
)
```

#### 3. Blocks Table
```sql
blocks (
    id UUID PRIMARY KEY,
    taluka_id UUID REFERENCES talukas(id),
    name VARCHAR(100),
    block_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP,
    UNIQUE(taluka_id, name)
)
```

#### 4. Cities Table
```sql
cities (
    id UUID PRIMARY KEY,
    district_id UUID REFERENCES districts(id),
    taluka_id UUID REFERENCES talukas(id),
    name VARCHAR(100),
    city_type VARCHAR(20) CHECK (city_type IN (
        'municipal_corporation', 'municipal_council', 
        'nagar_panchayat', 'census_town'
    )),
    population INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP
)
```

#### 5. Villages Table
```sql
villages (
    id UUID PRIMARY KEY,
    taluka_id UUID REFERENCES talukas(id),
    block_id UUID REFERENCES blocks(id),
    name VARCHAR(100),
    village_code VARCHAR(15),
    population INTEGER,
    is_coastal BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP
)
```

#### 6. Gram Panchayats Table
```sql
gram_panchayats (
    id UUID PRIMARY KEY,
    block_id UUID REFERENCES blocks(id),
    name VARCHAR(100),
    gp_code VARCHAR(15),
    headquarters_village VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at, updated_at TIMESTAMP
)
```

## API Endpoints

### 1. GET /api/v1/master/locations

#### Enhanced Response Format
```json
{
  "success": true,
  "data": [
    {
      "district_id": "uuid",
      "district": "Ratnagiri",
      "district_code": "RTG",
      "talukas": [
        {
          "id": "uuid",
          "name": "Dapoli",
          "code": "RTG2"
        }
      ]
    }
  ]
}
```

### 2. GET /api/v1/master/locations/hierarchy

#### Purpose
Get complete administrative hierarchy with cities, villages, and blocks.

#### Query Parameters
- `district` (string, optional): Specific district name
- `include_inactive` (boolean, optional): Include inactive locations

#### Response
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Ratnagiri",
      "code": "RTG",
      "talukas": [
        {
          "id": "uuid",
          "name": "Dapoli",
          "code": "RTG2",
          "cities": [
            {
              "id": "uuid",
              "name": "Dapoli",
              "type": "nagar_panchayat",
              "population": 8298
            }
          ],
          "villages": [
            {
              "id": "uuid",
              "name": "Murud",
              "code": "DPL001",
              "is_coastal": true,
              "population": 3245
            }
          ],
          "blocks": [
            {
              "id": "uuid", 
              "name": "Dapoli",
              "code": "RTGB2"
            }
          ]
        }
      ]
    }
  ]
}
```

### 3. GET /api/v1/master/locations/coastal

#### Purpose
Get all coastal villages, crucial for the fisheries and tourism focus of Samudrayan.

#### Query Parameters
- `district` (string, optional): Filter by district
- `taluka` (string, optional): Filter by taluka

#### Response
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Harnai",
      "village_code": "DPL002",
      "taluka": "Dapoli",
      "district": "Ratnagiri", 
      "population": 4156
    }
  ]
}
```

### 4. GET /api/v1/master/locations/search

#### Purpose
Search across all location types.

#### Query Parameters
- `q` (string, required): Search term
- `type` (string, optional): Location type filter ('district', 'taluka', 'village', etc.)
- `limit` (integer, optional): Max results (default: 50)

#### Response
```json
{
  "success": true,
  "data": [
    {
      "type": "village",
      "id": "uuid",
      "name": "Malvan",
      "display_name": "Malvan, Malvan, Sindhudurg",
      "parent_info": "Malvan, Sindhudurg"
    }
  ]
}
```

## Geographic Coverage

### Districts Included
1. **Ratnagiri** (RTG) - 8 talukas
2. **Sindhudurg** (SND) - 7 talukas  
3. **Thane** (THN) - 13 talukas (coastal areas)
4. **Mumbai City** (MBC) - 1 taluka
5. **Mumbai Suburban** (MBS) - 3 talukas
6. **Raigad** (RGD) - 16 talukas

### Key Coastal Areas

#### Ratnagiri District
- **Coastal Talukas**: Dapoli, Guhagar, Ratnagiri, Mandangad
- **Key Coastal Villages**: Murud, Harnai, Anjarle, Kelshi, Ganpatipule, Velas
- **Major Cities**: Ratnagiri (Municipal Council), Chiplun (Municipal Council)

#### Sindhudurg District  
- **Coastal Talukas**: Malvan, Vengurla, Devgad, Kudal, Kankavli
- **Key Coastal Villages**: Tarkarli, Devbag, Sindhudurg Fort, Vijaydurg
- **Major Cities**: Kudal (Municipal Council), Sawantwadi (Municipal Council)

## Usage Examples

### Frontend Location Selectors
```javascript
// Get all districts for dropdown
const districts = await fetch('/api/v1/master/locations').then(r => r.json());

// Get detailed hierarchy for a specific district
const ratnagirigHierarchy = await fetch(
  '/api/v1/master/locations/hierarchy?district=Ratnagiri'
).then(r => r.json());

// Populate taluka dropdown based on selected district
const talukas = ratnagirigHierarchy.data[0].talukas;
```

### Coastal Village Mapping
```javascript
// Get all coastal villages for tourism map
const coastalVillages = await fetch(
  '/api/v1/master/locations/coastal'
).then(r => r.json());

// Filter by district for regional focus
const ratnagigiCoastal = await fetch(
  '/api/v1/master/locations/coastal?district=Ratnagiri'
).then(r => r.json());
```

### Location Search
```javascript
// Autocomplete search
const searchResults = await fetch(
  '/api/v1/master/locations/search?q=Malvan&limit=10'
).then(r => r.json());

// Type-specific search
const villageResults = await fetch(
  '/api/v1/master/locations/search?q=Murud&type=village'
).then(r => r.json());
```

## Repository Methods

### LocationRepository Class

```javascript
// Get basic district-taluka structure (maintains backward compatibility)
await locationRepository.getAllLocations(includeInactive = false)

// Get complete hierarchy with cities, villages, blocks
await locationRepository.getLocationHierarchy(districtName = null, includeInactive = false)

// Get coastal villages (key for fisheries platform)
await locationRepository.getCoastalVillages(districtName = null)

// Get gram panchayats for a block
await locationRepository.getGramPanchayatsByBlock(blockId)

// Search across all location types
await locationRepository.searchLocations(searchTerm, locationType = null)

// Update active status
await locationRepository.updateLocationStatus(type, id, isActive)
```

## Performance Optimizations

### Indexes
- All foreign key relationships
- Location name fields
- `is_active` status fields  
- `is_coastal` flag for villages
- Composite indexes for common query patterns

### Query Optimizations
- JSON aggregation for nested structures
- Efficient JOIN patterns
- Pagination support
- Search limiting (50 results max)

## Data Quality Features

### Validation
- Unique constraints on location names within parent areas
- Check constraints for city types
- Population data validation
- Coastal flag validation

### Audit Trail
- `created_at` and `updated_at` timestamps
- Soft delete via `is_active` flags
- Change tracking capability

## Integration Points

### Homestay Registration
- District/Taluka validation against master data
- Coastal village identification for tourism focus

### Blue Economy Tracking
- Village-level data collection points
- Coastal area monitoring

### CSR Projects
- Block-level implementation
- Gram Panchayat coordination

### User Registration
- Location-based role assignment
- District/Taluka admin mappings

## Maintenance

### Adding New Locations
```sql
-- Add new district
INSERT INTO districts (name, district_code) VALUES ('New District', 'ND');

-- Add new village
INSERT INTO villages (taluka_id, name, village_code, is_coastal, population)
SELECT t.id, 'New Village', 'NV001', true, 1500
FROM talukas t
INNER JOIN districts d ON t.district_id = d.id
WHERE d.name = 'Target District' AND t.name = 'Target Taluka';
```

### Data Updates
```sql
-- Update village coastal status
UPDATE villages SET is_coastal = true WHERE name IN ('Village1', 'Village2');

-- Deactivate location
UPDATE villages SET is_active = false WHERE id = 'target-uuid';
```

## Future Enhancements

1. **Geographic Coordinates**: Add lat/lng for all locations
2. **Population Tracking**: Historical population data
3. **Economic Indicators**: GDP, fishing output per village
4. **Infrastructure**: Port facilities, market yards
5. **Tourism Assets**: Beaches, forts, temples per location
6. **Connectivity**: Road, rail, port connectivity indicators

This enhanced location system provides a robust foundation for the Samudrayan platform's comprehensive approach to coastal economic development in the Konkan region.