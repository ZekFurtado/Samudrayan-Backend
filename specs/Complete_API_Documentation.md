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

The Tourism module manages two types of tourism content:

1. **Tourist Locations** - Physical places of interest, attractions, and landmarks in the Konkan region
2. **Tourism Experiences** - Activities and experiences that can be offered by homestays to their guests

### Tourist Locations

Tourist locations represent actual physical places that tourists can visit, complete with descriptions, location details, visiting information, and media content.

### GET `/api/v1/tourism/locations`

**Purpose**: List all tourist locations with filtering options

**Authentication**: None required

**Query Parameters**:
- `taluka` - Filter by taluka name (optional)
- `search` - Search term for place name, description, famous_for, and location (optional)

**Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "sr_no": 1,
      "place_name": "Sindhudurg Fort",
      "taluka": "Malvan",
      "location": "Arabian Sea, Malvan Coast",
      "latitude_longitude": "16.0423,73.4010",
      "video_link": "https://youtube.com/watch?v=example",
      "description": "Historic sea fort built by Chhatrapati Shivaji Maharaj in the 17th century",
      "famous_for": "Historical significance, Marine architecture, Scuba diving",
      "best_time_to_visit": "October to March",
      "ideal_duration": "4-5 hours",
      "images_drive_link": "https://drive.google.com/folder/example",
      "firebase_storage_images": "gs://bucket/sindhudurg-fort/",
      "is_active": true,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**Features**:
- Search across place name, description, famous_for, and location fields
- Filter by taluka
- Returns only active locations

---

### GET `/api/v1/tourism/locations/:id`

**Purpose**: Get detailed information about a specific tourist location

**Authentication**: None required

**Path Parameters**:
- `id` - Location UUID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "sr_no": 1,
    "place_name": "Sindhudurg Fort",
    "taluka": "Malvan",
    "location": "Arabian Sea, Malvan Coast",
    "latitude_longitude": "16.0423,73.4010",
    "video_link": "https://youtube.com/watch?v=example",
    "description": "Historic sea fort built by Chhatrapati Shivaji Maharaj in the 17th century. The fort stands on a rocky island just off the coast of Malvan and is accessible by boat. It showcases excellent marine architecture and offers stunning views of the Arabian Sea.",
    "famous_for": "Historical significance, Marine architecture, Scuba diving",
    "best_time_to_visit": "October to March",
    "ideal_duration": "4-5 hours",
    "images_drive_link": "https://drive.google.com/folder/example",
    "firebase_storage_images": "gs://bucket/sindhudurg-fort/",
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Error Responses**:
- `404 LOCATION_NOT_FOUND` - Tourist location not found

---

### POST `/api/v1/tourism/locations`

**Purpose**: Create a new tourist location

**Authentication**: JWT required  
**Authorization**: `admin`

**Request Body**:
```json
{
  "sr_no": "number (optional, serial number)",
  "place_name": "string (required, location name)",
  "taluka": "string (required, taluka name)",
  "location": "string (optional, detailed location description)",
  "latitude_longitude": "string (optional, coordinates in lat,lng format)",
  "video_link": "string (optional, YouTube or video URL)",
  "description": "string (optional, detailed description)",
  "famous_for": "string (optional, what the place is known for)",
  "best_time_to_visit": "string (optional, recommended visiting time)",
  "ideal_duration": "string (optional, suggested visit duration)",
  "images_drive_link": "string (optional, Google Drive folder link)",
  "firebase_storage_images": "string (optional, Firebase Storage path)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "sr_no": 1,
    "place_name": "Sindhudurg Fort",
    "taluka": "Malvan",
    "location": "Arabian Sea, Malvan Coast",
    "latitude_longitude": "16.0423,73.4010",
    "video_link": "https://youtube.com/watch?v=example",
    "description": "Historic sea fort built by Chhatrapati Shivaji Maharaj",
    "famous_for": "Historical significance, Marine architecture",
    "best_time_to_visit": "October to March",
    "ideal_duration": "4-5 hours",
    "images_drive_link": "https://drive.google.com/folder/example",
    "firebase_storage_images": "gs://bucket/sindhudurg-fort/",
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields (place_name, taluka)
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin

**Validation Rules**:
- place_name: Required, non-empty string
- taluka: Required, non-empty string
- All other fields are optional

---

### POST `/api/v1/tourism/locations/:id/update`

**Purpose**: Update an existing tourist location

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - Location UUID (required)

**Request Body**:
```json
{
  "place_name": "string (required, location name)",
  "taluka": "string (required, taluka name)",
  "location": "string (optional, detailed location description)",
  "latitude_longitude": "string (optional, coordinates in lat,lng format)",
  "video_link": "string (optional, YouTube or video URL)",
  "description": "string (optional, detailed description)",
  "famous_for": "string (optional, what the place is known for)",
  "best_time_to_visit": "string (optional, recommended visiting time)",
  "ideal_duration": "string (optional, suggested visit duration)",
  "images_drive_link": "string (optional, Google Drive folder link)",
  "firebase_storage_images": "string (optional, Firebase Storage path)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "place_name": "Updated Location Name",
    "taluka": "Updated Taluka",
    "description": "Updated description",
    "updated_at": "2024-01-15T11:30:00Z"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid input data
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 LOCATION_NOT_FOUND` - Tourist location not found

---

### POST `/api/v1/tourism/locations/:id/delete`

**Purpose**: Delete (soft delete) a tourist location

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - Location UUID (required)

**Request Body**: Empty (no request body needed)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Tourist location deleted successfully",
    "deleted": {
      "id": "uuid",
      "place_name": "Sindhudurg Fort",
      "is_active": false,
      "updated_at": "2024-01-15T12:30:00Z"
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 LOCATION_NOT_FOUND` - Tourist location not found

**Notes**:
- This performs a soft delete by setting `is_active` to `false`
- The location data is preserved in the database but hidden from public endpoints
- This action can be reversed by updating the `is_active` flag

---

### GET `/api/v1/tourism/locations-statistics`

**Purpose**: Get tourist location statistics for admin dashboard

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "totalLocations": 150,
    "totalTalukas": 15,
    "locationsWithVideo": 45,
    "locationsWithImages": 120
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin

**Statistics Included**:
- Total number of active tourist locations
- Number of unique talukas represented
- Number of locations with video content
- Number of locations with image content

---

### Tourism Experiences

Tourism experiences represent activities and services that can be offered by homestays to enhance guest experiences.

### GET `/api/v1/tourism/experiences`

**Purpose**: List all tourism experiences with filtering options

**Authentication**: None required

**Query Parameters**:
- `search` - Search term for title and description (optional)
- `district` - Filter by district name (optional)
- `taluka` - Filter by taluka name (requires district, optional)
- `popular` - Set to any value to get popular experiences (optional)
- `limit` - Limit for popular experiences (default: 10, optional)

**Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "exp_1234567890_abcdefghi",
      "title": "Sunset Dolphin Watching",
      "description": "Experience the magical sunset while watching playful dolphins in their natural habitat",
      "price": 1500,
      "property_count": "3"
    },
    {
      "id": "exp_1234567891_bcdefghij",
      "title": "Traditional Fishing Experience",
      "description": "Learn traditional fishing techniques from local fishermen and catch your own dinner",
      "price": 800,
      "property_count": "5"
    }
  ]
}
```

**Features**:
- Search across title and description fields
- Filter by location (district/taluka)
- Get popular experiences (sorted by property count)
- Configurable limit for popular experiences

---

### GET `/api/v1/tourism/experiences/:id`

**Purpose**: Get detailed information about a specific tourism experience

**Authentication**: None required

**Path Parameters**:
- `id` - Experience ID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "exp_1234567890_abcdefghi",
    "title": "Sunset Dolphin Watching",
    "description": "Experience the magical sunset while watching playful dolphins in their natural habitat. Our experienced boat captains will take you to the best spots for dolphin sightings while ensuring minimal disturbance to marine life.",
    "price": 1500,
    "property_count": "3"
  }
}
```

**Error Responses**:
- `404 EXPERIENCE_NOT_FOUND` - Experience not found

---

### POST `/api/v1/tourism/experiences`

**Purpose**: Create a new tourism experience

**Authentication**: JWT required  
**Authorization**: `admin`

**Request Body**:
```json
{
  "title": "string (required, max 255 chars)",
  "description": "string (required, detailed description)",
  "price": "number (required, non-negative, price per person in INR)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "exp_1234567890_abcdefghi",
    "title": "Sunset Dolphin Watching",
    "description": "Experience the magical sunset while watching playful dolphins in their natural habitat",
    "price": 1500
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields or invalid price
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin

**Validation Rules**:
- Title: Required, non-empty string
- Description: Required, non-empty string
- Price: Required, must be a non-negative number

---

### PUT `/api/v1/tourism/experiences/:id`

**Purpose**: Update an existing tourism experience

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - Experience ID (required)

**Request Body**:
```json
{
  "title": "string (required)",
  "description": "string (required)",
  "price": "number (required, non-negative)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "exp_1234567890_abcdefghi",
    "title": "Updated Experience Title",
    "description": "Updated description with new details",
    "price": 1800
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid input data
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 EXPERIENCE_NOT_FOUND` - Experience not found

---

### DELETE `/api/v1/tourism/experiences/:id`

**Purpose**: Delete a tourism experience and all its property associations

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `id` - Experience ID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Experience deleted successfully",
    "deleted": {
      "id": "exp_1234567890_abcdefghi",
      "title": "Sunset Dolphin Watching",
      "description": "Experience description",
      "price": 1500
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 EXPERIENCE_NOT_FOUND` - Experience not found

**Notes**:
- Deletion is performed within a database transaction
- All property-experience associations are removed before deleting the experience
- This action is irreversible

---

### GET `/api/v1/tourism/statistics`

**Purpose**: Get tourism experience statistics for admin dashboard

**Authentication**: JWT required  
**Authorization**: `admin`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "totalExperiences": 25,
    "averagePrice": 1200.50,
    "priceRange": {
      "min": 300,
      "max": 3000
    },
    "propertiesWithExperiences": 12
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin

**Statistics Included**:
- Total number of experiences
- Average price across all experiences
- Price range (minimum and maximum)
- Number of unique properties offering experiences

---

### POST `/api/v1/tourism/experiences/:experienceId/properties/:propertyId`

**Purpose**: Associate an experience with a homestay property

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `experienceId` - Experience ID (required)
- `propertyId` - Homestay/Property ID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Experience added to property successfully",
    "association": {
      "experience_id": "exp_1234567890_abcdefghi",
      "property_id": "homestay_uuid"
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 EXPERIENCE_NOT_FOUND` - Experience not found
- `409 ASSOCIATION_EXISTS` - Association already exists (handled gracefully)

**Notes**:
- Uses `ON CONFLICT DO NOTHING` to handle duplicate associations gracefully
- Allows homestays to offer multiple experiences
- Allows experiences to be offered by multiple homestays

---

### DELETE `/api/v1/tourism/experiences/:experienceId/properties/:propertyId`

**Purpose**: Remove experience association from a homestay property

**Authentication**: JWT required  
**Authorization**: `admin`

**Path Parameters**:
- `experienceId` - Experience ID (required)
- `propertyId` - Homestay/Property ID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Experience removed from property successfully",
    "removed": {
      "experience_id": "exp_1234567890_abcdefghi",
      "property_id": "homestay_uuid"
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - User is not admin
- `404 ASSOCIATION_NOT_FOUND` - Association not found

---

### Legacy Endpoints (Backward Compatibility)

### GET `/api/v1/tourism/spots`

**Purpose**: List tourist locations (legacy endpoint for backward compatibility)

**Authentication**: None required

**Query Parameters**:
- `taluka` - Filter by taluka name (optional)
- `search` - Search term (optional)

**Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "sr_no": 1,
      "place_name": "Sindhudurg Fort",
      "taluka": "Malvan",
      "location": "Arabian Sea, Malvan Coast",
      "description": "Historic sea fort built by Chhatrapati Shivaji Maharaj",
      "famous_for": "Historical significance, Marine architecture",
      "best_time_to_visit": "October to March",
      "ideal_duration": "4-5 hours",
      "is_active": true
    }
  ]
}
```

**Notes**: This endpoint now redirects to `/locations` functionality and returns tourist locations instead of experiences for better semantic alignment with "tourism spots".

---

### POST `/api/v1/tourism/spots`

**Purpose**: Create tourist location (legacy endpoint)

**Authentication**: JWT required  
**Authorization**: `admin`

**Request Body**: Same as `/locations` endpoint

**Success Response (201)**: Same as `/locations` endpoint

**Notes**: This endpoint now provides the same functionality as `POST /locations` for creating tourist locations rather than experiences.

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

*Last Updated: November 29, 2024*  
*API Version: 1.0*  
*Documentation Version: 1.0*