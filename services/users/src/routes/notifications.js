const express = require('express');
const shared = require('@samudrayan/shared');
const { verifyJWT } = shared.middleware;
const { AppError } = shared.middleware;
const UserRepository = require('../repositories/UserRepository');

const router = express.Router();
const userRepository = new UserRepository();

// Contract mirrors specs/backend_new_changes.md §12 exactly (the Flutter
// Notifications screen is already coded against this shape) — a top-level
// `notifications` array, not nested under `data` like the rest of this API.
router.get('/', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const [listResult, unreadResult] = await Promise.all([
      pool.query(
        `SELECT id, category, title, message, is_read, created_at
         FROM notifications WHERE user_id = $1
         ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
        [user.id, limit, offset]
      ),
      pool.query(
        'SELECT COUNT(*) as unread FROM notifications WHERE user_id = $1 AND is_read = FALSE',
        [user.id]
      ),
    ]);

    res.json({
      success: true,
      notifications: listResult.rows.map((n) => ({
        id: n.id,
        category: n.category,
        title: n.title,
        message: n.message,
        createdAt: n.created_at,
        isRead: n.is_read,
      })),
      unreadCount: parseInt(unreadResult.rows[0].unread, 10),
    });
  } catch (error) {
    next(error);
  }
});

router.patch('/:id/read', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();
    await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2',
      [req.params.id, user.id]
    );

    res.json({ success: true, data: { message: 'Notification marked as read' } });
  } catch (error) {
    next(error);
  }
});

router.post('/read-all', verifyJWT, async (req, res, next) => {
  try {
    const user = await userRepository.findByFirebaseUid(req.user.uid);
    if (!user) {
      return next(new AppError('User not found', 404, 'USER_NOT_FOUND'));
    }

    const pool = shared.db.getPool();
    await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE',
      [user.id]
    );

    res.json({ success: true, data: { message: 'All notifications marked as read' } });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
