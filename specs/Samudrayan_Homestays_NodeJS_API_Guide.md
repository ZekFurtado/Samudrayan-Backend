# Samudrayan – API Specification (Inferred from “APIs” Worksheet & Platform Features)

> **Note:** The XLSX worksheet isn’t visible here, so this document is built directly from the Samudrayan PPT features (community/stakeholder onboarding, tourism hub, homestay booking, Samudrayan Fresh marketplace, CSR & investment, learning/training, events/summit, blue-economy tracker, feedback/policy hub, gamification).  
> Treat this as the **master brief for Claude** to convert into actual Node.js (Clean Architecture) APIs.  
> All endpoints should follow REST, use JSON, and be versioned: e.g. `/api/v1/...`.

---

## 0. Common Conventions

- **Auth**: JWT (Bearer) in `Authorization` header.
- **Roles** (from PPT users): `admin`, `district-admin`, `taluka-admin`, `homestay-owner`, `fisherfolk`, `artisan`, `ngo`, `investor`, `tourist`, `trainer`.
- **IDs**: UUID v4.
- **Timestamps**: ISO 8601.
- **Pagination**: `?page=1&limit=20`.
- **Errors**:
    - `400` – validation failed
    - `401` – not authenticated
    - `403` – not authorized
    - `404` – not found
    - `409` – duplicate / state conflict
    - `500` – server error

#### Standard error shape:
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "homestayName is required",
    "details": {...}
  }
}
```


## 1. Auth & User Onboarding APIs

### 1.1 POST /api/v1/auth/register

#### Purpose:
Onboard all stakeholder types mentioned in PPT (fisherfolk, homestay owners, artisans, MSMEs, NGOs, tourists, investors).

#### Request:

```json{
  "uid" : "<firebase uid>",
  "fullName": "Vikas Aute",
  "email": "vikas@example.com",
  "phone": "+91xxxxxxxxxx",
  "role": "homestay-owner",
  "district": "Ratnagiri",
  "taluka": "Dapoli",
  "organizationName": "Konkan Homestays",
  "idDocs": [
    {
      "type": "aadhaar",
      "number": "xxxx-xxxx-xxxx",
      "fileUrl": "https://..."
    }
  ]
}
```

#### Response:

```json{
  "success": true,
  "data": {
    "requiresVerification": true
  }
}
```

#### Use Cases:
	•	homestay owner wanting to list
	•	fisherfolk wanting to join marketplace
	•	tourist registration for booking
	•	CSR org wanting dashboard access

#### Edge Cases:
	•	phone already exists → 409
	•	userType requires KYC but docs missing → respond with requiresVerification: true
	•	OTP flow could be added as separate API



### 1.2 POST /api/v1/auth/login

#### Purpose:
Issue JWT.

#### Request:

```json{ "uid" : "<firebase uid>" }```

#### Response:

```json{
  "success": true,
  "data": {
    "accessToken": "jwt-token",
    "refreshToken": "jwt-refresh",
    "user": {
      "role": "homestay-owner",
      "roles": ["homestay-owner"]
    }
  }
}
```
#### Failures:
	•	wrong creds → 401
	•	user not verified → 403 with code: "NOT_VERIFIED"


### 1.3 GET /api/v1/users/me

#### Purpose: 
Fetch profile + role-based dashboard tiles (like PPT home screen).

#### Response:

```json{
  "success": true,
  "data": {
    "id": "<firebase uid>",
    "fullName": "Vikas",
    "role": "homestay-owner",
    "district": "Ratnagiri",
    "dashboard": [
      "my-homestays",
      "my-bookings",
      "training",
      "csr-projects"
    ]
  }
}
```

### 1.4 PATCH /api/v1/users/me

#### Purpose: update language (EN/MR), location, KYC docs.

#### Edge Cases: do not allow role escalation here; that goes via admin API.

⸻

## 2. Location, Taxonomy & Master Data APIs

These support filters like district → taluka → village and tourism categories.

### 2.1 GET /api/v1/master/locations

#### Purpose: 
List districts/talukas/villages configured for Samudrayan.

#### Response:

```json{
  "success": true,
  "data": [
    {
      "district": "Ratnagiri",
      "talukas": ["Dapoli", "Guhagar", "Chiplun", "Mandangad"]
    }
  ]
}
```
#### Edge Case: admin may want only active locations → ?status=active.

### 2.2 GET /api/v1/master/categories

#### Purpose: 
Homestay categories (silver/gold/diamond from PPT), marketplace categories, tourism categories.

#### Response:

```json{
  "success": true,
  "data": {
    "homestayGrades": ["silver", "gold", "diamond"],
    "marketplace": ["seafood", "spices", "handicrafts", "coastal-cuisine"],
    "tourism": ["beaches", "forts", "mangrove-trails", "festivals"]
  }
}
```

## 3. Homestay & Tourism Experience APIs

These come straight from PPT: “Homestay booking engine with ratings and sustainability scores.”

### 3.1 POST /api/v1/homestays

#### Role: 
Homestay-owner or admin

#### Purpose: 
Create homestay listing.

#### Request:

```json{
  "name": "Ganpatipule Beach Homestay",
  "description": "Sea-facing homestay...",
  "ownerId": "uuid",
  "grade": "gold",
  "district": "Ratnagiri",
  "taluka": "Ganpatipule",
  "location": { "lat": 16.229, "lng": 73.43 },
  "amenities": ["wifi", "power-backup", "24h-water"],
  "rooms": [
    { "name": "Deluxe Konkan Room", "capacity": 3, "pricePerNight": 2500 }
  ],
  "media": ["https://.../img1.jpg"],
  "sustainabilityScore": 82
}
```

#### Response: created homestay with id.

#### Edge Cases:
	•	owner not verified → 403
	•	district/taluka not in master → 400
	•	duplicate name for same owner → 409

⸻

### 3.2 GET /api/v1/homestays

Purpose: search/browse homestays for tourists.

#### Query params:
	•	district=Ratnagiri
	•	grade=gold
	•	minPrice=1000&maxPrice=4000
	•	sustainabilityScoreGte=70
	•	pagination

#### Response:

```json{
  "success": true,
  "data": [
    {
      "id": "<firebase uid>",
      "name": "Ganpatipule Beach Homestay",
      "grade": "gold",
      "priceFrom": 2500,
      "district": "Ratnagiri",
      "taluka": "Ganpatipule",
      "rating": 4.5
    }
  ]
}
```
#### Edge Cases:
	•	no results → return empty array, not error
	•	large filters → ensure indexed search

⸻

### 3.3 GET /api/v1/homestays/{id}

Purpose: details page in the app.

#### Edge Cases:
	•	homestay exists but is inactive → show only if requester is owner/admin
	•	include future availability for booking

⸻

### 3.4 POST /api/v1/homestays/{id}/bookings

Purpose: tourist books a homestay.

#### Request:

```json{
  "checkIn": "2025-01-10",
  "checkOut": "2025-01-12",
  "guests": 2,
  "roomId": "uuid",
  "paymentMethod": "upi"
}
```
#### Response:

```json{
  "success": true,
  "data": {
    "bookingId": "uuid",
    "status": "pending-payment"
  }
}
```
#### Edge Cases:
	•	room already booked → 409 with "code": "ROOM_NOT_AVAILABLE"
	•	checkIn >= checkOut → 400
	•	homestay not verified → 403 for public users

#### Failures:
	•	payment gateway failed → booking stays in pending → create a retry API

⸻

### 3.5 GET /api/v1/bookings/me

Purpose: show tourist/homestay-owner bookings list.

⸻

## 4. Tourism & Experience Map APIs

PPT mentions “Interactive Coastal Map,” “heritage, festivals, eco-trails.”

### 4.1 POST /api/v1/tourism/spots

#### Role: 
Admin

#### Purpose: 
Create spot.

#### Request:

```json{
  "title": "Marleshwar Waterfall",
  "type": "nature",
  "district": "Sangameshwar",
  "description": "Scenic waterfall...",
  "location": { "lat": 16.9, "lng": 73.5 },
  "media": ["https://.../marleshwar.jpg"],
  "isActive": true
}
```

⸻

### 4.2 GET /api/v1/tourism/spots

#### Purpose:
Mobile/web app shows pins.

#### Filters:
District, type, isActive=true

⸻

## 5. Marketplace – “Samudrayan Fresh” APIs

From PPT: “traceable seafood, spices, handicrafts, cart & payment, QR traceability.”

### 5.1 POST /api/v1/marketplace/products

#### Role:
Artisan, fisherfolk, homestay-owner, admin

#### Purpose: 
List a product with traceability.

#### Request:

```json{
  "name": "Fresh Pomfret (1kg)",
  "category": "seafood",
  "price": 750,
  "stockQty": 25,
  "originVillage": "Harne",
  "traceId": "BLOCKCHAIN-ID-123",
  "media": ["https://.../fish.jpg"]
}
```
#### Edge Cases:
	•	stock negative → 400
	•	category not in master → 400

⸻

5.2 GET /api/v1/marketplace/products

Purpose: browse products.

Filters: category=seafood, district=Ratnagiri, minPrice, maxPrice, sustainabilityScore

⸻

5.3 POST /api/v1/marketplace/cart

Purpose: add to cart.

Request:

{
  "productId": "uuid",
  "quantity": 2
}

Edge Cases:
	•	stock < quantity → 409
	•	product inactive → 403

⸻

5.4 POST /api/v1/marketplace/orders

Purpose: place order (UPI, CSR-linked donations in PPT).

Request:

{
  "items": [
    { "productId": "uuid", "quantity": 2 }
  ],
  "paymentMethod": "upi",
  "deliveryAddress": "Konkan House, Ratnagiri",
  "csrTagId": "uuid"
}

Response:

{
  "success": true,
  "data": {
    "orderId": "uuid",
    "status": "pending-payment"
  }
}

Failures:
	•	some items out of stock → return partial success with line-level errors
	•	CSR tag invalid → ignore tag but proceed, or return 400 based on business rule

⸻

6. Learning & Certification APIs

From PPT: “Workshops & E-learning Modules,” “Digital Certificates.”

6.1 POST /api/v1/learning/modules

Role: admin or trainer

Purpose: upload course/module.

Request:

{
  "title": "Sustainable Fishing Practices",
  "language": "mr",
  "description": "Module created with NCSCM",
  "contentUrl": "https://...",
  "quiz": [
    {
      "question": "What is bycatch?",
      "options": ["A", "B", "C", "D"],
      "answerIndex": 2
    }
  ],
  "certificateTemplateId": "uuid"
}


⸻

6.2 POST /api/v1/learning/modules/{id}/attempt

Purpose: user starts module, to enable gamification.

Edge Cases: user already completed → respond with existing certificate ID.

⸻

6.3 POST /api/v1/learning/modules/{id}/submit

Purpose: evaluate quiz, issue certificate.

Response:

{
  "success": true,
  "data": {
    "score": 85,
    "passed": true,
    "certificateUrl": "https://.../certs/uuid.pdf",
    "rewards": {
      "points": 50,
      "badge": "Eco Ambassador"
    }
  }
}

Failures:
	•	attempt not found → 404
	•	quiz tampering → 400

⸻

7. CSR & Investment Dashboard APIs

From PPT: “CSR project listing,” “Impact reporting,” “Investor Connect.”

7.1 POST /api/v1/csr/projects

Role: admin

Purpose: publish CSR project.

Request:

{
  "title": "Coastal Waste Recycling",
  "description": "Plastic-free beaches",
  "sdgAlignment": ["SDG12", "SDG14"],
  "targetBeneficiaries": 500,
  "district": "Ratnagiri",
  "budget": 1000000,
  "status": "active"
}


⸻

7.2 GET /api/v1/csr/projects

Purpose: list CSR projects for public/CSR partners.

Filters: status=active, district=Ratnagiri, sdg=SDG12

⸻

7.3 POST /api/v1/csr/projects/{id}/contributions

Purpose: log funds/participation.

Request:

{
  "amount": 25000,
  "contributorType": "corporate",
  "contributorName": "Tata CSR",
  "notes": "Beach cleanup"
}

Edge Cases: project closed → 403

⸻

7.4 GET /api/v1/csr/projects/{id}/impact

Purpose: show metrics as in PPT (beneficiaries, SDG alignment)

⸻

8. Event & Summit Integration APIs

From PPT: “Live updates,” “Virtual participation & ticketing,” “Countdown.”

8.1 POST /api/v1/events

Role: admin

Purpose: create Summit 2025 sessions, district-level mini-conferences.

⸻

8.2 GET /api/v1/events

Purpose: public listing with filters type=summit, date>=2025-03-01.

⸻

8.3 POST /api/v1/events/{id}/register

Purpose: delegates, partners, media register.

Edge Cases:
	•	event full → 409
	•	registration closed → 403

⸻

8.4 GET /api/v1/events/{id}/stream

Purpose: return stream token/URL (handled via integration).

⸻

9. Blue Economy Tracker & Data Upload APIs

From PPT: “Fishing zones, water quality, mangrove restoration,” “Community uploads.”

9.1 POST /api/v1/blue-economy/records

Role: admin or verified community-reporter

Purpose: upload data point.

Request:

{
  "type": "water-quality",
  "district": "Ratnagiri",
  "taluka": "Guhagar",
  "location": { "lat": 16.3, "lng": 73.2 },
  "value": {
    "salinity": 31.5,
    "ph": 7.8
  },
  "recordedAt": "2025-11-07T10:00:00Z"
}

Edge Cases: unknown type → 400 (schema-driven)

⸻

9.2 GET /api/v1/blue-economy/records

Purpose: visualize on dashboard (filters by date range, district, type).

⸻

10. Feedback, Policy Hub & Survey APIs

From PPT: “Survey tools,” “Open data repository,” “Citizen polls.”

10.1 POST /api/v1/feedback/forms

Role: admin

Purpose: create survey/poll.

Request:

{
  "title": "Konkan Mangrove Feedback",
  "questions": [
    {
      "type": "single-choice",
      "label": "Are you from coastal village?",
      "options": ["Yes", "No"],
      "required": true
    }
  ],
  "targetAudience": ["fisherfolk", "homestay-owner"],
  "validTill": "2025-12-31"
}


⸻

10.2 POST /api/v1/feedback/forms/{id}/responses

Purpose: citizens submit responses from the app.

Edge Cases:
	•	duplicate submission by same user → either overwrite or block → define in form config
	•	form expired → 403

⸻

10.3 GET /api/v1/feedback/forms/{id}/analytics

Role: admin

Purpose: dashboard view with counts & district-wise split.

⸻

11. Gamified Engagement & Rewards APIs

From PPT: “Eco Ambassador Badges,” “Points redeemable,” “Leaderboards.”

11.1 GET /api/v1/rewards/me

Purpose: show user’s current points, badges, redeemables.

⸻

11.2 POST /api/v1/rewards/redeem

Purpose: user redeems points.

Edge Cases:
	•	insufficient points → 400
	•	reward inactive → 403

⸻

11.3 GET /api/v1/rewards/leaderboard

Purpose: show top-performing coastal entrepreneurs / participants.

⸻

12. Admin & Moderation APIs

12.1 GET /api/v1/admin/verifications/pending

Purpose: list users, homestays, products awaiting verification.

⸻

12.2 POST /api/v1/admin/verifications/{id}/approve

Purpose: approve KYC/listings.

Edge Cases:
	•	already approved → idempotent success
	•	missing documents → 400 with detail

⸻

12.3 PATCH /api/v1/admin/users/{id}/roles

Purpose: assign district-admin, etc.

Edge Cases:
	•	cannot remove own admin role → 403
	•	cannot escalate to super-admin unless super-admin

⸻

13. System-Level / Utility APIs

13.1 GET /api/v1/health

Purpose: for load balancer / uptime checks.

⸻

13.2 GET /api/v1/config

Purpose: return app constants (languages, feature flags: offline mode, blue-flag beaches URLs).

⸻

14. Typical Failures & Exception Patterns
	1.	Validation Error
	•	Cause: missing district on homestay
	•	Response:

{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "district is required"
  }
}


	2.	Business Rule Error
	•	e.g. booking on inactive homestay
	•	403 with code: "HOMESTAY_INACTIVE"
	3.	Conflict
	•	e.g. booking same room same dates
	•	409 with code: "ROOM_NOT_AVAILABLE"
	4.	Auth Error
	•	missing token → 401
	•	role mismatch → 403
	5.	Upstream / Integration Error
	•	payment / CSR wallet / streaming service fails
	•	return 502 or 500 with code: "UPSTREAM_ERROR"

⸻

15. Clean Architecture Notes for Claude

When Claude implements these:
	•	Domain layer: entities like User, Homestay, Booking, Product, CSRProject, LearningModule, Event, FeedbackForm, RewardAccount.
	•	Use-case layer: CreateHomestay, SearchHomestays, BookHomestay, CreateCSRProject, SubmitFeedback, CompleteLearningModule, RedeemReward.
	•	Interface/Controller layer: maps HTTP → use-case DTOs.
	•	Infra layer: PostgreSQL repos (or the Excel “PostgreSQL Schema” sheet you have), file storage for media, payment adapter.

Each of the APIs above maps 1:1 to a use case; validation + auth + error mapping stays at controller level; domain should throw business errors (e.g. HomestayNotActiveError) which controller converts to the JSON errors shown above.

⸻

16. Edge Cases to Keep in Mind (Global)
	•	Multi-language (Marathi/English) – support Accept-Language.
	•	Offline-first users – mobile may sync later → allow idempotent create with client-generated IDs.
	•	Seasonal tourism data – some APIs should filter by date (/tourism/spots?season=monsoon).
	•	Soft deletes – don’t hard delete homestays/products because admin reporting needs history.
	•	Rate limiting on public APIs (tourism map, events) to prevent abuse during summit.

