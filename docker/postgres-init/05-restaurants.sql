-- =============================================================================
-- Restaurant Management Module — Database Schema
-- Run order: after create-users-table.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. Shared trigger function (idempotent; also used by other modules)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 1. Extend the users role enum to include restaurant-owner
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'users_role_check'
          AND conrelid = 'users'::regclass
    ) THEN
        -- Only alter if restaurant-owner is not already present
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'users_role_check'
              AND conrelid = 'users'::regclass
              AND pg_get_constraintdef(oid) LIKE '%restaurant-owner%'
        ) THEN
            ALTER TABLE users DROP CONSTRAINT users_role_check;
            ALTER TABLE users ADD CONSTRAINT users_role_check
                CHECK (role IN (
                    'admin', 'district-admin', 'taluka-admin',
                    'homestay-owner', 'fisherfolk', 'artisan',
                    'ngo', 'investor', 'tourist', 'trainer',
                    'verified-reporter', 'restaurant-owner'
                ));
        END IF;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 2. restaurants
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurants (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id            UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Core details
    name                VARCHAR(255)    NOT NULL,
    description         TEXT,
    cuisine_type        VARCHAR(100),

    -- Contact
    contact_phone       VARCHAR(15),
    contact_email       VARCHAR(255),

    -- Location
    address             TEXT            NOT NULL,
    district            VARCHAR(100)    NOT NULL,
    taluka              VARCHAR(100)    NOT NULL,
    location_lat        DECIMAL(10, 8),
    location_lng        DECIMAL(11, 8),

    -- Operations
    opening_hours       JSONB,          -- {"monday":{"open":"09:00","close":"22:00"}, ...}
    average_cost_for_two DECIMAL(10, 2),
    seating_capacity    INTEGER         CHECK (seating_capacity IS NULL OR seating_capacity > 0),

    -- Media & amenities
    amenities           TEXT[],
    photos              TEXT[],

    -- Status & ratings
    status              VARCHAR(30)     NOT NULL DEFAULT 'pending-verification'
                            CHECK (status IN ('pending-verification', 'active', 'inactive', 'suspended')),
    is_verified         BOOLEAN         NOT NULL DEFAULT FALSE,
    rating              DECIMAL(2, 1)   NOT NULL DEFAULT 0.0
                            CHECK (rating >= 0 AND rating <= 5),
    total_reviews       INTEGER         NOT NULL DEFAULT 0,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Prevent duplicate restaurant names per owner
    CONSTRAINT uq_restaurant_owner_name UNIQUE (owner_id, name)
);

CREATE INDEX IF NOT EXISTS idx_restaurants_owner_id    ON restaurants(owner_id);
CREATE INDEX IF NOT EXISTS idx_restaurants_district    ON restaurants(district);
CREATE INDEX IF NOT EXISTS idx_restaurants_taluka      ON restaurants(taluka);
CREATE INDEX IF NOT EXISTS idx_restaurants_status      ON restaurants(status);
CREATE INDEX IF NOT EXISTS idx_restaurants_cuisine     ON restaurants(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_restaurants_name_search ON restaurants USING gin(to_tsvector('english', name));

DROP TRIGGER IF EXISTS trg_restaurants_updated_at ON restaurants;
CREATE TRIGGER trg_restaurants_updated_at
    BEFORE UPDATE ON restaurants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE restaurants IS 'Restaurant listings created by restaurant-owner users';
COMMENT ON COLUMN restaurants.opening_hours     IS 'JSONB: {"monday":{"open":"HH:MM","close":"HH:MM"}, ...}';
COMMENT ON COLUMN restaurants.amenities         IS 'Array of feature strings, e.g. ["WiFi","AC","Parking"]';
COMMENT ON COLUMN restaurants.photos            IS 'Array of photo URLs';

-- ---------------------------------------------------------------------------
-- 3. restaurant_menu
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurant_menu (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id       UUID            NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,

    category            VARCHAR(100)    NOT NULL,   -- "Starters", "Main Course", etc.
    item_name           VARCHAR(255)    NOT NULL,
    description         TEXT,
    price               DECIMAL(10, 2)  NOT NULL CHECK (price >= 0),

    -- Dietary flags
    is_vegetarian       BOOLEAN         NOT NULL DEFAULT FALSE,
    is_vegan            BOOLEAN         NOT NULL DEFAULT FALSE,
    contains_gluten     BOOLEAN         NOT NULL DEFAULT FALSE,

    spice_level         VARCHAR(20)     CHECK (spice_level IN ('mild', 'medium', 'spicy', 'very-spicy')),
    preparation_time    INTEGER         CHECK (preparation_time IS NULL OR preparation_time > 0), -- minutes
    photo_url           TEXT,
    is_available        BOOLEAN         NOT NULL DEFAULT TRUE,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_menu_restaurant_id ON restaurant_menu(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_menu_category      ON restaurant_menu(restaurant_id, category);
CREATE INDEX IF NOT EXISTS idx_menu_available     ON restaurant_menu(restaurant_id, is_available);

DROP TRIGGER IF EXISTS trg_restaurant_menu_updated_at ON restaurant_menu;
CREATE TRIGGER trg_restaurant_menu_updated_at
    BEFORE UPDATE ON restaurant_menu
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE restaurant_menu IS 'Menu items for each restaurant, grouped by category';

-- ---------------------------------------------------------------------------
-- 4. restaurant_reservations
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurant_reservations (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id       UUID            NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    customer_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Customer contact (captured at booking time, independent of user profile)
    customer_name       VARCHAR(255)    NOT NULL,
    customer_phone      VARCHAR(15)     NOT NULL,
    customer_email      VARCHAR(255),

    -- Booking details
    reservation_date    DATE            NOT NULL,
    reservation_time    TIME            NOT NULL,
    party_size          INTEGER         NOT NULL CHECK (party_size > 0),
    special_requests    TEXT,
    table_preference    VARCHAR(100),   -- "window", "corner", "outdoor", etc.

    -- Lifecycle
    status              VARCHAR(20)     NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no-show')),
    confirmed_at        TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    cancellation_reason TEXT,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Ensure confirmed_at is populated when status is confirmed
    CONSTRAINT chk_confirmed_at CHECK (
        status != 'confirmed' OR confirmed_at IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_reservations_restaurant_id ON restaurant_reservations(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_reservations_customer_id   ON restaurant_reservations(customer_id);
CREATE INDEX IF NOT EXISTS idx_reservations_date          ON restaurant_reservations(restaurant_id, reservation_date);
CREATE INDEX IF NOT EXISTS idx_reservations_status        ON restaurant_reservations(restaurant_id, status);

DROP TRIGGER IF EXISTS trg_restaurant_reservations_updated_at ON restaurant_reservations;
CREATE TRIGGER trg_restaurant_reservations_updated_at
    BEFORE UPDATE ON restaurant_reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE restaurant_reservations IS 'Table reservation requests and their lifecycle status';
COMMENT ON COLUMN restaurant_reservations.customer_name  IS 'Name as provided at booking time (may differ from users.full_name)';
COMMENT ON COLUMN restaurant_reservations.table_preference IS 'Free-text seating preference, e.g. window / corner / outdoor';

-- ---------------------------------------------------------------------------
-- 5. restaurant_time_slots  (optional: structured slot management)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurant_time_slots (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id   UUID        NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,

    day_of_week     SMALLINT    NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday
    start_time      TIME        NOT NULL,
    end_time        TIME        NOT NULL,
    max_capacity    INTEGER     NOT NULL CHECK (max_capacity > 0),
    slot_duration   INTEGER     NOT NULL DEFAULT 60 CHECK (slot_duration > 0), -- minutes
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_time_slot UNIQUE (restaurant_id, day_of_week, start_time),
    CONSTRAINT chk_end_after_start CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_time_slots_restaurant_id ON restaurant_time_slots(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_time_slots_day           ON restaurant_time_slots(restaurant_id, day_of_week);

DROP TRIGGER IF EXISTS trg_restaurant_time_slots_updated_at ON restaurant_time_slots;
CREATE TRIGGER trg_restaurant_time_slots_updated_at
    BEFORE UPDATE ON restaurant_time_slots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE restaurant_time_slots IS 'Available booking time slots per restaurant per day';
COMMENT ON COLUMN restaurant_time_slots.day_of_week IS '0=Sunday, 1=Monday … 6=Saturday';
COMMENT ON COLUMN restaurant_time_slots.slot_duration IS 'Duration of each slot in minutes (default 60)';
