const http = require('http');

// Test data for creating a homestay
const testData = {
  name: 'Ganpatipule Beach Homestay',
  description: 'Beautiful sea-facing homestay with traditional Konkan architecture',
  grade: 'gold',
  district: 'Ratnagiri',
  taluka: 'Ganpatipule',
  location: { lat: 17.1329, lng: 73.2641 },
  amenities: ['wifi', 'power-backup', '24h-water', 'ac', 'parking'],
  rooms: [
    { 
      name: 'Deluxe Konkan Room', 
      capacity: 3, 
      pricePerNight: 2500 
    },
    { 
      name: 'Standard Room', 
      capacity: 2, 
      pricePerNight: 1800 
    }
  ],
  media: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
  sustainabilityScore: 82
};

function testCreateHomestayAPI() {
  const postData = JSON.stringify(testData);
  
  const options = {
    hostname: 'localhost',
    port: 3000, // Adjust port if different
    path: '/api/v1/homestays',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      // Note: In real implementation, you would need a valid JWT token
      'Authorization': 'Bearer YOUR_JWT_TOKEN_HERE'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Headers:`, res.headers);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('Response:', JSON.stringify(response, null, 2));
      } catch (error) {
        console.log('Raw Response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('Request failed:', error.message);
  });

  req.write(postData);
  req.end();
}

// Test validation errors
function testValidationErrors() {
  const invalidData = {
    // Missing required fields
    name: 'Test Homestay'
    // description, grade, district, taluka, location are missing
  };

  const postData = JSON.stringify(invalidData);
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/homestays',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Authorization': 'Bearer YOUR_JWT_TOKEN_HERE'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`\nValidation Test - Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('Validation Error Response:', JSON.stringify(response, null, 2));
      } catch (error) {
        console.log('Raw Response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('Validation test request failed:', error.message);
  });

  req.write(postData);
  req.end();
}

// Test GET /api/v1/homestays (list all)
function testGetHomestaysAPI() {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/homestays?page=1&limit=5&district=Ratnagiri',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`\nGET Homestays - Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('GET Homestays Response:', JSON.stringify(response, null, 2));
      } catch (error) {
        console.log('Raw Response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('GET homestays request failed:', error.message);
  });

  req.end();
}

// Test GET /api/v1/homestays/:id (get single)
function testGetHomestayByIdAPI() {
  // Using a sample UUID - in real testing, you'd use an actual homestay ID
  const sampleId = '123e4567-e89b-12d3-a456-426614174000';
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: `/api/v1/homestays/${sampleId}`,
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`\nGET Homestay by ID - Status Code: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        console.log('GET Homestay by ID Response:', JSON.stringify(response, null, 2));
      } catch (error) {
        console.log('Raw Response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('GET homestay by ID request failed:', error.message);
  });

  req.end();
}

console.log('Testing Homestay APIs...');
console.log('========================================');

// Test sequence with delays
console.log('1. Testing Create Homestay API...');
testCreateHomestayAPI();

setTimeout(() => {
  console.log('\n2. Testing validation errors...');
  testValidationErrors();
}, 2000);

setTimeout(() => {
  console.log('\n3. Testing GET Homestays API...');
  testGetHomestaysAPI();
}, 4000);

setTimeout(() => {
  console.log('\n4. Testing GET Homestay by ID API...');
  testGetHomestayByIdAPI();
}, 6000);