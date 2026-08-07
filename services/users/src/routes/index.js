const express = require('express');
const shared = require('@samudrayan/shared');
const { middleware, computeProfileCompletion, partnerCategories } = shared;
const { verifyJWT } = middleware;
const UserRepository = require('../repositories/UserRepository');
const { AppError } = middleware;

const router = express.Router();
const userRepository = new UserRepository();

function serializeCategories(categories) {
  return categories.map((c) => ({
    categoryId: c.category_id,
    label: partnerCategories.PARTNER_CATEGORY_LABELS[c.category_id] || c.category_id,
    status: c.status,
  }));
}

router.get('/me', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);

    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const dashboards = {
      'homestay-owner': ['my-homestays', 'my-bookings', 'training', 'csr-projects'],
      'fisherfolk': ['marketplace', 'training', 'blue-economy'],
      'artisan': ['marketplace', 'training', 'csr-projects'],
      'tourist': ['homestays', 'events', 'marketplace'],
      'admin': ['all-users', 'homestays', 'events', 'analytics'],
      'district-admin': ['district-users', 'district-homestays', 'events'],
      'taluka-admin': ['taluka-users', 'taluka-homestays', 'events'],
      'ngo': ['csr-projects', 'training', 'events'],
      'investor': ['csr-projects', 'blue-economy', 'analytics'],
      'trainer': ['training-programs', 'participants']
    };

    const categories = await userRepository.getPartnerCategories(user.id);

    res.json({
      success: true,
      data: {
        id: user.id,
        firebaseUid: user.firebase_uid,
        fullName: user.full_name,
        email: user.email,
        phone: user.phone,
        userType: user.role || user.user_type,
        district: user.district,
        taluka: user.taluka,
        village: user.village,
        state: user.state,
        isVerified: user.is_verified,
        status: user.status,
        aadharVerificationStatus: user.aadhar_verification_status,
        dashboard: dashboards[user.role] || [],
        partnerId: user.partner_id,
        organizationName: user.organization_name,
        aboutBusiness: user.about_business,
        address: user.address,
        profilePic: user.profile_pic,
        coverPhotoUrl: user.cover_photo_url,
        bankName: user.bank_name,
        bankAccountNumber: user.bank_account_number,
        bankIfscCode: user.bank_ifsc_code,
        bankUpiId: user.bank_upi_id,
        categories: serializeCategories(categories),
        profileCompletionPercent: computeProfileCompletion(user),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Maps the request-body keys the Flutter client sends (mostly camelCase,
// full_name/phone stay snake_case for backwards compatibility with the
// already-documented contract) onto their users-table column names.
const PATCH_ME_FIELD_MAP = {
  full_name: 'full_name',
  phone: 'phone',
  organizationName: 'organization_name',
  profilePic: 'profile_pic',
  coverPhotoUrl: 'cover_photo_url',
  aboutBusiness: 'about_business',
  address: 'address',
};

router.patch('/me', verifyJWT, async (req, res, next) => {
  try {
    const updates = {};

    Object.keys(req.body).forEach(key => {
      const dbKey = PATCH_ME_FIELD_MAP[key];
      if (dbKey && req.body[key] !== undefined) {
        updates[dbKey] = req.body[key];
      }
    });

    if (Object.keys(updates).length === 0) {
      return next(new AppError('No valid fields to update', 400, 'NO_VALID_UPDATES'));
    }

    const updatedUser = await userRepository.update(req.user.uid, updates);

    res.json({
      success: true,
      data: {
        message: 'Profile updated successfully',
        user: {
          id: updatedUser.id,
          fullName: updatedUser.full_name,
          phone: updatedUser.phone,
          organizationName: updatedUser.organization_name,
          profilePic: updatedUser.profile_pic,
          coverPhotoUrl: updatedUser.cover_photo_url,
          aboutBusiness: updatedUser.about_business,
          address: updatedUser.address,
        }
      },
    });
  } catch (error) {
    next(error);
  }
});

router.patch('/me/bank-settlement', verifyJWT, async (req, res, next) => {
  try {
    const { bankName, accountNumber, ifscCode, upiId } = req.body;

    if (!bankName || !accountNumber || !ifscCode || !upiId) {
      return next(new AppError(
        'bankName, accountNumber, ifscCode, and upiId are all required',
        400,
        'VALIDATION_ERROR'
      ));
    }

    const updatedUser = await userRepository.update(req.user.uid, {
      bank_name: bankName,
      bank_account_number: accountNumber,
      bank_ifsc_code: ifscCode,
      bank_upi_id: upiId,
    });

    res.json({
      success: true,
      data: {
        message: 'Bank settlement details updated successfully',
        bankName: updatedUser.bank_name,
        bankAccountNumber: updatedUser.bank_account_number,
        bankIfscCode: updatedUser.bank_ifsc_code,
        bankUpiId: updatedUser.bank_upi_id,
      },
    });
  } catch (error) {
    next(error);
  }
});

router.post('/me/device-tokens', verifyJWT, async (req, res, next) => {
  try {
    const { token, platform } = req.body;

    if (!token) {
      return next(new AppError('token is required', 400, 'VALIDATION_ERROR'));
    }
    if (platform && !['android', 'ios', 'web'].includes(platform)) {
      return next(new AppError('platform must be one of android|ios|web', 400, 'VALIDATION_ERROR'));
    }

    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    await userRepository.upsertDeviceToken(user.id, token, platform);

    res.json({
      success: true,
      data: { message: 'Device token registered' },
    });
  } catch (error) {
    next(error);
  }
});

// NOTE: the former GET /me/bookings endpoint now lives on the booking service
// as GET /api/v1/homestays/bookings/me (see services/booking/src/routes/index.js)
// since bookings are booking-service's owned data, not users-service's.

module.exports = router;
