const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/products', verifyJWT, authorize('artisan', 'fisherfolk', 'homestay-owner', 'admin'), async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Product created successfully' } });
  } catch (error) { next(error); }
});

router.get('/products', async (req, res, next) => {
  try {
    res.json({ success: true, data: [] });
  } catch (error) { next(error); }
});

router.post('/cart', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { message: 'Added to cart' } });
  } catch (error) { next(error); }
});

router.post('/orders', verifyJWT, async (req, res, next) => {
  try {
    res.json({ success: true, data: { orderId: 'sample-order-id', status: 'pending-payment' } });
  } catch (error) { next(error); }
});

module.exports = router;