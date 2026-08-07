// Server-side profile-completion heuristic backing specs/backend_new_changes.md
// §8. Ten equally-weighted signals (10% each) spanning basic contact info,
// business-profile fields, bank-settlement details, and verification status —
// deliberately simple/even-weighted rather than a tuned scoring model, since
// no product guidance on weighting exists yet.
const SIGNALS = [
  (user) => Boolean(user.full_name),
  (user) => Boolean(user.email),
  (user) => Boolean(user.phone),
  (user) => Boolean(user.district),
  (user) => Boolean(user.taluka),
  (user) => Boolean(user.profile_pic),
  (user) => Boolean(user.about_business),
  (user) => Boolean(user.address),
  (user) => Boolean(user.bank_account_number && user.bank_ifsc_code),
  (user) => Boolean(user.is_verified),
];

function computeProfileCompletion(user) {
  if (!user) return 0;
  const satisfied = SIGNALS.filter((check) => check(user)).length;
  return Math.round((satisfied / SIGNALS.length) * 100);
}

module.exports = { computeProfileCompletion };
