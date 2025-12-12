const http = require('http');

function testDetailedDebug() {
  console.log('Testing admin verifications with detailed debugging...');
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
          testPendingVerificationsRaw(loginResponse.data.accessToken);
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

function testPendingVerificationsRaw(token) {
  console.log('\n2. Testing pending verifications (raw response)...');
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/admin/verifications/pending?limit=1', // Just get 1 for detailed inspection
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success && response.data.verifications.length > 0) {
          console.log('\n📊 First verification (full response):');
          console.log(JSON.stringify(response.data.verifications[0], null, 2));
        } else {
          console.log('Full response:', JSON.stringify(response, null, 2));
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
testDetailedDebug();