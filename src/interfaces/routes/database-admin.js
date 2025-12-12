const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');

const router = express.Router();

// Temporary endpoint to create missing database tables (simplified - no auth for debugging)
router.post('/create-tables', async (req, res) => {
  try {
    const pool = require('../../../config/database');
    
    console.log('Creating bookings tables...');
    
    // First check if the table already exists
    const tableExistsResult = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'bookings'
      );
    `);
    
    if (tableExistsResult.rows[0].exists) {
      console.log('ℹ️  Bookings table already exists');
    } else {
      // Create bookings table
      const createBookingsSQL = `
        CREATE TABLE bookings (
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
            
            CONSTRAINT valid_dates CHECK (check_out_date > check_in_date)
        );
      `;

      await pool.query(createBookingsSQL);
      console.log('✅ Bookings table created');
    }

    // Create payment transactions table
    const createPaymentSQL = `
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
    `;

    await pool.query(createPaymentSQL);
    console.log('✅ Payment transactions table created');

    // Create indexes
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_bookings_room_id ON bookings(room_id);',
      'CREATE INDEX IF NOT EXISTS idx_bookings_guest_user_id ON bookings(guest_user_id);',
      'CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);',
      'CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(check_in_date, check_out_date);',
      'CREATE INDEX IF NOT EXISTS idx_payment_transactions_booking_id ON payment_transactions(booking_id);'
    ];

    for (const indexSQL of indexes) {
      await pool.query(indexSQL);
    }
    console.log('✅ Indexes created');

    // Add triggers (if the function exists)
    try {
      await pool.query(`
        CREATE TRIGGER update_bookings_updated_at 
            BEFORE UPDATE ON bookings 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
      `);
      
      await pool.query(`
        CREATE TRIGGER update_payment_transactions_updated_at 
            BEFORE UPDATE ON payment_transactions 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
      `);
      console.log('✅ Triggers created');
    } catch (triggerError) {
      console.log('⚠️  Triggers not created (function might not exist):', triggerError.message);
    }

    res.json({
      success: true,
      data: {
        message: 'Database tables created successfully',
        tables: ['bookings', 'payment_transactions'],
        indexes: 5,
        triggers: 'attempted'
      }
    });

  } catch (error) {
    console.error('Error creating database tables:', error);
    res.status(500).json({
      success: false,
      error: {
        code: error.code || 'DATABASE_ERROR',
        message: error.message,
        details: 'Failed to create database tables'
      }
    });
  }
});

module.exports = router;