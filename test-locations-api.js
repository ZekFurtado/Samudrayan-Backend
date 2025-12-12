require('dotenv').config();
const pool = require('./config/database');
const LocationRepository = require('./src/domain/repositories/LocationRepository');

async function testLocationsAPI() {
  try {
    console.log('🧪 Testing Locations API implementation...');
    
    const locationRepository = new LocationRepository();
    
    // Test 1: Get all locations (simulating API call)
    console.log('\n📍 Test 1: Get all locations');
    const allLocations = await locationRepository.getAllLocations();
    console.log('Result:', JSON.stringify(allLocations, null, 2));
    
    // Test 2: Get only active locations (simulating ?status=active query)
    console.log('\n📍 Test 2: Get only active locations');
    const activeLocations = await locationRepository.getAllLocations(false);
    console.log('Result:', JSON.stringify(activeLocations, null, 2));
    
    // Test 3: Get talukas for a specific district
    console.log('\n📍 Test 3: Get talukas for Ratnagiri');
    const ratnagigiTalukas = await locationRepository.getTalukasByDistrict('Ratnagiri');
    console.log('Result:', ratnagigiTalukas.map(t => t.name));
    
    // Test 4: Verify API response format matches specification
    console.log('\n📍 Test 4: Verify API response format');
    const apiResponse = {
      success: true,
      data: allLocations
    };
    
    console.log('API Response Format:', JSON.stringify(apiResponse, null, 2));
    
    // Validate against spec format
    const isValidFormat = apiResponse.success && 
                         Array.isArray(apiResponse.data) &&
                         apiResponse.data.every(item => 
                           item.hasOwnProperty('district') && 
                           Array.isArray(item.talukas)
                         );
    
    console.log('\n✅ API Response matches specification format:', isValidFormat);
    
    if (allLocations.length > 0) {
      console.log('✅ Sample district:', allLocations[0].district);
      console.log('✅ Sample talukas:', allLocations[0].talukas);
    }
    
    console.log('\n🎉 All location tests completed successfully!');
    
  } catch (error) {
    console.error('❌ Location test failed:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

// Check if we should also setup the database first
async function setupAndTest() {
  try {
    // Test database connection first
    const client = await pool.connect();
    
    // Check if locations tables exist
    const tableCheck = await client.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      AND tablename IN ('districts', 'talukas')
    `);
    
    if (tableCheck.rows.length < 2) {
      console.log('🔧 Locations tables not found, setting up...');
      client.release();
      
      // Run setup script
      const fs = require('fs');
      const path = require('path');
      const sqlPath = path.join(__dirname, 'scripts', 'create-locations-table.sql');
      
      if (fs.existsSync(sqlPath)) {
        const sql = fs.readFileSync(sqlPath, 'utf8');
        const setupClient = await pool.connect();
        await setupClient.query(sql);
        setupClient.release();
        console.log('✅ Locations tables setup completed');
      }
    } else {
      client.release();
      console.log('✅ Locations tables already exist');
    }
    
    // Now run the tests
    await testLocationsAPI();
    
  } catch (error) {
    console.error('❌ Setup and test failed:', error.message);
    console.error('Full error:', error);
  }
}

setupAndTest();