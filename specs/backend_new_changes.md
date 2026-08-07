# Samudrayan Partner App — Backend Requirements (running log)

## Context

This is the **single running log of backend gaps** found while building out the partner-facing Flutter app (Figma file `Samudrayan`) — one file, appended to as new screens are wired up, rather than a new spec doc per screen. It started with the shared home/dashboard screen (hence the filename) but now also covers the Bookings Hub and Notifications screens; treat the filename as historical.

Covered so far, in the order they were built:
- **Home/Dashboard** (Figma node `819:1206`) — §1–10.
- **Bookings Hub** (Enquiries/Bookings tabs, Figma nodes `819:2175` / `819:1600`) — §11.
- **Notifications & Alerts** (Figma node `819:1860`) — §12.
- **Account Console / Edit Profile / Apply for New Category** (Figma nodes `819:2377`, `819:2678`, `819:2619`) — §13. This is where multi-category partner accounts (gap #9) actually got a UI.

All of these share **one common UI shell** reused by every partner type (homestay-owner, restaurant-owner, artisan, fisherfolk, trainer, etc. — see `role`/`userType` enum in `Complete_API_Documentation.md`):

- `lib/src/dashboard/presentation/widgets/partner_chrome.dart` — shared header + bottom nav.
- `lib/src/dashboard/presentation/widgets/partner_home_screen.dart` — dashboard shell.
- `lib/src/dashboard/presentation/widgets/bookings_hub_screen.dart` — Enquiries/Bookings shell.
- `lib/src/dashboard/presentation/widgets/notifications_screen.dart` — Notifications shell.
- `lib/src/dashboard/presentation/widgets/account_console_screen.dart`, `edit_profile_screen.dart` — Account Console / Edit Profile shells.
- `lib/src/homestay/presentation/pages/homestay_owner_dashboard.dart`, `homestay_bookings_hub_page.dart` — the first per-partner-type wiring (homestay-owner). Other partner-type pages (restaurant-owner, etc.) will be wired to the same shared widgets later.
- `lib/src/notifications/` — the Notifications feature module (entity/repository/usecases/bloc), partner-type agnostic.
- `lib/src/profile/presentation/pages/account_console_page.dart`, `edit_profile_page.dart`, `apply_for_category_page.dart` — Account Console wiring, partner-type agnostic.
- `lib/src/authentication/domain/entities/user.dart` (`LocalUser`) and `lib/src/authentication/domain/entities/partner_category.dart` — extended with the business-profile and multi-category fields these screens need (all nullable — see §13).
- `lib/core/common/partner_categories.dart` — the shared 6-category list (Stays/Food/Activities/Events/Rides/Professional Services), used by onboarding's "Select Primary Category", the Account Console's "Unlocked Business Portals", and "Apply for New Category".

Existing endpoints referenced below are cited by their section in `Complete_API_Documentation.md`.

**How to use this file**: when a new screen needs backend support that doesn't exist yet, add a new numbered section at the bottom (don't create a separate spec file), update the summary table, and note the Flutter-side status (what mock/fallback/placeholder is standing in for it today, and where).

---

## Summary of gaps

| # | Gap | Priority | New or extend? |
|---|-----|----------|-----------------|
| 1 | Dashboard summary endpoint (stats aggregation) | High | New |
| 2 | Homestay ratings & reviews | High | Extend |
| 3 | Notifications module | Medium | New — frontend built against proposed contract, see §12 |
| 4 | Recent workspace activity feed | Low | New |
| 5 | Listing view analytics ("Monthly Views") | Medium | New |
| 6 | "New Enquiries" concept | Medium | Resolved via option (a) — see §11 |
| 7 | Generic partner verification status | High | Extend |
| 8 | Profile completion percentage | Medium | New/computed |
| 9 | Multi-category partner accounts | High (larger feature) | New — now has a concrete field/endpoint proposal, see §13 |
| 10 | "My homestays" incorrectly scoped to active-only | High | Fix/extend |
| 11 | Booking status transitions used by the Bookings Hub (approve/reject/confirm) | Medium | Product confirmation needed |
| 12 | Notifications module — concrete contract + fallback behavior | Medium | New |
| 13 | Account Console: business-profile fields, category applications, bank settlement | High | New/extend, see below |

---

## 1. Dashboard Summary Endpoint (new)

The home screen shows 6 stat cards: **Active Listings, Pending Listings, New Enquiries, Today's Bookings, Monthly Views, Average Rating**, plus a **Profile Completion %**. There is currently no single endpoint that returns these.

### Proposed: `GET /api/v1/dashboard/summary`

**Authentication**: JWT required (works for any partner `userType`)

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
- `activeListings`/`pendingListings` are currently computed client-side in `homestay_owner_dashboard.dart` from the existing owner-homestays list (filtering on `isActive`/`isVerified`/`verificationStatus`). This works today for a single-category (homestay-only) partner, but will need to be centralized server-side once multi-category accounts (see #9) ship, since a partner could have listings across multiple modules (homestays + restaurants).
- `newEnquiries`, `todaysBookings`, `monthlyViews`, `averageRating` have no backing data at all today — the Flutter UI currently renders `—` placeholders for these. See #2, #5, #6.
- `profileCompletionPercent` has no backend source — see #8.

---

## 2. Homestay Ratings & Reviews (extend existing)

Restaurants already return `rating` and `totalReviews` (see `GET /restaurants` and `GET /restaurants/:id` responses, `Complete_API_Documentation.md` lines ~763-764 and ~831-832). **Homestays do not** — `GET /homestays` and `GET /homestays/:id` responses have no rating/review fields at all.

The Flutter `Homestay` domain entity already anticipates this (`rating: double`, `reviewCount: int`, both currently always defaulting to `0.0`/`0` since the API never returns them).

**Needed**:
- Add `rating` (number) and `reviewCount`/`totalReviews` (number) to the `GET /homestays` and `GET /homestays/:id` responses, mirroring the restaurant shape.
- A review/rating submission endpoint for homestays, if one doesn't already exist generically (check whether the Feedback Module, #15 in the TOC, can be generalized to homestays instead of building a parallel system).

---

## 3. Notifications Module (new)

The dashboard's bottom navigation has a **Notifications** tab. No notifications endpoints exist anywhere in `Complete_API_Documentation.md`.

**Proposed**:
```
GET   /api/v1/notifications              # paginated list + unread count
PATCH /api/v1/notifications/:id/read     # mark one as read
POST  /api/v1/notifications/read-all     # mark all as read
```
Also confirm whether push-notification device-token registration exists elsewhere; if not, it'll be needed to actually deliver these.

*Flutter status*: **superseded by §12** — the Notifications screen has now been built against this proposed contract, with a temporary client-side fallback while the endpoints don't exist yet. See §12 for the finalized request/response shapes actually coded against.

---

## 4. Recent Workspace Activity Feed (new)

The dashboard has a "Recent Workspace Activity" section (per Figma) with no items shown in the design itself — likely meant to be populated dynamically. There's no activity/audit-log endpoint today.

**Proposed**: `GET /api/v1/dashboard/activity` — recent partner-relevant events (new booking, new review, listing approved/rejected, new enquiry, etc.), paginated.

*Flutter status*: currently renders a static "No recent activity yet" placeholder.

---

## 5. Listing View Analytics ("Monthly Views") (new)

No view-count tracking exists on homestay or restaurant detail endpoints today. Needed to populate the "Monthly Views" stat.

**Needed**: increment a view counter on `GET /homestays/:id` / `GET /restaurants/:id` (or a dedicated analytics event), plus an aggregate (e.g. "views in the last 30 days across all my listings") exposed via #1.

---

## 6. "New Enquiries" (needs a product decision)

There is no "enquiry" concept distinct from a firm booking/reservation anywhere in the current API. `enquiry`/`inquiry` only appears as UI copy in the Flutter bookings screen, not as a data model.

Two options for the backend/product team to decide between:
- **(a)** Reuse the existing booking/reservation status enum — e.g. treat `pending`/`pending-payment` bookings as "enquiries" until confirmed.
- **(b)** Introduce a distinct, lightweight `Enquiry`/`Lead` entity for pre-booking customer interest that hasn't become a real booking yet.

Whichever is chosen, the count needs to be exposed via the dashboard summary endpoint (#1).

*Update*: the Bookings Hub screen (§11) went ahead and implemented **option (a)** so the screen wouldn't sit blocked on a product decision — `pending` bookings render as "enquiries" and `pending-payment` bookings render as "approved enquiries" pending confirmation. This is a Flutter-side assumption, not a confirmed product decision; please sanity-check it against §11 and correct the mapping (or migrate to option (b)) once decided.

---

## 7. Generic Partner Verification Status (extend existing)

The dashboard shows a **"Verified Partner"** / **"Pending Verification"** badge for the logged-in partner, regardless of `userType`.

Today:
- `POST /api/v1/auth/login` already documents an `isVerified: boolean` field on the returned `user` object.
- But the actual Verification Module (`/api/v1/verification/aadhar/*`) is **homestay-owner-specific only** (per its own authorization rules and the "Prerequisites" note on `POST /homestays`).
- Other partner types (`restaurant-owner`, `artisan`, `fisherfolk`, `trainer`, etc.) have no defined verification flow at all in the docs.

**Needed**: either confirm `isVerified` is reliably populated for every partner type (with some non-Aadhar verification path for non-homestay partners), or define type-specific verification flows analogous to the Aadhar one. The dashboard badge needs a single boolean it can trust regardless of partner type.

---

## 8. Profile Completion Percentage (new/computed)

No such field/endpoint exists anywhere. The Flutter app currently computes a **temporary client-side heuristic** (fraction of `name`/`email`/`phone`/`district`/`taluka`/`profilePic` that are non-empty on the locally cached user — see `_computeProfileCompletion` in `homestay_owner_dashboard.dart`), which should be replaced once a real value is available.

**Recommendation**: compute this server-side (via `GET /users/me` or the new dashboard summary endpoint, #1) since it can factor in server-only requirements the client can't see (e.g. KYC/Aadhar document status, bank details for payouts, etc.) — a more meaningful measure of "profile completion" than what the client can compute from cached fields alone.

---

## 9. Multi-Category Partner Accounts (new, larger feature)

This ties directly to the earlier "Select Primary Category" onboarding screen (Figma node `819:1352`), whose subtitle reads: *"Choose the primary category to start listing. You can apply to unlock additional categories later under your account."* That screen offers 6 categories: **Stays, Food, Activities, Events, Rides, Professional Services** (see `_roles` in `lib/src/authentication/presentation/pages/role_selection_screen.dart`, using ids `stays`, `food`, `activities`, `events`, `rides`, `professional-services`).

The new dashboard's header includes a **category-switcher dropdown** (currently showing "Stays" as a static label in the Flutter UI), implying a partner account can eventually hold **multiple approved categories** and switch between them.

Today, `userType` is a **single enum string** per user (`homestay-owner`, `restaurant-owner`, `artisan`, `fisherfolk`, `ngo`, `investor`, `tourist`, `trainer`, `verified-reporter`, etc. — see the Authentication & Authorization table). There is no concept of a partner holding more than one category/role at once, nor an application/approval flow for additional categories.

**Needed** (flagging as an open design question — not a fully specified endpoint):
- `GET /api/v1/users/me/categories` — list a partner's approved categories, to populate the dashboard dropdown.
- An application + admin-approval flow for requesting an additional category, mirroring the existing homestay verification approve/reject pattern (`Admin Module`, section 6).
- **Naming mismatch to resolve**: the category ids used by the onboarding screen (`stays`, `food`, `activities`, `events`, `rides`, `professional-services`) don't correspond 1:1 with the existing `userType` enum (`homestay-owner`, `restaurant-owner`, `artisan`, `fisherfolk`, ...). These two taxonomies need to be reconciled — either the onboarding category maps onto an existing `userType`, or `userType` needs to evolve into (or be joined by) a proper category system.

This is the largest and most architecturally significant item in this document; recommend a dedicated design discussion before implementation.

*Update*: the Account Console screen (§13) went ahead and built a concrete UI for this — "Unlocked Business Portals" (list with Active/Pending/Rejected badges) and an "Apply for New Category" form — against a Flutter-side proposal for the fields/endpoints involved. The open design questions above (especially the naming mismatch) are **still unresolved**; §13 documents what the client now assumes so backend/product can confirm or correct it.

---

## 10. "My Homestays" is scoped to active-only listings (likely bug)

The Flutter app's `GetHomestaysByOwnerEvent` (used to compute the Active/Pending Listings stats) does **not** call a dedicated "my homestays" endpoint. It calls the public listing endpoint with an **undocumented** `ownerId` query param:

```
GET /api/v1/homestays?ownerId={ownerId}
```
(`lib/src/homestay/data/datasources/homestay_owner_remote_data_source.dart:102-109`)

Per `Complete_API_Documentation.md`'s own spec for `GET /api/v1/homestays`, the `status` query param **defaults to `active`** when omitted, and the call site never passes `status`. This means:
- `ownerId` isn't documented as a supported filter on this endpoint at all (may work by accident, or may not be supported server-side — please confirm).
- Any of the owner's own homestays that are `pending-verification` or `inactive` are likely **silently excluded** from their own dashboard, since the endpoint defaults to active-only. This directly undermines the new "Pending Listings" stat (#1) — an owner would never see their own pending listings.

**Needed**: either a dedicated `GET /api/v1/homestays/my` (or `/owners/me/homestays`) endpoint that returns **all** of the authenticated owner's homestays regardless of status, or make `status` accept an explicit override (e.g. `status=all`) when `ownerId` matches the authenticated user.

**Also worth checking**: there's an existing, currently-unused code path in the same file — `getOwnerDashboard()` (`homestay_owner_remote_data_source.dart:265-267`) — which calls `GET /api/v1/owners/{ownerId}/dashboard`. This isn't documented in `Complete_API_Documentation.md` either, but it's plausible this endpoint was already built (or stubbed) specifically to power an owner dashboard summary. Worth checking whether it already returns some/all of the fields requested in #1 before building a new endpoint from scratch.

**Minor, unrelated observation**: the restaurant module's equivalent call uses a different path shape and API prefix — `GET /api/restaurants/owner/{ownerId}` (`lib/src/food_culinary/data/datasources/restaurant_owner_remote_data_source.dart:133-137`) — versus the homestay module's `/api/v1/homestays/...`. Flagging this prefix/versioning inconsistency (`/api/restaurants` vs `/api/v1/homestays`) in case it's not intentional.

---

## 11. Booking status transitions used by the Bookings Hub (needs product/backend confirmation)

The Bookings Hub screen (Figma nodes `819:2175` "Enquiries Screen" / `819:1600` "Bookings Hub") reuses the **existing** `Booking` entity/status enum end-to-end — no new backend work was strictly required to ship the UI, because `updateBookingStatus(bookingId, status)` was already fully implemented (repository → datasource → `PATCH /api/v1/bookings/:id/status`, see `homestay_owner_remote_data_source.dart:236`) but had no usecase/bloc wiring calling it. That wiring now exists (`UpdateBookingStatus` usecase, `UpdateBookingStatusEvent` on `OwnerBookingsBloc`).

**What needs confirming**: the UI encodes a specific interpretation of the status enum as a two-stage enquiry→booking workflow, per §6 option (a):

| Booking.status | Enquiries tab | Bookings tab | Owner action available |
|---|---|---|---|
| `pending` | shown, badge "Pending" | — | Approve (→ `pending-payment`) / Reject (→ `cancelled`) |
| `pending-payment` | shown, badge "Approved" | — | "Confirm Booking" (→ `confirmed`) |
| `confirmed` / `checked-in` | — | shown, filtered by check-in date (Today's/Upcoming) | — |
| `checked-out` | — | shown, filter "Completed" | — |
| `cancelled` / `refunded` | — | shown, filter "Cancelled" | — |

This mapping was **invented on the Flutter side** to make the design's two-stage "Pending → Approved → Confirm Booking" enquiry flow work with the existing three-state `pending`/`pending-payment`/`confirmed` enum, since there's no dedicated "approved" status. Please confirm with product/backend whether this is the intended semantics of `pending-payment`, or whether it actually means something else (e.g. "guest is mid-checkout, awaiting their payment" rather than "owner approved, awaiting owner confirmation") — if the latter, the enquiry-approval step needs its own status value instead of reusing `pending-payment`.

**Also undocumented**: `PATCH /api/v1/bookings/:id/status` itself doesn't appear in `Complete_API_Documentation.md` at all, despite being implemented and now actively used. Worth adding it to the docs with its accepted `status` values and any server-side transition validation (e.g. can an owner move `checked-out` back to `pending`? Presumably not — but the client doesn't enforce this today).

*Flutter status*: fully wired — `lib/src/homestay/domain/usecases/update_booking_status.dart`, `OwnerBookingsBloc.UpdateBookingStatusEvent`. No mock/fallback; this hits the real endpoint.

---

## 12. Notifications Module — contract implemented, backend pending (extends §3)

The Notifications & Alerts screen (Figma node `819:1860`) is now built (`lib/src/notifications/`), coded against the endpoint contract proposed in §3. Concrete shapes used by the Flutter parser (`PartnerNotificationModel.fromMap`):

### `GET /api/v1/notifications`
```json
{
  "success": true,
  "notifications": [
    {
      "id": "string",
      "category": "announcement | alert",
      "title": "string",
      "message": "string",
      "createdAt": "ISO-8601 string",
      "isRead": "boolean"
    }
  ]
}
```
(The client also accepts a top-level `data` key instead of `notifications`, and `type`/`body`/`created_at`/`is_read` as fallback field names, for forward compatibility — but the shape above is the target.)

### `PATCH /api/v1/notifications/:id/read`
No body; 2xx with any/no payload is treated as success.

### `POST /api/v1/notifications/read-all`
No body; 2xx with any/no payload is treated as success.

**`category` values**: only `announcement` (megaphone icon) and `alert` (bell icon) are used by the two sample notifications in the design. Confirm with product whether more categories are needed (e.g. `booking`, `review`, `payout`) before backend implementation — the Flutter enum (`NotificationCategory`) can be extended trivially once known.

**Temporary fallback (remove once the endpoint ships)**: since none of the three endpoints exist on the backend yet, `NotificationsRepositoryImpl.getNotifications()` catches the resulting `ApiException` and returns two starter/onboarding notifications instead of an error screen (mirrors the existing profile-completion-percent fallback pattern, §8). This is clearly commented in `lib/src/notifications/data/repositories/notifications_repository_impl.dart` with a pointer back to this section — delete the fallback and let the exception propagate once the real endpoint is live. `markNotificationAsRead`/`markAllNotificationsAsRead` do **not** have a fallback — they'll surface a normal error (logged, non-blocking) until the backend exists.

**Not yet addressed**: push-notification delivery (device token registration) — still an open question from §3, unaffected by this frontend work.

*Flutter status*: full Clean Architecture stack in place (`domain/`, `data/`, `presentation/bloc/`), wired to DI (`injection_container.dart`) and routed at `/notifications`. Reachable from the Notifications tab in the bottom nav on both the Dashboard and the Bookings Hub.

---

## 13. Account Console / Edit Profile / Apply for New Category (new + extend)

Three screens, one connected feature: the Account tab now shows a consolidated **Business Profile** (Figma node `819:2377`), which links out to **Edit Profile** (`819:2678`) and **Apply for New Category** (`819:2619`). Together they're the first real UI for multi-category partner accounts (gap #9). None of the fields/endpoints below exist on the backend yet — everything is coded against a proposed contract and gracefully degrades (placeholder text, disabled affordances) until it ships.

Flutter-side, `LocalUser` (`lib/src/authentication/domain/entities/user.dart`) was extended with nullable fields for all of this rather than inventing a parallel "business profile" model, since it's still fundamentally "data about the current partner." `LocalUserModel.fromMap`/`toMap` parse/serialize them leniently — absent fields just stay `null` and the UI shows a "Not provided"/"Not set" placeholder (same pattern as the existing profile-completion-percent fallback, §8).

### 13a. Extend `GET /api/v1/users/me`

Add these fields to the existing response (documented today with only `id`, `firebaseUid`, `fullName`, `email`, `phone`, `userType`, `district`, `taluka`, `isVerified`, `status`, `dashboard`):

```json
{
  "partnerId": "string, e.g. 'SAM-2026-RTN-098' — human-readable partner identifier",
  "organizationName": "string (already accepted elsewhere but not documented on this response)",
  "aboutBusiness": "string — free-text business description",
  "address": "string — detailed street-level address (distinct from district/taluka/village, which already exist)",
  "village": "string (already parsed client-side, not in the documented response)",
  "state": "string (already parsed client-side, not in the documented response)",
  "coverPhotoUrl": "string (URL)",
  "profilePic": "string (URL) — already parsed client-side, not in the documented response",
  "bankName": "string",
  "bankAccountNumber": "string",
  "bankIfscCode": "string",
  "bankUpiId": "string",
  "categories": [
    { "categoryId": "string, one of stays|food|activities|events|rides|professional-services", "label": "string", "status": "active|pending|rejected" }
  ]
}
```

Note several of these (`organizationName`, `village`, `state`, `verificationStatus`, `aadharVerificationStatus`, `profilePic`) are **already parsed** by `LocalUserModel.fromMap` today even though `Complete_API_Documentation.md`'s response sample for this endpoint doesn't list them — worth reconciling the docs with actual server behavior regardless of the new fields above.

### 13b. Extend `PATCH /api/v1/users/me`

Documented today as accepting only `full_name` and `phone`. The Edit Profile screen (`819:2678`) needs it to also accept:

```json
{
  "full_name": "string (optional)",
  "phone": "string (optional)",
  "organizationName": "string (optional)",
  "profilePic": "string, URL (optional)",
  "coverPhotoUrl": "string, URL (optional)",
  "aboutBusiness": "string (optional)",
  "address": "string (optional)"
}
```

*Flutter status*: `UpdateUserProfile` usecase (`lib/src/profile/domain/usecases/update_user_profile.dart`) sends exactly this shape today via `UserProfileRemoteDataSourceImpl.updateUserProfile`. Since the backend currently only honors `full_name`, saving from Edit Profile will silently no-op on every other field until this ships — the client re-fetches `GET /users/me` after saving rather than trusting the PATCH response's partial echo, so it'll reflect reality either way.

**Note**: the Edit Profile form doesn't expose `phone` (Figma doesn't show it there), even though the backend already accepts it — not a gap, just unused today.

### 13c. New: `POST /api/v1/partners/category-applications` (Apply for New Category, node `819:2619`)

**Request Body**:
```json
{
  "categoryId": "string, one of stays|food|activities|events|rides|professional-services",
  "registrationNumber": "string — local trade license / RTO permit / DOT registration number",
  "description": "string — business setup, experience, capacity, assets",
  "documentUrl": "string, URL (optional) — supporting document"
}
```

**Expected behavior**: creates a `pending` entry in the partner's `categories` list (13a), presumably surfaced to an admin for approval — mirroring the existing homestay-verification approve/reject pattern (`Admin Module`, section 6). No response shape assumed by the client beyond success/failure.

**Document upload**: the client currently uploads the picked file **directly to Firebase Storage** (`FirebaseStorageService.uploadImage`, folder `category-applications/{uid}`) and sends the resulting download URL as `documentUrl` — the same approach already used for homestay images. Flagging for confirmation: is client-side-direct-to-Firebase-Storage the intended pattern for compliance documents too (vs. an authenticated upload endpoint that gives the backend a chance to validate/moderate before it's world-readable)? Worth a explicit decision given these are license/registration documents, not just marketing photos.

*Flutter status*: `ApplyForPartnerCategory` usecase + `ApplyForCategoryPage` (`lib/src/profile/presentation/pages/apply_for_category_page.dart`). The category dropdown excludes categories already `active` on the account (best-effort, client-side only — the backend should also reject a duplicate/overlapping application).

### 13d. New: bank settlement update endpoint

Figma's "Direct Bank Settlements" section (node `819:2377`, Section 4) states explicitly: *"Samudrayan does not process payments directly on the platform... Please enter your bank account details below to share them with tourists for direct bank transfers/UPI."* This is a wholly new concept with no existing backend support.

**Proposed**: `PATCH /api/v1/users/me/bank-settlement`
```json
{ "bankName": "string", "accountNumber": "string", "ifscCode": "string", "upiId": "string" }
```
Returns the updated user (same shape as 13a) or at minimum a success/failure signal.

**Security note for backend**: since these values are displayed to tourists (not just the owner), confirm whether they need masking/partial-redaction anywhere else `GET /users/me`-shaped data is exposed to non-owner callers (e.g. a public partner-profile endpoint, if one exists or is planned) — bank account numbers probably shouldn't be world-readable even if UPI IDs are intended to be shown to guests.

*Flutter status*: `UpdateBankSettlement` usecase, invoked from a bottom-sheet form on the Account Console (pencil icon next to "Direct Tourist Bank Transfers"). Fields render as "Not set" placeholders until populated.

### 13e. Naming mismatch (carried over from gap #9, still open)

The `categoryId` values above (`stays`, `food`, `activities`, `events`, `rides`, `professional-services` — see `lib/core/common/partner_categories.dart`) still don't correspond 1:1 with the `userType` enum (`homestay-owner`, `restaurant-owner`, ...). The Account Console's "Unlocked Business Portals" list falls back to a **client-side guess** when the backend doesn't return a `categories` array yet: `kUserTypeToPrimaryCategoryId` in `partner_categories.dart` currently only maps `homestay-owner → stays` and `restaurant-owner → food`; every other `userType` renders an empty portals list. This mapping needs to be resolved server-side (either `categories` always comes back populated, or the taxonomies get unified) rather than guessed client-side long-term.

---

## Appendix: What already works (no backend changes needed)

- Greeting name → `fullName` from `GET /api/v1/users/me`.
- Active/Pending listing counts are computable today from the existing owner-homestays data (see note in #1) for a single-category homestay-owner.
- `isVerified` boolean is already documented on the login response (partial — see #7 for cross-partner-type gaps).
