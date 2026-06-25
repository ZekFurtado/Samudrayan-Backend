const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');
const logger = require('../../../config/logger');

const router = express.Router();

// Create a new restaurant
router.post('/', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const {
      name,
      description,
      cuisineType,
      contactPhone,
      contactEmail,
      address,
      district,
      taluka,
      location,
      openingHours,
      averageCostForTwo,
      seatingCapacity,
      amenities,
      photos
    } = req.body;

    // Validation
    if (!name || !address || !district || !taluka) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Required fields: name, address, district, taluka'
        }
      });
    }

    if (location && (!location.lat || !location.lng)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Location must include lat and lng coordinates'
        }
      });
    }

    // Get database connection
    const pool = require('../../../config/database');
    
    // Generate UUID for restaurant
    const { v4: uuidv4 } = await import('uuid');
    const restaurantId = uuidv4();
    
    // Get the user's UUID from firebase_uid
    const userQuery = 'SELECT id FROM users WHERE firebase_uid = $1';
    const userResult = await pool.query(userQuery, [req.user.uid]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const ownerId = userResult.rows[0].id;

    // Insert restaurant into database
    const insertQuery = `
      INSERT INTO restaurants (
        id, owner_id, name, description, cuisine_type, contact_phone, contact_email,
        address, district, taluka, location_lat, location_lng, opening_hours,
        average_cost_for_two, seating_capacity, amenities, photos, status,
        created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
      RETURNING id, name, cuisine_type, district, taluka, status
    `;

    const values = [
      restaurantId,
      ownerId,
      name,
      description || null,
      cuisineType || null,
      contactPhone || null,
      contactEmail || null,
      address,
      district,
      taluka,
      location?.lat || null,
      location?.lng || null,
      openingHours ? JSON.stringify(openingHours) : null,
      averageCostForTwo || null,
      seatingCapacity || null,
      amenities || null,
      photos || null,
      'pending-verification',
      new Date().toISOString(),
      new Date().toISOString()
    ];

    const result = await pool.query(insertQuery, values);
    const createdRestaurant = result.rows[0];

    res.status(201).json({
      success: true,
      data: {
        id: createdRestaurant.id,
        name: createdRestaurant.name,
        cuisineType: createdRestaurant.cuisine_type,
        district: createdRestaurant.district,
        taluka: createdRestaurant.taluka,
        status: createdRestaurant.status,
        message: 'Restaurant created successfully and submitted for verification'
      }
    });

  } catch (error) {
    console.error('Error creating restaurant:', error);
    
    // Handle specific database errors
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({
        success: false,
        error: {
          code: 'DUPLICATE_RESTAURANT',
          message: 'A restaurant with this name already exists for this owner'
        }
      });
    }

    next(error);
  }
});

// Get all restaurants with filtering
router.get('/', async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    
    // Extract query parameters
    const {
      district,
      taluka,
      cuisineType,
      search,
      page = 1,
      limit = 10,
      status = 'active'
    } = req.query;

    // Build dynamic query with conditions
    let whereConditions = ['r.status = $1'];
    let queryParams = [status];
    let paramCounter = 1;

    // Add filtering conditions
    if (district) {
      paramCounter++;
      whereConditions.push(`r.district ILIKE $${paramCounter}`);
      queryParams.push(`%${district}%`);
    }

    if (taluka) {
      paramCounter++;
      whereConditions.push(`r.taluka ILIKE $${paramCounter}`);
      queryParams.push(`%${taluka}%`);
    }

    if (cuisineType) {
      paramCounter++;
      whereConditions.push(`r.cuisine_type ILIKE $${paramCounter}`);
      queryParams.push(`%${cuisineType}%`);
    }

    if (search) {
      paramCounter++;
      whereConditions.push(`(r.name ILIKE $${paramCounter} OR r.description ILIKE $${paramCounter})`);
      queryParams.push(`%${search}%`);
    }

    // Calculate offset for pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Main query to get restaurants
    const restaurantsQuery = `
      SELECT 
        r.id,
        r.name,
        r.description,
        r.cuisine_type,
        r.contact_phone,
        r.contact_email,
        r.address,
        r.district,
        r.taluka,
        r.location_lat,
        r.location_lng,
        r.opening_hours,
        r.average_cost_for_two,
        r.seating_capacity,
        r.amenities,
        r.photos,
        r.rating,
        r.total_reviews,
        r.status,
        r.created_at,
        r.updated_at,
        u.full_name as owner_name
      FROM restaurants r
      LEFT JOIN users u ON r.owner_id = u.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY r.created_at DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query for pagination
    const countQuery = `
      SELECT COUNT(*) as total
      FROM restaurants r
      WHERE ${whereConditions.join(' AND ')}
    `;

    // Execute both queries
    const [restaurantsResult, countResult] = await Promise.all([
      pool.query(restaurantsQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const restaurants = restaurantsResult.rows.map(restaurant => ({
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      cuisineType: restaurant.cuisine_type,
      contactInfo: {
        phone: restaurant.contact_phone,
        email: restaurant.contact_email
      },
      location: {
        address: restaurant.address,
        district: restaurant.district,
        taluka: restaurant.taluka,
        coordinates: restaurant.location_lat && restaurant.location_lng ? {
          lat: parseFloat(restaurant.location_lat),
          lng: parseFloat(restaurant.location_lng)
        } : null
      },
      openingHours: restaurant.opening_hours || {},
      pricing: {
        averageCostForTwo: restaurant.average_cost_for_two ? parseFloat(restaurant.average_cost_for_two) : null
      },
      seatingCapacity: restaurant.seating_capacity,
      amenities: restaurant.amenities || [],
      photos: restaurant.photos || [],
      rating: restaurant.rating ? parseFloat(restaurant.rating) : 0,
      totalReviews: restaurant.total_reviews || 0,
      status: restaurant.status,
      ownerName: restaurant.owner_name,
      createdAt: restaurant.created_at,
      updatedAt: restaurant.updated_at
    }));

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        restaurants,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1
        },
        filters: {
          district,
          taluka,
          cuisineType,
          search,
          status
        }
      }
    });

  } catch (error) {
    console.error('Error fetching restaurants:', error);
    next(error);
  }
});

// Get specific restaurant by ID
router.get('/:id', async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;

    // Query to get restaurant details
    const restaurantQuery = `
      SELECT 
        r.*,
        u.full_name as owner_name,
        u.email as owner_email,
        u.phone as owner_phone
      FROM restaurants r
      LEFT JOIN users u ON r.owner_id = u.id
      WHERE r.id = $1
    `;

    const result = await pool.query(restaurantQuery, [restaurantId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = result.rows[0];

    const response = {
      id: restaurant.id,
      ownerId: restaurant.owner_id,
      name: restaurant.name,
      description: restaurant.description,
      cuisineType: restaurant.cuisine_type,
      contactInfo: {
        phone: restaurant.contact_phone,
        email: restaurant.contact_email
      },
      location: {
        address: restaurant.address,
        district: restaurant.district,
        taluka: restaurant.taluka,
        coordinates: restaurant.location_lat && restaurant.location_lng ? {
          lat: parseFloat(restaurant.location_lat),
          lng: parseFloat(restaurant.location_lng)
        } : null
      },
      openingHours: restaurant.opening_hours || {},
      pricing: {
        averageCostForTwo: restaurant.average_cost_for_two ? parseFloat(restaurant.average_cost_for_two) : null
      },
      seatingCapacity: restaurant.seating_capacity,
      amenities: restaurant.amenities || [],
      photos: restaurant.photos || [],
      rating: restaurant.rating ? parseFloat(restaurant.rating) : 0,
      totalReviews: restaurant.total_reviews || 0,
      status: restaurant.status,
      isVerified: restaurant.is_verified,
      owner: {
        name: restaurant.owner_name,
        email: restaurant.owner_email,
        phone: restaurant.owner_phone
      },
      createdAt: restaurant.created_at,
      updatedAt: restaurant.updated_at
    };

    res.json({
      success: true,
      data: response
    });

  } catch (error) {
    console.error('Error fetching restaurant by ID:', error);
    next(error);
  }
});

// Upload photos for restaurant
router.post('/:id/photos', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const { photos } = req.body;

    if (!photos || !Array.isArray(photos)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Photos array is required'
        }
      });
    }

    // Check if restaurant exists and user owns it (unless admin)
    const checkQuery = `
      SELECT r.owner_id, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only upload photos for your own restaurant'
        }
      });
    }

    // Update photos
    const updateQuery = `
      UPDATE restaurants 
      SET photos = $1, updated_at = $2
      WHERE id = $3
      RETURNING photos
    `;
    const updateResult = await pool.query(updateQuery, [
      JSON.stringify(photos),
      new Date().toISOString(),
      restaurantId
    ]);

    res.json({
      success: true,
      data: {
        message: 'Photos uploaded successfully',
        photos: updateResult.rows[0].photos
      }
    });

  } catch (error) {
    console.error('Error uploading restaurant photos:', error);
    next(error);
  }
});

// Menu Management APIs

// Create menu item
router.post('/:id/menu', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const {
      category,
      itemName,
      description,
      price,
      isVegetarian,
      isVegan,
      containsGluten,
      spiceLevel,
      preparationTime,
      photoUrl
    } = req.body;

    // Validation
    if (!category || !itemName || price == null) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Required fields: category, itemName, price'
        }
      });
    }

    if (price < 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Price must be non-negative'
        }
      });
    }

    // Check restaurant ownership
    const checkQuery = `
      SELECT r.owner_id, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only add menu items to your own restaurant'
        }
      });
    }

    // Generate UUID for menu item
    const { v4: uuidv4 } = await import('uuid');
    const menuItemId = uuidv4();

    // Insert menu item
    const insertQuery = `
      INSERT INTO restaurant_menu (
        id, restaurant_id, category, item_name, description, price,
        is_vegetarian, is_vegan, contains_gluten, spice_level,
        preparation_time, photo_url, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *
    `;

    const values = [
      menuItemId,
      restaurantId,
      category,
      itemName,
      description || null,
      price,
      isVegetarian || false,
      isVegan || false,
      containsGluten || false,
      spiceLevel || null,
      preparationTime || null,
      photoUrl || null,
      new Date().toISOString(),
      new Date().toISOString()
    ];

    const result = await pool.query(insertQuery, values);
    const menuItem = result.rows[0];

    res.status(201).json({
      success: true,
      data: {
        id: menuItem.id,
        category: menuItem.category,
        itemName: menuItem.item_name,
        description: menuItem.description,
        price: parseFloat(menuItem.price),
        isVegetarian: menuItem.is_vegetarian,
        isVegan: menuItem.is_vegan,
        containsGluten: menuItem.contains_gluten,
        spiceLevel: menuItem.spice_level,
        preparationTime: menuItem.preparation_time,
        photoUrl: menuItem.photo_url,
        isAvailable: menuItem.is_available,
        createdAt: menuItem.created_at,
        updatedAt: menuItem.updated_at,
        message: 'Menu item added successfully'
      }
    });

  } catch (error) {
    console.error('Error creating menu item:', error);
    next(error);
  }
});

// Get restaurant menu
router.get('/:id/menu', async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const { category, available } = req.query;

    // Build query conditions
    let whereConditions = ['restaurant_id = $1'];
    let queryParams = [restaurantId];
    let paramCounter = 1;

    if (category) {
      paramCounter++;
      whereConditions.push(`category ILIKE $${paramCounter}`);
      queryParams.push(`%${category}%`);
    }

    if (available === 'true') {
      paramCounter++;
      whereConditions.push(`is_available = $${paramCounter}`);
      queryParams.push(true);
    } else if (available === 'false') {
      paramCounter++;
      whereConditions.push(`is_available = $${paramCounter}`);
      queryParams.push(false);
    }

    const menuQuery = `
      SELECT * FROM restaurant_menu
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY category, item_name
    `;

    const result = await pool.query(menuQuery, queryParams);

    const menuItems = result.rows.map(item => ({
      id: item.id,
      category: item.category,
      itemName: item.item_name,
      description: item.description,
      price: parseFloat(item.price),
      isVegetarian: item.is_vegetarian,
      isVegan: item.is_vegan,
      containsGluten: item.contains_gluten,
      spiceLevel: item.spice_level,
      preparationTime: item.preparation_time,
      photoUrl: item.photo_url,
      isAvailable: item.is_available,
      createdAt: item.created_at,
      updatedAt: item.updated_at
    }));

    // Group by category
    const menuByCategory = {};
    menuItems.forEach(item => {
      if (!menuByCategory[item.category]) {
        menuByCategory[item.category] = [];
      }
      menuByCategory[item.category].push(item);
    });

    res.json({
      success: true,
      data: {
        restaurantId,
        menu: menuByCategory,
        totalItems: menuItems.length,
        filters: { category, available }
      }
    });

  } catch (error) {
    console.error('Error fetching menu:', error);
    next(error);
  }
});

// Update menu item
router.put('/:id/menu/:menuId', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const menuItemId = req.params.menuId;
    const updateData = req.body;

    // Check restaurant ownership
    const checkQuery = `
      SELECT r.owner_id, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only update menu items for your own restaurant'
        }
      });
    }

    // Build update query dynamically
    const allowedFields = [
      'category', 'item_name', 'description', 'price', 'is_vegetarian', 
      'is_vegan', 'contains_gluten', 'spice_level', 'preparation_time', 
      'photo_url', 'is_available'
    ];

    const updates = [];
    const values = [];
    let paramCounter = 0;

    Object.keys(updateData).forEach(key => {
      const dbKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(dbKey)) {
        paramCounter++;
        updates.push(`${dbKey} = $${paramCounter}`);
        values.push(updateData[key]);
      }
    });

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'NO_VALID_UPDATES',
          message: 'No valid fields provided for update'
        }
      });
    }

    // Add updated_at
    paramCounter++;
    updates.push(`updated_at = $${paramCounter}`);
    values.push(new Date().toISOString());

    // Add WHERE conditions
    paramCounter++;
    values.push(menuItemId);
    paramCounter++;
    values.push(restaurantId);

    const updateQuery = `
      UPDATE restaurant_menu 
      SET ${updates.join(', ')}
      WHERE id = $${paramCounter - 1} AND restaurant_id = $${paramCounter}
      RETURNING *
    `;

    const result = await pool.query(updateQuery, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'MENU_ITEM_NOT_FOUND',
          message: 'Menu item not found'
        }
      });
    }

    const menuItem = result.rows[0];

    res.json({
      success: true,
      data: {
        id: menuItem.id,
        category: menuItem.category,
        itemName: menuItem.item_name,
        description: menuItem.description,
        price: parseFloat(menuItem.price),
        isVegetarian: menuItem.is_vegetarian,
        isVegan: menuItem.is_vegan,
        containsGluten: menuItem.contains_gluten,
        spiceLevel: menuItem.spice_level,
        preparationTime: menuItem.preparation_time,
        photoUrl: menuItem.photo_url,
        isAvailable: menuItem.is_available,
        updatedAt: menuItem.updated_at,
        message: 'Menu item updated successfully'
      }
    });

  } catch (error) {
    console.error('Error updating menu item:', error);
    next(error);
  }
});

// Delete menu item
router.delete('/:id/menu/:menuId', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const menuItemId = req.params.menuId;

    // Check restaurant ownership
    const checkQuery = `
      SELECT r.owner_id, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only delete menu items from your own restaurant'
        }
      });
    }

    // Delete menu item
    const deleteQuery = `
      DELETE FROM restaurant_menu 
      WHERE id = $1 AND restaurant_id = $2
      RETURNING item_name
    `;

    const result = await pool.query(deleteQuery, [menuItemId, restaurantId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'MENU_ITEM_NOT_FOUND',
          message: 'Menu item not found'
        }
      });
    }

    res.json({
      success: true,
      data: {
        message: `Menu item '${result.rows[0].item_name}' deleted successfully`
      }
    });

  } catch (error) {
    console.error('Error deleting menu item:', error);
    next(error);
  }
});

// Reservation Management APIs

// Create table reservation
router.post('/:id/reservations', verifyJWT, async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const {
      reservationDate,
      reservationTime,
      partySize,
      specialRequests,
      tablePreference,
      customerName,
      customerPhone,
      customerEmail
    } = req.body;

    // Validation
    if (!reservationDate || !reservationTime || !partySize || !customerName || !customerPhone) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Required fields: reservationDate, reservationTime, partySize, customerName, customerPhone'
        }
      });
    }

    if (partySize <= 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Party size must be greater than 0'
        }
      });
    }

    // Check if reservation date is not in the past
    const reservationDateTime = new Date(`${reservationDate} ${reservationTime}`);
    if (reservationDateTime <= new Date()) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Reservation must be scheduled for a future date and time'
        }
      });
    }

    // Check if restaurant exists
    const restaurantQuery = 'SELECT id, name, seating_capacity FROM restaurants WHERE id = $1 AND status = $2';
    const restaurantResult = await pool.query(restaurantQuery, [restaurantId, 'active']);

    if (restaurantResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found or not active'
        }
      });
    }

    const restaurant = restaurantResult.rows[0];

    // Check seating capacity (basic availability check)
    if (restaurant.seating_capacity && partySize > restaurant.seating_capacity) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'CAPACITY_EXCEEDED',
          message: `Party size exceeds restaurant capacity (${restaurant.seating_capacity})`
        }
      });
    }

    // Get customer ID from JWT
    const userQuery = 'SELECT id FROM users WHERE firebase_uid = $1';
    const userResult = await pool.query(userQuery, [req.user.uid]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const customerId = userResult.rows[0].id;

    // Generate UUID for reservation
    const { v4: uuidv4 } = await import('uuid');
    const reservationId = uuidv4();

    // Insert reservation
    const insertQuery = `
      INSERT INTO restaurant_reservations (
        id, restaurant_id, customer_id, customer_name, customer_phone, customer_email,
        reservation_date, reservation_time, party_size, special_requests, table_preference,
        status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *
    `;

    const values = [
      reservationId,
      restaurantId,
      customerId,
      customerName,
      customerPhone,
      customerEmail || null,
      reservationDate,
      reservationTime,
      partySize,
      specialRequests || null,
      tablePreference || null,
      'pending',
      new Date().toISOString(),
      new Date().toISOString()
    ];

    const result = await pool.query(insertQuery, values);
    const reservation = result.rows[0];

    res.status(201).json({
      success: true,
      data: {
        id: reservation.id,
        restaurantName: restaurant.name,
        reservationDate: reservation.reservation_date,
        reservationTime: reservation.reservation_time,
        partySize: reservation.party_size,
        customerName: reservation.customer_name,
        customerPhone: reservation.customer_phone,
        customerEmail: reservation.customer_email,
        specialRequests: reservation.special_requests,
        tablePreference: reservation.table_preference,
        status: reservation.status,
        createdAt: reservation.created_at,
        message: 'Reservation created successfully. Please wait for confirmation from the restaurant.'
      }
    });

  } catch (error) {
    console.error('Error creating reservation:', error);
    next(error);
  }
});

// Get restaurant reservations (for restaurant owners)
router.get('/:id/reservations', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const {
      status,
      dateFrom,
      dateTo,
      page = 1,
      limit = 20
    } = req.query;

    // Check restaurant ownership
    const checkQuery = `
      SELECT r.owner_id, r.name as restaurant_name, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only view reservations for your own restaurant'
        }
      });
    }

    // Build query conditions
    let whereConditions = ['restaurant_id = $1'];
    let queryParams = [restaurantId];
    let paramCounter = 1;

    if (status) {
      paramCounter++;
      whereConditions.push(`status = $${paramCounter}`);
      queryParams.push(status);
    }

    if (dateFrom) {
      paramCounter++;
      whereConditions.push(`reservation_date >= $${paramCounter}`);
      queryParams.push(dateFrom);
    }

    if (dateTo) {
      paramCounter++;
      whereConditions.push(`reservation_date <= $${paramCounter}`);
      queryParams.push(dateTo);
    }

    // Calculate offset for pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Main query
    const reservationsQuery = `
      SELECT 
        rr.*,
        u.full_name as customer_full_name,
        u.email as customer_user_email
      FROM restaurant_reservations rr
      LEFT JOIN users u ON rr.customer_id = u.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY rr.reservation_date DESC, rr.reservation_time DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query
    const countQuery = `
      SELECT COUNT(*) as total
      FROM restaurant_reservations
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [reservationsResult, countResult] = await Promise.all([
      pool.query(reservationsQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const reservations = reservationsResult.rows.map(reservation => ({
      id: reservation.id,
      customer: {
        name: reservation.customer_name,
        phone: reservation.customer_phone,
        email: reservation.customer_email,
        userFullName: reservation.customer_full_name,
        userEmail: reservation.customer_user_email
      },
      reservationDate: reservation.reservation_date,
      reservationTime: reservation.reservation_time,
      partySize: reservation.party_size,
      specialRequests: reservation.special_requests,
      tablePreference: reservation.table_preference,
      status: reservation.status,
      confirmedAt: reservation.confirmed_at,
      cancelledAt: reservation.cancelled_at,
      cancellationReason: reservation.cancellation_reason,
      createdAt: reservation.created_at,
      updatedAt: reservation.updated_at
    }));

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    // Calculate summary statistics
    const summary = {
      totalReservations: total,
      pendingReservations: reservations.filter(r => r.status === 'pending').length,
      confirmedReservations: reservations.filter(r => r.status === 'confirmed').length,
      completedReservations: reservations.filter(r => r.status === 'completed').length,
      cancelledReservations: reservations.filter(r => r.status === 'cancelled').length
    };

    res.json({
      success: true,
      data: {
        restaurantId,
        restaurantName: restaurant.restaurant_name,
        reservations,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1
        },
        filters: {
          status,
          dateFrom,
          dateTo
        },
        summary
      }
    });

  } catch (error) {
    console.error('Error fetching restaurant reservations:', error);
    next(error);
  }
});

// Update reservation status (for restaurant owners)
router.patch('/:id/reservations/:reservationId/status', verifyJWT, authorize('restaurant-owner', 'admin'), async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const restaurantId = req.params.id;
    const reservationId = req.params.reservationId;
    const { status, cancellationReason } = req.body;

    // Validate status
    const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no-show'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: `Status must be one of: ${validStatuses.join(', ')}`
        }
      });
    }

    // Check restaurant ownership
    const checkQuery = `
      SELECT r.owner_id, r.name as restaurant_name, u.id as user_id, u.role 
      FROM restaurants r 
      LEFT JOIN users u ON u.firebase_uid = $2
      WHERE r.id = $1
    `;
    const checkResult = await pool.query(checkQuery, [restaurantId, req.user.uid]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESTAURANT_NOT_FOUND',
          message: 'Restaurant not found'
        }
      });
    }

    const restaurant = checkResult.rows[0];
    const isOwner = restaurant.owner_id === restaurant.user_id;
    const isAdmin = ['admin', 'district-admin', 'taluka-admin'].includes(restaurant.role);

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'You can only update reservations for your own restaurant'
        }
      });
    }

    // Build update query
    const now = new Date().toISOString();
    let updateQuery = 'UPDATE restaurant_reservations SET status = $1, updated_at = $2';
    let values = [status, now];
    let paramCounter = 2;

    if (status === 'confirmed') {
      paramCounter++;
      updateQuery += `, confirmed_at = $${paramCounter}`;
      values.push(now);
    }

    if (status === 'cancelled') {
      paramCounter++;
      updateQuery += `, cancelled_at = $${paramCounter}`;
      values.push(now);
      
      if (cancellationReason) {
        paramCounter++;
        updateQuery += `, cancellation_reason = $${paramCounter}`;
        values.push(cancellationReason);
      }
    }

    paramCounter++;
    values.push(reservationId);
    paramCounter++;
    values.push(restaurantId);

    updateQuery += ` WHERE id = $${paramCounter - 1} AND restaurant_id = $${paramCounter} RETURNING *`;

    const result = await pool.query(updateQuery, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'RESERVATION_NOT_FOUND',
          message: 'Reservation not found'
        }
      });
    }

    const reservation = result.rows[0];

    res.json({
      success: true,
      data: {
        id: reservation.id,
        status: reservation.status,
        confirmedAt: reservation.confirmed_at,
        cancelledAt: reservation.cancelled_at,
        cancellationReason: reservation.cancellation_reason,
        updatedAt: reservation.updated_at,
        message: `Reservation ${status} successfully`
      }
    });

  } catch (error) {
    console.error('Error updating reservation status:', error);
    next(error);
  }
});

// Get user's reservations
router.get('/my-reservations', verifyJWT, async (req, res, next) => {
  try {
    const pool = require('../../../config/database');
    const {
      status,
      page = 1,
      limit = 20
    } = req.query;

    // Get user ID
    const userQuery = 'SELECT id FROM users WHERE firebase_uid = $1';
    const userResult = await pool.query(userQuery, [req.user.uid]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found'
        }
      });
    }

    const customerId = userResult.rows[0].id;

    // Build query conditions
    let whereConditions = ['rr.customer_id = $1'];
    let queryParams = [customerId];
    let paramCounter = 1;

    if (status) {
      paramCounter++;
      whereConditions.push(`rr.status = $${paramCounter}`);
      queryParams.push(status);
    }

    // Calculate offset for pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    paramCounter++;
    const limitParam = paramCounter;
    paramCounter++;
    const offsetParam = paramCounter;
    queryParams.push(parseInt(limit), offset);

    // Main query
    const reservationsQuery = `
      SELECT 
        rr.*,
        r.name as restaurant_name,
        r.address as restaurant_address,
        r.contact_phone as restaurant_phone
      FROM restaurant_reservations rr
      LEFT JOIN restaurants r ON rr.restaurant_id = r.id
      WHERE ${whereConditions.join(' AND ')}
      ORDER BY rr.reservation_date DESC, rr.reservation_time DESC
      LIMIT $${limitParam} OFFSET $${offsetParam}
    `;

    // Count query
    const countQuery = `
      SELECT COUNT(*) as total
      FROM restaurant_reservations rr
      WHERE ${whereConditions.join(' AND ')}
    `;

    const [reservationsResult, countResult] = await Promise.all([
      pool.query(reservationsQuery, queryParams),
      pool.query(countQuery, queryParams.slice(0, -2))
    ]);

    const reservations = reservationsResult.rows.map(reservation => ({
      id: reservation.id,
      restaurant: {
        id: reservation.restaurant_id,
        name: reservation.restaurant_name,
        address: reservation.restaurant_address,
        phone: reservation.restaurant_phone
      },
      reservationDate: reservation.reservation_date,
      reservationTime: reservation.reservation_time,
      partySize: reservation.party_size,
      specialRequests: reservation.special_requests,
      tablePreference: reservation.table_preference,
      status: reservation.status,
      confirmedAt: reservation.confirmed_at,
      cancelledAt: reservation.cancelled_at,
      cancellationReason: reservation.cancellation_reason,
      createdAt: reservation.created_at,
      updatedAt: reservation.updated_at
    }));

    const total = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        reservations,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems: total,
          itemsPerPage: parseInt(limit),
          hasNext: parseInt(page) < totalPages,
          hasPrev: parseInt(page) > 1
        },
        filters: { status }
      }
    });

  } catch (error) {
    console.error('Error fetching user reservations:', error);
    next(error);
  }
});

module.exports = router;