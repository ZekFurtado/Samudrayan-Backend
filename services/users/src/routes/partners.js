const express = require('express');
const shared = require('@samudrayan/shared');
const { verifyJWT } = shared.middleware;
const { AppError } = shared.middleware;
const { PARTNER_CATEGORY_IDS } = shared.partnerCategories;
const UserRepository = require('../repositories/UserRepository');

const router = express.Router();
const userRepository = new UserRepository();

// Apply for an additional partner category (specs/backend_new_changes.md
// §9/§13c) — creates a 'pending' partner_categories row for admin review,
// mirroring the existing homestay-verification approve/reject pattern in
// services/admin. The category chosen at signup is auto-granted 'active'
// elsewhere (services/auth); this endpoint is only for *additional*
// categories requested later via Account Console.
router.post('/category-applications', verifyJWT, async (req, res, next) => {
  try {
    const { categoryId, registrationNumber, description, documentUrl } = req.body;

    if (!PARTNER_CATEGORY_IDS.includes(categoryId)) {
      return next(new AppError(
        `categoryId must be one of ${PARTNER_CATEGORY_IDS.join(', ')}`,
        400,
        'VALIDATION_ERROR'
      ));
    }

    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();
    const existing = await pool.query(
      'SELECT id, status FROM partner_categories WHERE user_id = $1 AND category_id = $2',
      [user.id, categoryId]
    );

    if (existing.rows.length > 0 && existing.rows[0].status !== 'rejected') {
      return next(new AppError(
        `You already have a ${existing.rows[0].status} application for this category`,
        409,
        'DUPLICATE_CATEGORY'
      ));
    }

    let result;
    if (existing.rows.length > 0) {
      // Re-applying after a prior rejection — reset to pending.
      result = await pool.query(
        `UPDATE partner_categories
         SET status = 'pending', registration_number = $1, description = $2, document_url = $3,
             reviewed_by = NULL, reviewed_at = NULL, updated_at = NOW()
         WHERE id = $4
         RETURNING *`,
        [registrationNumber || null, description || null, documentUrl || null, existing.rows[0].id]
      );
    } else {
      result = await pool.query(
        `INSERT INTO partner_categories (user_id, category_id, status, registration_number, description, document_url)
         VALUES ($1, $2, 'pending', $3, $4, $5)
         RETURNING *`,
        [user.id, categoryId, registrationNumber || null, description || null, documentUrl || null]
      );
    }

    res.status(201).json({
      success: true,
      data: {
        categoryId: result.rows[0].category_id,
        status: result.rows[0].status,
        message: 'Category application submitted for review',
      },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
