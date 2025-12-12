# Locations Master Data API

## GET /api/v1/master/locations

### Purpose
List districts/talukas/villages configured for Samudrayan platform.

### Authentication
No authentication required (public endpoint).

### Query Parameters
- `status` (optional): Filter by status
  - `active` - Only returns active locations (default behavior)
  - `all` - Returns all locations including inactive ones

### Request Example
```bash
GET /api/v1/master/locations
GET /api/v1/master/locations?status=active
```

### Response Format

#### Success Response
```json
{
  "success": true,
  "data": [
    {
      "district": "Ratnagiri",
      "talukas": ["Dapoli", "Guhagar", "Chiplun", "Mandangad", "Ratnagiri", "Lanja", "Sangameshwar", "Ganpatipule"]
    },
    {
      "district": "Sindhudurg",
      "talukas": ["Malvan", "Vengurla", "Sawantwadi", "Kudal", "Kankavli", "Devgad", "Dodamarg"]
    }
  ]
}
```

#### Error Response
```json
{
  "success": false,
  "error": {
    "code": "SERVER_ERROR",
    "message": "Database connection failed"
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Indicates if the request was successful |
| data | array | Array of district objects |
| data[].district | string | Name of the district |
| data[].talukas | array | Array of taluka names in the district |

### HTTP Status Codes
- `200` - Success
- `500` - Server Error (database issues, etc.)

### Edge Cases
1. **No results**: Returns empty array in data field, not an error
2. **Admin requesting inactive locations**: Use `?status=all` to include inactive locations
3. **Database unavailable**: Returns 500 error with appropriate message

### Usage Examples

#### Frontend application loading location dropdowns
```javascript
fetch('/api/v1/master/locations')
  .then(response => response.json())
  .then(data => {
    const districts = data.data.map(item => item.district);
    // Populate district dropdown
  });
```

#### Getting talukas for a specific district
```javascript
fetch('/api/v1/master/locations')
  .then(response => response.json())
  .then(data => {
    const ratnagiriData = data.data.find(item => item.district === 'Ratnagiri');
    const talukas = ratnagiriData ? ratnagiriData.talukas : [];
    // Populate taluka dropdown based on selected district
  });
```

### Database Schema

The endpoint reads from the following tables:

#### Districts Table
```sql
CREATE TABLE districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Talukas Table  
```sql
CREATE TABLE talukas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES districts(id),
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(district_id, name)
);
```

### Implementation Notes

1. **Performance**: The endpoint uses a single SQL query with JOIN and aggregation for optimal performance
2. **Caching**: Consider implementing Redis caching for this frequently-accessed master data
3. **Ordering**: Results are ordered alphabetically by district name, talukas within each district are also ordered alphabetically
4. **Future Extensions**: The schema supports villages table for more granular location data

### Related APIs
- `GET /api/v1/master/categories` - Get homestay grades and other categorization data
- `POST /api/v1/homestays` - Uses district/taluka validation against this master data
- `POST /api/v1/auth/register` - Uses district/taluka for user registration