const express = require('express');
const shared = require('@samudrayan/shared');
const { verifyJWT, authorize, AppError } = shared.middleware;
const { createNotification } = require('@samudrayan/shared-firebase');
const logger = shared.logger;


const router = express.Router();

router.post('/', verifyJWT, authorize('homestay-owner', 'admin'), async (req, res, next) => {
  try {
    const {
      name,
      description,
      grade,
      district,
      taluka,
      location,
      amenities,
      rooms,
      media,
      sustainabilityScore
    } = req.body;

    // Validation
    if (!name || !description || !grade || !district || !taluka || !location) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Required fields: name, description, grade, district, taluka, location'
        }
      });
    }


    if (!location.lat || !location.lng) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Location must include lat and lng coordinates'
        }
      });
    }

    if (!['silver', 'gold', 'diamond'].includes(grade)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Grade must be one of: silver, gold, diamond'
        }
      });
    }

    // Get database connection
    const pool = require('@samudrayan/shared').db.getPool();
    
    // TODO: Re-enable Aadhar verification later
    // Check if user is Aadhar verified (required for homestay owners)
    if (req.user.userType === 'homestay-owner') {
      const userVerificationQuery = 'SELECT aadhar_verification_status FROM users WHERE firebase_uid = $1';
      const userVerificationResult = await pool.query(userVerificationQuery, [req.user.uid]);
      
      if (userVerificationResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found'
          }
        });
      }

      const verificationStatus = userVerificationResult.rows[0].aadhar_verification_status;
      
      if (verificationStatus !== 'verified') {
        return res.status(403).json({
          success: false,
          error: {
            code: 'AADHAR_VERIFICATION_REQUIRED',
            message: 'Aadhar verification is required before registering a homestay. Please complete your Aadhar verification first.',
            verificationStatus: verificationStatus,
            verificationUrl: '/api/verification/aadhar/verify'
          }
        });
      }
    }
    
    // Generate UUID for homestay
    const { v4: uuidv4 } = await import('uuid');
    const homestayId = uuidv4();
    const ownerId = req.user.uid; // From JWT token

    // Insert homestay into database
    const insertQuery = `
      INSERT INTO homestays (
        id, owner_id, name, description, grade, district, taluka, 
        latitude, longitude, amenities, media, sustainability_score, 
        created_at, updated_at, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      RETURNING id, name, grade, district, taluka, status
    `;

    const values = [
      homestayId,
      ownerId,
      name,
      description,
      grade,
      district,
      taluka,
      location.lat,
      location.lng,
      JSON.stringify(amenities || []),
      JSON.stringify(media || []),
      sustainabilityScore || 0,
      new Date().toISOString(),
      new Date().toISOString(),
      'pending-verification'
    ];

    const result = await pool.query(insertQuery, values);

    // Insert rooms if provided
    if (rooms && rooms.length > 0) {
      const roomInsertQuery = `
        INSERT INTO homestay_rooms (
          id, homestay_id, name, capacity, price_per_night, amenities, status, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `;

      for (const room of rooms) {
        const roomId = uuidv4();
        const now = new Date().toISOString();
        await pool.query(roomInsertQuery, [
          roomId,
          homestayId,
          room.name || 'Standard Room',
          room.capacity || 2,
          room.pricePerNight || 0,
          JSON.stringify(room.amenities || []),
          'active',
          now,
          now
        ]);
      }
    }

    const createdHomestay = result.rows[0];

    res.status(201).json({
      success: true,
      data: {
        id: createdHomestay.id,
        name: createdHomestay.name,
        grade: createdHomestay.grade,
        district: createdHomestay.district,
        taluka: createdHomestay.taluka,
        status: createdHomestay.status,
        message: 'Homestay created successfully and submitted for verification'
      }
    });

  } catch (error) {
    console.error('Error creating homestay:', error);
    
    // Handle specific database errors
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({
        success: false,
        error: {
          code: 'DUPLICATE_HOMESTAY',
          message: 'A homestay with this name already exists for this owner'
        }
      });
    }

    next(error);
  }
});

router.get('/', async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    
    // Extract query parameters
    const {
      district,
      taluka,
      grade,
      search,
      page = 1,
      limit = 10,
      status = 'active'
    } = req.query;

    // Build dynamic query with conditions
    let whereConditions = ['h.status = $1'];
    let queryParams = [status];
    let paramCounter = 1;

    // Add filtering conditions
    if (district) {
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

    if (search) {
      paramCounter++;
      whereConditions.push(`(h.name ILIKE $${paramCounter} OR h.description ILIKE $${paramCounter})`);
      queryParams.push(`%${search}%`);
    }

    // Calculate offset for pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Main query to get homestays with room information
    const homestaysQuery = `
      SELECT 
        h.id,
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
        h.rating,
        h.total_reviews,
        h.created_at,
        h.updated_at,
        COUNT(r.id) as total_rooms,
        COALESCE(MIN(r.price_per_night), 0) as min_price,
        COALESCE(MAX(r.price_per_night), 0) as max_price,
        COALESCE(SUM(r.capacity), 0) as total_capacity
      FROM homestays h
      LEFT JOIN homestay_rooms r ON h.id = r.homestay_id AND r.status = 'active'
      WHERE ${whereConditions.join(' AND ')}
      GROUP BY h.id
      ORDER BY h.created_at DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query for pagination (exclude LIMIT and OFFSET params)
    const countQuery = `
      SELECT COUNT(*) as total
      FROM homestays h
      WHERE ${whereConditions.join(' AND ')}
    `;

    // Execute both queries
    const [homestaysResult, countResult] = await Promise.all([
      pool.query(homestaysQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const homestays = homestaysResult.rows.map(homestay => ({
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
      amenities: homestay.amenities || [],
      media: homestay.media || [],
      sustainabilityScore: homestay.sustainability_score,
      status: homestay.status,
      rating: parseFloat(homestay.rating),
      totalReviews: homestay.total_reviews,
      roomInfo: {
        totalRooms: parseInt(homestay.total_rooms),
        priceRange: {
          min: parseFloat(homestay.min_price),
          max: parseFloat(homestay.max_price)
        },
        totalCapacity: parseInt(homestay.total_capacity)
      },
      createdAt: homestay.created_at,
      updatedAt: homestay.updated_at
    }));

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    logger.info(`homestays\n`);
    logger.info(homestays);

    res.json({
      success: true,
      data: {
        homestays,
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
          search,
          status
        }
      }
    });

  } catch (error) {
    console.error('Error fetching homestays:', error);
    next(error);
  }
});

// Registered ahead of GET /:id so the literal path "/my" isn't swallowed by
// the ":id" param route (resolves specs/backend_new_changes.md §10 — today
// GET /homestays only returns active listings by default, silently hiding an
// owner's own pending/inactive homestays from their own dashboard).
router.get('/my', verifyJWT, async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();

    const query = `
      SELECT
        h.id, h.name, h.description, h.grade, h.district, h.taluka,
        h.latitude, h.longitude, h.amenities, h.media, h.sustainability_score,
        h.status, h.rating, h.total_reviews, h.created_at, h.updated_at,
        COUNT(r.id) as total_rooms,
        COALESCE(MIN(r.price_per_night), 0) as min_price,
        COALESCE(MAX(r.price_per_night), 0) as max_price,
        COALESCE(SUM(r.capacity), 0) as total_capacity
      FROM homestays h
      LEFT JOIN homestay_rooms r ON h.id = r.homestay_id AND r.status = 'active'
      WHERE h.owner_id = $1
      GROUP BY h.id
      ORDER BY h.created_at DESC
    `;

    const result = await pool.query(query, [req.user.uid]);

    const homestays = result.rows.map(homestay => ({
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
      amenities: homestay.amenities || [],
      media: homestay.media || [],
      sustainabilityScore: homestay.sustainability_score,
      status: homestay.status,
      rating: parseFloat(homestay.rating),
      totalReviews: homestay.total_reviews,
      roomInfo: {
        totalRooms: parseInt(homestay.total_rooms),
        priceRange: {
          min: parseFloat(homestay.min_price),
          max: parseFloat(homestay.max_price)
        },
        totalCapacity: parseInt(homestay.total_capacity)
      },
      createdAt: homestay.created_at,
      updatedAt: homestay.updated_at
    }));

    res.json({
      success: true,
      data: { homestays }
    });
  } catch (error) {
    console.error('Error fetching my homestays:', error);
    next(error);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const homestayId = req.params.id;

    // Fire-and-forget view-count tracking (specs/backend_new_changes.md §5) —
    // deliberately not awaited so a slow/failed insert never adds latency to
    // this, the hottest read path in the app.
    pool.query(
      'INSERT INTO listing_views (listing_type, listing_id, viewer_user_id) VALUES ($1, $2, $3)',
      ['homestay', homestayId, null]
    ).catch(err => logger.error('Failed to record homestay view', { error: err.message, homestayId }));

    // Query to get homestay with detailed room information
    const homestayQuery = `
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
        h.rating,
        h.total_reviews,
        h.created_at,
        h.updated_at
      FROM homestays h
      WHERE h.id = $1
    `;

    // Query to get all rooms for this homestay
    const roomsQuery = `
      SELECT 
        r.id,
        r.name,
        r.capacity,
        r.price_per_night,
        r.amenities,
        r.status,
        r.created_at,
        r.updated_at
      FROM homestay_rooms r
      WHERE r.homestay_id = $1 AND r.status = 'active'
      ORDER BY r.price_per_night ASC
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

    // Format the response
    const response = {
      id: homestay.id,
      ownerId: homestay.owner_id,
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
      amenities: homestay.amenities || [],
      media: homestay.media || [],
      sustainabilityScore: homestay.sustainability_score,
      status: homestay.status,
      rating: parseFloat(homestay.rating),
      totalReviews: homestay.total_reviews,
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
      createdAt: homestay.created_at,
      updatedAt: homestay.updated_at
    };

    res.json({
      success: true,
      data: response
    });

  } catch (error) {
    console.error('Error fetching homestay by ID:', error);
    next(error);
  }
});

router.get('/:id/bookings', verifyJWT, async (req, res, next) => {
  try {
    const BookingRepository = require('../repositories/BookingRepository');
    const bookingRepository = new BookingRepository();
    
    const homestayId = req.params.id;
    const {
      status,
      dateFrom,
      dateTo,
      page = 1,
      limit = 20
    } = req.query;

    // Check if homestay exists and get owner
    const homestayOwner = await bookingRepository.getHomestayOwner(homestayId);
    if (!homestayOwner) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'HOMESTAY_NOT_FOUND',
          message: 'Homestay not found'
        }
      });
    }

    // Authorization check: only homestay owner or admin can view bookings
    const userType = req.user.userType;
    const isOwner = req.user.uid === homestayOwner;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(userType);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'Only homestay owner or admin can view bookings'
        }
      });
    }

    // Get bookings with filters
    const filters = {
      status,
      dateFrom,
      dateTo,
      page: parseInt(page),
      limit: parseInt(limit)
    };

    const result = await bookingRepository.getBookingsByHomestayId(homestayId, filters);

    // Format the response
    const formattedBookings = result.bookings.map(booking => ({
      id: booking.id,
      room: {
        id: booking.room_id,
        name: booking.room_name,
        capacity: booking.room_capacity
      },
      guest: {
        userId: booking.guest_user_id,
        name: booking.guest_name || 'Guest',
        email: booking.guest_email,
        phone: booking.guest_phone
      },
      dates: {
        checkIn: booking.check_in_date,
        checkOut: booking.check_out_date,
        nights: Math.ceil((new Date(booking.check_out_date) - new Date(booking.check_in_date)) / (1000 * 60 * 60 * 24))
      },
      guestsCount: booking.guests_count,
      totalAmount: parseFloat(booking.total_amount),
      paymentMethod: booking.payment_method,
      status: booking.status,
      specialRequests: booking.special_requests,
      payment: {
        amount: booking.payment_amount ? parseFloat(booking.payment_amount) : null,
        status: booking.payment_status,
        transactionId: booking.gateway_transaction_id
      },
      createdAt: booking.created_at,
      updatedAt: booking.updated_at
    }));

    res.json({
      success: true,
      data: {
        homestayId,
        homestayName: result.bookings[0]?.homestay_name || 'Unknown',
        bookings: formattedBookings,
        pagination: result.pagination,
        filters: {
          status,
          dateFrom,
          dateTo
        },
        summary: {
          totalBookings: result.pagination.totalItems,
          confirmedBookings: formattedBookings.filter(b => b.status === 'confirmed').length,
          pendingBookings: formattedBookings.filter(b => ['pending', 'approved', 'pending-payment'].includes(b.status)).length,
          totalRevenue: formattedBookings
            .filter(b => ['confirmed', 'checked-out'].includes(b.status))
            .reduce((sum, b) => sum + b.totalAmount, 0)
        }
      }
    });

  } catch (error) {
    console.error('Error fetching homestay bookings:', error);
    next(error);
  }
});

router.post('/:id/bookings', verifyJWT, async (req, res, next) => {
  try {
    const BookingRepository = require('../repositories/BookingRepository');
    const bookingRepository = new BookingRepository();
    const { v4: uuidv4 } = await import('uuid');

    const homestayId = req.params.id;
    const {
      checkIn,
      checkOut,
      guests,
      roomId,
      paymentMethod,
      specialRequests
    } = req.body;

    // Validation
    if (!checkIn || !checkOut || !guests || !roomId) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Required fields: checkIn, checkOut, guests, roomId'
        }
      });
    }

    const checkInDate = new Date(checkIn);
    const checkOutDate = new Date(checkOut);

    if (checkInDate >= checkOutDate) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Check-out date must be after check-in date'
        }
      });
    }

    if (checkInDate <= new Date()) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Check-in date must be in the future'
        }
      });
    }

    // Check room availability
    const isAvailable = await bookingRepository.checkRoomAvailability(
      roomId,
      checkIn,
      checkOut
    );

    if (!isAvailable) {
      return res.status(409).json({
        success: false,
        error: {
          code: 'ROOM_NOT_AVAILABLE',
          message: 'Room is not available for the selected dates'
        }
      });
    }

    // Get room details to calculate price
    const pool = require('@samudrayan/shared').db.getPool();
    const roomQuery = 'SELECT * FROM homestay_rooms WHERE id = $1 AND homestay_id = $2';
    const roomResult = await pool.query(roomQuery, [roomId, homestayId]);
    
    if (roomResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'ROOM_NOT_FOUND',
          message: 'Room not found in this homestay'
        }
      });
    }

    const room = roomResult.rows[0];
    const nights = Math.ceil((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24));
    const totalAmount = room.price_per_night * nights;

    // bookings.guest_user_id stores the guest's Firebase UID directly (see
    // docker/postgres-init/04-bookings.sql), not a users.id UUID — still
    // verify the user exists in our DB before accepting the booking.
    const userQuery = 'SELECT id FROM users WHERE firebase_uid = $1';
    const userResult = await pool.query(userQuery, [req.user.uid]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    // Create booking
    const bookingData = {
      homestayId,
      roomId,
      guestFirebaseUid: req.user.uid,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      guestsCount: guests,
      totalAmount,
      specialRequests
    };

    const booking = await bookingRepository.createBooking(bookingData);

    const ownerFirebaseUid = await bookingRepository.getHomestayOwner(homestayId);
    const ownerResult = await pool.query(userQuery, [ownerFirebaseUid]);
    if (ownerResult.rows.length > 0) {
      createNotification(pool, {
        userId: ownerResult.rows[0].id,
        category: 'alert',
        title: 'New booking enquiry',
        message: `You have a new booking enquiry for ${checkIn} to ${checkOut}.`,
      }).catch(() => {});
    }

    res.status(201).json({
      success: true,
      data: {
        bookingId: booking.id,
        status: booking.status,
        checkIn,
        checkOut,
        totalAmount,
        nights,
        message: 'Booking request submitted. The host will review and approve your enquiry.'
      }
    });

  } catch (error) {
    console.error('Error creating booking:', error);
    
    // Handle specific database errors
    if (error.code === '23P01') { // Exclusion constraint violation (overlapping bookings)
      return res.status(409).json({
        success: false,
        error: {
          code: 'ROOM_NOT_AVAILABLE',
          message: 'Room is not available for the selected dates'
        }
      });
    }

    next(error);
  }
});

router.get('/bookings/me', verifyJWT, async (req, res, next) => {
  try {
    const BookingRepository = require('../repositories/BookingRepository');
    const bookingRepository = new BookingRepository();

    const { status, dateFrom, dateTo, page = 1, limit = 20 } = req.query;

    const filters = {
      status,
      dateFrom,
      dateTo,
      page: parseInt(page),
      limit: parseInt(limit)
    };

    // bookings.guest_user_id stores the guest's Firebase UID (req.user.uid),
    // not the app-DB users.id UUID (req.user.userId) — see 04-bookings.sql.
    const result = await bookingRepository.getBookingsByUserId(req.user.uid, filters);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
});

// The enquiry -> booking state machine (specs/backend_new_changes.md §6/§11):
//   pending -> approved -> pending-payment -> confirmed -> checked-in -> checked-out
// with cancellation available from any non-terminal state, and refund only
// after cancellation. 'pending-payment' keeps its original meaning (guest is
// mid-checkout, awaiting THEIR payment) — 'approved' is the new state for
// "owner approved the enquiry, awaiting guest payment".
const STATUS_TRANSITIONS = {
  pending: ['approved', 'cancelled'],
  approved: ['pending-payment', 'cancelled'],
  'pending-payment': ['confirmed', 'cancelled'],
  confirmed: ['checked-in', 'cancelled', 'no-show'],
  'checked-in': ['checked-out'],
  cancelled: ['refunded'],
};

// Transitions the owner (or admin) drives; everything else not listed under
// OWNER_TRANSITIONS/GUEST_TRANSITIONS but reachable via STATUS_TRANSITIONS
// (cancelled, refunded) may be initiated by either party or admin.
const OWNER_TRANSITIONS = new Set(['approved', 'checked-in', 'checked-out', 'no-show']);
const GUEST_TRANSITIONS = new Set(['pending-payment', 'confirmed']);

const BOOKING_STATUS_MESSAGES = {
  approved: 'Your booking request has been approved. Please complete payment to confirm your stay.',
  'pending-payment': 'Payment is being processed for your booking.',
  confirmed: 'Your booking is confirmed!',
  cancelled: 'Your booking has been cancelled.',
  'checked-in': 'You have been checked in. Enjoy your stay!',
  'checked-out': 'Thanks for staying with us — you have been checked out.',
  refunded: 'Your payment has been refunded.',
  'no-show': 'Your booking was marked as a no-show.',
};

router.patch('/:id/status', verifyJWT, async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const BookingRepository = require('../repositories/BookingRepository');
    const bookingRepository = new BookingRepository();

    const bookingId = req.params.id;
    const { status: newStatus, reason } = req.body;

    if (!newStatus) {
      return next(new AppError('status is required', 400, 'VALIDATION_ERROR'));
    }

    const booking = await bookingRepository.getBookingWithHomestayOwner(bookingId);
    if (!booking) {
      return next(new AppError('Booking not found', 404, 'BOOKING_NOT_FOUND'));
    }

    const currentStatus = booking.status;
    const allowedNext = STATUS_TRANSITIONS[currentStatus] || [];

    if (!allowedNext.includes(newStatus)) {
      return next(new AppError(
        `Cannot transition booking from '${currentStatus}' to '${newStatus}'`,
        400,
        'INVALID_TRANSITION'
      ));
    }

    const isOwner = req.user.uid === booking.homestay_owner_id;
    const isGuest = req.user.uid === booking.guest_user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(req.user.userType);

    let authorized = isAdmin;
    if (!authorized) {
      if (newStatus === 'cancelled' || newStatus === 'refunded') {
        authorized = isOwner || isGuest;
      } else if (OWNER_TRANSITIONS.has(newStatus)) {
        authorized = isOwner;
      } else if (GUEST_TRANSITIONS.has(newStatus)) {
        authorized = isGuest;
      }
    }

    if (!authorized) {
      return next(new AppError(
        'You are not authorized to make this status change',
        403,
        'INSUFFICIENT_PERMISSIONS'
      ));
    }

    let updateResult;
    if (newStatus === 'cancelled') {
      updateResult = await pool.query(
        `UPDATE bookings
         SET status = $1, cancellation_reason = $2, cancellation_date = NOW(), updated_at = NOW()
         WHERE id = $3
         RETURNING *`,
        [newStatus, reason || null, bookingId]
      );
    } else {
      updateResult = await pool.query(
        'UPDATE bookings SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
        [newStatus, bookingId]
      );
    }

    const updatedBooking = updateResult.rows[0];

    const guestResult = await pool.query('SELECT id FROM users WHERE firebase_uid = $1', [booking.guest_user_id]);
    if (guestResult.rows.length > 0 && BOOKING_STATUS_MESSAGES[newStatus]) {
      createNotification(pool, {
        userId: guestResult.rows[0].id,
        category: 'alert',
        title: 'Booking update',
        message: BOOKING_STATUS_MESSAGES[newStatus],
      }).catch(() => {});
    }

    res.json({
      success: true,
      data: {
        id: updatedBooking.id,
        status: updatedBooking.status,
        previousStatus: currentStatus,
        updatedAt: updatedBooking.updated_at,
      },
    });
  } catch (error) {
    next(error);
  }
});

router.post('/:id/reviews', verifyJWT, async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const homestayId = req.params.id;
    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return next(new AppError('rating must be an integer between 1 and 5', 400, 'VALIDATION_ERROR'));
    }

    const userResult = await pool.query('SELECT id FROM users WHERE firebase_uid = $1', [req.user.uid]);
    if (userResult.rows.length === 0) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }
    const userId = userResult.rows[0].id;

    const homestayResult = await pool.query('SELECT id, owner_id FROM homestays WHERE id = $1', [homestayId]);
    if (homestayResult.rows.length === 0) {
      return next(new AppError('Homestay not found', 404, 'HOMESTAY_NOT_FOUND'));
    }

    // Review insert + rating/total_reviews recompute run as a single
    // transaction — the first explicit multi-statement transaction in this
    // codebase (everywhere else is a single autocommitted statement), used
    // here because app-level BEGIN/COMMIT is simpler to reason about and test
    // than an equivalent AFTER INSERT/UPDATE/DELETE PL/pgSQL trigger.
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(
        `INSERT INTO reviews (listing_type, listing_id, user_id, rating, comment)
         VALUES ('homestay', $1, $2, $3, $4)
         ON CONFLICT (listing_type, listing_id, user_id)
         DO UPDATE SET rating = EXCLUDED.rating, comment = EXCLUDED.comment, updated_at = NOW()`,
        [homestayId, userId, rating, comment || null]
      );
      const aggResult = await client.query(
        `SELECT COALESCE(AVG(rating), 0) as avg_rating, COUNT(*) as total
         FROM reviews WHERE listing_type = 'homestay' AND listing_id = $1`,
        [homestayId]
      );
      const { avg_rating: avgRating, total } = aggResult.rows[0];
      await client.query(
        'UPDATE homestays SET rating = $1, total_reviews = $2, updated_at = NOW() WHERE id = $3',
        [parseFloat(avgRating).toFixed(1), total, homestayId]
      );
      await client.query('COMMIT');
    } catch (txError) {
      await client.query('ROLLBACK');
      throw txError;
    } finally {
      client.release();
    }

    const ownerResult = await pool.query('SELECT id FROM users WHERE firebase_uid = $1', [homestayResult.rows[0].owner_id]);
    if (ownerResult.rows.length > 0) {
      createNotification(pool, {
        userId: ownerResult.rows[0].id,
        category: 'alert',
        title: 'New review received',
        message: `Your homestay received a new ${rating}-star review.`,
      }).catch(() => {});
    }

    res.status(201).json({
      success: true,
      data: { message: 'Review submitted successfully' },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;