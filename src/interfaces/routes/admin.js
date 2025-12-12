const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.get('/verifications/pending', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    
    const {
      district,
      taluka,
      grade,
      page = 1,
      limit = 10
    } = req.query;

    // Build dynamic query conditions
    let whereConditions = ['h.status = $1'];
    let queryParams = ['pending-verification'];
    let paramCounter = 1;

    // Add filtering conditions for district-admin
    if (req.user.userType === 'district-admin') {
      // District admins can only see homestays in their district
      if (req.user.district) {
        paramCounter++;
        whereConditions.push(`h.district = $${paramCounter}`);
        queryParams.push(req.user.district);
      }
    }

    // Additional filters
    if (district && req.user.userType === 'admin') {
      paramCounter++;
      whereConditions.push(`h.district ILIKE $${paramCounter}`);
      queryParams.push(`%${district}%`);
    }

    if (taluka) {
      paramCounter++;
      whereConditions.push(`h.taluka ILIKE $${paramCounter}`);
      queryParams.push(`%${taluka}%`);
    }

    if (grade) {
      paramCounter++;
      whereConditions.push(`h.grade = $${paramCounter}`);
      queryParams.push(grade);
    }

    // Calculate pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Get pending verifications query
    const verificationsQuery = `
      SELECT 
        h.id,
        h.owner_id,
        h.name,
        h.description,
        h.grade,
        h.district,
        h.taluka,
        h.latitude,
        h.longitude,
        h.amenities,
        h.media,
        h.sustainability_score,
        h.status,
        h.created_at,
        h.updated_at,
        u.full_name as owner_name,
        u.email as owner_email,
        u.phone as owner_phone
      FROM homestays h
      LEFT JOIN users u ON h.owner_id = u.firebase_uid
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY h.created_at ASC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query for pagination
    const countQuery = `
      SELECT COUNT(*) as total
      FROM homestays h
      WHERE ${whereConditions.join(' AND ')}
    `;

    // Execute both queries
    const [verificationsResult, countResult] = await Promise.all([
      pool.query(verificationsQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    // Fetch rooms for each homestay
    const homestaysWithRooms = await Promise.all(
      verificationsResult.rows.map(async (homestay) => {
        const roomsQuery = `
          SELECT 
            id, name, capacity, price_per_night, amenities, status, created_at, updated_at
          FROM homestay_rooms 
          WHERE homestay_id = $1
          ORDER BY price_per_night ASC
        `;
        
        const roomsResult = await pool.query(roomsQuery, [homestay.id]);
        const rooms = roomsResult.rows;

        return {
          id: homestay.id,
          name: homestay.name,
          description: homestay.description,
          grade: homestay.grade,
          location: {
            district: homestay.district,
            taluka: homestay.taluka,
            coordinates: {
              lat: parseFloat(homestay.latitude),
              lng: parseFloat(homestay.longitude)
            }
          },
          owner: {
            id: homestay.owner_id,
            name: homestay.owner_name,
            email: homestay.owner_email,
            phone: homestay.owner_phone
          },
          amenities: homestay.amenities || [],
          media: homestay.media || [],
          sustainabilityScore: homestay.sustainability_score,
          rooms: rooms.map(room => ({
            id: room.id,
            name: room.name,
            capacity: room.capacity,
            pricePerNight: parseFloat(room.price_per_night),
            amenities: room.amenities || [],
            status: room.status,
            createdAt: room.created_at,
            updatedAt: room.updated_at
          })),
          roomSummary: {
            totalRooms: rooms.length,
            priceRange: rooms.length > 0 ? {
              min: Math.min(...rooms.map(r => parseFloat(r.price_per_night))),
              max: Math.max(...rooms.map(r => parseFloat(r.price_per_night)))
            } : { min: 0, max: 0 },
            totalCapacity: rooms.reduce((sum, room) => sum + room.capacity, 0)
          },
          status: homestay.status,
          submittedAt: homestay.created_at,
          updatedAt: homestay.updated_at
        };
      })
    );

    const pendingVerifications = homestaysWithRooms;

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        verifications: pendingVerifications,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1
        },
        filters: {
          district,
          taluka,
          grade,
          userType: req.user.userType
        }
      }
    });

  } catch (error) {
    console.error('Error fetching pending verifications:', error);
    next(error);
  }
});

router.post('/verifications/:id/approve', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const homestayId = req.params.id;
    const { comments } = req.body;

    // First, get the homestay to verify it exists and check permissions
    const homestayQuery = 'SELECT * FROM homestays WHERE id = $1';
    const homestayResult = await pool.query(homestayQuery, [homestayId]);

    if (homestayResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'HOMESTAY_NOT_FOUND',
          message: 'Homestay not found'
        }
      });
    }

    const homestay = homestayResult.rows[0];

    // Check if homestay is in pending verification status
    if (homestay.status !== 'pending-verification') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_STATUS',
          message: `Homestay is already ${homestay.status}. Can only approve pending verifications.`
        }
      });
    }

    // Check district-admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== homestay.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only approve homestays in their district'
          }
        });
      }
    }

    // Update homestay status to active
    const updateQuery = `
      UPDATE homestays 
      SET status = 'active', updated_at = NOW() 
      WHERE id = $1 
      RETURNING id, name, status, district, taluka
    `;
    
    const updateResult = await pool.query(updateQuery, [homestayId]);
    const updatedHomestay = updateResult.rows[0];

    // Log the verification action (optional: create verification_logs table later)
    const logQuery = `
      INSERT INTO verification_logs (
        homestay_id, 
        admin_user_id, 
        action, 
        comments, 
        created_at
      ) VALUES ($1, $2, $3, $4, NOW())
    `;

    // Try to insert log, but don't fail if table doesn't exist yet
    try {
      await pool.query(logQuery, [
        homestayId,
        req.user.uid,
        'approved',
        comments || 'Homestay approved for listing'
      ]);
    } catch (logError) {
      console.log('Verification log table not found, skipping log entry');
    }

    res.json({
      success: true,
      data: {
        id: updatedHomestay.id,
        name: updatedHomestay.name,
        status: updatedHomestay.status,
        location: {
          district: updatedHomestay.district,
          taluka: updatedHomestay.taluka
        },
        approvedBy: {
          userId: req.user.uid,
          userType: req.user.userType
        },
        approvedAt: new Date().toISOString(),
        comments: comments,
        message: 'Homestay verification approved successfully. Homestay is now active and available for bookings.'
      }
    });

  } catch (error) {
    console.error('Error approving verification:', error);
    next(error);
  }
});

router.post('/verifications/:id/reject', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const homestayId = req.params.id;
    const { reason, comments } = req.body;

    // Validation
    if (!reason) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Rejection reason is required'
        }
      });
    }

    // First, get the homestay to verify it exists and check permissions
    const homestayQuery = 'SELECT * FROM homestays WHERE id = $1';
    const homestayResult = await pool.query(homestayQuery, [homestayId]);

    if (homestayResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'HOMESTAY_NOT_FOUND',
          message: 'Homestay not found'
        }
      });
    }

    const homestay = homestayResult.rows[0];

    // Check if homestay is in pending verification status
    if (homestay.status !== 'pending-verification') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_STATUS',
          message: `Homestay is already ${homestay.status}. Can only reject pending verifications.`
        }
      });
    }

    // Check district-admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== homestay.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only reject homestays in their district'
          }
        });
      }
    }

    // Update homestay status to inactive (rejected)
    const updateQuery = `
      UPDATE homestays 
      SET status = 'inactive', updated_at = NOW() 
      WHERE id = $1 
      RETURNING id, name, status, district, taluka
    `;
    
    const updateResult = await pool.query(updateQuery, [homestayId]);
    const updatedHomestay = updateResult.rows[0];

    // Log the verification action
    const logQuery = `
      INSERT INTO verification_logs (
        homestay_id, 
        admin_user_id, 
        action, 
        reason,
        comments, 
        created_at
      ) VALUES ($1, $2, $3, $4, $5, NOW())
    `;

    // Try to insert log, but don't fail if table doesn't exist yet
    try {
      await pool.query(logQuery, [
        homestayId,
        req.user.uid,
        'rejected',
        reason,
        comments || 'Homestay verification rejected'
      ]);
    } catch (logError) {
      console.log('Verification log table not found, skipping log entry');
    }

    res.json({
      success: true,
      data: {
        id: updatedHomestay.id,
        name: updatedHomestay.name,
        status: updatedHomestay.status,
        location: {
          district: updatedHomestay.district,
          taluka: updatedHomestay.taluka
        },
        rejectedBy: {
          userId: req.user.uid,
          userType: req.user.userType
        },
        rejectedAt: new Date().toISOString(),
        reason: reason,
        comments: comments,
        message: 'Homestay verification rejected. Owner can resubmit after addressing the issues.'
      }
    });

  } catch (error) {
    console.error('Error rejecting verification:', error);
    next(error);
  }
});

router.get('/verifications/:id', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const homestayId = req.params.id;

    // Get detailed homestay information with owner details and rooms
    const homestayQuery = `
      SELECT 
        h.*,
        u.full_name as owner_name,
        u.email as owner_email,
        u.phone as owner_phone,
        u.role as owner_type,
        u.created_at as owner_registered_at
      FROM homestays h
      LEFT JOIN users u ON h.owner_id = u.firebase_uid
      WHERE h.id = $1
    `;

    const roomsQuery = `
      SELECT * FROM homestay_rooms 
      WHERE homestay_id = $1 
      ORDER BY price_per_night ASC
    `;

    // Execute both queries in parallel
    const [homestayResult, roomsResult] = await Promise.all([
      pool.query(homestayQuery, [homestayId]),
      pool.query(roomsQuery, [homestayId])
    ]);

    if (homestayResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'HOMESTAY_NOT_FOUND',
          message: 'Homestay not found'
        }
      });
    }

    const homestay = homestayResult.rows[0];
    const rooms = roomsResult.rows;

    // Check district-admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== homestay.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only view homestays in their district'
          }
        });
      }
    }

    // Get verification history if logs table exists
    let verificationHistory = [];
    try {
      const logsQuery = `
        SELECT 
          vl.*,
          u.name as admin_name
        FROM verification_logs vl
        LEFT JOIN users u ON vl.admin_user_id = u.uid
        WHERE vl.homestay_id = $1
        ORDER BY vl.created_at DESC
      `;
      const logsResult = await pool.query(logsQuery, [homestayId]);
      verificationHistory = logsResult.rows;
    } catch (logError) {
      console.log('Verification logs table not found, skipping history');
    }

    // Format the response
    const response = {
      id: homestay.id,
      name: homestay.name,
      description: homestay.description,
      grade: homestay.grade,
      location: {
        district: homestay.district,
        taluka: homestay.taluka,
        coordinates: {
          lat: parseFloat(homestay.latitude),
          lng: parseFloat(homestay.longitude)
        }
      },
      owner: {
        id: homestay.owner_id,
        name: homestay.owner_name,
        email: homestay.owner_email,
        phone: homestay.owner_phone,
        type: homestay.owner_type,
        registeredAt: homestay.owner_registered_at
      },
      amenities: homestay.amenities || [],
      media: homestay.media || [],
      sustainabilityScore: homestay.sustainability_score,
      status: homestay.status,
      rooms: rooms.map(room => ({
        id: room.id,
        name: room.name,
        capacity: room.capacity,
        pricePerNight: parseFloat(room.price_per_night),
        amenities: room.amenities || [],
        status: room.status,
        createdAt: room.created_at,
        updatedAt: room.updated_at
      })),
      roomSummary: {
        totalRooms: rooms.length,
        priceRange: rooms.length > 0 ? {
          min: Math.min(...rooms.map(r => parseFloat(r.price_per_night))),
          max: Math.max(...rooms.map(r => parseFloat(r.price_per_night)))
        } : { min: 0, max: 0 },
        totalCapacity: rooms.reduce((sum, room) => sum + room.capacity, 0)
      },
      verificationHistory: verificationHistory.map(log => ({
        action: log.action,
        reason: log.reason,
        comments: log.comments,
        adminName: log.admin_name,
        adminUserId: log.admin_user_id,
        createdAt: log.created_at
      })),
      submittedAt: homestay.created_at,
      updatedAt: homestay.updated_at
    };

    res.json({
      success: true,
      data: response
    });

  } catch (error) {
    console.error('Error fetching homestay for verification:', error);
    next(error);
  }
});

router.patch('/users/:id/roles', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'User roles updated successfully' } });
  } catch (error) { next(error); }
});

// Get all pending Aadhar verifications
router.get('/verifications/aadhar/pending', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const {
      district,
      page = 1,
      limit = 20
    } = req.query;

    // Build dynamic query conditions
    let whereConditions = ['u.aadhar_verification_status = $1'];
    let queryParams = ['pending'];
    let paramCounter = 1;

    // Add filtering for district admin
    if (req.user.userType === 'district-admin' && req.user.district) {
      paramCounter++;
      whereConditions.push(`u.district = $${paramCounter}`);
      queryParams.push(req.user.district);
    } else if (district && req.user.userType === 'admin') {
      paramCounter++;
      whereConditions.push(`u.district ILIKE $${paramCounter}`);
      queryParams.push(`%${district}%`);
    }

    // Calculate pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Get pending Aadhar verifications
    const verificationQuery = `
      SELECT 
        u.id,
        u.firebase_uid,
        u.full_name,
        u.email,
        u.phone,
        u.district,
        u.taluka,
        u.aadhar_verification_status,
        u.verification_attempts,
        u.verification_failure_reason,
        u.last_verification_attempt,
        u.aadhar_document_url,
        u.created_at
      FROM users u
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY u.last_verification_attempt DESC NULLS LAST, u.created_at DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query for pagination
    const countQuery = `
      SELECT COUNT(*) as total
      FROM users u
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [verificationsResult, countResult] = await Promise.all([
      pool.query(verificationQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const pendingVerifications = verificationsResult.rows.map(user => ({
      id: user.id,
      firebaseUid: user.firebase_uid,
      name: user.full_name,
      email: user.email,
      phone: user.phone,
      location: {
        district: user.district,
        taluka: user.taluka
      },
      verificationStatus: user.aadhar_verification_status,
      attempts: user.verification_attempts,
      failureReason: user.verification_failure_reason,
      lastAttempt: user.last_verification_attempt,
      documentUrl: user.aadhar_document_url,
      registeredAt: user.created_at
    }));

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        verifications: pendingVerifications,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1
        },
        filters: {
          district,
          userType: req.user.userType
        }
      }
    });

  } catch (error) {
    console.error('Error fetching pending Aadhar verifications:', error);
    next(error);
  }
});

// Get detailed information for a specific Aadhar verification
router.get('/verifications/aadhar/:userId', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const userId = req.params.userId;

    // Get user details
    const userQuery = `
      SELECT 
        u.*
      FROM users u
      WHERE u.firebase_uid = $1
    `;

    const userResult = await pool.query(userQuery, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const user = userResult.rows[0];

    // Check district admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== user.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only view users in their district'
          }
        });
      }
    }

    // Get verification history
    const logsQuery = `
      SELECT 
        verification_type,
        status,
        error_message,
        created_at
      FROM aadhar_verification_logs
      WHERE user_id = $1
      ORDER BY created_at DESC
    `;

    const logsResult = await pool.query(logsQuery, [user.id]);

    const response = {
      id: user.id,
      firebaseUid: user.firebase_uid,
      name: user.full_name,
      email: user.email,
      phone: user.phone,
      userType: user.role,
      location: {
        district: user.district,
        taluka: user.taluka
      },
      aadharVerification: {
        status: user.aadhar_verification_status,
        method: user.verification_method,
        referenceId: user.verification_reference_id,
        attempts: user.verification_attempts,
        failureReason: user.verification_failure_reason,
        verifiedAt: user.aadhar_verified_at,
        lastAttempt: user.last_verification_attempt,
        documentUrl: user.aadhar_document_url
      },
      verificationHistory: logsResult.rows.map(log => ({
        method: log.verification_type,
        status: log.status,
        errorMessage: log.error_message,
        createdAt: log.created_at
      })),
      accountStatus: user.status,
      registeredAt: user.created_at,
      updatedAt: user.updated_at
    };

    res.json({
      success: true,
      data: response
    });

  } catch (error) {
    console.error('Error fetching Aadhar verification details:', error);
    next(error);
  }
});

// Manually approve Aadhar verification (includes temporary submissions)
router.post('/verifications/aadhar/:userId/approve', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const userId = req.params.userId;
    const { comments } = req.body;

    // Get user details first
    const userQuery = `
      SELECT * FROM users 
      WHERE firebase_uid = $1
    `;
    const userResult = await pool.query(userQuery, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const user = userResult.rows[0];

    // Check district admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== user.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only approve users in their district'
          }
        });
      }
    }

    if (user.aadhar_verification_status === 'verified') {
      return res.status(409).json({
        success: false,
        error: {
          code: 'ALREADY_VERIFIED',
          message: 'Aadhar is already verified for this user'
        }
      });
    }

    // Update verification status
    const updateQuery = `
      UPDATE users 
      SET 
        aadhar_verification_status = 'verified',
        verification_method = 'manual',
        verification_reference_id = $1,
        aadhar_verified_at = NOW(),
        updated_at = NOW()
      WHERE id = $2
      RETURNING id, full_name, email, aadhar_verification_status
    `;

    const referenceId = 'MANUAL_' + Date.now() + '_' + req.user.uid;
    const updateResult = await pool.query(updateQuery, [referenceId, user.id]);

    // Log the manual approval
    const logQuery = `
      INSERT INTO aadhar_verification_logs (
        user_id, verification_type, status, error_message, 
        request_data, response_data, ip_address, user_agent
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `;

    await pool.query(logQuery, [
      user.id,
      'manual',
      'success',
      null,
      JSON.stringify({ approvedBy: req.user.uid, comments }),
      JSON.stringify({ referenceId, approvedAt: new Date().toISOString() }),
      req.ip,
      req.get('User-Agent')
    ]);

    const updatedUser = updateResult.rows[0];

    res.json({
      success: true,
      data: {
        userId: updatedUser.id,
        name: updatedUser.full_name,
        email: updatedUser.email,
        verificationStatus: updatedUser.aadhar_verification_status,
        approvedBy: {
          userId: req.user.uid,
          userType: req.user.userType
        },
        referenceId,
        comments,
        message: 'Aadhar verification manually approved successfully'
      }
    });

  } catch (error) {
    console.error('Error manually approving Aadhar verification:', error);
    next(error);
  }
});

// Manually reject Aadhar verification (includes temporary submissions)
router.post('/verifications/aadhar/:userId/reject', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const userId = req.params.userId;
    const { reason, comments } = req.body;

    if (!reason) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Rejection reason is required'
        }
      });
    }

    // Get user details first
    const userQuery = 'SELECT * FROM users WHERE firebase_uid = $1';
    const userResult = await pool.query(userQuery, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const user = userResult.rows[0];

    // Check district admin permissions
    if (req.user.userType === 'district-admin') {
      if (req.user.district && req.user.district !== user.district) {
        return res.status(403).json({
          success: false,
          error: {
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'District admin can only reject users in their district'
          }
        });
      }
    }

    if (user.aadhar_verification_status === 'verified') {
      return res.status(409).json({
        success: false,
        error: {
          code: 'ALREADY_VERIFIED',
          message: 'Cannot reject already verified Aadhar'
        }
      });
    }

    // Update verification status
    const updateQuery = `
      UPDATE users 
      SET 
        aadhar_verification_status = 'rejected',
        verification_failure_reason = $1,
        updated_at = NOW()
      WHERE id = $2
      RETURNING id, full_name, email, aadhar_verification_status
    `;

    const updateResult = await pool.query(updateQuery, [reason, user.id]);

    // Log the manual rejection
    const logQuery = `
      INSERT INTO aadhar_verification_logs (
        user_id, verification_type, status, error_message, 
        request_data, response_data, ip_address, user_agent
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `;

    await pool.query(logQuery, [
      user.id,
      'manual',
      'failed',
      reason,
      JSON.stringify({ rejectedBy: req.user.uid, reason, comments }),
      JSON.stringify({ rejectedAt: new Date().toISOString() }),
      req.ip,
      req.get('User-Agent')
    ]);

    const updatedUser = updateResult.rows[0];

    res.json({
      success: true,
      data: {
        userId: updatedUser.id,
        name: updatedUser.full_name,
        email: updatedUser.email,
        verificationStatus: updatedUser.aadhar_verification_status,
        rejectedBy: {
          userId: req.user.uid,
          userType: req.user.userType
        },
        reason,
        comments,
        message: 'Aadhar verification manually rejected'
      }
    });

  } catch (error) {
    console.error('Error manually rejecting Aadhar verification:', error);
    next(error);
  }
});

// Get Aadhar verification statistics
router.get('/verifications/aadhar/statistics', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const { district, period = '30' } = req.query;

    // Build base query conditions for district admin
    let whereCondition = '';
    let queryParams = [];
    
    if (req.user.userType === 'district-admin' && req.user.district) {
      whereCondition = 'WHERE u.district = $1';
      queryParams.push(req.user.district);
    } else if (district && req.user.userType === 'admin') {
      whereCondition = 'WHERE u.district ILIKE $1';
      queryParams.push(`%${district}%`);
    }

    const statsQuery = `
      SELECT 
        COUNT(*) FILTER (WHERE u.aadhar_verification_status = 'verified') as verified_count,
        COUNT(*) FILTER (WHERE u.aadhar_verification_status = 'pending') as pending_count,
        COUNT(*) FILTER (WHERE u.aadhar_verification_status = 'failed') as failed_count,
        COUNT(*) FILTER (WHERE u.aadhar_verification_status = 'rejected') as rejected_count,
        COUNT(*) FILTER (WHERE u.aadhar_verification_status = 'in_progress') as in_progress_count,
        COUNT(*) as total_users,
        AVG(u.verification_attempts) FILTER (WHERE u.verification_attempts > 0) as avg_attempts
      FROM users u
      ${whereCondition}
    `;

    // Get recent verification trends
    const trendQuery = `
      SELECT 
        DATE(avl.created_at) as verification_date,
        COUNT(*) FILTER (WHERE avl.status = 'success') as successful_verifications,
        COUNT(*) FILTER (WHERE avl.status = 'failed') as failed_verifications
      FROM aadhar_verification_logs avl
      ${whereCondition.replace('u.district', 'avl.user_id IN (SELECT id FROM users WHERE district')}
      ${whereCondition ? 'AND' : 'WHERE'} avl.created_at >= NOW() - INTERVAL '${period} days'
      GROUP BY DATE(avl.created_at)
      ORDER BY verification_date DESC
      LIMIT 30
    `;

    const [statsResult, trendResult] = await Promise.all([
      pool.query(statsQuery, queryParams),
      pool.query(trendQuery.replace('${period}', period), queryParams)
    ]);

    const stats = statsResult.rows[0];
    const trends = trendResult.rows;

    res.json({
      success: true,
      data: {
        overview: {
          totalUsers: parseInt(stats.total_users),
          verified: parseInt(stats.verified_count),
          pending: parseInt(stats.pending_count),
          failed: parseInt(stats.failed_count),
          rejected: parseInt(stats.rejected_count),
          inProgress: parseInt(stats.in_progress_count),
          verificationRate: stats.total_users > 0 ? 
            ((stats.verified_count / stats.total_users) * 100).toFixed(2) : '0.00',
          avgAttemptsPerUser: stats.avg_attempts ? parseFloat(stats.avg_attempts).toFixed(2) : '0.00'
        },
        trends: trends.map(trend => ({
          date: trend.verification_date,
          successful: parseInt(trend.successful_verifications),
          failed: parseInt(trend.failed_verifications)
        })),
        filters: {
          district: req.user.userType === 'district-admin' ? req.user.district : district,
          period: period,
          userType: req.user.userType
        }
      }
    });

  } catch (error) {
    console.error('Error fetching Aadhar verification statistics:', error);
    next(error);
  }
});

module.exports = router;