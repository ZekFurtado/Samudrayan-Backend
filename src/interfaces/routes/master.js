const express = require('express');
const LocationRepository = require('../../domain/repositories/LocationRepository');
const CategoryRepository = require('../../domain/repositories/CategoryRepository');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();
const locationRepository = new LocationRepository();
const categoryRepository = new CategoryRepository();

router.get('/locations', async (req, res, next) => {
  try {
    const { status } = req.query;
    const includeInactive = status !== 'active';
    
    const locations = await locationRepository.getAllLocations(includeInactive);
    
    res.json({
      success: true,
      data: locations,
    });
  } catch (error) {
    next(error);
  }
});

router.get('/categories', async (req, res, next) => {
  try {
    const { type, status } = req.query;
    const includeInactive = status !== 'active';
    
    let data;
    
    if (type) {
      // Return categories for a specific type
      const categories = await categoryRepository.getCategoriesByType(type, includeInactive);
      data = categories.map(cat => ({
        id: cat.id,
        name: cat.category_name,
        subcategories: cat.subcategories,
        benefits: cat.benefits,
        isActive: cat.is_active
      }));
    } else {
      // Return all categories in the legacy format for backward compatibility
      data = await categoryRepository.getFormattedCategories(includeInactive);
    }

    res.json({
      success: true,
      data: data,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;