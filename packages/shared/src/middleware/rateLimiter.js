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

const verificationLimiter = rateLimit({
  windowMs: 24 * 60 * 60 * 1000,
  max: 3,
  message: {
    success: false,
    error: {
      code: 'VERIFICATION_RATE_LIMIT_EXCEEDED',
      message: 'Maximum verification attempts exceeded for today. Please try again tomorrow.',
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.user?.userId || req.user?.uid || rateLimit.ipKeyGenerator(req),
  skip: (req) => req.user?.userType === 'admin',
});

module.exports = {
  createRateLimiter,
  authLimiter,
  apiLimiter,
  strictLimiter,
  verificationLimiter,
};
