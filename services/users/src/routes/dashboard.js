const express = require('express');
const shared = require('@samudrayan/shared');
const { verifyJWT } = shared.middleware;
const { AppError } = shared.middleware;
const { computeProfileCompletion } = shared;
const UserRepository = require('../repositories/UserRepository');

const router = express.Router();
const userRepository = new UserRepository();

// Backs the 6 dashboard stat cards + profile-completion bar
// (specs/backend_new_changes.md §1). homestays.owner_id stores the owner's
// firebase_uid while restaurants.owner_id is a users.id UUID (a pre-existing
// inconsistency between the two tables), so each listing type is queried
// separately with its own key and summed in application code rather than one
// fragile UNION query.
router.get('/summary', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();

    const [homestaysResult, restaurantsResult] = await Promise.all([
      pool.query('SELECT id, status, rating, total_reviews FROM homestays WHERE owner_id = $1', [req.user.uid]),
      pool.query('SELECT id, status, rating, total_reviews FROM restaurants WHERE owner_id = $1', [user.id]),
    ]);

    const homestays = homestaysResult.rows;
    const restaurants = restaurantsResult.rows;
    const homestayIds = homestays.map((h) => h.id);
    const restaurantIds = restaurants.map((r) => r.id);

    const activeListings = homestays.filter((h) => h.status === 'active').length
      + restaurants.filter((r) => r.status === 'active').length;
    const pendingListings = homestays.filter((h) => h.status === 'pending-verification').length
      + restaurants.filter((r) => r.status === 'pending-verification').length;

    let newEnquiries = 0;
    if (homestayIds.length) {
      const result = await pool.query(
        `SELECT COUNT(*) as count FROM bookings b
         INNER JOIN homestay_rooms r ON b.room_id = r.id
         WHERE r.homestay_id = ANY($1) AND b.status = 'pending'`,
        [homestayIds]
      );
      newEnquiries += parseInt(result.rows[0].count, 10);
    }
    if (restaurantIds.length) {
      const result = await pool.query(
        `SELECT COUNT(*) as count FROM restaurant_reservations
         WHERE restaurant_id = ANY($1) AND status = 'pending'`,
        [restaurantIds]
      );
      newEnquiries += parseInt(result.rows[0].count, 10);
    }

    let todaysBookings = 0;
    if (homestayIds.length) {
      const result = await pool.query(
        `SELECT COUNT(*) as count FROM bookings b
         INNER JOIN homestay_rooms r ON b.room_id = r.id
         WHERE r.homestay_id = ANY($1) AND b.check_in_date = CURRENT_DATE
         AND b.status IN ('confirmed', 'checked-in')`,
        [homestayIds]
      );
      todaysBookings += parseInt(result.rows[0].count, 10);
    }
    if (restaurantIds.length) {
      const result = await pool.query(
        `SELECT COUNT(*) as count FROM restaurant_reservations
         WHERE restaurant_id = ANY($1) AND reservation_date = CURRENT_DATE AND status = 'confirmed'`,
        [restaurantIds]
      );
      todaysBookings += parseInt(result.rows[0].count, 10);
    }

    let monthlyViews = 0;
    if (homestayIds.length || restaurantIds.length) {
      const result = await pool.query(
        `SELECT COUNT(*) as count FROM listing_views
         WHERE viewed_at >= NOW() - INTERVAL '30 days'
         AND ((listing_type = 'homestay' AND listing_id = ANY($1))
           OR (listing_type = 'restaurant' AND listing_id = ANY($2)))`,
        [homestayIds, restaurantIds]
      );
      monthlyViews = parseInt(result.rows[0].count, 10);
    }

    const ratedListings = [...homestays, ...restaurants].filter((l) => l.total_reviews > 0);
    const averageRating = ratedListings.length
      ? ratedListings.reduce((sum, l) => sum + parseFloat(l.rating), 0) / ratedListings.length
      : 0;

    res.json({
      success: true,
      data: {
        activeListings,
        pendingListings,
        newEnquiries,
        todaysBookings,
        monthlyViews,
        averageRating: Math.round(averageRating * 10) / 10,
        profileCompletionPercent: computeProfileCompletion(user),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Computed/derived feed rather than a new write-instrumented audit-log table
// (specs/backend_new_changes.md §4 is explicitly "Low" priority) — unions
// recent booking-status changes, reviews, and category-application status
// changes across every listing this partner owns, sorted by recency.
router.get('/activity', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();
    const limit = parseInt(req.query.limit) || 20;

    const [homestaysResult, restaurantsResult] = await Promise.all([
      pool.query('SELECT id FROM homestays WHERE owner_id = $1', [req.user.uid]),
      pool.query('SELECT id FROM restaurants WHERE owner_id = $1', [user.id]),
    ]);
    const homestayIds = homestaysResult.rows.map((h) => h.id);
    const restaurantIds = restaurantsResult.rows.map((r) => r.id);

    const activities = [];

    if (homestayIds.length) {
      const [bookingActivity, reviewActivity] = await Promise.all([
        pool.query(
          `SELECT b.status, b.updated_at, h.name as listing_name
           FROM bookings b
           INNER JOIN homestay_rooms r ON b.room_id = r.id
           INNER JOIN homestays h ON r.homestay_id = h.id
           WHERE h.id = ANY($1)
           ORDER BY b.updated_at DESC LIMIT $2`,
          [homestayIds, limit]
        ),
        pool.query(
          `SELECT rv.rating, rv.created_at, h.name as listing_name
           FROM reviews rv
           INNER JOIN homestays h ON rv.listing_id = h.id AND rv.listing_type = 'homestay'
           WHERE h.id = ANY($1)
           ORDER BY rv.created_at DESC LIMIT $2`,
          [homestayIds, limit]
        ),
      ]);
      bookingActivity.rows.forEach((row) => activities.push({
        type: 'booking',
        message: `Booking for "${row.listing_name}" is now ${row.status}`,
        timestamp: row.updated_at,
      }));
      reviewActivity.rows.forEach((row) => activities.push({
        type: 'review',
        message: `New ${row.rating}-star review for "${row.listing_name}"`,
        timestamp: row.created_at,
      }));
    }

    if (restaurantIds.length) {
      const [reservationActivity, reviewActivity] = await Promise.all([
        pool.query(
          `SELECT rr.status, rr.updated_at, rt.name as listing_name
           FROM restaurant_reservations rr
           INNER JOIN restaurants rt ON rr.restaurant_id = rt.id
           WHERE rt.id = ANY($1)
           ORDER BY rr.updated_at DESC LIMIT $2`,
          [restaurantIds, limit]
        ),
        pool.query(
          `SELECT rv.rating, rv.created_at, rt.name as listing_name
           FROM reviews rv
           INNER JOIN restaurants rt ON rv.listing_id = rt.id AND rv.listing_type = 'restaurant'
           WHERE rt.id = ANY($1)
           ORDER BY rv.created_at DESC LIMIT $2`,
          [restaurantIds, limit]
        ),
      ]);
      reservationActivity.rows.forEach((row) => activities.push({
        type: 'reservation',
        message: `Reservation at "${row.listing_name}" is now ${row.status}`,
        timestamp: row.updated_at,
      }));
      reviewActivity.rows.forEach((row) => activities.push({
        type: 'review',
        message: `New ${row.rating}-star review for "${row.listing_name}"`,
        timestamp: row.created_at,
      }));
    }

    const categoryActivity = await pool.query(
      `SELECT category_id, status, updated_at FROM partner_categories
       WHERE user_id = $1 AND status != 'pending'
       ORDER BY updated_at DESC LIMIT $2`,
      [user.id, limit]
    );
    categoryActivity.rows.forEach((row) => activities.push({
      type: 'category-application',
      message: `Your "${row.category_id}" category application is now ${row.status}`,
      timestamp: row.updated_at,
    }));

    activities.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    res.json({
      success: true,
      data: { activities: activities.slice(0, limit) },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
