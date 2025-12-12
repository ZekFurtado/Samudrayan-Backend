const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/records', verifyJWT, authorize('admin', 'verified-reporter'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Blue economy record created successfully' } });
  } catch (error) { next(error); }
});

router.get('/records', async (req, res, next) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) { next(error); }
});

module.exports = router;