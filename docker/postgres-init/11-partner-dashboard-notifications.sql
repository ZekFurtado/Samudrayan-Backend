-- Backend support for the Samudrayan Partner App dashboard/bookings-hub/
-- notifications/account-console screens (see specs/backend_new_changes.md).
-- Idempotent: safe to re-run against an already-migrated database.

-- =====================================================================
-- 1. users: business-profile, bank-settlement, and partner-id fields
--    (specs/backend_new_changes.md §13a/13b/13d)
-- =====================================================================
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS partner_id VARCHAR(30) UNIQUE,
    ADD COLUMN IF NOT EXISTS organization_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS about_business TEXT,
    ADD COLUMN IF NOT EXISTS address TEXT,
    ADD COLUMN IF NOT EXISTS village VARCHAR(100),
    ADD COLUMN IF NOT EXISTS state VARCHAR(100),
    ADD COLUMN IF NOT EXISTS profile_pic TEXT,
    ADD COLUMN IF NOT EXISTS cover_photo_url TEXT,
    ADD COLUMN IF NOT EXISTS bank_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS bank_account_number VARCHAR(50),
    ADD COLUMN IF NOT EXISTS bank_ifsc_code VARCHAR(20),
    ADD COLUMN IF NOT EXISTS bank_upi_id VARCHAR(100);

CREATE INDEX IF NOT EXISTS idx_users_partner_id ON users(partner_id);

-- Per (year, category-code) atomic counter backing the human-readable
-- partner_id format 'SAM-{year}-{category-code}-{sequence}', e.g. SAM-2026-STY-0007.
CREATE TABLE IF NOT EXISTS partner_id_sequences (
    year INTEGER NOT NULL,
    category_code VARCHAR(3) NOT NULL,
    last_value INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (year, category_code)
);

-- =====================================================================
-- 2. bookings.status: widen the enquiry -> booking state machine
--    (specs/backend_new_changes.md §6/§11)
--    New stages: 'pending' (enquiry, not yet owner-approved) and
--    'approved' (owner-approved, awaiting guest payment). 'pending-payment'
--    keeps its original meaning: guest is mid-checkout, awaiting THEIR payment.
-- =====================================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'bookings_status_check' AND conrelid = 'bookings'::regclass
    ) THEN
        ALTER TABLE bookings DROP CONSTRAINT bookings_status_check;
    END IF;

    ALTER TABLE bookings ADD CONSTRAINT bookings_status_check CHECK (status IN (
        'pending', 'approved', 'pending-payment', 'confirmed', 'checked-in',
        'checked-out', 'cancelled', 'refunded', 'no-show'
    ));
END $$;

ALTER TABLE bookings ALTER COLUMN status SET DEFAULT 'pending';

-- =====================================================================
-- 3. partner_categories: multi-category partner accounts
--    (specs/backend_new_changes.md §9/§13c/§13e)
--    users.role remains the sole authz enum untouched by this table.
-- =====================================================================
CREATE TABLE IF NOT EXISTS partner_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id VARCHAR(30) NOT NULL CHECK (category_id IN (
        'stays', 'food', 'activities', 'events', 'rides', 'professional-services'
    )),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'rejected')),
    registration_number VARCHAR(255),
    description TEXT,
    document_url TEXT,
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_partner_category UNIQUE (user_id, category_id)
);

CREATE INDEX IF NOT EXISTS idx_partner_categories_user_id ON partner_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_partner_categories_status ON partner_categories(status);

DROP TRIGGER IF EXISTS update_partner_categories_updated_at ON partner_categories;
CREATE TRIGGER update_partner_categories_updated_at
    BEFORE UPDATE ON partner_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Best-effort audit trail for category-application approve/reject actions,
-- mirroring the (also best-effort, possibly-absent) verification_logs table
-- referenced by services/admin/src/routes/index.js for homestay verification.
CREATE TABLE IF NOT EXISTS category_application_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_category_id UUID REFERENCES partner_categories(id) ON DELETE CASCADE,
    admin_user_id TEXT,
    action VARCHAR(20) NOT NULL CHECK (action IN ('approved', 'rejected')),
    reason TEXT,
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_category_application_logs_partner_category_id
    ON category_application_logs(partner_category_id);

-- Backfill: existing single-category partners already operate a homestay or
-- restaurant business today, so they're grandfathered in as 'active' rather
-- than needing to (re-)apply for the category they already hold.
INSERT INTO partner_categories (user_id, category_id, status)
SELECT id, 'stays', 'active' FROM users WHERE role = 'homestay-owner'
ON CONFLICT (user_id, category_id) DO NOTHING;

INSERT INTO partner_categories (user_id, category_id, status)
SELECT id, 'food', 'active' FROM users WHERE role = 'restaurant-owner'
ON CONFLICT (user_id, category_id) DO NOTHING;

-- =====================================================================
-- 4. reviews: generalized rating/review submission for homestays and
--    restaurants (specs/backend_new_changes.md §2). No FK on listing_id
--    since it's polymorphic across two different tables; validity is
--    enforced in application code before insert.
-- =====================================================================
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_type VARCHAR(20) NOT NULL CHECK (listing_type IN ('homestay', 'restaurant')),
    listing_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_review_per_user_listing UNIQUE (listing_type, listing_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_listing ON reviews(listing_type, listing_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);

DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Homestays never got the rating/total_reviews columns restaurants have.
ALTER TABLE homestays
    ADD COLUMN IF NOT EXISTS rating DECIMAL(2, 1) NOT NULL DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    ADD COLUMN IF NOT EXISTS total_reviews INTEGER NOT NULL DEFAULT 0;

-- =====================================================================
-- 5. listing_views: view-count analytics for "Monthly Views"
--    (specs/backend_new_changes.md §5). BIGSERIAL, not UUID: this is
--    high-volume append-only telemetry, not a domain entity.
-- =====================================================================
CREATE TABLE IF NOT EXISTS listing_views (
    id BIGSERIAL PRIMARY KEY,
    listing_type VARCHAR(20) NOT NULL CHECK (listing_type IN ('homestay', 'restaurant')),
    listing_id UUID NOT NULL,
    viewer_user_id UUID REFERENCES users(id),
    viewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_listing_views_listing ON listing_views(listing_type, listing_id, viewed_at);

-- =====================================================================
-- 6. notifications (specs/backend_new_changes.md §3/§12)
--    category CHECK deliberately limited to announcement|alert per the
--    spec's own note that wider categories need product confirmation first.
-- =====================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(30) NOT NULL DEFAULT 'alert' CHECK (category IN ('announcement', 'alert')),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id) WHERE is_read = FALSE;

-- =====================================================================
-- 7. device_tokens: FCM push-notification delivery targets
-- =====================================================================
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    platform VARCHAR(20) CHECK (platform IN ('android', 'ios', 'web')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_device_token UNIQUE (user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);

DROP TRIGGER IF EXISTS update_device_tokens_updated_at ON device_tokens;
CREATE TRIGGER update_device_tokens_updated_at
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
