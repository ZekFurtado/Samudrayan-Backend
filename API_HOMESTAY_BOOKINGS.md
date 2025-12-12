# Homestay Bookings API

## GET /api/v1/homestays/{id}/bookings

### Purpose
Show bookings for a specific homestay. This endpoint is designed for homestay owners to manage their bookings and for admins to monitor booking activities.

### Authentication
**Required**: JWT Bearer token

### Authorization
- **Homestay Owner**: Can view bookings for their own homestays
- **Admin Roles**: `admin`, `district-admin`, `taluka-admin` can view all homestay bookings
- **Other Users**: Will receive 403 Forbidden

### Path Parameters
- `id` (UUID, required): The homestay ID

### Query Parameters
- `status` (string, optional): Filter by booking status
  - Values: `pending-payment`, `confirmed`, `checked-in`, `checked-out`, `cancelled`, `refunded`, `no-show`
- `dateFrom` (date, optional): Filter bookings from this date (YYYY-MM-DD)
- `dateTo` (date, optional): Filter bookings until this date (YYYY-MM-DD)
- `page` (integer, optional): Page number for pagination (default: 1)
- `limit` (integer, optional): Number of items per page (default: 20, max: 100)

### Request Example
```bash
GET /api/v1/homestays/550e8400-e29b-41d4-a716-446655440000/bookings
GET /api/v1/homestays/550e8400-e29b-41d4-a716-446655440000/bookings?status=confirmed&page=1&limit=10
GET /api/v1/homestays/550e8400-e29b-41d4-a716-446655440000/bookings?dateFrom=2024-12-01&dateTo=2024-12-31

# Headers
Authorization: Bearer <jwt-token>
```

### Success Response (200 OK)
```json
{
  "success": true,
  "data": {
    "homestayId": "550e8400-e29b-41d4-a716-446655440000",
    "homestayName": "Ganpatipule Beach Homestay",
    "bookings": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "room": {
          "id": "987fcdeb-51a2-43d1-9c20-123456789abc",
          "name": "Deluxe Konkan Room",
          "capacity": 3
        },
        "guest": {
          "userId": "firebase-uid-123",
          "name": "Raj Patil",
          "email": "raj.patil@example.com",
          "phone": "+919876543210"
        },
        "dates": {
          "checkIn": "2024-12-20",
          "checkOut": "2024-12-23",
          "nights": 3
        },
        "guestsCount": 2,
        "totalAmount": 7500.00,
        "paymentMethod": "upi",
        "status": "confirmed",
        "specialRequests": "Early check-in if possible",
        "payment": {
          "amount": 7500.00,
          "status": "success",
          "transactionId": "TXN123456789"
        },
        "createdAt": "2024-11-15T10:30:00Z",
        "updatedAt": "2024-11-15T11:00:00Z"
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
      "status": "confirmed",
      "dateFrom": null,
      "dateTo": null
    },
    "summary": {
      "totalBookings": 25,
      "confirmedBookings": 15,
      "pendingBookings": 8,
      "totalRevenue": 125000.00
    }
  }
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "NO_TOKEN",
    "message": "No token provided"
  }
}
```

#### 403 Forbidden
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "Only homestay owner or admin can view bookings"
  }
}
```

#### 404 Not Found
```json
{
  "success": false,
  "error": {
    "code": "HOMESTAY_NOT_FOUND",
    "message": "Homestay not found"
  }
}
```

#### 500 Server Error
```json
{
  "success": false,
  "error": {
    "code": "DATABASE_ERROR",
    "message": "Unable to fetch bookings"
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Request success indicator |
| data.homestayId | UUID | ID of the homestay |
| data.homestayName | string | Name of the homestay |
| data.bookings | array | Array of booking objects |
| data.bookings[].id | UUID | Booking ID |
| data.bookings[].room | object | Room details |
| data.bookings[].guest | object | Guest information |
| data.bookings[].dates | object | Check-in/check-out dates and duration |
| data.bookings[].guestsCount | integer | Number of guests |
| data.bookings[].totalAmount | number | Total booking amount |
| data.bookings[].status | string | Booking status |
| data.bookings[].payment | object | Payment information |
| data.pagination | object | Pagination metadata |
| data.summary | object | Booking statistics summary |

### Booking Status Values
- `pending-payment`: Booking created, awaiting payment
- `confirmed`: Payment received, booking confirmed
- `checked-in`: Guest has checked in
- `checked-out`: Guest has checked out
- `cancelled`: Booking cancelled by guest or owner
- `refunded`: Booking cancelled and refund processed
- `no-show`: Guest didn't show up

### Use Cases

#### 1. Homestay Owner Dashboard
```javascript
// Get all recent bookings
fetch('/api/v1/homestays/my-homestay-id/bookings?limit=50', {
  headers: { 'Authorization': 'Bearer ' + token }
})
.then(response => response.json())
.then(data => {
  // Display bookings in dashboard
  const bookings = data.data.bookings;
  const summary = data.data.summary;
});
```

#### 2. Filter Confirmed Bookings for Revenue Calculation
```javascript
// Get confirmed bookings for this month
fetch('/api/v1/homestays/my-homestay-id/bookings?status=confirmed&dateFrom=2024-12-01&dateTo=2024-12-31', {
  headers: { 'Authorization': 'Bearer ' + token }
})
.then(response => response.json())
.then(data => {
  const monthlyRevenue = data.data.summary.totalRevenue;
});
```

#### 3. Admin Monitoring
```javascript
// Admin checking all bookings for a homestay
fetch('/api/v1/homestays/homestay-id/bookings?page=1&limit=100', {
  headers: { 'Authorization': 'Bearer ' + adminToken }
})
.then(response => response.json())
.then(data => {
  // Monitor booking patterns, disputes, etc.
});
```

### Database Schema

The endpoint reads from the following tables:

#### Bookings Table
```sql
CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    homestay_id UUID REFERENCES homestays(id),
    room_id UUID REFERENCES homestay_rooms(id),
    guest_user_id TEXT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(20),
    status VARCHAR(30),
    special_requests TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

#### Related Tables
- `homestays`: Homestay details
- `homestay_rooms`: Room details
- `users`: Guest information
- `payment_transactions`: Payment tracking

### Performance Notes

1. **Indexes**: The endpoint uses optimized queries with proper indexes on:
   - `homestay_id`
   - `status`
   - `check_in_date, check_out_date`
   - `created_at`

2. **Pagination**: Always use pagination for large datasets
3. **Filtering**: Use status and date filters to reduce response size
4. **Caching**: Consider caching summary statistics for busy homestays

### Related APIs
- `POST /api/v1/homestays/{id}/bookings` - Create new booking
- `GET /api/v1/bookings/me` - Get user's own bookings
- `PATCH /api/v1/bookings/{id}` - Update booking status
- `GET /api/v1/homestays/{id}` - Get homestay details

### Business Rules

1. **Privacy**: Guest details are only visible to homestay owners and admins
2. **Data Retention**: Booking history is maintained for reporting purposes
3. **Real-time Updates**: Booking status changes are reflected immediately
4. **Revenue Calculation**: Only confirmed and checked-out bookings count toward revenue
5. **Cancellation Handling**: Cancelled bookings don't count in availability calculations

### Security Considerations

1. **Authorization**: Strict access control based on ownership and admin roles
2. **Data Filtering**: Users can only see data they're authorized to access
3. **Input Validation**: All query parameters are validated and sanitized
4. **Rate Limiting**: Consider implementing rate limits for high-frequency access
5. **Audit Trail**: All booking views can be logged for security monitoring