const pool = require('./config/database');

async function checkTables() {
  try {
    console.log('Checking database tables...');
    
    // Check if bookings table exists
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'bookings'
      );
    `);
    
    const bookingsExists = tableCheck.rows[0].exists;
    console.log('Bookings table exists:', bookingsExists);
    
    if (bookingsExists) {
      // Check the structure of the bookings table
      const columns = await pool.query(`
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = 'bookings' AND table_schema = 'public'
        ORDER BY ordinal_position;
      `);
      
      console.log('\nBookings table columns:');
      columns.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type} ${col.is_nullable === 'YES' ? '(nullable)' : '(not null)'}`);
      });
    }
    
    // Also check homestays and homestay_rooms tables
    const otherTables = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('homestays', 'homestay_rooms', 'users')
      ORDER BY table_name;
    `);
    
    console.log('\nOther important tables:');
    otherTables.rows.forEach(table => {
      console.log(`  ${table.table_name}`);
    });
    
    console.log('\n✅ Database check completed');
    
  } catch (error) {
    console.error('❌ Error checking database:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
    process.exit();
  }
}

checkTables();