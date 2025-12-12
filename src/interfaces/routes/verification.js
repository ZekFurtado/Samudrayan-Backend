const express = require('express');
const multer = require('multer');
const { verifyJWT, authorize } = require('../middleware/auth');
// RATE LIMITING TEMPORARILY DISABLED
// const { verificationLimiter, strictLimiter } = require('../middleware/rateLimiter');
const { body, validationResult } = require('express-validator');
const AadharVerificationService = require('../../services/aadharVerificationService');
const logger = require('../../../config/logger');

const router = express.Router();

// Initialize verification service
const verificationService = new AadharVerificationService();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept only image and PDF files
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPEG, PNG, and PDF files are allowed'), false);
    }
  }
});

// Validation middleware for Aadhar number
const validateAadharNumber = [
  body('aadharNumber')
    .isLength({ min: 12, max: 12 })
    .withMessage('Aadhar number must be 12 digits')
    .isNumeric()
    .withMessage('Aadhar number must contain only digits')
    .custom((value) => {
      // Basic format validation
      if (!/^\d{12}$/.test(value)) {
        throw new Error('Invalid Aadhar number format');
      }
      return true;
    })
];

// Start Aadhar verification process
router.post('/aadhar/verify', 
  verifyJWT, 
  authorize('homestay-owner', 'admin'),
  // verificationLimiter, // Rate limiting for verification attempts - TEMPORARILY DISABLED
  upload.single('document'),
  validateAadharNumber,
  async (req, res, next) => {
    try {
      // Check validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid input data',
            details: errors.array()
          }
        });
      }

      const { aadharNumber } = req.body;
      const documentFile = req.file;
      const userId = req.user.userId;
      const ipAddress = req.ip || req.connection.remoteAddress;
      const userAgent = req.get('User-Agent');

      // TODO: Re-enable rate limiting - max 3 attempts per day
      // const today = new Date();
      // today.setHours(0, 0, 0, 0);
      // 
      // const attemptsQuery = `
      //   SELECT COUNT(*) as attempt_count 
      //   FROM aadhar_verification_logs 
      //   WHERE user_id = $1::uuid AND created_at >= $2
      // `;
      // 
      // const attemptsResult = await verificationService.pool.query(attemptsQuery, [userId, today]);
      // const todayAttempts = parseInt(attemptsResult.rows[0].attempt_count);

      // if (todayAttempts >= 3) {
      //   return res.status(429).json({
      //     success: false,
      //     error: {
      //       code: 'RATE_LIMIT_EXCEEDED',
      //       message: 'Maximum verification attempts exceeded for today. Please try again tomorrow.'
      //     }
      //   });
      // }

      // Check if document is provided for better verification
      if (!documentFile) {
        logger.warn(`Aadhar verification attempted without document upload by user ${userId}`);
      }

      // Start verification process
      const verificationResult = await verificationService.verifyAadhar(
        userId,
        aadharNumber,
        documentFile,
        ipAddress,
        userAgent
      );

      res.json({
        success: true,
        data: {
          verificationStatus: 'verified',
          method: verificationResult.method,
          referenceId: verificationResult.referenceId,
          message: verificationResult.message,
          verifiedAt: new Date().toISOString()
        }
      });

      // Log successful verification
      logger.info(`Aadhar verification successful for user ${userId} via ${verificationResult.method}`);

    } catch (error) {
      logger.error('Aadhar verification error:', error);

      // Handle specific error types
      if (error.message.includes('already verified')) {
        return res.status(409).json({
          success: false,
          error: {
            code: 'ALREADY_VERIFIED',
            message: error.message
          }
        });
      }

      if (error.message.includes('Invalid Aadhar')) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_AADHAR',
            message: error.message
          }
        });
      }

      if (error.message.includes('API')) {
        return res.status(503).json({
          success: false,
          error: {
            code: 'SERVICE_UNAVAILABLE',
            message: 'Verification service temporarily unavailable. Please try again later.'
          }
        });
      }

      res.status(500).json({
        success: false,
        error: {
          code: 'VERIFICATION_FAILED',
          message: 'Aadhar verification failed. Please check your details and try again.'
        }
      });
    }
  }
);

// Get verification status
router.get('/aadhar/status', verifyJWT, async (req, res, next) => {
  try {
    const userId = req.user.uid;
    
    const status = await verificationService.getVerificationStatus(userId);
    
    res.json({
      success: true,
      data: {
        verificationStatus: status.aadhar_verification_status,
        verificationMethod: status.verification_method,
        verifiedAt: status.aadhar_verified_at,
        attempts: status.verification_attempts,
        lastAttempt: status.last_verification_attempt,
        failureReason: status.verification_failure_reason,
        referenceId: status.verification_reference_id
      }
    });

  } catch (error) {
    logger.error('Error fetching verification status:', error);
    next(error);
  }
});

// Get verification history
router.get('/aadhar/history', verifyJWT, async (req, res, next) => {
  try {
    const userId = req.user.uid;
    
    const history = await verificationService.getVerificationHistory(userId);
    
    const formattedHistory = history.map(record => ({
      method: record.verification_type,
      status: record.status,
      errorMessage: record.error_message,
      attemptedAt: record.created_at
    }));

    res.json({
      success: true,
      data: {
        verificationHistory: formattedHistory,
        totalAttempts: formattedHistory.length
      }
    });

  } catch (error) {
    logger.error('Error fetching verification history:', error);
    next(error);
  }
});

// Retry verification (for failed attempts)
router.post('/aadhar/retry', 
  verifyJWT, 
  authorize('homestay-owner', 'admin'),
  // verificationLimiter, // Rate limiting for retry attempts - TEMPORARILY DISABLED
  upload.single('document'),
  validateAadharNumber,
  async (req, res, next) => {
    try {
      // Check validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid input data',
            details: errors.array()
          }
        });
      }

      const { aadharNumber } = req.body;
      const documentFile = req.file;
      const userId = req.user.userId;
      const ipAddress = req.ip || req.connection.remoteAddress;
      const userAgent = req.get('User-Agent');

      // Check current verification status
      const currentStatus = await verificationService.getVerificationStatus(userId);
      
      if (currentStatus.aadhar_verification_status === 'verified') {
        return res.status(409).json({
          success: false,
          error: {
            code: 'ALREADY_VERIFIED',
            message: 'Aadhar is already verified'
          }
        });
      }

      if (currentStatus.aadhar_verification_status === 'in_progress') {
        return res.status(409).json({
          success: false,
          error: {
            code: 'VERIFICATION_IN_PROGRESS',
            message: 'Verification is already in progress. Please wait.'
          }
        });
      }

      // TODO: Re-enable rate limiting - max 3 retries per day
      // const today = new Date();
      // today.setHours(0, 0, 0, 0);
      // 
      // const retriesQuery = `
      //   SELECT COUNT(*) as retry_count 
      //   FROM aadhar_verification_logs 
      //   WHERE user_id = $1::uuid AND created_at >= $2 AND status = 'failed'
      // `;
      // 
      // const retriesResult = await verificationService.pool.query(retriesQuery, [userId, today]);
      // const todayRetries = parseInt(retriesResult.rows[0].retry_count);

      // if (todayRetries >= 3) {
      //   return res.status(429).json({
      //     success: false,
      //     error: {
      //       code: 'RETRY_LIMIT_EXCEEDED',
      //       message: 'Maximum retry attempts exceeded for today. Please try again tomorrow.'
      //     }
      //   });
      // }

      // Start retry verification process
      const verificationResult = await verificationService.verifyAadhar(
        userId,
        aadharNumber,
        documentFile,
        ipAddress,
        userAgent
      );

      res.json({
        success: true,
        data: {
          verificationStatus: 'verified',
          method: verificationResult.method,
          referenceId: verificationResult.referenceId,
          message: verificationResult.message,
          verifiedAt: new Date().toISOString(),
          retryAttempt: true
        }
      });

      // Log successful retry
      logger.info(`Aadhar verification retry successful for user ${userId} via ${verificationResult.method}`);

    } catch (error) {
      logger.error('Aadhar verification retry error:', error);
      
      res.status(500).json({
        success: false,
        error: {
          code: 'RETRY_FAILED',
          message: 'Verification retry failed. Please contact support if the issue persists.'
        }
      });
    }
  }
);

// Upload document for verification (separate endpoint)
router.post('/aadhar/upload-document', 
  verifyJWT,
  authorize('homestay-owner', 'admin'),
  // strictLimiter, // Moderate rate limiting for document uploads - TEMPORARILY DISABLED
  upload.single('document'),
  async (req, res, next) => {
    try {
      const documentFile = req.file;
      const userId = req.user.userId;

      if (!documentFile) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'NO_DOCUMENT',
            message: 'Please provide an Aadhar document image'
          }
        });
      }

      // Create uploads directory if it doesn't exist
      const fs = require('fs').promises;
      const path = require('path');
      
      const uploadsDir = path.join(__dirname, '../../../uploads/aadhar');
      await fs.mkdir(uploadsDir, { recursive: true });
      
      // Generate unique filename
      const fileExtension = documentFile.originalname.split('.').pop();
      const fileName = `${userId}_${Date.now()}.${fileExtension}`;
      const filePath = path.join(uploadsDir, fileName);
      const documentUrl = `/uploads/aadhar/${fileName}`;
      
      // Save file to disk
      await fs.writeFile(filePath, documentFile.buffer);
      
      // Update user record with document URL
      await verificationService.pool.query(
        'UPDATE users SET aadhar_document_url = $1, updated_at = NOW() WHERE id = $2::uuid',
        [documentUrl, userId]
      );

      res.json({
        success: true,
        data: {
          documentUrl,
          message: 'Document uploaded successfully. You can now proceed with verification.'
        }
      });

    } catch (error) {
      logger.error('Document upload error:', error);
      next(error);
    }
  }
);

// Check Aadhar number availability (without storing)
router.post('/aadhar/check', 
  verifyJWT,
  validateAadharNumber,
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid Aadhar number format',
            details: errors.array()
          }
        });
      }

      const { aadharNumber } = req.body;

      // Basic validation only
      const isValidFormat = verificationService.validateAadharNumber(aadharNumber);
      const isValidChecksum = isValidFormat ? verificationService.validateAadharChecksum(aadharNumber) : false;

      res.json({
        success: true,
        data: {
          isValidFormat: isValidFormat,
          isValidChecksum: isValidChecksum,
          message: isValidFormat && isValidChecksum ? 'Aadhar number format and checksum are valid' : 
                   isValidFormat ? 'Aadhar number format is valid but checksum is invalid' :
                   'Invalid Aadhar number format'
        }
      });

    } catch (error) {
      logger.error('Aadhar check error:', error);
      next(error);
    }
  }
);

// Temporary endpoint for homestay owners to submit Aadhar for admin verification
// (bypassing UIDAI/Digilocker verification)
router.post('/aadhar/submit', 
  verifyJWT, 
  authorize('homestay-owner', 'admin'),
  // verificationLimiter, // TEMPORARILY DISABLED
  upload.single('document'),
  validateAadharNumber,
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid input data',
            details: errors.array()
          }
        });
      }

      const { aadharNumber } = req.body;
      const documentFile = req.file;
      const userId = req.user.uid;

      if (!documentFile) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'NO_DOCUMENT',
            message: 'Please provide an Aadhar document image'
          }
        });
      }

      // Get database connection
      const pool = require('../../../config/database');
      
      // Check if user already has a verification request
      const existingQuery = 'SELECT aadhar_verification_status FROM users WHERE firebase_uid = $1';
      const existingResult = await pool.query(existingQuery, [userId]);
      
      if (existingResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found'
          }
        });
      }

      const currentStatus = existingResult.rows[0].aadhar_verification_status;
      
      if (currentStatus === 'verified') {
        return res.status(409).json({
          success: false,
          error: {
            code: 'ALREADY_VERIFIED',
            message: 'Aadhar is already verified'
          }
        });
      }

      // Save document file
      const fs = require('fs').promises;
      const path = require('path');
      
      const uploadsDir = path.join(__dirname, '../../../uploads/aadhar');
      await fs.mkdir(uploadsDir, { recursive: true });
      
      const fileExtension = documentFile.originalname.split('.').pop();
      const fileName = `${userId}_${Date.now()}.${fileExtension}`;
      const filePath = path.join(uploadsDir, fileName);
      const documentUrl = `/uploads/aadhar/${fileName}`;
      
      await fs.writeFile(filePath, documentFile.buffer);

      // Update user record with Aadhar details and set status to pending
      const updateQuery = `
        UPDATE users 
        SET 
          aadhar_number_encrypted = $1,
          aadhar_document_url = $2,
          aadhar_verification_status = 'pending',
          last_verification_attempt = NOW(),
          updated_at = NOW()
        WHERE firebase_uid = $3
        RETURNING id, full_name, email
      `;

      const updateResult = await pool.query(updateQuery, [aadharNumber, documentUrl, userId]);
      const user = updateResult.rows[0];

      // Log the submission
      try {
        const logQuery = `
          INSERT INTO aadhar_verification_logs (
            user_id, verification_type, status, error_message, 
            request_data, ip_address, user_agent
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        `;

        await pool.query(logQuery, [
          user.id,
          'temporary_submission',
          'pending',
          null,
          JSON.stringify({ aadharNumber: aadharNumber.slice(-4), documentUrl }),
          req.ip,
          req.get('User-Agent')
        ]);
      } catch (logError) {
        console.log('Could not log verification attempt:', logError.message);
      }

      res.json({
        success: true,
        data: {
          verificationStatus: 'pending',
          message: 'Aadhar details submitted successfully. Your verification is pending admin review.',
          submittedAt: new Date().toISOString(),
          referenceId: `TEMP_${user.id}_${Date.now()}`
        }
      });

      logger.info(`Aadhar verification submitted for admin review by user ${userId}`);

    } catch (error) {
      logger.error('Aadhar submission error:', error);
      
      res.status(500).json({
        success: false,
        error: {
          code: 'SUBMISSION_FAILED',
          message: 'Failed to submit Aadhar for verification. Please try again.'
        }
      });
    }
  }
);

module.exports = router;