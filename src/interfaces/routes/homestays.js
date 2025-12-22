const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');
const logger = require('../../../config/logger');


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
    const pool = require('../../../config/database');
    
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
    const pool = require('../../../config/database');
    
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

router.get('/:id', async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const homestayId = req.params.id;

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
    const BookingRepository = require('../../domain/repositories/BookingRepository');
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
        userId: booking.guest_id,
        name: booking.guest_name || 'Guest',
        email: booking.guest_email,
        phone: booking.guest_phone
      },
      dates: {
        checkIn: booking.check_in,
        checkOut: booking.check_out,
        nights: Math.ceil((new Date(booking.check_out) - new Date(booking.check_in)) / (1000 * 60 * 60 * 24))
      },
      guestsCount: booking.guests,
      totalAmount: parseFloat(booking.total),
      paymentMethod: 'N/A', // Not available in current schema
      status: booking.status,
      specialRequests: booking.guest_note,
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
          pendingBookings: formattedBookings.filter(b => b.status === 'pending-payment').length,
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
    const BookingRepository = require('../../domain/repositories/BookingRepository');
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
    const pool = require('../../../config/database');
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

    // Get the user's UUID from the database (bookings table uses UUID guest_id)
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

    const guestId = userResult.rows[0].id;

    // Create booking
    const bookingData = {
      roomId,
      guestId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      guestsCount: guests,
      totalAmount,
      specialRequests
    };

    const booking = await bookingRepository.createBooking(bookingData);

    res.status(201).json({
      success: true,
      data: {
        bookingId: booking.id,
        status: booking.status,
        checkIn,
        checkOut,
        totalAmount,
        nights,
        message: 'Booking created successfully. Please complete payment to confirm.'
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

module.exports = router;