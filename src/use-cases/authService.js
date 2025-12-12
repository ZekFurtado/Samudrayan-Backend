const jwt = require('jsonwebtoken');
const admin = require('../../config/firebase');
const UserRepository = require('../domain/repositories/UserRepository');
const { AppError } = require('../interfaces/middleware/errorHandler');

class AuthService {
  constructor() {
    this.userRepository = new UserRepository();
  }

  generateTokens(user) {
    const payload = {
      uid: user.firebase_uid,
      userId: user.id,
      email: user.email,
      userType: user.role,
      district: user.district,
      taluka: user.taluka,
      isVerified: user.is_verified
    };

    const accessToken = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { 
        expiresIn: process.env.JWT_EXPIRES_IN || '24h',
        issuer: 'samudrayan-backend',
        audience: 'samudrayan-app'
      }
    );

    const refreshToken = jwt.sign(
      { uid: user.firebase_uid, userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { 
        expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
        issuer: 'samudrayan-backend',
        audience: 'samudrayan-app'
      }
    );

    return { accessToken, refreshToken };
  }

  async loginWithFirebaseUid(firebaseUid) {
    try {
      // Verify Firebase token is valid by checking Firebase auth
      const firebaseUser = await admin.auth().getUser(firebaseUid);

      // Find user in our database
      let user = await this.userRepository.findByFirebaseUid(firebaseUid);
      
      if (!user) {
        // Auto-create user with Firebase data if they don't exist in our database
        user = await this.userRepository.create({
          firebaseUid: firebaseUid,
          fullName: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || 'User',
          email: firebaseUser.email || `${firebaseUid}@placeholder.com`,
          phone: firebaseUser.phoneNumber || null,
          userType: 'tourist', // Default user type
          district: 'Unknown',
          taluka: 'Unknown'
        });
      }

      // Generate JWT tokens
      const tokens = this.generateTokens(user);

      return {
        user: {
          id: user.id,
          firebaseUid: user.firebase_uid,
          fullName: user.full_name,
          email: user.email,
          userType: user.role,
          district: user.district,
          taluka: user.taluka,
          isVerified: user.is_verified,
          roles: [user.role]
        },
        tokens
      };
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      
      // Handle Firebase auth errors
      if (error.code === 'auth/user-not-found') {
        throw new AppError('Invalid Firebase UID', 401, 'INVALID_FIREBASE_UID');
      }
      
      throw new AppError('Authentication failed', 500, 'AUTH_FAILED');
    }
  }

  async registerUser(userData) {
    try {
      // Check if user already exists in database
      const existingUser = await this.userRepository.findByFirebaseUid(userData.uid);
      if (existingUser) {
        throw new AppError('User already registered', 409, 'USER_EXISTS');
      }

      // If user not in database, verify Firebase UID exists and get Firebase user info
      const isDevelopmentTestUID = process.env.NODE_ENV === 'development' && userData.uid.startsWith('test-');
      let firebaseUser = null;
      
      if (!isDevelopmentTestUID) {
        try {
          firebaseUser = await admin.auth().getUser(userData.uid);
        } catch (firebaseError) {
          if (firebaseError.code === 'auth/user-not-found') {
            throw new AppError('Firebase UID does not exist', 400, 'INVALID_FIREBASE_UID');
          }
          throw firebaseError;
        }
      }

      // Check if email is already used
      const existingEmail = await this.userRepository.findByEmail(userData.email);
      if (existingEmail) {
        throw new AppError('Email already in use', 409, 'EMAIL_EXISTS');
      }

      // Check if phone is already used
      const existingPhone = await this.userRepository.findByPhone(userData.phone);
      if (existingPhone) {
        throw new AppError('Phone number already in use', 409, 'PHONE_EXISTS');
      }

      // Since Firebase UID is verified to exist, create new user in database
      const newUser = await this.userRepository.create({
        firebaseUid: userData.uid,
        fullName: userData.fullName,
        email: userData.email,
        phone: userData.phone,
        userType: userData.userType,
        district: userData.district,
        taluka: userData.taluka
      });

      return {
        id: newUser.id,
        firebaseUid: newUser.firebase_uid,
        fullName: newUser.full_name,
        email: newUser.email,
        userType: newUser.role,
        district: newUser.district,
        taluka: newUser.taluka
      };
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      
      if (error.code === 'auth/user-not-found') {
        throw new AppError('Invalid Firebase UID', 400, 'INVALID_FIREBASE_UID');
      }
      
      // Log the actual error for debugging
      console.error('Registration error details:', {
        message: error.message,
        code: error.code,
        stack: error.stack,
        detail: error.detail
      });
      
      // Check for specific database errors
      if (error.code === '23505') {
        throw new AppError('User already exists with this information', 409, 'DUPLICATE_USER');
      }
      
      if (error.code === '42703') {
        throw new AppError('Database schema error', 500, 'SCHEMA_ERROR');
      }
      
      throw new AppError(`Registration failed: ${error.message}`, 500, 'REGISTRATION_FAILED');
    }
  }

  async refreshAccessToken(refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      
      const user = await this.userRepository.findByFirebaseUid(decoded.uid);
      if (!user) {
        throw new AppError('User not found', 404, 'USER_NOT_FOUND');
      }


      const tokens = this.generateTokens(user);
      return { accessToken: tokens.accessToken };
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      
      throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH_TOKEN');
    }
  }
}

module.exports = AuthService;