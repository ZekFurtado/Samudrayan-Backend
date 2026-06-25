-- Add restaurant-owner role to existing users table role enum
-- First check if restaurant-owner is not already in the enum
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'users_role_check' 
        AND conbin LIKE '%restaurant-owner%'
    ) THEN
        -- Drop the existing constraint
        ALTER TABLE users DROP CONSTRAINT users_role_check;
        
        -- Add the new constraint with restaurant-owner included
        ALTER TABLE users ADD CONSTRAINT users_role_check 
        CHECK (role IN (
            'admin', 'district-admin', 'taluka-admin', 'homestay-owner', 
            'fisherfolk', 'artisan', 'ngo', 'investor', 'tourist', 'trainer', 'restaurant-owner'
        ));
    END IF;
END $$;

-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    cuisine_type VARCHAR(100),
    contact_phone VARCHAR(15),
    contact_email VARCHAR(255),
    address TEXT NOT NULL,
    district VARCHAR(100) NOT NULL,
    taluka VARCHAR(100) NOT NULL,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    opening_hours JSONB, -- Store as {"monday": {"open": "09:00", "close": "22:00"}, ...}
    average_cost_for_two DECIMAL(10, 2),
    seating_capacity INTEGER,
    amenities TEXT[], -- Array of amenities like ["WiFi", "AC", "Parking", "Live Music"]
    photos TEXT[], -- Array of photo URLs
    status VARCHAR(20) DEFAULT 'pending-verification' CHECK (status IN ('pending-verification', 'active', 'inactive', 'suspended')),
    is_verified BOOLEAN DEFAULT FALSE,
    rating DECIMAL(2, 1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create restaurant menu table
CREATE TABLE IF NOT EXISTS restaurant_menu (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL, -- e.g., "Starters", "Main Course", "Desserts", "Beverages"
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    contains_gluten BOOLEAN DEFAULT FALSE,
    spice_level VARCHAR(20) CHECK (spice_level IN ('mild', 'medium', 'spicy', 'very-spicy')),
    preparation_time INTEGER, -- in minutes
    is_available BOOLEAN DEFAULT TRUE,
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create restaurant reservations table
CREATE TABLE IF NOT EXISTS restaurant_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(15) NOT NULL,
    customer_email VARCHAR(255),
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INTEGER NOT NULL CHECK (party_size > 0),
    special_requests TEXT,
    table_preference VARCHAR(100), -- e.g., "window", "corner", "outdoor"
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no-show')),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create restaurant time slots table (for managing available time slots)
CREATE TABLE IF NOT EXISTS restaurant_time_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0 = Sunday, 6 = Saturday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_capacity INTEGER NOT NULL CHECK (max_capacity > 0),
    slot_duration INTEGER DEFAULT 60, -- in minutes
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, day_of_week, start_time)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_restaurants_owner_id ON restaurants(owner_id);
CREATE INDEX IF NOT EXISTS idx_restaurants_district ON restaurants(district);
CREATE INDEX IF NOT EXISTS idx_restaurants_taluka ON restaurants(taluka);
CREATE INDEX IF NOT EXISTS idx_restaurants_status ON restaurants(status);
CREATE INDEX IF NOT EXISTS idx_restaurants_cuisine_type ON restaurants(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_restaurants_location ON restaurants USING GIST (POINT(location_lng, location_lat));

CREATE INDEX IF NOT EXISTS idx_restaurant_menu_restaurant_id ON restaurant_menu(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_menu_category ON restaurant_menu(category);
CREATE INDEX IF NOT EXISTS idx_restaurant_menu_is_available ON restaurant_menu(is_available);

CREATE INDEX IF NOT EXISTS idx_restaurant_reservations_restaurant_id ON restaurant_reservations(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_reservations_customer_id ON restaurant_reservations(customer_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_reservations_date ON restaurant_reservations(reservation_date);
CREATE INDEX IF NOT EXISTS idx_restaurant_reservations_status ON restaurant_reservations(status);

CREATE INDEX IF NOT EXISTS idx_restaurant_time_slots_restaurant_id ON restaurant_time_slots(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_time_slots_day ON restaurant_time_slots(day_of_week);

-- Add triggers to update updated_at timestamp
CREATE TRIGGER update_restaurants_updated_at 
    BEFORE UPDATE ON restaurants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurant_menu_updated_at 
    BEFORE UPDATE ON restaurant_menu 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurant_reservations_updated_at 
    BEFORE UPDATE ON restaurant_reservations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurant_time_slots_updated_at 
    BEFORE UPDATE ON restaurant_time_slots 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments for documentation
COMMENT ON TABLE restaurants IS 'Stores restaurant information and details';
COMMENT ON TABLE restaurant_menu IS 'Stores menu items for each restaurant';
COMMENT ON TABLE restaurant_reservations IS 'Stores table reservation requests and confirmations';
COMMENT ON TABLE restaurant_time_slots IS 'Defines available time slots for reservations at each restaurant';

COMMENT ON COLUMN restaurants.opening_hours IS 'JSON object storing opening and closing hours for each day of the week';
COMMENT ON COLUMN restaurants.amenities IS 'Array of restaurant amenities and features';
COMMENT ON COLUMN restaurants.photos IS 'Array of restaurant photo URLs';
COMMENT ON COLUMN restaurant_time_slots.day_of_week IS '0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday';