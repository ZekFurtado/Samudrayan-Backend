const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { logger, middleware } = require('@samudrayan/shared');
const routes = require('./routes');
const notificationsRoutes = require('./routes/notifications');
const partnersRoutes = require('./routes/partners');
const dashboardRoutes = require('./routes/dashboard');

const app = express();

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
}));

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));

app.use(morgan('combined', {
  stream: { write: (message) => logger.info(message.trim()) },
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// This service answers behind four separate gateway path prefixes (see
// gateway/nginx.conf and microservices_deployment_scripts/step4.sh) — not
// just /api/v1/users — because routes/notifications.js, routes/partners.js,
// and routes/dashboard.js are all mounted here too.
const PUBLIC_PREFIXES = ['/api/v1/users', '/api/v1/notifications', '/api/v1/dashboard', '/api/v1/partners'];
app.use((req, res, next) => {
  const queryIndex = req.url.indexOf('?');
  const path = queryIndex === -1 ? req.url : req.url.slice(0, queryIndex);
  const query = queryIndex === -1 ? '' : req.url.slice(queryIndex);

  const prefix = PUBLIC_PREFIXES.find((p) => path === p || path.startsWith(`${p}/`));
  if (prefix) {
    req.url = (path.slice(prefix.length) || '/') + query;
  }
  next();
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    data: {
      status: 'OK',
      service: 'users',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
    },
  });
});

app.use('/', routes);
app.use('/', notificationsRoutes);
app.use('/', partnersRoutes);
app.use('/', dashboardRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.originalUrl} not found`,
    },
  });
});

app.use(middleware.errorHandler);

process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  process.exit(1);
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

module.exports = app;
