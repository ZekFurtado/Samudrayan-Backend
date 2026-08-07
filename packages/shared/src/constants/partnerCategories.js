// The 6 partner-account categories from the Flutter onboarding "Select Primary
// Category" screen (specs/backend_new_changes.md §9/§13e) — deliberately kept
// separate from the users.role authz enum, see partner_categories table.
const PARTNER_CATEGORY_IDS = ['stays', 'food', 'activities', 'events', 'rides', 'professional-services'];

const PARTNER_CATEGORY_LABELS = {
  stays: 'Stays',
  food: 'Food',
  activities: 'Activities',
  events: 'Events',
  rides: 'Rides',
  'professional-services': 'Professional Services',
};

// Best-effort mapping from the pre-existing single-role userType enum onto the
// primary category it corresponds to, used to auto-grant a category at
// registration time. Roles with no natural category (fisherfolk/artisan/ngo/
// investor/tourist/trainer/admin/etc.) are intentionally absent — those users
// hold no category until they explicitly apply for one.
const ROLE_TO_PRIMARY_CATEGORY = {
  'homestay-owner': 'stays',
  'restaurant-owner': 'food',
};

const CATEGORY_CODE = {
  stays: 'STY',
  food: 'FOD',
  activities: 'ACT',
  events: 'EVT',
  rides: 'RID',
  'professional-services': 'PRO',
};

module.exports = {
  PARTNER_CATEGORY_IDS,
  PARTNER_CATEGORY_LABELS,
  ROLE_TO_PRIMARY_CATEGORY,
  CATEGORY_CODE,
};
