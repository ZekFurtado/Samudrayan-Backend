const express = require('express');
const { body, validationResult } = require('express-validator');
// RATE LIMITING TEMPORARILY DISABLED
// const { authLimiter } = require('../middleware/rateLimiter');
const AuthService = require('../../use-cases/authService');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();
const authService = new AuthService();

const validateRegister = [
  body('uid')
    .notEmpty()
    .withMessage('Firebase UID is required')
    .isLength({ min: 10 })
    .withMessage('Invalid Firebase UID format'),
  body('fullName')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Full name must be 2-50 characters')
    .matches(/^[a-zA-Z\s]+$/)
    .withMessage('Full name can only contain letters and spaces'),
  body('email')
    .isEmail()
    .withMessage('Valid email is required')
    .normalizeEmail(),
  body('phone')
    .optional()
    .matches(/^[6-9]\d{9}$/)
    .withMessage('Phone number must be a 10-digit Indian mobile number starting with 6-9'),
  body('userType')
    .isIn([
      'admin', 'district-admin', 'taluka-admin', 'homestay-owner', 
      'fisherfolk', 'artisan', 'ngo', 'investor', 'tourist', 'trainer'
    ])
    .withMessage('Valid user type is required'),
  body('district')
    .trim()
    .notEmpty()
    .withMessage('District is required')
    .isLength({ max: 100 })
    .withMessage('District name too long'),
  body('taluka')
    .trim()
    .notEmpty()
    .withMessage('Taluka is required')
    .isLength({ max: 100 })
    .withMessage('Taluka name too long'),
];

const validateLogin = [
  body('uid').notEmpty().withMessage('Firebase UID is required'),
];

const validateRefresh = [
  body('refreshToken').notEmpty().withMessage('Refresh token is required'),
];

router.post('/register', /* authLimiter, */ validateRegister, async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return next(new AppError('Validation failed', 400, 'VALIDATION_ERROR', errors.array()));
    }

    const userData = await authService.registerUser(req.body);
    
    res.status(201).json({
      success: true,
      data: {
        user: userData,
        requiresVerification: true,
        message: 'Registration successful. Please wait for verification.',
      },
    });
  } catch (error) {
    next(error);
  }
});

router.post('/login', /* authLimiter, */ validateLogin, async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return next(new AppError('Validation failed', 400, 'VALIDATION_ERROR', errors.array()));
    }

    const { uid } = req.body;
    const result = await authService.loginWithFirebaseUid(uid);
    
    res.json({
      success: true,
      data: {
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
        user: result.user,
      },
    });
  } catch (error) {
    next(error);
  }
});

router.post('/refresh', /* authLimiter, */ validateRefresh, async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return next(new AppError('Validation failed', 400, 'VALIDATION_ERROR', errors.array()));
    }

    const { refreshToken } = req.body;
    const result = await authService.refreshAccessToken(refreshToken);
    
    res.json({
      success: true,
      data: {
        accessToken: result.accessToken,
      },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;