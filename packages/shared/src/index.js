const { verifyJWT, authorize } = require('./middleware/auth');
const { AppError, errorHandler } = require('./middleware/errorHandler');
const rateLimiter = require('./middleware/rateLimiter');
const { createLogger } = require('./config/logger');
const db = require('./config/db');
const { computeProfileCompletion } = require('./services/profileCompletion');
const partnerCategories = require('./constants/partnerCategories');

module.exports = {
  middleware: {
    verifyJWT,
    authorize,
    errorHandler,
    AppError,
    ...rateLimiter,
  },
  logger: createLogger(process.env.SERVICE_NAME || 'service'),
  db,
  computeProfileCompletion,
  partnerCategories,
};
