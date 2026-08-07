const admin = require('firebase-admin');
const shared = require('@samudrayan/shared');
const { AppError } = shared.middleware;
const { logger } = shared;

// Initialization is deliberately lazy (deferred to first actual use, via getAdmin())
// rather than run at require()-time, so a service can boot and serve /health even
// when Firebase credentials aren't configured (e.g. local dev without a Firebase
// project) — it only fails, with a clear error, on the first request that actually
// needs Firebase.
function getAdmin() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      }),
    });
  }
  return admin;
}

const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new AppError('No token provided', 401, 'NO_TOKEN'));
    }

    const token = authHeader.split(' ')[1];
    const decodedToken = await getAdmin().auth().verifyIdToken(token);

    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
    };

    next();
  } catch (error) {
    return next(new AppError('Invalid or expired token', 401, 'INVALID_TOKEN'));
  }
};

// Best-effort push delivery — never throws. A missing/invalid token, an
// unconfigured Firebase project, or an FCM outage must never fail the
// caller's primary request (mirrors the try/catch-wrapped audit-log-insert
// convention already used for verification_logs in services/admin).
async function sendPush(tokens, { title, body, data } = {}) {
  if (!tokens || !tokens.length) return;
  try {
    await getAdmin().messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data || {}).map(([k, v]) => [k, String(v)])
      ),
    });
  } catch (error) {
    logger.error('Push notification delivery failed', { error: error.message });
  }
}

// Creates an in-app notification row and best-effort fans it out as a push
// notification to every device token registered for that user. This is the
// single shared entry point every service should call on a notification-
// worthy event (new enquiry, booking approved/confirmed, new review,
// category-application approved/rejected, verification approved/rejected)
// so the DB-insert-plus-push behavior stays identical everywhere.
async function createNotification(pool, { userId, category, title, message }) {
  try {
    await pool.query(
      `INSERT INTO notifications (user_id, category, title, message)
       VALUES ($1, $2, $3, $4)`,
      [userId, category, title, message]
    );
  } catch (error) {
    logger.error('Failed to create notification', { error: error.message, userId });
    return;
  }

  try {
    const { rows } = await pool.query(
      'SELECT token FROM device_tokens WHERE user_id = $1',
      [userId]
    );
    const tokens = rows.map((r) => r.token);
    await sendPush(tokens, { title, body: message, data: { category } });
  } catch (error) {
    logger.error('Failed to push-deliver notification', { error: error.message, userId });
  }
}

module.exports = { getAdmin, verifyFirebaseToken, sendPush, createNotification };
