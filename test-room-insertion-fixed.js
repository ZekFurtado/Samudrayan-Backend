const http = require('http');

// Test data for creating a homestay with rooms
const testData = {
  name: 'Test Beach Resort With Rooms Fixed',
  description: 'Testing room insertion functionality',
  grade: 'gold',
  district: 'Ratnagiri',
  taluka: 'Ganpatipule',
  location: { lat: 17.1329, lng: 73.2641 },
  amenities: ['wifi', 'power-backup', '24h-water'],
  rooms: [
    { 
      name: 'Test Deluxe Room', 
      capacity: 3, 
      pricePerNight: 2500,
      amenities: ['ac', 'tv', 'balcony']
    },
    { 
      name: 'Test Standard Room', 
      capacity: 2, 
      pricePerNight: 1800,
      amenities: ['fan', 'tv']
    }
  ],
  media: ['https://example.com/img1.jpg'],
  sustainabilityScore: 75
};

// Use existing user Firebase UID
function testLoginAndCreateHomestay() {
  console.log('Testing Room Insertion in Homestay Creation...');
  console.log('========================================');
  
  const loginData = {
    uid: 'J5TROvXYTahgnB0hywjDOOsTYYi2' // Existing user from database
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
        console.log('Login Response:', JSON.stringify(loginResponse, null, 2));
        
        if (loginResponse.success && loginResponse.data && loginResponse.data.accessToken) {
          // Use the token to create homestay
          createHomestayWithToken(loginResponse.data.accessToken);
        } else {
          console.log('❌ Login failed. Cannot test homestay creation.');
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

function createHomestayWithToken(token) {
  console.log('\n2. Creating homestay with authentication...');
  
  const postData = JSON.stringify(testData);
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/homestays',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Authorization': `Bearer ${token}`
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Create Homestay Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('Create Homestay Response:', JSON.stringify(response, null, 2));
        
        if (response.success && response.data && response.data.id) {
          console.log(`✅ Homestay created successfully with ID: ${response.data.id}`);
          // Now fetch the created homestay to verify rooms were inserted
          fetchHomestayById(response.data.id);
        } else {
          console.log('❌ Failed to create homestay');
        }
      } catch (error) {
        console.error('Error parsing create response:', error);
        console.log('Raw response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('Create homestay request error:', error);
  });

  req.write(postData);
  req.end();
}

function fetchHomestayById(homestayId) {
  console.log(`\n3. Fetching created homestay to verify rooms were inserted...`);
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: `/api/v1/homestays/${homestayId}`,
    method: 'GET',
    headers: {
      'Accept': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Fetch Homestay Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('Fetched Homestay Response:', JSON.stringify(response, null, 2));
        
        if (response.success && response.data && response.data.rooms) {
          const roomCount = response.data.rooms.length;
          console.log(`\n✅ SUCCESS: Found ${roomCount} rooms in the homestay!`);
          console.log('Room details:');
          response.data.rooms.forEach((room, index) => {
            console.log(`  Room ${index + 1}: ${room.name} (Capacity: ${room.capacity}, Price: ${room.pricePerNight})`);
            if (room.amenities && room.amenities.length > 0) {
              console.log(`    Amenities: ${room.amenities.join(', ')}`);
            }
          });
          
          if (roomCount === testData.rooms.length) {
            console.log('✅ All rooms were successfully inserted!');
            console.log('✅ Room insertion fix is working correctly!');
          } else {
            console.log(`⚠️  Expected ${testData.rooms.length} rooms, but found ${roomCount}`);
          }
        } else {
          console.log('❌ No rooms found in the created homestay');
        }
      } catch (error) {
        console.error('Error parsing fetch response:', error);
        console.log('Raw response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('Fetch request error:', error);
  });

  req.end();
}

// Run the test
testLoginAndCreateHomestay();