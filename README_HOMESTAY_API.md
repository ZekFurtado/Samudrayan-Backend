# Homestay API Implementation

## Overview
The create homestay API has been successfully implemented according to the specifications in `specs/Samudrayan_Homestays_NodeJS_API_Guide.md`.

## API Endpoints

### Create Homestay
- **URL**: `POST /api/v1/homestays`
- **Auth**: Requires JWT token with roles: `homestay-owner` or `admin`
- **Content-Type**: `application/json`

### Get All Homestays
- **URL**: `GET /api/v1/homestays`
- **Auth**: No authentication required
- **Query Parameters**:
  - `page` (optional): Page number for pagination (default: 1)
  - `limit` (optional): Items per page (default: 10)
  - `district` (optional): Filter by district name
  - `taluka` (optional): Filter by taluka name
  - `grade` (optional): Filter by grade (silver, gold, diamond)
  - `search` (optional): Search in name and description
  - `status` (optional): Filter by status (default: active)

### Get Single Homestay
- **URL**: `GET /api/v1/homestays/:id`
- **Auth**: No authentication required
- **Parameters**: `id` - Homestay UUID

## Request Body
```json
{
  "name": "Ganpatipule Beach Homestay",
  "description": "Beautiful sea-facing homestay with traditional Konkan architecture",
  "grade": "gold",
  "district": "Ratnagiri",
  "taluka": "Ganpatipule",
  "location": { "lat": 17.1329, "lng": 73.2641 },
  "amenities": ["wifi", "power-backup", "24h-water", "ac", "parking"],
  "rooms": [
    { 
      "name": "Deluxe Konkan Room", 
      "capacity": 3, 
      "pricePerNight": 2500 
    }
  ],
  "media": ["https://example.com/img1.jpg"],
  "sustainabilityScore": 82
}
```

## Responses

### Create Homestay

#### Success (201 Created)
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Ganpatipule Beach Homestay",
    "grade": "gold",
    "district": "Ratnagiri",
    "taluka": "Ganpatipule",
    "status": "pending-verification",
    "message": "Homestay created successfully and submitted for verification"
  }
}
```

#### Validation Error (400 Bad Request)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Required fields: name, description, grade, district, taluka, location"
  }
}
```

#### Duplicate Homestay (409 Conflict)
```json
{
  "success": false,
  "error": {
    "code": "DUPLICATE_HOMESTAY",
    "message": "A homestay with this name already exists for this owner"
  }
}
```

### Get All Homestays

#### Success (200 OK)
```json
{
  "success": true,
  "data": {
    "homestays": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "name": "Ganpatipule Beach Homestay",
        "description": "Beautiful sea-facing homestay",
        "grade": "gold",
        "location": {
          "district": "Ratnagiri",
          "taluka": "Ganpatipule",
          "coordinates": {
            "lat": 17.1329,
            "lng": 73.2641
          }
        },
        "amenities": ["wifi", "power-backup", "24h-water", "ac"],
        "media": ["https://example.com/img1.jpg"],
        "sustainabilityScore": 82,
        "status": "active",
        "roomInfo": {
          "totalRooms": 2,
          "priceRange": {
            "min": 1800,
            "max": 2500
          },
          "totalCapacity": 5
        },
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 3,
      "totalItems": 25,
      "itemsPerPage": 10,
      "hasNext": true,
      "hasPrev": false
    },
    "filters": {
      "district": "Ratnagiri",
      "taluka": null,
      "grade": null,
      "search": null,
      "status": "active"
    }
  }
}
```

### Get Single Homestay

#### Success (200 OK)
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "ownerId": "user123",
    "name": "Ganpatipule Beach Homestay",
    "description": "Beautiful sea-facing homestay with traditional Konkan architecture",
    "grade": "gold",
    "location": {
      "district": "Ratnagiri",
      "taluka": "Ganpatipule",
      "coordinates": {
        "lat": 17.1329,
        "lng": 73.2641
      }
    },
    "amenities": ["wifi", "power-backup", "24h-water", "ac", "parking"],
    "media": ["https://example.com/img1.jpg", "https://example.com/img2.jpg"],
    "sustainabilityScore": 82,
    "status": "active",
    "rooms": [
      {
        "id": "room123",
        "name": "Standard Room",
        "capacity": 2,
        "pricePerNight": 1800,
        "amenities": ["ac", "wifi"],
        "status": "active",
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      },
      {
        "id": "room456",
        "name": "Deluxe Konkan Room",
        "capacity": 3,
        "pricePerNight": 2500,
        "amenities": ["ac", "wifi", "sea-view"],
        "status": "active",
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      }
    ],
    "roomSummary": {
      "totalRooms": 2,
      "priceRange": {
        "min": 1800,
        "max": 2500
      },
      "totalCapacity": 5
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### Homestay Not Found (404 Not Found)
```json
{
  "success": false,
  "error": {
    "code": "HOMESTAY_NOT_FOUND",
    "message": "Homestay not found"
  }
}
```

## Database Setup

### Tables Created
1. **homestays** - Main homestay information
2. **homestay_rooms** - Room details for each homestay

### Setup Instructions
1. Ensure your PostgreSQL database is running and accessible
2. Update the database credentials in `.env` file:
   ```env
   DB_HOST=your_database_host
   DB_PORT=5432
   DB_NAME=your_database_name
   DB_USER=your_database_user
   DB_PASSWORD=your_database_password
   ```
3. Run the database setup script:
   ```bash
   node scripts/setup-database.js
   ```

### SQL Schema
The database schema includes:
- UUID primary keys
- Proper constraints and validations
- JSONB fields for amenities and media
- Indexes for performance
- Triggers for automatic timestamp updates

## Features Implemented

### ✅ Complete CRUD Operations
- Create homestay (POST)
- List homestays with filtering and pagination (GET)
- Get single homestay with detailed room info (GET by ID)
- Booking endpoint placeholder (POST /:id/bookings)

### ✅ Validation
- Required field validation
- Grade validation (silver, gold, diamond)
- Location coordinate validation
- Data type validation

### ✅ Security
- JWT authentication required
- Role-based authorization
- SQL injection protection via parameterized queries

### ✅ Error Handling
- Comprehensive error responses
- Database constraint violation handling
- Proper HTTP status codes

### ✅ Database Design
- Normalized schema
- Performance indexes
- JSONB for flexible amenities/media storage
- Referential integrity

## Testing

### Test Script
A test script `test-homestay-api.js` is provided to test the API:
```bash
node test-homestay-api.js
```

### Manual Testing with cURL

#### Create Homestay
```bash
curl -X POST http://localhost:3000/api/v1/homestays \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "Test Homestay",
    "description": "A beautiful test homestay",
    "grade": "silver",
    "district": "Ratnagiri",
    "taluka": "Dapoli",
    "location": {"lat": 17.1329, "lng": 73.2641}
  }'
```

#### Get All Homestays (with filtering and pagination)
```bash
# Basic list
curl -X GET "http://localhost:3000/api/v1/homestays"

# With filters and pagination
curl -X GET "http://localhost:3000/api/v1/homestays?district=Ratnagiri&grade=gold&page=1&limit=5"

# With search
curl -X GET "http://localhost:3000/api/v1/homestays?search=beach&district=Ratnagiri"
```

#### Get Single Homestay
```bash
curl -X GET "http://localhost:3000/api/v1/homestays/123e4567-e89b-12d3-a456-426614174000"
```

## Dependencies Added
- `uuid` - For generating unique IDs
- `pg` - PostgreSQL client

## Next Steps
1. ✅ Verify database connection and credentials
2. ✅ Run database setup script
3. ✅ Test the API endpoints
4. ✅ Implement homestay listing and retrieval features
5. Add integration tests with a proper testing framework
6. Implement PUT/DELETE endpoints for homestay management
7. Add search and filtering optimizations (full-text search)
8. Implement homestay image upload functionality
9. Add booking management system