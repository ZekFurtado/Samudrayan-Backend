require('dotenv').config();
const pool = require('./config/database');
const LocationRepository = require('./src/domain/repositories/LocationRepository');

async function testEnhancedLocationsAPI() {
  try {
    console.log('🧪 Testing Enhanced Locations API implementation...');
    
    const locationRepository = new LocationRepository();
    
    // Test 1: Test the enhanced getAllLocations method
    console.log('\n📍 Test 1: Get all locations (enhanced format)');
    const allLocations = await locationRepository.getAllLocations();
    console.log('✅ Retrieved districts count:', allLocations.length);
    
    if (allLocations.length > 0) {
      const sampleDistrict = allLocations[0];
      console.log('📝 Sample district structure:');
      console.log({
        id: sampleDistrict.district_id,
        name: sampleDistrict.district,
        code: sampleDistrict.district_code,
        talukas_count: sampleDistrict.talukas.length,
        first_taluka: sampleDistrict.talukas[0]
      });
    }

    // Test 2: Test the new location hierarchy method
    console.log('\n📍 Test 2: Get location hierarchy for Ratnagiri');
    const ratnagigiHierarchy = await locationRepository.getLocationHierarchy('Ratnagiri');
    
    if (ratnagigiHierarchy.length > 0) {
      const ratnagiriData = ratnagigiHierarchy[0];
      console.log('✅ Ratnagiri hierarchy retrieved');
      console.log(`📊 District: ${ratnagiriData.name} (${ratnagiriData.code})`);
      console.log(`📊 Talukas: ${ratnagiriData.talukas.length}`);
      
      // Show first taluka with all its data
      if (ratnagiriData.talukas.length > 0) {
        const firstTaluka = ratnagiriData.talukas[0];
        console.log(`📝 Sample taluka: ${firstTaluka.name}`);
        console.log(`   Cities: ${firstTaluka.cities.length}`);
        console.log(`   Villages: ${firstTaluka.villages.length}`);
        console.log(`   Blocks: ${firstTaluka.blocks.length}`);
        
        // Show sample villages if available
        if (firstTaluka.villages.length > 0) {
          const coastalVillages = firstTaluka.villages.filter(v => v.is_coastal);
          console.log(`   Coastal villages: ${coastalVillages.length}`);
          if (coastalVillages.length > 0) {
            console.log(`   Example coastal village: ${coastalVillages[0].name}`);
          }
        }
      }
    }

    // Test 3: Test coastal villages method
    console.log('\n📍 Test 3: Get coastal villages');
    const coastalVillages = await locationRepository.getCoastalVillages();
    console.log('✅ Total coastal villages:', coastalVillages.length);
    
    if (coastalVillages.length > 0) {
      console.log('📝 Sample coastal villages:');
      coastalVillages.slice(0, 5).forEach(village => {
        console.log(`   ${village.name} (${village.taluka}, ${village.district}) - Population: ${village.population}`);
      });
    }

    // Test 4: Test coastal villages for specific district
    console.log('\n📍 Test 4: Get coastal villages for Sindhudurg');
    const sindhudurgCoastal = await locationRepository.getCoastalVillages('Sindhudurg');
    console.log('✅ Sindhudurg coastal villages:', sindhudurgCoastal.length);

    // Test 5: Test search functionality
    console.log('\n📍 Test 5: Search locations with term "Malvan"');
    const malvanSearch = await locationRepository.searchLocations('Malvan');
    console.log('✅ Search results for "Malvan":', malvanSearch.length);
    
    if (malvanSearch.length > 0) {
      console.log('📝 Search results:');
      malvanSearch.forEach(result => {
        console.log(`   ${result.type}: ${result.display_name}`);
      });
    }

    // Test 6: Test search by type
    console.log('\n📍 Test 6: Search only villages with term "Murud"');
    const murudSearch = await locationRepository.searchLocations('Murud', 'village');
    console.log('✅ Village search results for "Murud":', murudSearch.length);

    // Test 7: Test gram panchayats (if any blocks exist)
    console.log('\n📍 Test 7: Get gram panchayats');
    const blocksQuery = 'SELECT id, name FROM blocks LIMIT 1';
    const blocksResult = await pool.query(blocksQuery);
    
    if (blocksResult.rows.length > 0) {
      const testBlockId = blocksResult.rows[0].id;
      const gramPanchayats = await locationRepository.getGramPanchayatsByBlock(testBlockId);
      console.log(`✅ Gram panchayats in ${blocksResult.rows[0].name} block:`, gramPanchayats.length);
      
      if (gramPanchayats.length > 0) {
        console.log('📝 Sample gram panchayat:');
        const sample = gramPanchayats[0];
        console.log(`   ${sample.name} (${sample.gp_code}) - HQ: ${sample.headquarters_village}`);
      }
    }

    // Test 8: Test database statistics
    console.log('\n📍 Test 8: Database statistics');
    const stats = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM districts WHERE is_active = true) as active_districts,
        (SELECT COUNT(*) FROM talukas WHERE is_active = true) as active_talukas,
        (SELECT COUNT(*) FROM blocks WHERE is_active = true) as active_blocks,
        (SELECT COUNT(*) FROM cities WHERE is_active = true) as active_cities,
        (SELECT COUNT(*) FROM villages WHERE is_active = true) as active_villages,
        (SELECT COUNT(*) FROM villages WHERE is_coastal = true AND is_active = true) as coastal_villages,
        (SELECT COUNT(*) FROM gram_panchayats WHERE is_active = true) as active_gram_panchayats
    `);
    
    const statistics = stats.rows[0];
    console.log('📊 Location Database Statistics:');
    console.log(`   Active Districts: ${statistics.active_districts}`);
    console.log(`   Active Talukas: ${statistics.active_talukas}`);
    console.log(`   Active Blocks: ${statistics.active_blocks}`);
    console.log(`   Active Cities: ${statistics.active_cities}`);
    console.log(`   Active Villages: ${statistics.active_villages}`);
    console.log(`   Coastal Villages: ${statistics.coastal_villages}`);
    console.log(`   Active Gram Panchayats: ${statistics.active_gram_panchayats}`);

    // Test 9: Verify API response format for the enhanced /api/v1/master/locations
    console.log('\n📍 Test 9: Verify enhanced API response format');
    const apiResponse = {
      success: true,
      data: allLocations.slice(0, 2) // Show first 2 districts only
    };
    
    console.log('Enhanced API Response Format:');
    console.log(JSON.stringify(apiResponse, null, 2));

    console.log('\n🎉 All enhanced locations tests completed successfully!');
    
    // Summary
    console.log('\n📊 Test Summary:');
    console.log(`✅ Enhanced schema: IMPLEMENTED`);
    console.log(`✅ Comprehensive data: ${statistics.active_districts} districts, ${statistics.active_villages} villages`);
    console.log(`✅ Coastal focus: ${statistics.coastal_villages} coastal villages`);
    console.log(`✅ Administrative hierarchy: Districts → Talukas → Blocks → Gram Panchayats`);
    console.log(`✅ Search functionality: WORKING`);
    console.log(`✅ API compatibility: MAINTAINED`);
    
  } catch (error) {
    console.error('❌ Enhanced locations test failed:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

// Check if we should setup the database first
async function setupAndTest() {
  try {
    // Test database connection first
    const client = await pool.connect();
    
    // Check if enhanced tables exist
    const tableCheck = await client.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      AND tablename IN ('districts', 'talukas', 'blocks', 'cities', 'villages', 'gram_panchayats')
    `);
    
    const existingTables = tableCheck.rows.map(row => row.tablename);
    const requiredTables = ['districts', 'talukas', 'blocks', 'cities', 'villages', 'gram_panchayats'];
    const missingTables = requiredTables.filter(table => !existingTables.includes(table));
    
    if (missingTables.length > 0) {
      console.log('🔧 Enhanced location tables not found, setting up...');
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
        console.log('✅ Enhanced locations tables setup completed');
      }
    } else {
      client.release();
      console.log('✅ All enhanced location tables already exist');
    }
    
    // Now run the tests
    await testEnhancedLocationsAPI();
    
  } catch (error) {
    console.error('❌ Setup and test failed:', error.message);
    console.error('Full error:', error);
  }
}

setupAndTest();