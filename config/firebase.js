const admin = require('firebase-admin');

const serviceAccount = require("./samudrayan-fdce7-firebase-adminsdk-fbsvc-bb36bf0457.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = admin;

