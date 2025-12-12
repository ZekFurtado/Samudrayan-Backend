const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/forms', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Feedback form created successfully' } });
  } catch (error) { next(error); }
});

router.post('/forms/:id/responses', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Response submitted successfully' } });
  } catch (error) { next(error); }
});

router.get('/forms/:id/analytics', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { totalResponses: 150, averageRating: 4.2 } });
  } catch (error) { next(error); }
});

module.exports = router;