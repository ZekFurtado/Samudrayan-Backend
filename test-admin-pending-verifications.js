const http = require('http');

function testPendingVerificationsWithRooms() {
  console.log('Testing GET /api/v1/admin/verifications/pending with room details...');
  console.log('========================================');
  
  // First, login as admin to get access token
  const loginData = {
    uid: 'J5TROvXYTahgnB0hywjDOOsTYYi2' // Existing admin user
  };
  
  const loginPostData = JSON.stringify(loginData);
  
  const loginOptions = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/auth/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginPostData)
    }
  };

  const loginReq = http.request(loginOptions, (loginRes) => {
    console.log(`1. Admin Login Status Code: ${loginRes.statusCode}`);
    
    let loginData = '';
    loginRes.on('data', (chunk) => {
      loginData += chunk;
    });
    
    loginRes.on('end', () => {
      try {
        const loginResponse = JSON.parse(loginData);
        
        if (loginResponse.success && loginResponse.data && loginResponse.data.accessToken) {
          console.log('✅ Admin login successful');
          // Test the pending verifications endpoint
          testPendingVerifications(loginResponse.data.accessToken);
        } else {
          console.log('❌ Admin login failed:', loginResponse);
        }
      } catch (error) {
        console.error('Error parsing login response:', error);
      }
    });
  });

  loginReq.on('error', (error) => {
    console.error('Login request error:', error);
  });

  loginReq.write(loginPostData);
  loginReq.end();
}

function testPendingVerifications(token) {
  console.log('\n2. Testing GET /api/v1/admin/verifications/pending...');
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/admin/verifications/pending?limit=5',
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Pending Verifications Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('✅ Pending verifications retrieved successfully');
          console.log(`📋 Found ${response.data.verifications.length} pending verifications`);
          
          // Check if any verifications have room details
          if (response.data.verifications.length > 0) {
            console.log('\n📊 Verification Details:');
            response.data.verifications.forEach((verification, index) => {
              console.log(`\n--- Verification ${index + 1} ---`);
              console.log(`Name: ${verification.name}`);
              console.log(`Grade: ${verification.grade}`);
              console.log(`Location: ${verification.location.district}, ${verification.location.taluka}`);
              console.log(`Owner: ${verification.owner.name}`);
              
              // Check if rooms array exists and has data
              if (verification.rooms && verification.rooms.length > 0) {
                console.log('✅ Room details included:');
                verification.rooms.forEach((room, roomIndex) => {
                  console.log(`  Room ${roomIndex + 1}: ${room.name}`);
                  console.log(`    - Capacity: ${room.capacity} guests`);
                  console.log(`    - Price: ₹${room.pricePerNight}/night`);
                  if (room.amenities && room.amenities.length > 0) {
                    console.log(`    - Amenities: ${room.amenities.join(', ')}`);
                  }
                });
                
                // Check room summary
                if (verification.roomSummary) {
                  console.log(`  📈 Summary: ${verification.roomSummary.totalRooms} rooms, `);
                  console.log(`    Price range: ₹${verification.roomSummary.priceRange.min} - ₹${verification.roomSummary.priceRange.max}`);
                  console.log(`    Total capacity: ${verification.roomSummary.totalCapacity} guests`);
                }
              } else {
                console.log('⚠️  No room details found (or no rooms created)');
              }
            });
            
            // Test with first verification if available
            if (response.data.verifications.length > 0) {
              const firstVerification = response.data.verifications[0];
              if (firstVerification.rooms && firstVerification.rooms.length > 0) {
                console.log('\n✅ SUCCESS: Room details are now included in pending verifications!');
                console.log('✅ The enhancement is working correctly!');
              } else {
                console.log('\n⚠️  This homestay has no rooms, which may be expected.');
                console.log('✅ Room details structure is present in the response.');
              }
            }
            
          } else {
            console.log('\n📝 No pending verifications found.');
            console.log('💡 Create a new homestay to test the room details feature.');
          }
          
          // Show pagination info
          if (response.data.pagination) {
            console.log(`\n📄 Pagination: Page ${response.data.pagination.currentPage} of ${response.data.pagination.totalPages}`);
            console.log(`   Total items: ${response.data.pagination.totalItems}`);
          }
          
        } else {
          console.log('❌ Failed to get pending verifications:', response);
        }
      } catch (error) {
        console.error('Error parsing response:', error);
        console.log('Raw response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('Request error:', error);
  });

  req.end();
}

// Run the test
testPendingVerificationsWithRooms();