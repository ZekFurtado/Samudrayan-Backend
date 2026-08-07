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
   - [Restaurant Management Module](#4-restaurant-management-module)
   - [Verification Module](#5-verification-module)
   - [Admin Module](#6-admin-module)
   - [Master Data Module](#7-master-data-module)
   - [Marketplace Module](#8-marketplace-module)
   - [Events Module](#9-events-module)
   - [Tourism Module](#10-tourism-module)
   - [Learning Module](#11-learning-module)
   - [CSR Module](#12-csr-module)
   - [Blue Economy Module](#13-blue-economy-module)
   - [Rewards Module](#14-rewards-module)
   - [Feedback Module](#15-feedback-module)
   - [System Endpoints](#16-system-endpoints)
   - [Dashboard Module](#17-dashboard-module)
   - [Notifications Module](#18-notifications-module)
   - [Partner Categories Module](#19-partner-categories-module)

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
| `restaurant-owner` | Restaurant proprietor | Can manage restaurants, menus, and view reservations |

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
| `RESTAURANT_NOT_FOUND` | Restaurant not found |
| `DUPLICATE_RESTAURANT` | Restaurant already exists |
| `MENU_ITEM_NOT_FOUND` | Menu item not found |
| `RESERVATION_NOT_FOUND` | Reservation not found |
| `CAPACITY_EXCEEDED` | Party size exceeds restaurant capacity |
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
      "userType": "string",
      "partnerId": "string, e.g. 'SAM-2026-STY-0007'"
    },
    "requiresVerification": true,
    "message": "Registration successful. Please wait for verification."
  }
}
```

**Notes**:
- Every registrant is assigned a `partnerId` in the format `SAM-{year}-{categoryCode}-{sequence}` (sequence is atomically incremented per year+category via the `partner_id_sequences` table). `categoryCode` is `STY`/`FOD`/`ACT`/`EVT`/`RID`/`PRO` for the 6 partner categories, or `GEN` for roles with no category mapping.
- `homestay-owner` and `restaurant-owner` registrants are additionally granted their primary category (`stays`/`food` respectively) as `active` immediately in `partner_categories` — see the Partner Categories Module. This is *not* gated behind admin approval (unlike applying for an *additional* category later), since these roles already face the existing Aadhar-verification gate before they can list.

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
    "village": "string | null",
    "state": "string | null",
    "isVerified": "boolean",
    "status": "string",
    "aadharVerificationStatus": "string",
    "dashboard": ["array of dashboard module names"],
    "partnerId": "string | null, e.g. 'SAM-2026-STY-0007' — human-readable partner identifier, auto-generated at registration",
    "organizationName": "string | null",
    "aboutBusiness": "string | null — free-text business description",
    "address": "string | null — detailed street-level address (distinct from district/taluka/village)",
    "profilePic": "string (URL) | null",
    "coverPhotoUrl": "string (URL) | null",
    "bankName": "string | null",
    "bankAccountNumber": "string | null",
    "bankIfscCode": "string | null",
    "bankUpiId": "string | null",
    "categories": [
      { "categoryId": "stays|food|activities|events|rides|professional-services", "label": "string", "status": "active|pending|rejected" }
    ],
    "profileCompletionPercent": "number (0-100)"
  }
}
```

**Notes**:
- `partnerId` and a `categories` entry for the partner's primary category (`stays` for `homestay-owner`, `food` for `restaurant-owner`) are assigned automatically at registration (see Authentication Module) — other roles get no automatic category.
- `profileCompletionPercent` is computed server-side from an even-weighted set of ~10 signals (contact info, business-profile fields, bank-settlement presence, verification status) — see `packages/shared/src/services/profileCompletion.js`.
- Bank fields are returned in full to the authenticated owner on this endpoint; no public/unauthenticated partner-profile endpoint exists today, but if one is added later, only `bankUpiId` should ever be exposed on it — never `bankAccountNumber`.

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
  "phone": "string (optional, 10-digit Indian mobile)",
  "organizationName": "string (optional)",
  "profilePic": "string, URL (optional)",
  "coverPhotoUrl": "string, URL (optional)",
  "aboutBusiness": "string (optional)",
  "address": "string (optional)"
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
      "phone": "string",
      "organizationName": "string | null",
      "profilePic": "string | null",
      "coverPhotoUrl": "string | null",
      "aboutBusiness": "string | null",
      "address": "string | null"
    }
  }
}
```

**Error Responses**:
- `400 NO_VALID_UPDATES` - No valid fields provided to update
- `400 VALIDATION_ERROR` - Invalid field values

---

### PATCH `/api/v1/users/me/bank-settlement`

**Purpose**: Set/update the bank account and UPI details shared with tourists for direct bank transfers (Samudrayan does not process payments on-platform).

**Authentication**: JWT required

**Request Body** (all fields required):
```json
{ "bankName": "string", "accountNumber": "string", "ifscCode": "string", "upiId": "string" }
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Bank settlement details updated successfully",
    "bankName": "string",
    "bankAccountNumber": "string",
    "bankIfscCode": "string",
    "bankUpiId": "string"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - One or more of bankName/accountNumber/ifscCode/upiId missing

---

### POST `/api/v1/users/me/device-tokens`

**Purpose**: Register an FCM device token so in-app notifications (see Notifications Module) are also delivered as push notifications.

**Authentication**: JWT required

**Request Body**:
```json
{ "token": "string", "platform": "android|ios|web (optional)" }
```

**Success Response (200)**:
```json
{ "success": true, "data": { "message": "Device token registered" } }
```

Upserts on `(user, token)` conflict — safe to call again with the same token (e.g. on every app launch).

**Error Responses**:
- `400 VALIDATION_ERROR` - token missing, or platform not one of android|ios|web

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
        "rating": "number (0-5)",
        "totalReviews": "number",
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

### GET `/api/v1/homestays/my`

**Purpose**: Get every homestay the authenticated owner has, regardless of status (fixes the "My Homestays" scoping bug — `GET /api/v1/homestays` defaults to `status=active` and has no documented way to see one's own pending/inactive listings).

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "homestays": [ /* same shape as GET /api/v1/homestays list items, all statuses included */ ]
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
    "rating": "number (0-5)",
    "totalReviews": "number",
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
    "status": "pending",
    "totalAmount": "number",
    "nights": "number",
    "message": "Booking request submitted. The host will review and approve your enquiry."
  }
}
```

**Notes**: every new booking starts as `pending` — the enquiry stage, awaiting the owner's approval. Owner notifications are sent automatically (see Notifications Module). See `PATCH /api/v1/bookings/:id/status` below for the full enquiry → booking lifecycle.

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid dates, guest count, or missing fields
- `404 ROOM_NOT_FOUND` - Room not found in homestay
- `409 ROOM_NOT_AVAILABLE` - Room already booked for specified dates

---

### POST `/api/v1/homestays/:id/reviews`

**Purpose**: Submit (or update) a rating/review for a homestay. Recomputes the homestay's aggregate `rating`/`totalReviews`.

**Authentication**: JWT required

**Path Parameters**:
- `id` - Homestay UUID (required)

**Request Body**:
```json
{ "rating": "integer (1-5, required)", "comment": "string (optional)" }
```

**Success Response (201)**:
```json
{ "success": true, "data": { "message": "Review submitted successfully" } }
```

Submitting again for the same homestay updates your existing review (rating + comment) rather than creating a duplicate — one review per user per listing. The homestay owner receives a notification.

**Error Responses**:
- `400 VALIDATION_ERROR` - rating missing or not between 1 and 5
- `404 HOMESTAY_NOT_FOUND` / `404 USER_NOT_FOUND`

---

### PATCH `/api/v1/bookings/:id/status`

**Purpose**: Transition a booking through the enquiry → booking lifecycle. This resolves the two-stage "Pending → Approved → Confirm Booking" workflow the Bookings Hub screen needs, using a dedicated `approved` status distinct from `pending-payment` (which keeps its original meaning: the guest is mid-checkout, awaiting their own payment — not "owner approved").

**Authentication**: JWT required

**Path Parameters**:
- `id` - Booking UUID (required)

**Request Body**:
```json
{ "status": "string (required, one of the values below)", "reason": "string (optional, used for cancellation)" }
```

**Status values and the full transition graph**:

| From | Allowed next status | Who can trigger it |
|---|---|---|
| `pending` | `approved`, `cancelled` | owner (approve), owner/guest (cancel) — admin can do either |
| `approved` | `pending-payment`, `cancelled` | guest (starts checkout), owner/guest (cancel) |
| `pending-payment` | `confirmed`, `cancelled` | guest (reports payment success — no payment-gateway integration exists yet, this is client-reported), owner/guest (cancel) |
| `confirmed` | `checked-in`, `cancelled`, `no-show` | owner (check-in / no-show), owner/guest (cancel) |
| `checked-in` | `checked-out` | owner |
| `cancelled` | `refunded` | owner/guest/admin |

`admin`/`district-admin`/`taluka-admin` may perform any transition regardless of the table above. Any transition not listed is rejected with `400 INVALID_TRANSITION`.

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "string",
    "previousStatus": "string",
    "updatedAt": "ISO date"
  }
}
```

The guest receives a notification on every successful transition (see Notifications Module).

**Error Responses**:
- `400 VALIDATION_ERROR` - status missing
- `400 INVALID_TRANSITION` - the requested status isn't reachable from the booking's current status
- `403 INSUFFICIENT_PERMISSIONS` - the caller isn't authorized to make this specific transition
- `404 BOOKING_NOT_FOUND`

---

## 4. Restaurant Management Module

### POST `/api/v1/restaurants`

**Purpose**: Create a new restaurant listing

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin`

**Request Body**:
```json
{
  "name": "string (required, max 255 chars)",
  "description": "string (optional, restaurant description)",
  "cuisineType": "string (optional, type of cuisine)",
  "contactPhone": "string (optional, 10-digit phone number)",
  "contactEmail": "string (optional, valid email)",
  "address": "string (required, restaurant address)",
  "district": "string (required)",
  "taluka": "string (required)",
  "location": {
    "lat": "number (optional, latitude)",
    "lng": "number (optional, longitude)"
  },
  "openingHours": {
    "monday": {"open": "09:00", "close": "22:00"},
    "tuesday": {"open": "09:00", "close": "22:00"}
  },
  "averageCostForTwo": "number (optional, cost in INR)",
  "seatingCapacity": "number (optional, maximum seats)",
  "amenities": ["array of strings (optional)"],
  "photos": ["array of photo URLs (optional)"]
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "cuisineType": "string",
    "district": "string",
    "taluka": "string",
    "status": "pending-verification",
    "message": "Restaurant created successfully and submitted for verification"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields or invalid data
- `404 USER_NOT_FOUND` - User not found
- `409 DUPLICATE_RESTAURANT` - Restaurant name already exists for owner

---

### GET `/api/v1/restaurants`

**Purpose**: List restaurants with filters and pagination

**Authentication**: None required

**Query Parameters**:
- `district` - Filter by district name (partial match)
- `taluka` - Filter by taluka name (partial match)
- `cuisineType` - Filter by cuisine type (partial match)
- `search` - Search in name and description
- `page` - Page number (default: 1, min: 1)
- `limit` - Items per page (default: 10, min: 1, max: 50)
- `status` - Filter by status (default: active)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "restaurants": [
      {
        "id": "uuid",
        "name": "string",
        "description": "string",
        "cuisineType": "string",
        "contactInfo": {
          "phone": "string",
          "email": "string"
        },
        "location": {
          "address": "string",
          "district": "string",
          "taluka": "string",
          "coordinates": {
            "lat": "number",
            "lng": "number"
          }
        },
        "openingHours": "object",
        "pricing": {
          "averageCostForTwo": "number"
        },
        "seatingCapacity": "number",
        "amenities": ["array"],
        "photos": ["array"],
        "rating": "number",
        "totalReviews": "number",
        "status": "string",
        "ownerName": "string",
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
      "cuisineType": "string",
      "search": "string",
      "status": "string"
    }
  }
}
```

---

### GET `/api/v1/restaurants/my`

**Purpose**: Get every restaurant the authenticated owner has, regardless of status — the restaurant-module equivalent of `GET /api/v1/homestays/my`. Replaces the previously undocumented, non-`/v1`-prefixed `GET /api/restaurants/owner/{ownerId}` path (which doesn't match any gateway route and returns 404).

**Authentication**: JWT required

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "restaurants": [ /* same shape as GET /api/v1/restaurants list items, all statuses included */ ]
  }
}
```

---

### GET `/api/v1/restaurants/:id`

**Purpose**: Get detailed restaurant information

**Authentication**: None required

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "ownerId": "uuid",
    "name": "string",
    "description": "string",
    "cuisineType": "string",
    "contactInfo": {
      "phone": "string",
      "email": "string"
    },
    "location": {
      "address": "string",
      "district": "string",
      "taluka": "string",
      "coordinates": {
        "lat": "number",
        "lng": "number"
      }
    },
    "openingHours": "object",
    "pricing": {
      "averageCostForTwo": "number"
    },
    "seatingCapacity": "number",
    "amenities": ["array"],
    "photos": ["array"],
    "rating": "number",
    "totalReviews": "number",
    "status": "string",
    "isVerified": "boolean",
    "owner": {
      "name": "string",
      "email": "string",
      "phone": "string"
    },
    "createdAt": "ISO date",
    "updatedAt": "ISO date"
  }
}
```

**Error Responses**:
- `404 RESTAURANT_NOT_FOUND` - Restaurant not found

---

### POST `/api/v1/restaurants/:id/reviews`

**Purpose**: Submit (or update) a rating/review for a restaurant. Recomputes the restaurant's aggregate `rating`/`totalReviews` — the same mechanism as the homestay reviews endpoint.

**Authentication**: JWT required

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Request Body**:
```json
{ "rating": "integer (1-5, required)", "comment": "string (optional)" }
```

**Success Response (201)**:
```json
{ "success": true, "data": { "message": "Review submitted successfully" } }
```

One review per user per restaurant — submitting again updates your existing review. The restaurant owner receives a notification.

**Error Responses**:
- `400 VALIDATION_ERROR` - rating missing or not between 1 and 5
- `404 RESTAURANT_NOT_FOUND` / `404 USER_NOT_FOUND`

---

### POST `/api/v1/restaurants/:id/photos`

**Purpose**: Upload photos for restaurant

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Request Body**:
```json
{
  "photos": ["array of photo URLs (required)"]
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Photos uploaded successfully",
    "photos": ["array of photo URLs"]
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Photos array is required
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 RESTAURANT_NOT_FOUND` - Restaurant not found

---

### Menu Management APIs

### POST `/api/v1/restaurants/:id/menu`

**Purpose**: Add menu item to restaurant

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Request Body**:
```json
{
  "category": "string (required, e.g., 'Starters', 'Main Course')",
  "itemName": "string (required, name of the dish)",
  "description": "string (optional, dish description)",
  "price": "number (required, non-negative price)",
  "isVegetarian": "boolean (optional, default: false)",
  "isVegan": "boolean (optional, default: false)",
  "containsGluten": "boolean (optional, default: false)",
  "spiceLevel": "string (optional, enum: mild|medium|spicy|very-spicy)",
  "preparationTime": "number (optional, time in minutes)",
  "photoUrl": "string (optional, item photo URL)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "category": "string",
    "itemName": "string",
    "description": "string",
    "price": "number",
    "isVegetarian": "boolean",
    "isVegan": "boolean",
    "containsGluten": "boolean",
    "spiceLevel": "string",
    "preparationTime": "number",
    "photoUrl": "string",
    "isAvailable": "boolean",
    "createdAt": "ISO date",
    "updatedAt": "ISO date",
    "message": "Menu item added successfully"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields or invalid price
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 RESTAURANT_NOT_FOUND` - Restaurant not found

---

### GET `/api/v1/restaurants/:id/menu`

**Purpose**: Get restaurant menu

**Authentication**: None required

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Query Parameters**:
- `category` - Filter by category (optional)
- `available` - Filter by availability (true/false, optional)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "restaurantId": "uuid",
    "menu": {
      "Starters": [
        {
          "id": "uuid",
          "category": "string",
          "itemName": "string",
          "description": "string",
          "price": "number",
          "isVegetarian": "boolean",
          "isVegan": "boolean",
          "containsGluten": "boolean",
          "spiceLevel": "string",
          "preparationTime": "number",
          "photoUrl": "string",
          "isAvailable": "boolean",
          "createdAt": "ISO date",
          "updatedAt": "ISO date"
        }
      ],
      "Main Course": [...]
    },
    "totalItems": "number",
    "filters": {
      "category": "string",
      "available": "string"
    }
  }
}
```

---

### PUT `/api/v1/restaurants/:id/menu/:menuId`

**Purpose**: Update menu item

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)
- `menuId` - Menu item UUID (required)

**Request Body**: Same fields as POST menu item (all optional for update)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "category": "string",
    "itemName": "string",
    "description": "string",
    "price": "number",
    "isVegetarian": "boolean",
    "isVegan": "boolean",
    "containsGluten": "boolean",
    "spiceLevel": "string",
    "preparationTime": "number",
    "photoUrl": "string",
    "isAvailable": "boolean",
    "updatedAt": "ISO date",
    "message": "Menu item updated successfully"
  }
}
```

**Error Responses**:
- `400 NO_VALID_UPDATES` - No valid fields provided for update
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 MENU_ITEM_NOT_FOUND` - Menu item not found

---

### DELETE `/api/v1/restaurants/:id/menu/:menuId`

**Purpose**: Delete menu item

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)
- `menuId` - Menu item UUID (required)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "message": "Menu item 'Item Name' deleted successfully"
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 MENU_ITEM_NOT_FOUND` - Menu item not found

---

### Table Reservation APIs

### POST `/api/v1/restaurants/:id/reservations`

**Purpose**: Create table reservation

**Authentication**: JWT required

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Request Body**:
```json
{
  "reservationDate": "string (required, YYYY-MM-DD format)",
  "reservationTime": "string (required, HH:MM format)",
  "partySize": "number (required, min: 1)",
  "specialRequests": "string (optional, special requirements)",
  "tablePreference": "string (optional, e.g., 'window', 'corner')",
  "customerName": "string (required, customer name)",
  "customerPhone": "string (required, contact number)",
  "customerEmail": "string (optional, contact email)"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "restaurantName": "string",
    "reservationDate": "date",
    "reservationTime": "time",
    "partySize": "number",
    "customerName": "string",
    "customerPhone": "string",
    "customerEmail": "string",
    "specialRequests": "string",
    "tablePreference": "string",
    "status": "pending",
    "createdAt": "ISO date",
    "message": "Reservation created successfully. Please wait for confirmation from the restaurant."
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Missing required fields or invalid data
- `400 CAPACITY_EXCEEDED` - Party size exceeds restaurant capacity
- `404 RESTAURANT_NOT_FOUND` - Restaurant not found or not active
- `404 USER_NOT_FOUND` - User not found

---

### GET `/api/v1/restaurants/:id/reservations`

**Purpose**: Get restaurant reservations (for restaurant owners)

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)

**Query Parameters**:
- `status` - Filter by reservation status
- `dateFrom` - Filter reservations from date (YYYY-MM-DD)
- `dateTo` - Filter reservations to date (YYYY-MM-DD)
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20, max: 100)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "restaurantId": "uuid",
    "restaurantName": "string",
    "reservations": [
      {
        "id": "uuid",
        "customer": {
          "name": "string",
          "phone": "string",
          "email": "string",
          "userFullName": "string",
          "userEmail": "string"
        },
        "reservationDate": "date",
        "reservationTime": "time",
        "partySize": "number",
        "specialRequests": "string",
        "tablePreference": "string",
        "status": "string",
        "confirmedAt": "ISO date",
        "cancelledAt": "ISO date",
        "cancellationReason": "string",
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
      "totalReservations": "number",
      "pendingReservations": "number",
      "confirmedReservations": "number",
      "completedReservations": "number",
      "cancelledReservations": "number"
    }
  }
}
```

**Error Responses**:
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 RESTAURANT_NOT_FOUND` - Restaurant not found

---

### PATCH `/api/v1/restaurants/:id/reservations/:reservationId/status`

**Purpose**: Update reservation status (for restaurant owners)

**Authentication**: JWT required  
**Authorization**: `restaurant-owner`, `admin` (owner only or admin)

**Path Parameters**:
- `id` - Restaurant UUID (required)
- `reservationId` - Reservation UUID (required)

**Request Body**:
```json
{
  "status": "string (required, enum: pending|confirmed|cancelled|completed|no-show)",
  "cancellationReason": "string (optional, required if status is cancelled)"
}
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "string",
    "confirmedAt": "ISO date",
    "cancelledAt": "ISO date",
    "cancellationReason": "string",
    "updatedAt": "ISO date",
    "message": "Reservation confirmed successfully"
  }
}
```

**Error Responses**:
- `400 VALIDATION_ERROR` - Invalid status
- `403 INSUFFICIENT_PERMISSIONS` - Not restaurant owner or admin
- `404 RESERVATION_NOT_FOUND` - Reservation not found

---

### GET `/api/v1/restaurants/my-reservations`

**Purpose**: Get user's restaurant reservations

**Authentication**: JWT required

**Query Parameters**:
- `status` - Filter by reservation status
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "reservations": [
      {
        "id": "uuid",
        "restaurant": {
          "id": "uuid",
          "name": "string",
          "address": "string",
          "phone": "string"
        },
        "reservationDate": "date",
        "reservationTime": "time",
        "partySize": "number",
        "specialRequests": "string",
        "tablePreference": "string",
        "status": "string",
        "confirmedAt": "ISO date",
        "cancelledAt": "ISO date",
        "cancellationReason": "string",
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
      "status": "string"
    }
  }
}
```

**Error Responses**:
- `404 USER_NOT_FOUND` - User not found

---

## 5. Verification Module

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

## 6. Admin Module

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

**Notes**: also sets `users.is_verified = true` and `users.status = 'active'` (previously this endpoint only updated `aadhar_verification_status`, leaving the generic `isVerified` flag the dashboard's "Verified Partner" badge reads permanently `false` even after a successful manual approval — fixed alongside the Dashboard Module work). Sends the user a notification.

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

### PATCH `/api/v1/admin/users/:id/verification`

**Purpose**: Generic partner-verification toggle for partner types that have no dedicated verification flow (only `homestay-owner` has one — Aadhar). Lets an admin set the same `isVerified` boolean the dashboard badge reads, for any partner type.

**Authentication**: JWT required  
**Authorization**: `admin`, `district-admin` (district-admin scoped to their own district)

**Path Parameters**:
- `id` - User UUID (required)

**Request Body**:
```json
{ "isVerified": "boolean (required)" }
```

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "name": "string",
    "userType": "string",
    "isVerified": "boolean",
    "message": "User verification status updated successfully"
  }
}
```

Sends the user a notification. Errors: `400 VALIDATION_ERROR`, `403 INSUFFICIENT_PERMISSIONS`, `404 USER_NOT_FOUND`.

---

### Category Applications (multi-category partner accounts)

Mirrors the homestay-verification pending/detail/approve/reject shape above exactly, applied to `partner_categories` applications instead of homestays (see also the Partner Categories Module for the applicant-facing submission endpoint).

#### GET `/api/v1/admin/category-applications/pending`

**Authorization**: `admin`, `district-admin` (auto-scoped to own district)

**Query Parameters**: `district` (admin only), `page`, `limit`

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "applications": [
      {
        "id": "uuid",
        "categoryId": "stays|food|activities|events|rides|professional-services",
        "registrationNumber": "string | null",
        "description": "string | null",
        "documentUrl": "string | null",
        "applicant": { "userId": "uuid", "name": "string", "email": "string", "phone": "string", "userType": "string", "district": "string", "taluka": "string" },
        "submittedAt": "ISO date"
      }
    ],
    "pagination": { "currentPage": "number", "totalPages": "number", "totalItems": "number", "itemsPerPage": "number", "hasNext": "boolean", "hasPrev": "boolean" }
  }
}
```

#### GET `/api/v1/admin/category-applications/:id`

Same shape as above for a single application, plus `status` and `reviewedAt`.

#### POST `/api/v1/admin/category-applications/:id/approve`

**Request Body**: `{ "comments": "string (optional)" }`

Sets the `partner_categories` row to `status: active`, records `reviewed_by`/`reviewed_at`, best-effort logs to `category_application_logs`, and notifies the applicant.

**Errors**: `400 INVALID_STATUS` (not pending), `403 INSUFFICIENT_PERMISSIONS`, `404 APPLICATION_NOT_FOUND`.

#### POST `/api/v1/admin/category-applications/:id/reject`

**Request Body**: `{ "reason": "string (required)", "comments": "string (optional)" }`

Sets the row to `status: rejected` and notifies the applicant. Same error set as approve, plus `400 VALIDATION_ERROR` if `reason` is missing.

---

## 7. Master Data Module

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

## 8. Marketplace Module

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

## 9. Events Module

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

## 10. Tourism Module

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

## 11. Learning Module

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

## 12. CSR Module

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

## 13. Blue Economy Module

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

## 14. Rewards Module

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

## 15. Feedback Module

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

## 16. System Endpoints

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

## 17. Dashboard Module

Backs the partner-app home screen's 6 stat cards + profile-completion bar. Both endpoints aggregate across every listing the authenticated partner owns — homestays (joined via `owner_id = firebase_uid`) and restaurants (joined via `owner_id = users.id` — a pre-existing inconsistency between the two tables' owner-reference type).

### GET `/api/v1/dashboard/summary`

**Authentication**: JWT required (any partner `userType`)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "activeListings": "number",
    "pendingListings": "number",
    "newEnquiries": "number",
    "todaysBookings": "number",
    "monthlyViews": "number",
    "averageRating": "number",
    "profileCompletionPercent": "number (0-100)"
  }
}
```

**Notes**:
- `newEnquiries` = homestay bookings with `status: pending` + restaurant reservations with `status: pending`.
- `todaysBookings` = homestay bookings checking in today with `status` in `confirmed`/`checked-in` + restaurant reservations for today with `status: confirmed`.
- `monthlyViews` = count of `listing_views` rows across all owned listings in the last 30 days (written by `GET /homestays/:id` and `GET /restaurants/:id`, fire-and-forget so it never adds latency to those reads).
- `averageRating` = mean of `rating` across owned listings that have at least one review (listings with zero reviews are excluded, not treated as 0).

---

### GET `/api/v1/dashboard/activity`

**Purpose**: "Recent Workspace Activity" feed. Computed on read from existing tables (booking status changes, reviews, category-application status changes) rather than a separate write-instrumented activity-log table.

**Authentication**: JWT required

**Query Parameters**: `limit` (default 20)

**Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "activities": [
      { "type": "booking | reservation | review | category-application", "message": "string", "timestamp": "ISO date" }
    ]
  }
}
```

---

## 18. Notifications Module

### GET `/api/v1/notifications`

**Authentication**: JWT required

**Query Parameters**: `page` (default 1), `limit` (default 20)

**Success Response (200)** — note the top-level `notifications` key (not nested under `data`), matching the Flutter client's existing parser:
```json
{
  "success": true,
  "notifications": [
    {
      "id": "uuid",
      "category": "announcement | alert",
      "title": "string",
      "message": "string",
      "createdAt": "ISO date",
      "isRead": "boolean"
    }
  ],
  "unreadCount": "number"
}
```

`category` is currently limited to `announcement`/`alert` — wider categories (`booking`, `review`, `payout`) need product confirmation before the DB CHECK constraint and this doc are widened.

---

### PATCH `/api/v1/notifications/:id/read`

**Authentication**: JWT required

**Success Response (200)**: `{ "success": true, "data": { "message": "Notification marked as read" } }`

---

### POST `/api/v1/notifications/read-all`

**Authentication**: JWT required

**Success Response (200)**: `{ "success": true, "data": { "message": "All notifications marked as read" } }`

---

**Push delivery**: every notification insert best-effort fans out as an FCM push to the user's registered device tokens (see `POST /api/v1/users/me/device-tokens`) via `packages/shared-firebase`'s `sendPush()`/`createNotification()`. Push delivery failures (missing/invalid token, unconfigured Firebase project) are logged and never block the notification's creation or the triggering request.

**Mutation points that create a notification today**: new booking enquiry (owner), booking status change (guest), new homestay/restaurant review (owner), category application approved/rejected (applicant), Aadhar verification approved/rejected (user), generic verification toggled (user).

---

## 19. Partner Categories Module

Backs multi-category partner accounts (the dashboard's category-switcher dropdown and the Account Console's "Unlocked Business Portals" / "Apply for New Category"). Categories are tracked in a dedicated `partner_categories` table, separate from the single-value `users.role` authorization enum — a partner can hold multiple categories (`stays`, `food`, `activities`, `events`, `rides`, `professional-services`) at once, each independently `active`/`pending`/`rejected`.

The category chosen implicitly at signup (`stays` for `homestay-owner`, `food` for `restaurant-owner`) is granted `active` immediately at registration — see the Authentication Module. This endpoint is only for applying for an *additional* category later.

### POST `/api/v1/partners/category-applications`

**Authentication**: JWT required

**Request Body**:
```json
{
  "categoryId": "string, one of stays|food|activities|events|rides|professional-services",
  "registrationNumber": "string (optional) — local trade license / RTO permit / DOT registration number",
  "description": "string (optional) — business setup, experience, capacity, assets",
  "documentUrl": "string, URL (optional) — supporting document"
}
```

**Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "categoryId": "string",
    "status": "pending",
    "message": "Category application submitted for review"
  }
}
```

Creates a `pending` `partner_categories` row surfaced to admins via `GET /api/v1/admin/category-applications/pending`. Re-applying after a prior rejection resets the same row back to `pending`. The resulting `categories` array (with `label` and `status` per entry) is returned on `GET /api/v1/users/me`.

**Error Responses**:
- `400 VALIDATION_ERROR` - categoryId not one of the 6 valid values
- `404 USER_NOT_FOUND`
- `409 DUPLICATE_CATEGORY` - an active or already-pending application exists for this category

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