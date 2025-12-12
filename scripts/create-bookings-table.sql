-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    homestay_id UUID NOT NULL REFERENCES homestays(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES homestay_rooms(id) ON DELETE CASCADE,
    guest_user_id TEXT NOT NULL, -- Firebase UID of the guest
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER NOT NULL DEFAULT 1 CHECK (guests_count > 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    payment_method VARCHAR(20) DEFAULT 'upi' CHECK (payment_method IN ('upi', 'card', 'netbanking', 'cash')),
    status VARCHAR(30) DEFAULT 'pending-payment' CHECK (status IN (
        'pending-payment', 'confirmed', 'checked-in', 'checked-out', 
        'cancelled', 'refunded', 'no-show'
    )),
    special_requests TEXT,
    guest_contact_phone VARCHAR(15),
    guest_contact_email VARCHAR(255),
    payment_transaction_id VARCHAR(255),
    cancellation_reason TEXT,
    cancellation_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure check-out is after check-in
    CONSTRAINT valid_dates CHECK (check_out_date > check_in_date),
    
    -- Prevent overlapping bookings for the same room
    EXCLUDE USING gist (
        room_id WITH =,
        daterange(check_in_date, check_out_date, '[]') WITH &&
    ) WHERE (status NOT IN ('cancelled', 'refunded', 'no-show'))
);

-- Create payment_transactions table for tracking payment details
CREATE TABLE IF NOT EXISTS payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('payment', 'refund')),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'cancelled')),
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create booking_guest_details table for additional guest information
CREATE TABLE IF NOT EXISTS booking_guest_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    guest_name VARCHAR(255) NOT NULL,
    guest_age INTEGER CHECK (guest_age > 0 AND guest_age < 150),
    guest_id_type VARCHAR(20) CHECK (guest_id_type IN ('aadhaar', 'pan', 'passport', 'driving_license')),
    guest_id_number VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_bookings_homestay_id ON bookings(homestay_id);
CREATE INDEX IF NOT EXISTS idx_bookings_room_id ON bookings(room_id);
CREATE INDEX IF NOT EXISTS idx_bookings_guest_user_id ON bookings(guest_user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_booking_id ON payment_transactions(booking_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_status ON payment_transactions(status);

CREATE INDEX IF NOT EXISTS idx_booking_guest_details_booking_id ON booking_guest_details(booking_id);

-- Add trigger to update updated_at timestamp
CREATE TRIGGER update_bookings_updated_at 
    BEFORE UPDATE ON bookings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_transactions_updated_at 
    BEFORE UPDATE ON payment_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_booking_guest_details_updated_at 
    BEFORE UPDATE ON booking_guest_details 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample booking data for testing
INSERT INTO bookings (
    homestay_id, room_id, guest_user_id, check_in_date, check_out_date, 
    guests_count, total_amount, payment_method, status, guest_contact_phone, guest_contact_email
) VALUES 
-- Note: These UUIDs would need to match actual homestays and rooms in your database
-- This is just sample structure
(
    (SELECT id FROM homestays LIMIT 1),
    (SELECT id FROM homestay_rooms LIMIT 1),
    'sample-guest-firebase-uid',
    '2024-12-15',
    '2024-12-17',
    2,
    5000.00,
    'upi',
    'confirmed',
    '+919876543210',
    'guest@example.com'
) ON CONFLICT DO NOTHING;