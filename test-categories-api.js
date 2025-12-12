require('dotenv').config();

async function testCategoriesAPI() {
  const baseUrl = `http://localhost:${process.env.PORT || 3000}/api/v1/master/categories`;
  
  console.log('Testing Categories API...\n');

  try {
    // Test 1: Get all categories (legacy format)
    console.log('1. Testing GET /api/v1/master/categories (all categories)');
    let response = await fetch(baseUrl);
    let data = await response.json();
    console.log('Response status:', response.status);
    console.log('Response data:', JSON.stringify(data, null, 2));
    console.log('\n');

    // Test 2: Get tourism categories only
    console.log('2. Testing GET /api/v1/master/categories?type=tourism');
    response = await fetch(`${baseUrl}?type=tourism`);
    data = await response.json();
    console.log('Response status:', response.status);
    console.log('Response data (first 3 items):', JSON.stringify(data.data?.slice(0, 3), null, 2));
    console.log('Total tourism categories:', data.data?.length);
    console.log('\n');

    // Test 3: Get homestay categories only
    console.log('3. Testing GET /api/v1/master/categories?type=homestay');
    response = await fetch(`${baseUrl}?type=homestay`);
    data = await response.json();
    console.log('Response status:', response.status);
    console.log('Response data:', JSON.stringify(data, null, 2));
    console.log('\n');

    // Test 4: Get marketplace categories only
    console.log('4. Testing GET /api/v1/master/categories?type=marketplace');
    response = await fetch(`${baseUrl}?type=marketplace`);
    data = await response.json();
    console.log('Response status:', response.status);
    console.log('Response data:', JSON.stringify(data, null, 2));
    console.log('\n');

    // Test 5: Get all categories including inactive
    console.log('5. Testing GET /api/v1/master/categories?status=all');
    response = await fetch(`${baseUrl}?status=all`);
    data = await response.json();
    console.log('Response status:', response.status);
    console.log('Response tourism categories count:', data.data?.tourism?.length);
    console.log('\n');

    console.log('All tests completed successfully!');

  } catch (error) {
    console.error('Error testing API:', error.message);
  }
}

testCategoriesAPI();