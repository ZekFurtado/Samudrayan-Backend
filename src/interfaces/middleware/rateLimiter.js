// RATE LIMITING TEMPORARILY DISABLED - TO BE IMPLEMENTED LATER
/*
const rateLimit = require('express-rate-limit');

const createRateLimiter = (windowMs = 15 * 60 * 1000, max = 100) => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      error: {
        code: 'RATE_LIMIT_EXCEEDED',
        message: 'Too many requests from this IP, please try again later.',
      },
    },
    standardHeaders: true,
    legacyHeaders: false,
  });
};

const authLimiter = createRateLimiter(15 * 60 * 1000, 5);
const apiLimiter = createRateLimiter(15 * 60 * 1000, 100);
const strictLimiter = createRateLimiter(15 * 60 * 1000, 10);

// Special rate limiter for Aadhar verification - very strict
const verificationLimiter = rateLimit({
  windowMs: 24 * 60 * 60 * 1000, // 24 hours
  max: 3, // Maximum 3 attempts per day
  message: {
    success: false,
    error: {
      code: 'VERIFICATION_RATE_LIMIT_EXCEEDED',
      message: 'Maximum verification attempts exceeded for today. Please try again tomorrow.',
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => {
    const rateLimit = require('express-rate-limit');
    // Use user ID instead of IP for verification rate limiting
    return req.user?.userId || req.user?.uid || rateLimit.ipKeyGenerator(req);
  },
  skip: (req) => {
    // Skip rate limiting for admin users
    return req.user?.userType === 'admin';
  }
});
*/

// Dummy middleware functions to replace rate limiters
const createRateLimiter = () => (req, res, next) => next();
const authLimiter = (req, res, next) => next();
const apiLimiter = (req, res, next) => next();
const strictLimiter = (req, res, next) => next();
const verificationLimiter = (req, res, next) => next();

module.exports = {
  createRateLimiter,
  authLimiter,
  apiLimiter,
  strictLimiter,
  verificationLimiter,
};