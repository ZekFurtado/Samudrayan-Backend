# Samudrayan Backend API

Backend APIs for the Samudrayan Platform - A digital ecosystem for Konkan coastal tourism, homestays, and blue economy.

## Quick Start

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

4. Start production server:
   ```bash
   npm start
   ```

## API Documentation

The API follows REST conventions and is versioned at `/api/v1/`.

### Health Check
- `GET /api/v1/health` - Server health status

### Core Modules
- `/api/v1/auth` - Authentication & registration
- `/api/v1/users` - User profile management  
- `/api/v1/homestays` - Homestay listings & bookings
- `/api/v1/marketplace` - Samudrayan Fresh marketplace
- `/api/v1/tourism` - Tourism spots & experiences
- `/api/v1/learning` - E-learning modules & certificates
- `/api/v1/csr` - CSR projects & impact tracking
- `/api/v1/events` - Summit & event management
- `/api/v1/blue-economy` - Environmental data tracking
- `/api/v1/feedback` - Surveys & feedback forms
- `/api/v1/rewards` - Gamification & rewards
- `/api/v1/admin` - Admin & moderation tools

### Authentication

All protected routes require a Bearer token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

## Architecture

This project follows Clean Architecture principles:

- **Domain Layer** (`src/domain/`): Core business entities and rules
- **Use Cases** (`src/use-cases/`): Application business logic  
- **Interface Layer** (`src/interfaces/`): Controllers, routes, middleware
- **Infrastructure** (`src/infrastructure/`): External concerns (DB, storage, etc.)

## Development

```bash
# Run in development mode with auto-reload
npm run dev

# Lint code
npm run lint

# Format code  
npm run format
```

## Environment Variables

See `.env.example` for all required environment variables.

## Contributing

1. Follow the existing code structure and conventions
2. Run linting and formatting before commits
3. Update API documentation for new endpoints
4. Test thoroughly in development environment

# Samudrayan Backend - Complete API Documentation

## Overview

The Samudrayan Backend is a comprehensive platform for managing coastal tourism, homestays, marketplace, and community engagement in the Konkan region. This API provides extensive functionality for multiple user types with robust authentication, verification, and administrative features.

**Base URL**: `https://your-domain.com/api/v1`

## Table of Contents

1. [Authentication & Authorization](#authentication--authorization)
2. [Common Response Format](#common-response-format)
3. [Error Codes Reference](#error-codes-reference)
4. [API Endpoints](#api-endpoints)
   - [Authentication Module](#1-authentication-module)
   - [User Management Module](#2-user-management-module)
   - [Homestay Management Module](#3-homestay-management-module)
   - [Verification Module](#4-verification-module)
   - [Admin Module](#5-admin-module)
   - [Master Data Module](#6-master-data-module)
   - [Marketplace Module](#7-marketplace-module)
   - [Events Module](#8-events-module)
   - [Tourism Module](#9-tourism-module)
   - [Learning Module](#10-learning-module)
   - [CSR Module](#11-csr-module)
   - [Blue Economy Module](#12-blue-economy-module)
   - [Rewards Module](#13-rewards-module)
   - [Feedback Module](#14-feedback-module)
   - [System Endpoints](#15-system-endpoints)

---

## Authentication & Authorization

### Authentication Methods
- **JWT Tokens**: Primary authentication using JWT with refresh token support
- **Bearer Token**: Required in `Authorization: Bearer <token>` header for protected endpoints

### User Types & Roles
| Role | Description | Access Level |
|------|-------------|--------------|
| `admin` | System administrator | Full system access |
| `district-admin` | District-level admin | District-specific admin functions |
| `taluka-admin` | Taluka-level admin | Taluka-specific admin functions |
| `homestay-owner` | Homestay proprietor | Can manage homestays and view bookings |
| `fisherfolk` | Fisher community member | Access to marketplace and training |
| `artisan` | Local artisan | Access to marketplace and training |
| `ngo` | NGO representative | Access to CSR projects and training |
| `investor` | Investment partner | Access to CSR projects and analytics |
| `tourist` | Tourist/visitor | Access to homestays, events, marketplace |
| `trainer` | Training provider | Can create training modules |
| `verified-reporter` | Verified data reporter | Can create blue economy records |

### Rate Limiting
| Endpoint Type | Limit | Window | User-specific |
|---------------|--------|--------|---------------|
| Auth endpoints | 5 requests | 15 minutes | IP-based |
| API endpoints | 100 requests | 15 minutes | IP-based |
| Verification endpoints | 3 attempts | 24 hours | User-based |
| Strict endpoints | 10 requests | 15 minutes | IP-based |

---

## Common Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data here
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {} // Optional additional details
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": {
    "items": [], // Array of items
    "pagination": {
      "currentPage": 1,
      "totalPages": 10,
      "totalItems": 100,
      "itemsPerPage": 10,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

---

## Error Codes Reference

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request / Validation Error
- `401` - Unauthorized / Authentication Required
- `403` - Forbidden / Insufficient Permissions
- `404` - Not Found
- `409` - Conflict / Duplicate Resource
- `429` - Too Many Requests / Rate Limit Exceeded
- `500` - Internal Server Error
- `503` - Service Unavailable

### Application Error Codes
| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `NO_TOKEN` | Authentication token missing |
| `INVALID_TOKEN` | Authentication token invalid or expired |
| `TOKEN_EXPIRED` | Authentication token expired |
| `INSUFFICIENT_PERMISSIONS` | User lacks required permissions |
| `USER_NOT_FOUND` | User account not found |
| `HOMESTAY_NOT_FOUND` | Homestay not found |
| `ROOM_NOT_FOUND` | Room not found |
| `ALREADY_VERIFIED` | Resource already verified |
| `AADHAR_VERIFICATION_REQUIRED` | Aadhar verification needed |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `VERIFICATION_RATE_LIMIT_EXCEEDED` | Verification attempts exceeded |
| `ROOM_NOT_AVAILABLE` | Room booking conflict |
| `DUPLICATE_HOMESTAY` | Homestay already exists |
| `INVALID_STATUS` | Resource in wrong status for operation |
| `SERVICE_UNAVAILABLE` | External service unavailable |

---

## API Endpoints

## 1. Authentication Module

### POST `/api/v1/auth/register`

**Purpose**: Register a new user account

**Authentication**: None required  
**Rate Limit**: 5 requests per 15 minutes

**Request Body**:
```json
{
  "uid": "string (Firebase UID, required)",
  "fullName": "string (2-50 characters, required)",
  "email": "string (valid email, required)",
  "phone": "string (10-digit Indian mobile, required)",
  "userType": "string (enum: admin|district-admin|taluka-admin|homestay-owner|fisherfolk|artisan|ngo|investor|tourist|trainer, required)",
  "district": "string (required)",
  "taluka": "string (required)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "firebaseUid": "string",
      "fullName": "string",
      "email": "string",
      "userType": "string"
    },
    "requiresVerification": true,
    "message": "Registration successful. Please wait for verification."
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid input data
- `409 DUPLICATE_USER` - User with email/phone already exists

---

### POST `/api/v1/auth/login`

**Purpose**: Authenticate user and receive JWT tokens

**Authentication**: None required  
**Rate Limit**: 5 requests per 15 minutes

**Request Body**:
```json
{
  "uid": "string (Firebase UID, required)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "user": {
      "id": "uuid",
      "firebaseUid": "string",
      "fullName": "string",
      "email": "string",
      "userType": "string",
      "district": "string",
      "taluka": "string",
      "isVerified": "boolean"
    }
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing Firebase UID
- `401 UNAUTHORIZED` - Invalid credentials
- `404 USER_NOT_FOUND` - User not found

---

### POST `/api/v1/auth/refresh`

**Purpose**: Refresh access token using refresh token

**Authentication**: None required  
**Rate Limit**: 5 requests per 15 minutes

**Request Body**:
```json
{
  "refreshToken": "string (required)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "string"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing refresh token
- `401 INVALID_TOKEN` - Invalid or expired refresh token

---

## 2. User Management Module

### GET `/api/v1/users/me`

**Purpose**: Get current user profile and dashboard configuration

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "firebaseUid": "string",
    "fullName": "string",
    "email": "string",
    "phone": "string",
    "userType": "string",
    "district": "string",
    "taluka": "string",
    "isVerified": "boolean",
    "status": "string",
    "dashboard": ["array of dashboard module names"]
  }
}
```

**Error Responses**:
- `401 UNAUTHORIZED` - Invalid or missing token
- `404 USER_NOT_FOUND` - User not found

---

### PATCH `/api/v1/users/me`

**Purpose**: Update current user profile

**Authentication**: JWT required

**Request Body**:
```json
{
  "full_name": "string (optional)",
  "phone": "string (optional, 10-digit Indian mobile)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Profile updated successfully",
    "user": {
      "id": "uuid",
      "fullName": "string",
      "phone": "string"
    }
  }
}
```

**Error Responses**:
- `400 NO_VALID_UPDATES` - No valid fields provided to update
- `400 VALIDATION_ERROR` - Invalid field values

---

## 3. Homestay Management Module

### POST `/api/v1/homestays`

**Purpose**: Create a new homestay listing

**Authentication**: JWT required  
**Authorization**: `homestay-owner`, `admin`  
**Prerequisites**: ~~Aadhar verification required for homestay-owners~~ (temporarily disabled)

**Request Body**:
```json
{
  "name": "string (required, max 255 chars)",
  "description": "string (required, max 1000 chars)",
  "grade": "string (enum: silver|gold|diamond, required)",
  "district": "string (required)",
  "taluka": "string (required)",
  "location": {
    "lat": "number (required, -90 to 90)",
    "lng": "number (required, -180 to 180)"
  },
  "amenities": ["array of strings (optional)"],
  "rooms": [
    {
      "name": "string (optional, default: 'Standard Room')",
      "capacity": "number (optional, default: 2, min: 1, max: 10)",
      "pricePerNight": "number (optional, default: 0, min: 0)"
    }
  ],
  "media": ["array of media URLs (optional)"],
  "sustainabilityScore": "number (optional, default: 0, 0-100)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "grade": "string",
    "district": "string",
    "taluka": "string",
    "status": "pending-verification",
    "message": "Homestay created successfully and submitted for verification"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields or invalid data
- ~~`403 AADHAR_VERIFICATION_REQUIRED` - User Aadhar not verified~~ (temporarily disabled)
- `409 DUPLICATE_HOMESTAY` - Homestay name already exists for owner

---

### GET `/api/v1/homestays`

**Purpose**: List homestays with filters and pagination

**Authentication**: None required

**Query Parameters**:
- `district` - Filter by district name (partial match)
- `taluka` - Filter by taluka name (partial match)
- `grade` - Filter by grade (exact match: silver|gold|diamond)
- `search` - Search in name and description
- `page` - Page number (default: 1, min: 1)
- `limit` - Items per page (default: 10, min: 1, max: 50)
- `status` - Filter by status (default: active)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "homestays": [
      {
        "id": "uuid",
        "name": "string",
        "description": "string",
        "grade": "string",
        "location": {
          "district": "string",
          "taluka": "string",
          "coordinates": {
            "lat": "number",
            "lng": "number"
          }
        },
        "amenities": ["array"],
        "media": ["array"],
        "sustainabilityScore": "number",
        "status": "string",
        "roomInfo": {
          "totalRooms": "number",
          "priceRange": {
            "min": "number",
            "max": "number"
          },
          "totalCapacity": "number"
        },
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number",
      "itemsPerPage": "number",
      "hasNext": "boolean",
      "hasPrev": "boolean"
    },
    "filters": {
      "district": "string",
      "taluka": "string",
      "grade": "string",
      "search": "string",
      "status": "string"
    }
  }
}
```

---

### GET `/api/v1/homestays/:id`

**Purpose**: Get detailed homestay information including rooms

**Authentication**: None required

**Path Parameters**:
- `id` - Homestay UUID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "ownerId": "string",
    "name": "string",
    "description": "string",
    "grade": "string",
    "location": {
      "district": "string",
      "taluka": "string",
      "coordinates": {
        "lat": "number",
        "lng": "number"
      }
    },
    "amenities": ["array"],
    "media": ["array"],
    "sustainabilityScore": "number",
    "status": "string",
    "rooms": [
      {
        "id": "uuid",
        "name": "string",
        "capacity": "number",
        "pricePerNight": "number",
        "amenities": ["array"],
        "status": "string",
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "roomSummary": {
      "totalRooms": "number",
      "priceRange": {
        "min": "number",
        "max": "number"
      },
      "totalCapacity": "number"
    },
    "createdAt": "ISO date",
    "updatedAt": "ISO date"
  }
}
```

**Error Responses**:
- `404 HOMESTAY_NOT_FOUND` - Homestay not found

---

### GET `/api/v1/homestays/:id/bookings`

**Purpose**: Get bookings for a specific homestay

**Authentication**: JWT required  
**Authorization**: Homestay owner or admin only

**Path Parameters**:
- `id` - Homestay UUID (required)

**Query Parameters**:
- `status` - Filter by booking status
- `dateFrom` - Filter bookings from date (YYYY-MM-DD)
- `dateTo` - Filter bookings to date (YYYY-MM-DD)
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20, max: 100)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "homestayId": "uuid",
    "homestayName": "string",
    "bookings": [
      {
        "id": "uuid",
        "room": {
          "id": "uuid",
          "name": "string",
          "capacity": "number"
        },
        "guest": {
          "userId": "string",
          "name": "string",
          "email": "string",
          "phone": "string"
        },
        "dates": {
          "checkIn": "ISO date",
          "checkOut": "ISO date",
          "nights": "number"
        },
        "guestsCount": "number",
        "totalAmount": "number",
        "paymentMethod": "string",
        "status": "string",
        "specialRequests": "string",
        "payment": {
          "amount": "number",
          "status": "string",
          "transactionId": "string"
        },
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number",
      "itemsPerPage": "number",
      "hasNext": "boolean",
      "hasPrev": "boolean"
    },
    "filters": {
      "status": "string",
      "dateFrom": "string",
      "dateTo": "string"
    },
    "summary": {
      "totalBookings": "number",
      "confirmedBookings": "number",
      "pendingBookings": "number",
      "totalRevenue": "number"
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - Not homestay owner or admin
- `404 HOMESTAY_NOT_FOUND` - Homestay not found

---

### POST `/api/v1/homestays/:id/bookings`

**Purpose**: Create a booking for a homestay room

**Authentication**: JWT required

**Path Parameters**:
- `id` - Homestay UUID (required)

**Request Body**:
```json
{
  "checkIn": "string (ISO date, required)",
  "checkOut": "string (ISO date, required, must be after checkIn)",
  "guests": "number (required, min: 1, max: room capacity)",
  "roomId": "uuid (required)",
  "paymentMethod": "string (required)",
  "specialRequests": "string (optional, max 500 chars)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "bookingId": "uuid",
    "status": "pending-payment",
    "totalAmount": "number",
    "nights": "number",
    "message": "Booking created successfully. Please complete payment to confirm."
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid dates, guest count, or missing fields
- `404 ROOM_NOT_FOUND` - Room not found in homestay
- `409 ROOM_NOT_AVAILABLE` - Room already booked for specified dates

---

## 4. Verification Module

**⚠️ Temporary Verification Mode**: Currently operating in temporary verification mode where homestay owners can submit Aadhar details for manual admin approval instead of automated UIDAI/Digilocker verification. This bypasses external verification services and allows immediate homestay creation after admin review.

**Temporary Flow**:
1. Homestay owners submit Aadhar via `/api/v1/verification/aadhar/submit`
2. Status becomes 'pending' for admin review
3. Admins approve/reject via admin endpoints
4. Approved users can create homestays immediately

**Original Flow** (temporarily disabled):
1. Homestay owners verify Aadhar via `/api/v1/verification/aadhar/verify` 
2. System validates with UIDAI/Digilocker APIs
3. Only verified users can create homestays

### POST `/api/v1/verification/aadhar/verify`

**Purpose**: Start Aadhar verification process

**Authentication**: JWT required  
**Authorization**: `homestay-owner`  
**Rate Limit**: 3 attempts per 24 hours  
**Content Type**: `multipart/form-data`

**Request Body**:
```json
{
  "aadharNumber": "string (12 digits, required)",
  "document": "file (image/pdf, optional, max 10MB)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verificationStatus": "verified",
    "method": "string (uidai|digilocker)",
    "referenceId": "string",
    "message": "Aadhar verified successfully through UIDAI",
    "verifiedAt": "ISO date"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid Aadhar number format or checksum
- `409 ALREADY_VERIFIED` - Aadhar already verified for user
- `429 VERIFICATION_RATE_LIMIT_EXCEEDED` - Maximum attempts exceeded for today
- `503 SERVICE_UNAVAILABLE` - Verification service temporarily unavailable

**Edge Cases**:
- Invalid Aadhar checksum using Verhoeff algorithm
- Document processing failure (QR code extraction)
- Both UIDAI and DigiLocker API failures

---

### GET `/api/v1/verification/aadhar/status`

**Purpose**: Get current Aadhar verification status

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verificationStatus": "string (pending|in_progress|verified|failed|rejected)",
    "verificationMethod": "string",
    "verifiedAt": "ISO date",
    "attempts": "number",
    "lastAttempt": "ISO date",
    "failureReason": "string",
    "referenceId": "string"
  }
}
```

---

### GET `/api/v1/verification/aadhar/history`

**Purpose**: Get verification attempt history

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verificationHistory": [
      {
        "method": "string",
        "status": "string",
        "errorMessage": "string",
        "attemptedAt": "ISO date"
      }
    ],
    "totalAttempts": "number"
  }
}
```

---

### POST `/api/v1/verification/aadhar/retry`

**Purpose**: Retry failed Aadhar verification

**Authentication**: JWT required  
**Authorization**: `homestay-owner`  
**Rate Limit**: 3 attempts per 24 hours  
**Content Type**: `multipart/form-data`

**Request Body**: Same as `/verify` endpoint

**Success Response**: Same as `/verify` with additional field:
```json
{
  "success": true,
  "data": {
    // ... same as verify response
    "retryAttempt": true
  }
}
```

**Error Responses**: Same as `/verify` plus:
- `409 VERIFICATION_IN_PROGRESS` - Verification already in progress
- `429 RETRY_LIMIT_EXCEEDED` - Maximum retries exceeded

---

### POST `/api/v1/verification/aadhar/upload-document`

**Purpose**: Upload Aadhar document separately

**Authentication**: JWT required  
**Authorization**: `homestay-owner`  
**Rate Limit**: 10 requests per 15 minutes  
**Content Type**: `multipart/form-data`

**Request Body**:
```json
{
  "document": "file (image/pdf, required, max 10MB)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "documentUrl": "string",
    "message": "Document uploaded successfully. You can now proceed with verification."
  }
}
```

**Error Responses**:
- `400 NO_DOCUMENT` - No document file provided
- `400 VALIDATION_ERROR` - Invalid file type or size

---

### POST `/api/v1/verification/aadhar/submit`

**Purpose**: Submit Aadhar details for temporary admin verification (bypassing UIDAI/Digilocker)

**Authentication**: JWT required  
**Authorization**: `homestay-owner`, `admin`  
**Rate Limit**: 3 attempts per 24 hours  
**Content Type**: `multipart/form-data`

**Request Body**:
```json
{
  "aadharNumber": "string (12 digits, required)",
  "document": "file (image/pdf, required, max 10MB)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verificationStatus": "pending",
    "message": "Aadhar details submitted successfully. Your verification is pending admin review.",
    "submittedAt": "ISO date",
    "referenceId": "string"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid Aadhar number format or missing document
- `400 NO_DOCUMENT` - No document file provided
- `404 USER_NOT_FOUND` - User not found
- `409 ALREADY_VERIFIED` - Aadhar already verified

**Notes**:
- This is a temporary endpoint that bypasses automated verification
- Documents are stored securely and reviewed manually by admins
- Sets verification status to 'pending' for admin review
- Replaces automated UIDAI/Digilocker verification temporarily
- **Database Update Required**: Run `/scripts/update-verification-logs.sql` to support new verification type

---

### POST `/api/v1/verification/aadhar/check`

**Purpose**: Validate Aadhar number format without storing

**Authentication**: JWT required

**Request Body**:
```json
{
  "aadharNumber": "string (12 digits, required)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "isValidFormat": "boolean",
    "isValidChecksum": "boolean",
    "message": "string"
  }
}
```

---

## 5. Admin Module

### GET `/api/v1/admin/verifications/pending`

**Purpose**: Get pending homestay verifications with filtering and pagination

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Query Parameters**:
- `district` - Filter by district (admin only, auto-applied for district-admin)
- `taluka` - Filter by taluka
- `grade` - Filter by homestay grade
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10, max: 50)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verifications": [
      {
        "id": "uuid",
        "name": "string",
        "description": "string",
        "grade": "string",
        "location": {
          "district": "string",
          "taluka": "string",
          "coordinates": {
            "lat": "number",
            "lng": "number"
          }
        },
        "owner": {
          "id": "string",
          "name": "string",
          "email": "string",
          "phone": "string"
        },
        "amenities": ["array"],
        "media": ["array"],
        "sustainabilityScore": "number",
        "totalRooms": "number",
        "status": "pending-verification",
        "submittedAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number",
      "itemsPerPage": "number",
      "hasNext": "boolean",
      "hasPrev": "boolean"
    },
    "filters": {
      "district": "string",
      "taluka": "string",
      "grade": "string",
      "userType": "string"
    }
  }
}
```

---

### GET `/api/v1/admin/verifications/:id`

**Purpose**: Get detailed homestay information for verification review

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `id` - Homestay UUID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "grade": "string",
    "location": {
      "district": "string",
      "taluka": "string",
      "coordinates": {
        "lat": "number",
        "lng": "number"
      }
    },
    "owner": {
      "id": "string",
      "name": "string",
      "email": "string",
      "phone": "string",
      "type": "string",
      "registeredAt": "ISO date"
    },
    "amenities": ["array"],
    "media": ["array"],
    "sustainabilityScore": "number",
    "status": "string",
    "rooms": [
      {
        "id": "uuid",
        "name": "string",
        "capacity": "number",
        "pricePerNight": "number",
        "amenities": ["array"],
        "status": "string",
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "roomSummary": {
      "totalRooms": "number",
      "priceRange": {
        "min": "number",
        "max": "number"
      },
      "totalCapacity": "number"
    },
    "verificationHistory": [
      {
        "action": "string",
        "reason": "string",
        "comments": "string",
        "adminName": "string",
        "adminUserId": "string",
        "createdAt": "ISO date"
      }
    ],
    "submittedAt": "ISO date",
    "updatedAt": "ISO date"
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - District admin outside jurisdiction
- `404 HOMESTAY_NOT_FOUND` - Homestay not found

---

### POST `/api/v1/admin/verifications/:id/approve`

**Purpose**: Approve a pending homestay verification

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `id` - Homestay UUID (required)

**Request Body**:
```json
{
  "comments": "string (optional, max 500 chars)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "status": "active",
    "location": {
      "district": "string",
      "taluka": "string"
    },
    "approvedBy": {
      "userId": "string",
      "userType": "string"
    },
    "approvedAt": "ISO date",
    "comments": "string",
    "message": "Homestay verification approved successfully. Homestay is now active and available for bookings."
  }
}
```

**Error Responses**:
- `400 INVALID_STATUS` - Homestay not in pending verification status
- `403 INSUFFICIENT_PERMISSIONS` - District admin outside jurisdiction
- `404 HOMESTAY_NOT_FOUND` - Homestay not found

---

### POST `/api/v1/admin/verifications/:id/reject`

**Purpose**: Reject a pending homestay verification

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `id` - Homestay UUID (required)

**Request Body**:
```json
{
  "reason": "string (required, max 500 chars)",
  "comments": "string (optional, max 500 chars)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "status": "inactive",
    "location": {
      "district": "string",
      "taluka": "string"
    },
    "rejectedBy": {
      "userId": "string",
      "userType": "string"
    },
    "rejectedAt": "ISO date",
    "reason": "string",
    "comments": "string",
    "message": "Homestay verification rejected. Owner can resubmit after addressing the issues."
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing rejection reason
- `400 INVALID_STATUS` - Homestay not in pending verification status
- `403 INSUFFICIENT_PERMISSIONS` - District admin outside jurisdiction
- `404 HOMESTAY_NOT_FOUND` - Homestay not found

---

### GET `/api/v1/admin/verifications/aadhar/pending`

**Purpose**: Get pending Aadhar verifications for manual review

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Query Parameters**:
- `district` - Filter by district (auto-applied for district-admin)
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20, max: 100)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "verifications": [
      {
        "id": "number",
        "firebaseUid": "string",
        "name": "string",
        "email": "string",
        "phone": "string",
        "location": {
          "district": "string",
          "taluka": "string"
        },
        "verificationStatus": "pending",
        "attempts": "number",
        "failureReason": "string",
        "lastAttempt": "ISO date",
        "documentUrl": "string",
        "registeredAt": "ISO date"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number",
      "itemsPerPage": "number",
      "hasNext": "boolean",
      "hasPrev": "boolean"
    },
    "filters": {
      "district": "string",
      "userType": "string"
    }
  }
}
```

---

### GET `/api/v1/admin/verifications/aadhar/:userId`

**Purpose**: Get detailed Aadhar verification information for a specific user

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `userId` - User ID or Firebase UID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "number",
    "firebaseUid": "string",
    "name": "string",
    "email": "string",
    "phone": "string",
    "userType": "string",
    "location": {
      "district": "string",
      "taluka": "string"
    },
    "aadharVerification": {
      "status": "string",
      "method": "string",
      "referenceId": "string",
      "attempts": "number",
      "failureReason": "string",
      "verifiedAt": "ISO date",
      "lastAttempt": "ISO date",
      "documentUrl": "string"
    },
    "verificationHistory": [
      {
        "method": "string",
        "status": "string",
        "errorMessage": "string",
        "createdAt": "ISO date"
      }
    ],
    "accountStatus": "string",
    "registeredAt": "ISO date",
    "updatedAt": "ISO date"
  }
}
```

**Error Responses**:
- `404 USER_NOT_FOUND` - User not found

---

### POST `/api/v1/admin/verifications/aadhar/:userId/approve`

**Purpose**: Manually approve Aadhar verification (includes temporary submissions)

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `userId` - User ID or Firebase UID (required)

**Request Body**:
```json
{
  "comments": "string (optional, max 500 chars)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "userId": "number",
    "name": "string",
    "email": "string",
    "verificationStatus": "verified",
    "approvedBy": {
      "userId": "string",
      "userType": "string"
    },
    "referenceId": "string",
    "comments": "string",
    "message": "Aadhar verification manually approved successfully"
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - District admin outside jurisdiction  
- `404 USER_NOT_FOUND` - User not found
- `409 ALREADY_VERIFIED` - Aadhar already verified

---

### POST `/api/v1/admin/verifications/aadhar/:userId/reject`

**Purpose**: Manually reject Aadhar verification (includes temporary submissions)

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Path Parameters**:
- `userId` - User ID or Firebase UID (required)

**Request Body**:
```json
{
  "reason": "string (required, max 500 chars)",
  "comments": "string (optional, max 500 chars)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "userId": "number",
    "name": "string",
    "email": "string",
    "verificationStatus": "rejected",
    "rejectedBy": {
      "userId": "string",
      "userType": "string"
    },
    "reason": "string",
    "comments": "string",
    "message": "Aadhar verification manually rejected"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing rejection reason
- `403 INSUFFICIENT_PERMISSIONS` - District admin outside jurisdiction
- `404 USER_NOT_FOUND` - User not found
- `409 ALREADY_VERIFIED` - Cannot reject verified Aadhar

---

### GET `/api/v1/admin/verifications/aadhar/statistics`

**Purpose**: Get Aadhar verification statistics and trends for admin dashboard

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin`

**Query Parameters**:
- `district` - Filter by district (admin only, auto-applied for district-admin)
- `period` - Time period in days for trends (default: 30, max: 365)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "overview": {
      "totalUsers": "number",
      "verified": "number",
      "pending": "number",
      "failed": "number",
      "rejected": "number",
      "inProgress": "number",
      "verificationRate": "string (percentage)",
      "avgAttemptsPerUser": "string"
    },
    "trends": [
      {
        "date": "ISO date",
        "successful": "number",
        "failed": "number"
      }
    ],
    "filters": {
      "district": "string",
      "period": "string",
      "userType": "string"
    }
  }
}
```

---

### PATCH `/api/v1/admin/users/:id/roles`

**Purpose**: Update user roles and permissions

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - User ID (required)

**Request Body**: *(Implementation pending)*

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "User roles updated successfully"
  }
}
```

---

## 6. Master Data Module

### GET `/api/v1/master/locations`

**Purpose**: Get all available locations (districts and talukas) for the system

**Authentication**: None required

**Query Parameters**:
- `status` - Filter by location status (default: "active")

**Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "district": "Sindhudurg",
      "talukas": [
        "Malvan",
        "Devgad",
        "Kudal",
        "Sawantwadi",
        "Dodamarg",
        "Vengurla"
      ]
    },
    {
      "district": "Ratnagiri",
      "talukas": [
        "Ratnagiri",
        "Chiplun",
        "Guhagar",
        "Mandangad",
        "Khed",
        "Dapoli",
        "Rajapur",
        "Sangameshwar",
        "Lanja"
      ]
    }
  ]
}
```

---

### GET `/api/v1/master/categories`

**Purpose**: Get category data for various system modules

**Authentication**: None required

**Query Parameters**:
- `type` - Filter by category type
- `status` - Filter by category status (default: "active")

**Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Sustainable Tourism",
      "subcategories": [
        "Eco-friendly Practices",
        "Local Community Engagement",
        "Marine Conservation"
      ],
      "benefits": [
        "Environmental Protection",
        "Community Development",
        "Economic Growth"
      ],
      "isActive": true
    }
  ]
}
```

---

## 7. Marketplace Module

**Note**: These endpoints are currently implemented as placeholders returning mock data.

### POST `/api/v1/marketplace/products`

**Purpose**: Create a new marketplace product listing

**Authentication**: JWT required  
**Authorization**: `artisan`, `fisherfolk`, `homestay-owner`, `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Product created successfully"
  }
}
```

---

### GET `/api/v1/marketplace/products`

**Purpose**: List marketplace products with filtering

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

### POST `/api/v1/marketplace/cart`

**Purpose**: Add product to shopping cart

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Added to cart"
  }
}
```

---

### POST `/api/v1/marketplace/orders`

**Purpose**: Create a marketplace order

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "orderId": "sample-order-id",
    "status": "pending-payment"
  }
}
```

---

## 8. Events Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/events`

**Purpose**: Create a new event

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Event created successfully"
  }
}
```

---

### GET `/api/v1/events`

**Purpose**: List events

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

### POST `/api/v1/events/:id/register`

**Purpose**: Register for an event

**Authentication**: JWT required

**Path Parameters**:
- `id` - Event ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "registrationId": "sample-registration-id"
  }
}
```

---

## 9. Tourism Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/tourism/spots`

**Purpose**: Create tourism spot

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Tourism spot created successfully"
  }
}
```

---

### GET `/api/v1/tourism/spots`

**Purpose**: List tourism spots

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

## 10. Learning Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/learning/modules`

**Purpose**: Create learning module

**Authentication**: JWT required  
**Authorization**: `admin`, `trainer`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Learning module created successfully"
  }
}
```

---

### POST `/api/v1/learning/modules/:id/attempt`

**Purpose**: Start learning module attempt

**Authentication**: JWT required

**Path Parameters**:
- `id` - Module ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "attemptId": "sample-attempt-id"
  }
}
```

---

### POST `/api/v1/learning/modules/:id/submit`

**Purpose**: Submit learning module completion

**Authentication**: JWT required

**Path Parameters**:
- `id` - Module ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "score": 85,
    "passed": true,
    "certificateUrl": "sample-cert-url"
  }
}
```

---

## 11. CSR Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/csr/projects`

**Purpose**: Create CSR project

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "CSR project created successfully"
  }
}
```

---

### GET `/api/v1/csr/projects`

**Purpose**: List CSR projects

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

### POST `/api/v1/csr/projects/:id/contributions`

**Purpose**: Record CSR contribution

**Authentication**: JWT required

**Path Parameters**:
- `id` - Project ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Contribution recorded successfully"
  }
}
```

---

### GET `/api/v1/csr/projects/:id/impact`

**Purpose**: Get CSR project impact metrics

**Authentication**: None required

**Path Parameters**:
- `id` - Project ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "beneficiaries": 500,
    "contributions": 1000000
  }
}
```

---

## 12. Blue Economy Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/blue-economy/records`

**Purpose**: Create blue economy record

**Authentication**: JWT required  
**Authorization**: `admin`, `verified-reporter`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Blue economy record created successfully"
  }
}
```

---

### GET `/api/v1/blue-economy/records`

**Purpose**: List blue economy records

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

## 13. Rewards Module

**Note**: These endpoints are currently implemented as placeholders.

### GET `/api/v1/rewards/me`

**Purpose**: Get user reward status

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "points": 250,
    "badges": ["Eco Ambassador"],
    "level": "Bronze"
  }
}
```

---

### POST `/api/v1/rewards/redeem`

**Purpose**: Redeem reward

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Reward redeemed successfully"
  }
}
```

---

### GET `/api/v1/rewards/leaderboard`

**Purpose**: Get rewards leaderboard

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": []
}
```

---

## 14. Feedback Module

**Note**: These endpoints are currently implemented as placeholders.

### POST `/api/v1/feedback/forms`

**Purpose**: Create feedback form

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Feedback form created successfully"
  }
}
```

---

### POST `/api/v1/feedback/forms/:id/responses`

**Purpose**: Submit feedback response

**Authentication**: JWT required

**Path Parameters**:
- `id` - Form ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Response submitted successfully"
  }
}
```

---

### GET `/api/v1/feedback/forms/:id/analytics`

**Purpose**: Get feedback analytics

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - Form ID

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "totalResponses": 150,
    "averageRating": 4.2
  }
}
```

---

## 15. System Endpoints

### GET `/api/v1/health`

**Purpose**: Health check endpoint for monitoring

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "status": "OK",
    "timestamp": "2024-01-15T10:30:00Z",
    "uptime": 86400,
    "environment": "development"
  }
}
```

---

### GET `/api/v1/config`

**Purpose**: Get system configuration and constants

**Authentication**: None required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "languages": ["en", "mr"],
    "features": {
      "offlineMode": true,
      "gamification": true,
      "csrIntegration": true
    },
    "constants": {
      "maxFileSize": 10485760,
      "supportedImageFormats": ["jpg", "jpeg", "png", "webp"],
      "supportedDocFormats": ["pdf", "doc", "docx"]
    }
  }
}
```

---

## Security & Validation Features

### Input Validation
- **Express Validator**: Comprehensive request body validation
- **File Upload Validation**: Type, size (10MB max), and content validation
- **Aadhar Number Validation**: 
  - Format validation (12 digits)
  - Verhoeff algorithm checksum validation
- **Phone Number Validation**: Indian mobile number format (10 digits)
- **Email Validation**: RFC-compliant email format validation
- **Location Validation**: Coordinate boundary validation

### Rate Limiting Implementation
- **IP-based Limiting**: Anonymous endpoints protected by IP
- **User-based Limiting**: Authenticated endpoints with user-specific limits
- **IPv6 Compatible**: Proper IP key generation for all address types
- **Tiered Limits**: Different limits based on endpoint sensitivity
- **Admin Bypass**: Administrative users exempt from rate limits on verification

### Authentication Security
- **JWT Implementation**: 
  - Short-lived access tokens (24 hours default)
  - Long-lived refresh tokens (7 days default)
  - Secure token signing and verification
- **Firebase Integration**: Alternative authentication via Firebase Auth
- **Bearer Token Standard**: Standard `Authorization: Bearer <token>` header
- **Role-based Authorization**: Granular permission system with role hierarchy

### Data Privacy & Security
- **Sensitive Data Protection**: Aadhar numbers encrypted at rest using AES encryption
- **Document Upload Security**: 
  - File type whitelisting
  - Size restrictions (10MB maximum)
  - Virus scanning capabilities
- **Audit Trail**: Complete logging of verification attempts and administrative actions
- **District Data Isolation**: District admins restricted to their geographical jurisdiction
- **HTTPS Enforcement**: All endpoints require secure connections in production

### Error Handling & Logging
- **Structured Error Responses**: Consistent error format across all endpoints
- **Error Categorization**: Application-specific error codes for client handling
- **Security Logging**: Failed authentication attempts and suspicious activities logged
- **Request Tracing**: Unique request IDs for debugging and monitoring

---

## Edge Cases & Important Notes

### Common Edge Cases
1. **Concurrent Bookings**: Room availability checked with database locks to prevent double-booking
2. **Verification Status Changes**: Race conditions handled in verification status updates
3. **File Upload Failures**: Graceful handling of upload interruptions and corrupted files
4. **Token Expiry**: Automatic token refresh handling recommendations
5. **Rate Limit Edge Cases**: Handling of distributed rate limiting across multiple server instances

### Performance Considerations
- **Pagination**: All list endpoints support pagination with configurable limits
- **Database Indexing**: Optimized indexes on frequently queried fields
- **Response Caching**: Cacheable responses for master data endpoints
- **File Storage**: Uploaded files stored in optimized cloud storage with CDN

### Monitoring & Analytics
- **Health Check**: `/api/v1/health` endpoint for uptime monitoring
- **Error Tracking**: Structured error logging for production monitoring
- **Performance Metrics**: Response time tracking and alerting
- **User Analytics**: Anonymized usage statistics for system optimization

---

## Contact & Support

For API questions, issues, or integration support:
- GitHub Repository: [samudrayan_backend](https://github.com/your-repo)
- Documentation Updates: Submit pull requests for documentation improvements
- Bug Reports: Use GitHub Issues for bug reporting and feature requests

---

*Last Updated: December 12, 2024*  
*API Version: 1.0*  
*Documentation Version: 1.0*