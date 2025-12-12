
# Admin APIs
## Homestay Verification
### 1. GET /api/admin/verifications/pending
Get pending verifications with filtering and pagination

### 2. GET /api/admin/verifications/:id
Get detailed homestay info for verification

### 3. POST /api/admin/verifications/:id/approve
Approve homestay verification

### 4. POST /api/admin/verifications/:id/reject
Reject homestay verification


- POST /api/verification/aadhar/verify - Submit Aadhar for verification
- GET /api/verification/aadhar/status - Check verification status
- POST /api/verification/aadhar/retry - Retry failed verification
- POST /api/verification/aadhar/upload-document - Upload documents
- GET /api/verification/aadhar/history - View verification history

4. Admin Management (src/interfaces/routes/admin.js)

- GET /api/admin/verifications/aadhar/pending - View pending verifications
- POST /api/admin/verifications/aadhar/:userId/approve - Manual approval
- POST /api/admin/verifications/aadhar/:userId/reject - Manual rejection
- GET /api/admin/verifications/aadhar/statistics - Analytics dashboard