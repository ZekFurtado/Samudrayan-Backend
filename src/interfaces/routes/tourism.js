const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/spots', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Tourism spot created successfully' } });
  } catch (error) { next(error); }
});

router.get('/spots', async (req, res, next) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) { next(error); }
});

module.exports = router;