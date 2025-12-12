const express = require('express');
const { verifyJWT } = require('../middleware/auth');

const router = express.Router();

router.get('/me', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { points: 250, badges: ['Eco Ambassador'], level: 'Bronze' } });
  } catch (error) { next(error); }
});

router.post('/redeem', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Reward redeemed successfully' } });
  } catch (error) { next(error); }
});

router.get('/leaderboard', async (req, res, next) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) { next(error); }
});

module.exports = router;