require('dotenv').config();
const app = require('./app');
const { logger } = require('@samudrayan/shared');

const PORT = process.env.PORT || 4001;

const server = app.listen(PORT, () => {
  logger.info(`auth-service listening on port ${PORT}`);
});

const gracefulShutdown = () => {
  logger.info('Received shutdown signal, gracefully closing server...');
  server.close(() => {
    logger.info('Server closed.');
    process.exit(0);
  });
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);
