const express = require('express');
const { verifyJWT } = require('../middleware/auth');
const UserRepository = require('../../domain/repositories/UserRepository');
const BookingRepository = require('../../domain/repositories/BookingRepository');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();
const userRepository = new UserRepository();
const bookingRepository = new BookingRepository();

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

    res.json({
      success: true,
      data: {
        id: user.id,
        firebaseUid: user.firebase_uid,
        fullName: user.full_name,
        email: user.email,
        phone: user.phone,
        userType: user.role || user.user_type,
        // roles: [user.role || user.user_type],
        district: user.district,
        taluka: user.taluka,
        isVerified: user.is_verified,
        status: user.status,
        aadharVerificationStatus: user.aadhar_verification_status,
        dashboard: dashboards[user.role] || [],
      },
    });
  } catch (error) {
    next(error);
  }
});

router.patch('/me', verifyJWT, async (req, res, next) => {
  try {
    const allowedUpdates = ['full_name', 'phone'];
    const updates = {};
    
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.includes(key) && req.body[key] !== undefined) {
        updates[key] = req.body[key];
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
          phone: updatedUser.phone
        }
      },
    });
  } catch (error) {
    next(error);
  }
});

router.get('/me/bookings', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const { status, dateFrom, dateTo, page = 1, limit = 20 } = req.query;
    
    const filters = {
      status,
      dateFrom,
      dateTo,
      page: parseInt(page),
      limit: parseInt(limit)
    };

    const result = await bookingRepository.getBookingsByUserId(user.id, filters);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;