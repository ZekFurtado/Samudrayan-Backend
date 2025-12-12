const pool = require('../../../config/database');

class BookingRepository {
  async getBookingsByHomestayId(homestayId, filters = {}) {
    const {
      status,
      dateFrom,
      dateTo,
      page = 1,
      limit = 20
    } = filters;

    let whereConditions = ['r.homestay_id = $1'];
    let queryParams = [homestayId];
    let paramCounter = 1;

    // Add status filter
    if (status) {
      paramCounter++;
      whereConditions.push(`b.status = $${paramCounter}`);
      queryParams.push(status);
    }

    // Add date range filter
    if (dateFrom) {
      paramCounter++;
      whereConditions.push(`b.check_in >= $${paramCounter}`);
      queryParams.push(dateFrom);
    }

    if (dateTo) {
      paramCounter++;
      whereConditions.push(`b.check_out <= $${paramCounter}`);
      queryParams.push(dateTo);
    }

    // Calculate pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    const query = `
      SELECT 
        b.*,
        r.name as room_name,
        r.capacity as room_capacity,
        u.full_name as guest_name,
        u.email as guest_email,
        u.phone as guest_phone,
        h.name as homestay_name,
        pt.amount as payment_amount,
        pt.status as payment_status,
        pt.gateway_transaction_id
      FROM bookings b
      INNER JOIN homestay_rooms r ON b.room_id = r.id
      INNER JOIN homestays h ON r.homestay_id = h.id
      LEFT JOIN users u ON b.guest_id = u.id
      LEFT JOIN payment_transactions pt ON b.id = pt.booking_id AND pt.transaction_type = 'payment'
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY b.created_at DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query for pagination
    const countQuery = `
      SELECT COUNT(*) as total
      FROM bookings b
      INNER JOIN homestay_rooms r ON b.room_id = r.id
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [bookingsResult, countResult] = await Promise.all([
      pool.query(query, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    return {
      bookings: bookingsResult.rows,
      pagination: {
        currentPage: parseInt(page),
        totalPages,
        totalItems: total,
        itemsPerPage: parseInt(limit),
        hasNext: parseInt(page) < totalPages,
        hasPrev: parseInt(page) > 1
      }
    };
  }

  async getBookingById(bookingId) {
    const query = `
      SELECT 
        b.*,
        r.name as room_name,
        r.capacity as room_capacity,
        u.full_name as guest_name,
        u.email as guest_email,
        u.phone as guest_phone,
        h.name as homestay_name,
        h.district as homestay_district,
        h.taluka as homestay_taluka
      FROM bookings b
      INNER JOIN homestay_rooms r ON b.room_id = r.id
      INNER JOIN homestays h ON r.homestay_id = h.id
      LEFT JOIN users u ON b.guest_id = u.id
      WHERE b.id = $1
    `;

    const result = await pool.query(query, [bookingId]);
    return result.rows[0];
  }

  async getBookingsByUserId(userId, filters = {}) {
    const {
      status,
      dateFrom,
      dateTo,
      page = 1,
      limit = 20
    } = filters;

    let whereConditions = ['b.guest_id = $1'];
    let queryParams = [userId];
    let paramCounter = 1;

    if (status) {
      paramCounter++;
      whereConditions.push(`b.status = $${paramCounter}`);
      queryParams.push(status);
    }

    if (dateFrom) {
      paramCounter++;
      whereConditions.push(`b.check_in >= $${paramCounter}`);
      queryParams.push(dateFrom);
    }

    if (dateTo) {
      paramCounter++;
      whereConditions.push(`b.check_out <= $${paramCounter}`);
      queryParams.push(dateTo);
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    const query = `
      SELECT 
        b.*,
        r.name as room_name,
        r.capacity as room_capacity,
        h.name as homestay_name,
        h.district as homestay_district,
        h.taluka as homestay_taluka,
        h.grade as homestay_grade
      FROM bookings b
      INNER JOIN homestay_rooms r ON b.room_id = r.id
      INNER JOIN homestays h ON r.homestay_id = h.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY b.created_at DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    const countQuery = `
      SELECT COUNT(*) as total
      FROM bookings b
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [bookingsResult, countResult] = await Promise.all([
      pool.query(query, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    return {
      bookings: bookingsResult.rows,
      pagination: {
        currentPage: parseInt(page),
        totalPages,
        totalItems: total,
        itemsPerPage: parseInt(limit),
        hasNext: parseInt(page) < totalPages,
        hasPrev: parseInt(page) > 1
      }
    };
  }

  async createBooking(bookingData) {
    const {
      roomId,
      guestId,
      checkInDate,
      checkOutDate,
      guestsCount,
      totalAmount,
      specialRequests
    } = bookingData;

    const query = `
      INSERT INTO bookings (
        room_id, guest_id, check_in, check_out,
        guests, total, guest_note, status, subtotal
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;

    const values = [
      roomId, guestId, checkInDate, checkOutDate,
      guestsCount, totalAmount, specialRequests || null, 'pending_payment', totalAmount
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async updateBookingStatus(bookingId, status, additionalData = {}) {
    const updates = ['status = $2', 'updated_at = NOW()'];
    const values = [bookingId, status];
    let paramCounter = 2;

    if (additionalData.cancellationReason) {
      paramCounter++;
      updates.push(`cancellation_reason = $${paramCounter}`);
      values.push(additionalData.cancellationReason);
      
      paramCounter++;
      updates.push(`cancellation_date = $${paramCounter}`);
      values.push(new Date().toISOString());
    }

    if (additionalData.paymentTransactionId) {
      paramCounter++;
      updates.push(`payment_transaction_id = $${paramCounter}`);
      values.push(additionalData.paymentTransactionId);
    }

    const query = `
      UPDATE bookings 
      SET ${updates.join(', ')}
      WHERE id = $1
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async checkRoomAvailability(roomId, checkInDate, checkOutDate, excludeBookingId = null) {
    let query = `
      SELECT COUNT(*) as conflict_count
      FROM bookings
      WHERE room_id = $1
      AND status NOT IN ('canceled', 'completed')
      AND daterange($2, $3, '[]') && daterange(check_in, check_out, '[]')
    `;
    
    const params = [roomId, checkInDate, checkOutDate];

    if (excludeBookingId) {
      query += ' AND id != $4';
      params.push(excludeBookingId);
    }

    const result = await pool.query(query, params);
    return parseInt(result.rows[0].conflict_count) === 0;
  }

  async getHomestayOwner(homestayId) {
    const query = 'SELECT owner_id FROM homestays WHERE id = $1';
    const result = await pool.query(query, [homestayId]);
    return result.rows[0]?.owner_id;
  }
}

module.exports = BookingRepository;