const http = require('http');

function createTablesViaAPI() {
  console.log('Creating database tables via API...');
  
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
          callCreateTablesAPI(); // No token needed for simplified route
        } else {
          console.log('❌ Login failed, trying without auth...');
          callCreateTablesAPI(); // Try without token
        }
      } catch (error) {
        console.error('Error:', error);
      }
    });
  });

  loginReq.write(loginPostData);
  loginReq.end();
}

function callCreateTablesAPI(token = null) {
  console.log('\n2. Creating database tables...');
  
  const headers = { 'Accept': 'application/json' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/database-admin/create-tables',
    method: 'POST',
    headers: headers
  };

  const req = http.request(options, (res) => {
    console.log(`Create Tables Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('✅ SUCCESS: Database tables created!');
          console.log('Created tables:', response.data.tables);
          console.log('Created indexes:', response.data.indexes);
          console.log('\nNow testing the bookings endpoint...');
          testBookingsEndpoint(token);
        } else {
          console.log('❌ Failed to create tables:', response);
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

function testBookingsEndpoint(token) {
  console.log('\n3. Testing bookings endpoint after table creation...');
  
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
    console.log(`Bookings Endpoint Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('🎉 SUCCESS: Bookings endpoint is now working!');
          console.log(`Found ${response.data.bookings.length} bookings`);
          console.log('✅ The GET /api/homestays/:id/bookings API is fixed!');
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

createTablesViaAPI();