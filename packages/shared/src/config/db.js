const { Pool } = require('pg');

let pool;

function getPool() {
  if (!pool) {
    pool = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      // Neon (prod/staging) requires SSL; a plain local docker-compose Postgres
      // container doesn't support it — default to on, opt out with DB_SSL=false.
      ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false },
      max: parseInt(process.env.DB_POOL_MAX || '10', 10),
      idleTimeoutMillis: 60000,
      connectionTimeoutMillis: 10000,
      keepAlive: true,
    });

    pool.on('error', (err) => {
      // eslint-disable-next-line no-console
      console.error('Unexpected error on idle Postgres client', err);
    });
  }
  return pool;
}

module.exports = { getPool };
