const express = require('express');
const authRoutes = require('./auth');
const userRoutes = require('./users');
const masterRoutes = require('./master');
const homestayRoutes = require('./homestays');
const tourismRoutes = require('./tourism');
const marketplaceRoutes = require('./marketplace');
const learningRoutes = require('./learning');
const csrRoutes = require('./csr');
const eventRoutes = require('./events');
const blueEconomyRoutes = require('./blue-economy');
const feedbackRoutes = require('./feedback');
const rewardRoutes = require('./rewards');
const adminRoutes = require('./admin');
const verificationRoutes = require('./verification');
const databaseAdminRoutes = require('./database-admin');

const router = express.Router();

router.get('/health', (req, res) => {
  res.json({
    success: true,
    data: {
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
    },
  });
});

router.get('/config', (req, res) => {
  res.json({
    success: true,
    data: {
      languages: ['en', 'mr'],
      features: {
        offlineMode: true,
        gamification: true,
        csrIntegration: true,
      },
      constants: {
        maxFileSize: process.env.MAX_FILE_SIZE || 10485760,
        supportedImageFormats: ['jpg', 'jpeg', 'png', 'webp'],
        supportedDocFormats: ['pdf', 'doc', 'docx'],
      },
    },
  });
});

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/master', masterRoutes);
router.use('/homestays', homestayRoutes);
router.use('/tourism', tourismRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/learning', learningRoutes);
router.use('/csr', csrRoutes);
router.use('/events', eventRoutes);
router.use('/blue-economy', blueEconomyRoutes);
router.use('/feedback', feedbackRoutes);
router.use('/rewards', rewardRoutes);
router.use('/admin', adminRoutes);
router.use('/verification', verificationRoutes);
router.use('/database-admin', databaseAdminRoutes);

module.exports = router;