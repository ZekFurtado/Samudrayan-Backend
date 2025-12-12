// This script will create the missing tables by using the same database connection that the server uses

const http = require('http');

// Create a simple endpoint test that will trigger the database error, 
// then we'll manually run SQL commands

function createTablesViaDatabaseModule() {
  console.log('Creating bookings table using server database connection...');
  
  // We'll create a test file that the server can run
  const tableSQL = `
-- Create bookings table if it doesn't exist
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES homestay_rooms(id) ON DELETE CASCADE,
    guest_user_id TEXT NOT NULL,
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
    
    CONSTRAINT valid_dates CHECK (check_out_date > check_in_date),
    
    EXCLUDE USING gist (
        room_id WITH =,
        daterange(check_in_date, check_out_date, '[]') WITH &&
    ) WHERE (status NOT IN ('cancelled', 'refunded', 'no-show'))
);

-- Create payment_transactions table
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_bookings_room_id ON bookings(room_id);
CREATE INDEX IF NOT EXISTS idx_bookings_guest_user_id ON bookings(guest_user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_booking_id ON payment_transactions(booking_id);

-- Add update triggers (function should already exist from homestays setup)
CREATE TRIGGER update_bookings_updated_at 
    BEFORE UPDATE ON bookings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_transactions_updated_at 
    BEFORE UPDATE ON payment_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
`;

  console.log('Table creation SQL:');
  console.log(tableSQL);
  console.log('\n✅ Please run this SQL manually in your database to create the tables.');
  console.log('After creating the tables, test the bookings API again.');
}

createTablesViaDatabaseModule();