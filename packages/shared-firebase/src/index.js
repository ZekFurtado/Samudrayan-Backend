const admin = require('firebase-admin');
const { AppError } = require('@samudrayan/shared').middleware;

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

module.exports = { getAdmin, verifyFirebaseToken };
