const express = require('express');
const { verifyJWT, authorize } = require('@samudrayan/shared').middleware;
const { createNotification } = require('@samudrayan/shared-firebase');

const router = express.Router();

// Admin approve/reject flow for partner_categories applications
// (specs/backend_new_changes.md §9/§13c) — mirrors the existing homestay
// verification pending/detail/approve/reject shape in ./index.js exactly,
// including the best-effort (try/catch-wrapped) audit-log insert and
// district-admin scoping conventions.

router.get('/category-applications/pending', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const { district, page = 1, limit = 20 } = req.query;

    let whereConditions = ["pc.status = 'pending'"];
    let queryParams = [];
    let paramCounter = 0;

    if (req.user.userType === 'district-admin' && req.user.district) {
      paramCounter++;
      whereConditions.push(`u.district = $${paramCounter}`);
      queryParams.push(req.user.district);
    } else if (district && req.user.userType === 'admin') {
      paramCounter++;
      whereConditions.push(`u.district ILIKE $${paramCounter}`);
      queryParams.push(`%${district}%`);
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    const query = `
      SELECT
        pc.id, pc.category_id, pc.registration_number, pc.description, pc.document_url,
        pc.created_at,
        u.id as user_id, u.full_name, u.email, u.phone, u.district, u.taluka, u.role as user_type
      FROM partner_categories pc
      INNER JOIN users u ON pc.user_id = u.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY pc.created_at ASC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    const countQuery = `
      SELECT COUNT(*) as total
      FROM partner_categories pc
      INNER JOIN users u ON pc.user_id = u.id
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [applicationsResult, countResult] = await Promise.all([
      pool.query(query, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2)),
    ]);

    const applications = applicationsResult.rows.map((row) => ({
      id: row.id,
      categoryId: row.category_id,
      registrationNumber: row.registration_number,
      description: row.description,
      documentUrl: row.document_url,
      applicant: {
        userId: row.user_id,
        name: row.full_name,
        email: row.email,
        phone: row.phone,
        userType: row.user_type,
        district: row.district,
        taluka: row.taluka,
      },
      submittedAt: row.created_at,
    }));

    const total = parseInt(countResult.rows[0].total, 10);
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        applications,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1,
        },
      },
    });
  } catch (error) {
    console.error('Error fetching pending category applications:', error);
    next(error);
  }
});

router.get('/category-applications/:id', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const applicationId = req.params.id;

    const query = `
      SELECT
        pc.*, u.full_name, u.email, u.phone, u.district, u.taluka, u.role as user_type
      FROM partner_categories pc
      INNER JOIN users u ON pc.user_id = u.id
      WHERE pc.id = $1
    `;
    const result = await pool.query(query, [applicationId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'APPLICATION_NOT_FOUND', message: 'Category application not found' },
      });
    }

    const row = result.rows[0];

    if (req.user.userType === 'district-admin' && req.user.district && req.user.district !== row.district) {
      return res.status(403).json({
        success: false,
        error: { code: 'INSUFFICIENT_PERMISSIONS', message: 'District admin can only view applications in their district' },
      });
    }

    res.json({
      success: true,
      data: {
        id: row.id,
        categoryId: row.category_id,
        status: row.status,
        registrationNumber: row.registration_number,
        description: row.description,
        documentUrl: row.document_url,
        applicant: {
          userId: row.user_id,
          name: row.full_name,
          email: row.email,
          phone: row.phone,
          userType: row.user_type,
          district: row.district,
          taluka: row.taluka,
        },
        submittedAt: row.created_at,
        reviewedAt: row.reviewed_at,
      },
    });
  } catch (error) {
    console.error('Error fetching category application:', error);
    next(error);
  }
});

router.post('/category-applications/:id/approve', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const applicationId = req.params.id;
    const { comments } = req.body;

    const appResult = await pool.query(
      `SELECT pc.*, u.district as applicant_district
       FROM partner_categories pc
       INNER JOIN users u ON pc.user_id = u.id
       WHERE pc.id = $1`,
      [applicationId]
    );

    if (appResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'APPLICATION_NOT_FOUND', message: 'Category application not found' },
      });
    }

    const application = appResult.rows[0];

    if (application.status !== 'pending') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_STATUS',
          message: `Application is already ${application.status}. Can only approve pending applications.`,
        },
      });
    }

    if (req.user.userType === 'district-admin' && req.user.district && req.user.district !== application.applicant_district) {
      return res.status(403).json({
        success: false,
        error: { code: 'INSUFFICIENT_PERMISSIONS', message: 'District admin can only approve applications in their district' },
      });
    }

    const updateResult = await pool.query(
      `UPDATE partner_categories
       SET status = 'active', reviewed_by = $1, reviewed_at = NOW(), updated_at = NOW()
       WHERE id = $2
       RETURNING id, user_id, category_id, status`,
      [req.user.userId, applicationId]
    );
    const updated = updateResult.rows[0];

    try {
      await pool.query(
        `INSERT INTO category_application_logs (partner_category_id, admin_user_id, action, comments)
         VALUES ($1, $2, 'approved', $3)`,
        [applicationId, req.user.uid, comments || 'Category application approved']
      );
    } catch (logError) {
      console.log('category_application_logs insert skipped:', logError.message);
    }

    createNotification(pool, {
      userId: updated.user_id,
      category: 'alert',
      title: 'Category application approved',
      message: `Your application for the "${updated.category_id}" category has been approved.`,
    }).catch(() => {});

    res.json({
      success: true,
      data: {
        id: updated.id,
        categoryId: updated.category_id,
        status: updated.status,
        approvedBy: { userId: req.user.uid, userType: req.user.userType },
        approvedAt: new Date().toISOString(),
        comments,
        message: 'Category application approved successfully',
      },
    });
  } catch (error) {
    console.error('Error approving category application:', error);
    next(error);
  }
});

router.post('/category-applications/:id/reject', verifyJWT, authorize('admin', 'district-admin'), async (req, res, next) => {
  try {
    const pool = require('@samudrayan/shared').db.getPool();
    const applicationId = req.params.id;
    const { reason, comments } = req.body;

    if (!reason) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'Rejection reason is required' },
      });
    }

    const appResult = await pool.query(
      `SELECT pc.*, u.district as applicant_district
       FROM partner_categories pc
       INNER JOIN users u ON pc.user_id = u.id
       WHERE pc.id = $1`,
      [applicationId]
    );

    if (appResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { code: 'APPLICATION_NOT_FOUND', message: 'Category application not found' },
      });
    }

    const application = appResult.rows[0];

    if (application.status !== 'pending') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_STATUS',
          message: `Application is already ${application.status}. Can only reject pending applications.`,
        },
      });
    }

    if (req.user.userType === 'district-admin' && req.user.district && req.user.district !== application.applicant_district) {
      return res.status(403).json({
        success: false,
        error: { code: 'INSUFFICIENT_PERMISSIONS', message: 'District admin can only reject applications in their district' },
      });
    }

    const updateResult = await pool.query(
      `UPDATE partner_categories
       SET status = 'rejected', reviewed_by = $1, reviewed_at = NOW(), updated_at = NOW()
       WHERE id = $2
       RETURNING id, user_id, category_id, status`,
      [req.user.userId, applicationId]
    );
    const updated = updateResult.rows[0];

    try {
      await pool.query(
        `INSERT INTO category_application_logs (partner_category_id, admin_user_id, action, reason, comments)
         VALUES ($1, $2, 'rejected', $3, $4)`,
        [applicationId, req.user.uid, reason, comments || 'Category application rejected']
      );
    } catch (logError) {
      console.log('category_application_logs insert skipped:', logError.message);
    }

    createNotification(pool, {
      userId: updated.user_id,
      category: 'alert',
      title: 'Category application rejected',
      message: `Your application for the "${updated.category_id}" category was rejected: ${reason}`,
    }).catch(() => {});

    res.json({
      success: true,
      data: {
        id: updated.id,
        categoryId: updated.category_id,
        status: updated.status,
        rejectedBy: { userId: req.user.uid, userType: req.user.userType },
        rejectedAt: new Date().toISOString(),
        reason,
        comments,
        message: 'Category application rejected',
      },
    });
  } catch (error) {
    console.error('Error rejecting category application:', error);
    next(error);
  }
});

module.exports = router;
