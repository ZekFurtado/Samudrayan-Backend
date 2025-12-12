const http = require('http');

function createBookingsTable() {
  console.log('Creating bookings table through API...');
  
  // Login first
  const loginData = { uid: 'J5TROvXYTahgnB0hywjDOOsTYYi2' };
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
    let loginData = '';
    loginRes.on('data', (chunk) => { loginData += chunk; });
    
    loginRes.on('end', () => {
      try {
        const loginResponse = JSON.parse(loginData);
        if (loginResponse.success) {
          console.log('✅ Logged in successfully');
          // Now try to create a booking which should trigger table creation or show us the exact error
          testCreateBooking(loginResponse.data.accessToken);
        } else {
          console.log('❌ Login failed');
        }
      } catch (error) {
        console.error('Error:', error);
      }
    });
  });

  loginReq.write(loginPostData);
  loginReq.end();
}

function testCreateBooking(token) {
  console.log('\n2. Testing booking creation to understand table structure...');
  
  // Use existing homestay and room
  const homestayId = '82b62439-5533-4d66-8d4c-811473a4a2e4';
  const roomId = 'a14da547-702c-4956-8aa2-d725820299a3'; // Get this from the homestay details
  
  const today = new Date();
  const checkIn = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000); // 7 days from now
  const checkOut = new Date(today.getTime() + 9 * 24 * 60 * 60 * 1000); // 9 days from now
  
  const bookingData = {
    checkIn: checkIn.toISOString().split('T')[0],
    checkOut: checkOut.toISOString().split('T')[0],
    guests: 2,
    roomId: roomId,
    paymentMethod: 'upi',
    specialRequests: 'Test booking for table creation'
  };
  
  const postData = JSON.stringify(bookingData);
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: `/api/v1/homestays/${homestayId}/bookings`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Authorization': `Bearer ${token}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Create Booking Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('Create Booking Response:', JSON.stringify(response, null, 2));
        
        if (response.success) {
          console.log('✅ Booking created successfully! Now test the bookings list...');
          testBookingsList(token, homestayId);
        } else {
          console.log('❌ Booking creation failed. This will help us understand the table issue.');
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

  req.write(postData);
  req.end();
}

function testBookingsList(token, homestayId) {
  console.log('\n3. Testing bookings list endpoint...');
  
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
    console.log(`Bookings List Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('✅ SUCCESS: Bookings endpoint is now working!');
          console.log(`Found ${response.data.bookings.length} bookings`);
        } else {
          console.log('❌ Bookings endpoint still failing:', response.error);
        }
      } catch (error) {
        console.error('Error parsing response:', error);
        console.log('Raw response:', data);
      }
    });
  });

  req.end();
}

createBookingsTable();