const jwt = require('jsonwebtoken');
const admin = require('../../../config/firebase');
const { AppError } = require('./errorHandler');

const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new AppError('No token provided', 401, 'NO_TOKEN'));
    }

    const token = authHeader.split(' ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
    };

    next();
  } catch (error) {
    return next(new AppError('Invalid or expired token', 401, 'INVALID_TOKEN'));
  }
};

const verifyJWT = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new AppError('No token provided', 401, 'NO_TOKEN'));
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    req.user = decoded;
    next();
  } catch (error) {
    return next(new AppError('Invalid or expired token', 401, 'INVALID_TOKEN'));
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AppError('Access denied. Not authenticated', 401, 'NOT_AUTHENTICATED'));
    }

    if (!roles.includes(req.user.userType)) {
      return next(new AppError('Access denied. Insufficient permissions', 403, 'INSUFFICIENT_PERMISSIONS'));
    }

    next();
  };
};

module.exports = {
  verifyFirebaseToken,
  verifyJWT,
  authorize,
};