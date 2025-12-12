const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Event created successfully' } });
  } catch (error) { next(error); }
});

router.get('/', async (req, res, next) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) { next(error); }
});

router.post('/:id/register', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { registrationId: 'sample-registration-id' } });
  } catch (error) { next(error); }
});

module.exports = router;