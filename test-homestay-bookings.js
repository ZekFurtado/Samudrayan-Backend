const http = require('http');

function testHomestayBookings() {
  console.log('Testing GET /api/v1/homestays/:id/bookings endpoint...');
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
    console.log(`1. Login Status Code: ${loginRes.statusCode}`);
    
    let loginData = '';
    loginRes.on('data', (chunk) => {
      loginData += chunk;
    });
    
    loginRes.on('end', () => {
      try {
        const loginResponse = JSON.parse(loginData);
        
        if (loginResponse.success && loginResponse.data && loginResponse.data.accessToken) {
          console.log('✅ Login successful');
          // Test the homestay bookings endpoint
          testBookingsEndpoint(loginResponse.data.accessToken);
        } else {
          console.log('❌ Login failed:', loginResponse);
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

function testBookingsEndpoint(token) {
  console.log('\n2. Testing homestay bookings endpoint...');
  
  // Use an existing homestay ID - this one should exist from previous tests
  const homestayId = '82b62439-5533-4d66-8d4c-811473a4a2e4';
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: `/api/v1/homestays/${homestayId}/bookings`,
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Homestay Bookings Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('✅ Homestay bookings endpoint working!');
          console.log(`📋 Found ${response.data.bookings.length} bookings`);
          
          if (response.data.bookings.length > 0) {
            console.log('\n📊 Booking details:');
            response.data.bookings.forEach((booking, index) => {
              console.log(`  Booking ${index + 1}:`);
              console.log(`    - Guest: ${booking.guest.name}`);
              console.log(`    - Room: ${booking.room.name}`);
              console.log(`    - Dates: ${booking.dates.checkIn} to ${booking.dates.checkOut}`);
              console.log(`    - Status: ${booking.status}`);
              console.log(`    - Amount: ₹${booking.totalAmount}`);
            });
          } else {
            console.log('📝 No bookings found for this homestay');
          }
          
          if (response.data.pagination) {
            console.log(`\n📄 Pagination: ${response.data.pagination.totalItems} total bookings`);
          }
          
          if (response.data.summary) {
            console.log(`\n💰 Summary: Total Revenue: ₹${response.data.summary.totalRevenue}`);
            console.log(`    Confirmed: ${response.data.summary.confirmedBookings}, Pending: ${response.data.summary.pendingBookings}`);
          }
          
          console.log('\n✅ SUCCESS: The endpoint is working correctly!');
          
        } else {
          console.log('❌ Failed to get bookings:', response);
        }
      } catch (error) {
        console.error('❌ Error parsing response:', error);
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
testHomestayBookings();