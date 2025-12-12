const CryptoJS = require('crypto-js');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const FormData = require('form-data');
const xml2js = require('xml2js');
const QrCode = require('qrcode-reader');
const sharp = require('sharp');
const logger = require('../../config/logger');

class AadharVerificationService {
  constructor() {
    this.uidaiBaseUrl = process.env.UIDAI_BASE_URL || 'https://resident.uidai.gov.in/api';
    this.digilockerBaseUrl = process.env.DIGILOCKER_BASE_URL || 'https://api.digitallocker.gov.in/api';
    this.encryptionKey = process.env.AADHAR_ENCRYPTION_KEY || 'default-secret-key-change-in-production';
    this.uidaiLicenseKey = process.env.UIDAI_LICENSE_KEY;
    this.digilockerClientId = process.env.DIGILOCKER_CLIENT_ID;
    this.digilockerClientSecret = process.env.DIGILOCKER_CLIENT_SECRET;
    
    // Initialize database connection
    this.pool = require('../../config/database');
  }

  // Utility function to encrypt Aadhar number
  encryptAadhar(aadharNumber) {
    try {
      const encrypted = CryptoJS.AES.encrypt(aadharNumber.toString(), this.encryptionKey).toString();
      return encrypted;
    } catch (error) {
      logger.error('Error encrypting Aadhar number:', error);
      throw new Error('Encryption failed');
    }
  }

  // Utility function to decrypt Aadhar number
  decryptAadhar(encryptedAadhar) {
    try {
      const bytes = CryptoJS.AES.decrypt(encryptedAadhar, this.encryptionKey);
      const decrypted = bytes.toString(CryptoJS.enc.Utf8);
      return decrypted;
    } catch (error) {
      logger.error('Error decrypting Aadhar number:', error);
      throw new Error('Decryption failed');
    }
  }

  // Validate Aadhar number format
  validateAadharNumber(aadharNumber) {
    const aadharRegex = /^\d{12}$/;
    return aadharRegex.test(aadharNumber);
  }

  // Validate Aadhar checksum using Verhoeff algorithm
  validateAadharChecksum(aadharNumber) {
    const verhoeffTable_d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    ];

    const verhoeffTable_p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
    ];

    const verhoeffTable_inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

    let checksum = 0;
    const digits = aadharNumber.split('').map(Number).reverse();

    for (let i = 0; i < digits.length; i++) {
      checksum = verhoeffTable_d[checksum][verhoeffTable_p[i % 8][digits[i]]];
    }

    return checksum === 0;
  }

  // Log verification attempt
  async logVerificationAttempt(userId, verificationType, requestData, responseData, status, errorMessage, ipAddress, userAgent) {
    try {
      const query = `
        INSERT INTO aadhar_verification_logs (
          user_id, verification_type, request_data, response_data, 
          status, error_message, ip_address, user_agent
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
      `;
      
      const result = await this.pool.query(query, [
        userId,
        verificationType,
        JSON.stringify(requestData || {}),
        JSON.stringify(responseData || {}),
        status,
        errorMessage,
        ipAddress,
        userAgent
      ]);

      return result.rows[0].id;
    } catch (error) {
      logger.error('Error logging verification attempt:', error);
    }
  }

  // Update user verification status
  async updateUserVerificationStatus(userId, status, method, referenceId, failureReason = null) {
    try {
      const query = `
        UPDATE users 
        SET 
          aadhar_verification_status = $1::varchar,
          verification_method = $2::varchar,
          verification_reference_id = $3::varchar,
          verification_failure_reason = $4::text,
          verification_attempts = verification_attempts + 1,
          last_verification_attempt = NOW(),
          aadhar_verified_at = CASE WHEN $1::varchar = 'verified' THEN NOW() ELSE aadhar_verified_at END,
          updated_at = NOW()
        WHERE id = $5::uuid
        RETURNING id, aadhar_verification_status
      `;
      
      const result = await this.pool.query(query, [
        status,
        method,
        referenceId,
        failureReason,
        userId
      ]);

      return result.rows[0];
    } catch (error) {
      logger.error('Error updating user verification status:', error);
      throw error;
    }
  }

  // UIDAI Offline Verification (Primary method)
  async verifyWithUidaiOffline(userId, aadharNumber, documentFile, ipAddress, userAgent) {
    const logId = await this.logVerificationAttempt(
      userId,
      'uidai',
      { aadharNumber: '****' + aadharNumber.slice(-4) },
      null,
      'initiated',
      null,
      ipAddress,
      userAgent
    );

    try {
      // Validate Aadhar number
      if (!this.validateAadharNumber(aadharNumber)) {
        throw new Error('Invalid Aadhar number format');
      }

      if (!this.validateAadharChecksum(aadharNumber)) {
        throw new Error('Invalid Aadhar number checksum');
      }

      // Process QR code from uploaded document if available
      let qrCodeData = null;
      if (documentFile) {
        try {
          qrCodeData = await this.extractQRCodeFromDocument(documentFile);
        } catch (qrError) {
          logger.warn('Failed to extract QR code:', qrError.message);
        }
      }

      // UIDAI API call for offline verification
      const verificationResult = await this.callUidaiApi(aadharNumber, qrCodeData);

      if (verificationResult.success) {
        await this.updateUserVerificationStatus(
          userId,
          'verified',
          'uidai',
          verificationResult.referenceId
        );

        // Encrypt and store Aadhar number
        const encryptedAadhar = this.encryptAadhar(aadharNumber);
        await this.pool.query(
          'UPDATE users SET aadhar_number_encrypted = $1 WHERE id = $2::uuid',
          [encryptedAadhar, userId]
        );

        await this.logVerificationAttempt(
          userId,
          'uidai',
          { aadharNumber: '****' + aadharNumber.slice(-4) },
          { success: true, referenceId: verificationResult.referenceId },
          'success',
          null,
          ipAddress,
          userAgent
        );

        return {
          success: true,
          method: 'uidai',
          referenceId: verificationResult.referenceId,
          message: 'Aadhar verified successfully through UIDAI'
        };
      } else {
        throw new Error(verificationResult.error || 'UIDAI verification failed');
      }

    } catch (error) {
      await this.updateUserVerificationStatus(
        userId,
        'failed',
        'uidai',
        null,
        error.message
      );

      await this.logVerificationAttempt(
        userId,
        'uidai',
        { aadharNumber: '****' + aadharNumber.slice(-4) },
        null,
        'failed',
        error.message,
        ipAddress,
        userAgent
      );

      throw error;
    }
  }

  // DigiLocker Verification (Fallback method)
  async verifyWithDigiLocker(userId, aadharNumber, ipAddress, userAgent) {
    const logId = await this.logVerificationAttempt(
      userId,
      'digilocker',
      { aadharNumber: '****' + aadharNumber.slice(-4) },
      null,
      'initiated',
      null,
      ipAddress,
      userAgent
    );

    try {
      // Get DigiLocker access token
      const accessToken = await this.getDigiLockerAccessToken();
      
      // Call DigiLocker API for Aadhar verification
      const verificationResult = await this.callDigiLockerApi(aadharNumber, accessToken);

      if (verificationResult.success) {
        await this.updateUserVerificationStatus(
          userId,
          'verified',
          'digilocker',
          verificationResult.referenceId
        );

        // Encrypt and store Aadhar number
        const encryptedAadhar = this.encryptAadhar(aadharNumber);
        await this.pool.query(
          'UPDATE users SET aadhar_number_encrypted = $1 WHERE id = $2::uuid',
          [encryptedAadhar, userId]
        );

        await this.logVerificationAttempt(
          userId,
          'digilocker',
          { aadharNumber: '****' + aadharNumber.slice(-4) },
          { success: true, referenceId: verificationResult.referenceId },
          'success',
          null,
          ipAddress,
          userAgent
        );

        return {
          success: true,
          method: 'digilocker',
          referenceId: verificationResult.referenceId,
          message: 'Aadhar verified successfully through DigiLocker'
        };
      } else {
        throw new Error(verificationResult.error || 'DigiLocker verification failed');
      }

    } catch (error) {
      await this.updateUserVerificationStatus(
        userId,
        'failed',
        'digilocker',
        null,
        error.message
      );

      await this.logVerificationAttempt(
        userId,
        'digilocker',
        { aadharNumber: '****' + aadharNumber.slice(-4) },
        null,
        'failed',
        error.message,
        ipAddress,
        userAgent
      );

      throw error;
    }
  }

  // Extract QR code data from Aadhar document
  async extractQRCodeFromDocument(documentFile) {
    try {
      // Convert image to appropriate format
      const imageBuffer = await sharp(documentFile.buffer)
        .greyscale()
        .png()
        .toBuffer();

      return new Promise((resolve, reject) => {
        const qr = new QrCode();
        qr.callback = (err, value) => {
          if (err) {
            reject(new Error('QR code not found or unreadable'));
            return;
          }
          resolve(value.result);
        };
        qr.decode(imageBuffer);
      });
    } catch (error) {
      throw new Error('Failed to process document image: ' + error.message);
    }
  }

  // Mock UIDAI API call (replace with actual API implementation)
  async callUidaiApi(aadharNumber, qrCodeData) {
    try {
      // This is a mock implementation. Replace with actual UIDAI API calls
      // when you get access to the UIDAI services
      
      if (!this.uidaiLicenseKey) {
        throw new Error('UIDAI license key not configured');
      }

      const requestBody = {
        aadhaar_number: aadharNumber,
        qr_code_data: qrCodeData,
        license_key: this.uidaiLicenseKey
      };

      // Mock response for testing
      // Replace this with actual UIDAI API call
      const mockResponse = {
        success: true,
        referenceId: 'UIDAI_' + Date.now(),
        message: 'Verification successful'
      };

      return mockResponse;

      // Actual implementation would be:
      /*
      const response = await fetch(`${this.uidaiBaseUrl}/verify-offline`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.uidaiLicenseKey}`,
        },
        body: JSON.stringify(requestBody)
      });

      const result = await response.json();
      return result;
      */

    } catch (error) {
      logger.error('UIDAI API call failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // Get DigiLocker access token
  async getDigiLockerAccessToken() {
    try {
      const tokenUrl = `${this.digilockerBaseUrl}/oauth/token`;
      
      const formData = new FormData();
      formData.append('grant_type', 'client_credentials');
      formData.append('client_id', this.digilockerClientId);
      formData.append('client_secret', this.digilockerClientSecret);

      const response = await fetch(tokenUrl, {
        method: 'POST',
        body: formData
      });

      const result = await response.json();
      
      if (!response.ok || !result.access_token) {
        throw new Error('Failed to get DigiLocker access token');
      }

      return result.access_token;
    } catch (error) {
      throw new Error('DigiLocker authentication failed: ' + error.message);
    }
  }

  // Mock DigiLocker API call (replace with actual API implementation)
  async callDigiLockerApi(aadharNumber, accessToken) {
    try {
      // This is a mock implementation. Replace with actual DigiLocker API calls
      
      const requestBody = {
        aadhaar_number: aadharNumber
      };

      // Mock response for testing
      // Replace this with actual DigiLocker API call
      const mockResponse = {
        success: true,
        referenceId: 'DL_' + Date.now(),
        message: 'Verification successful'
      };

      return mockResponse;

      // Actual implementation would be:
      /*
      const response = await fetch(`${this.digilockerBaseUrl}/verify-aadhaar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify(requestBody)
      });

      const result = await response.json();
      return result;
      */

    } catch (error) {
      logger.error('DigiLocker API call failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // Main verification method that tries UIDAI first, then DigiLocker
  async verifyAadhar(userId, aadharNumber, documentFile, ipAddress, userAgent) {
    try {
      // Check if user already has a verified Aadhar
      const userQuery = 'SELECT aadhar_verification_status FROM users WHERE id = $1::uuid';
      const userResult = await this.pool.query(userQuery, [userId]);
      
      if (userResult.rows.length === 0) {
        throw new Error('User not found');
      }

      if (userResult.rows[0].aadhar_verification_status === 'verified') {
        throw new Error('Aadhar already verified for this user');
      }

      // Update status to in_progress
      await this.updateUserVerificationStatus(userId, 'in_progress', null, null);

      // Try UIDAI first
      try {
        const uidaiResult = await this.verifyWithUidaiOffline(
          userId, 
          aadharNumber, 
          documentFile, 
          ipAddress, 
          userAgent
        );
        return uidaiResult;
      } catch (uidaiError) {
        logger.warn('UIDAI verification failed, trying DigiLocker:', uidaiError.message);
        
        // Fallback to DigiLocker
        try {
          const digiLockerResult = await this.verifyWithDigiLocker(
            userId, 
            aadharNumber, 
            ipAddress, 
            userAgent
          );
          return digiLockerResult;
        } catch (digiLockerError) {
          logger.error('Both UIDAI and DigiLocker verification failed');
          throw new Error('Verification failed through all available methods');
        }
      }

    } catch (error) {
      await this.updateUserVerificationStatus(
        userId,
        'failed',
        'manual',
        null,
        error.message
      );
      throw error;
    }
  }

  // Get verification status for a user
  async getVerificationStatus(userId) {
    try {
      const query = `
        SELECT 
          aadhar_verification_status,
          verification_method,
          verification_reference_id,
          aadhar_verified_at,
          verification_attempts,
          verification_failure_reason,
          last_verification_attempt
        FROM users 
        WHERE id = $1::uuid
      `;
      
      const result = await this.pool.query(query, [userId]);
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      return result.rows[0];
    } catch (error) {
      logger.error('Error getting verification status:', error);
      throw error;
    }
  }

  // Get verification history for a user
  async getVerificationHistory(userId) {
    try {
      const query = `
        SELECT 
          verification_type,
          status,
          error_message,
          created_at
        FROM aadhar_verification_logs 
        WHERE user_id = $1::uuid
        ORDER BY created_at DESC
        LIMIT 10
      `;
      
      const result = await this.pool.query(query, [userId]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting verification history:', error);
      throw error;
    }
  }
}

module.exports = AadharVerificationService;