const express = require('express');
const { verifyJWT, authorize } = require('../middleware/auth');
const TourismRepository = require('../../domain/repositories/TourismRepository');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();
const tourismRepository = new TourismRepository();

// Get all tourist locations
router.get('/locations', async (req, res, next) => {
  try {
    const { taluka, search } = req.query;
    
    let locations;
    
    if (search) {
      locations = await tourismRepository.searchTouristLocations(search);
    } else if (taluka) {
      locations = await tourismRepository.getTouristLocationsByTaluka(taluka);
    } else {
      locations = await tourismRepository.getAllTouristLocations({ taluka, search });
    }
    
    res.json({
      success: true,
      data: locations,
    });
  } catch (error) {
    next(error);
  }
});

// Get single tourist location by ID
router.get('/locations/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const location = await tourismRepository.getTouristLocationById(id);
    
    if (!location) {
      throw new AppError('Tourist location not found', 404);
    }
    
    res.json({
      success: true,
      data: location,
    });
  } catch (error) {
    next(error);
  }
});

// Create new tourist location (admin only)
router.post('/locations', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const {
      sr_no,
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    } = req.body;
    
    // Validation
    if (!place_name || !taluka) {
      throw new AppError('Required fields: place_name, taluka', 400);
    }
    
    const locationData = {
      sr_no,
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    };
    
    const newLocation = await tourismRepository.createTouristLocation(locationData);
    
    res.status(201).json({
      success: true,
      data: newLocation,
    });
  } catch (error) {
    next(error);
  }
});

// Update tourist location (admin only)
router.post('/locations/:id/update', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    } = req.body;
    
    // Check if location exists
    const existingLocation = await tourismRepository.getTouristLocationById(id);
    if (!existingLocation) {
      throw new AppError('Tourist location not found', 404);
    }
    
    // Validation
    if (!place_name || !taluka) {
      throw new AppError('Required fields: place_name, taluka', 400);
    }
    
    const locationData = {
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    };
    
    const updatedLocation = await tourismRepository.updateTouristLocation(id, locationData);
    
    res.json({
      success: true,
      data: updatedLocation,
    });
  } catch (error) {
    next(error);
  }
});

// Delete tourist location (admin only)
router.post('/locations/:id/delete', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Check if location exists
    const existingLocation = await tourismRepository.getTouristLocationById(id);
    if (!existingLocation) {
      throw new AppError('Tourist location not found', 404);
    }
    
    const deletedLocation = await tourismRepository.deleteTouristLocation(id);
    
    res.json({
      success: true,
      data: {
        message: 'Tourist location deleted successfully',
        deleted: deletedLocation,
      },
    });
  } catch (error) {
    next(error);
  }
});

// Get tourist location statistics (admin only)
router.get('/locations-statistics', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const stats = await tourismRepository.getTouristLocationStatistics();
    
    res.json({
      success: true,
      data: {
        totalLocations: parseInt(stats.total_locations),
        totalTalukas: parseInt(stats.total_talukas),
        locationsWithVideo: parseInt(stats.locations_with_video),
        locationsWithImages: parseInt(stats.locations_with_images),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Get all experiences/tourism spots
router.get('/experiences', async (req, res, next) => {
  try {
    const { location, district, taluka, search, popular, limit } = req.query;
    
    let experiences;
    
    if (search) {
      experiences = await tourismRepository.searchExperiences(search);
    } else if (popular) {
      const limitNum = parseInt(limit) || 10;
      experiences = await tourismRepository.getPopularExperiences(limitNum);
    } else if (district) {
      experiences = await tourismRepository.getExperiencesByLocation(district, taluka);
    } else {
      experiences = await tourismRepository.getAllExperiences();
    }
    
    res.json({
      success: true,
      data: experiences,
    });
  } catch (error) {
    next(error);
  }
});

// Get single experience by ID
router.get('/experiences/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const experience = await tourismRepository.getExperienceById(id);
    
    if (!experience) {
      throw new AppError('Experience not found', 404);
    }
    
    res.json({
      success: true,
      data: experience,
    });
  } catch (error) {
    next(error);
  }
});

// Create new experience (admin only)
router.post('/experiences', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { title, description, price } = req.body;
    
    // Validation
    if (!title || !description || price === undefined) {
      throw new AppError('Required fields: title, description, price', 400);
    }
    
    if (typeof price !== 'number' || price < 0) {
      throw new AppError('Price must be a non-negative number', 400);
    }
    
    const experienceData = { title, description, price };
    const experience = await tourismRepository.createExperience(experienceData);
    
    res.status(201).json({
      success: true,
      data: experience,
    });
  } catch (error) {
    next(error);
  }
});

// Update experience (admin only)
router.put('/experiences/:id', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, description, price } = req.body;
    
    // Check if experience exists
    const existingExperience = await tourismRepository.getExperienceById(id);
    if (!existingExperience) {
      throw new AppError('Experience not found', 404);
    }
    
    // Validation
    if (!title || !description || price === undefined) {
      throw new AppError('Required fields: title, description, price', 400);
    }
    
    if (typeof price !== 'number' || price < 0) {
      throw new AppError('Price must be a non-negative number', 400);
    }
    
    const experienceData = { title, description, price };
    const experience = await tourismRepository.updateExperience(id, experienceData);
    
    res.json({
      success: true,
      data: experience,
    });
  } catch (error) {
    next(error);
  }
});

// Delete experience (admin only)
router.delete('/experiences/:id', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Check if experience exists
    const existingExperience = await tourismRepository.getExperienceById(id);
    if (!existingExperience) {
      throw new AppError('Experience not found', 404);
    }
    
    const deletedExperience = await tourismRepository.deleteExperience(id);
    
    res.json({
      success: true,
      data: {
        message: 'Experience deleted successfully',
        deleted: deletedExperience,
      },
    });
  } catch (error) {
    next(error);
  }
});

// Get tourism statistics (admin only)
router.get('/statistics', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const stats = await tourismRepository.getExperienceStatistics();
    
    res.json({
      success: true,
      data: {
        totalExperiences: parseInt(stats.total_experiences),
        averagePrice: parseFloat(stats.average_price) || 0,
        priceRange: {
          min: parseFloat(stats.min_price) || 0,
          max: parseFloat(stats.max_price) || 0,
        },
        propertiesWithExperiences: parseInt(stats.properties_with_experiences),
      },
    });
  } catch (error) {
    next(error);
  }
});

// Add experience to property (admin only)
router.post('/experiences/:experienceId/properties/:propertyId', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { experienceId, propertyId } = req.params;
    
    // Check if experience exists
    const experience = await tourismRepository.getExperienceById(experienceId);
    if (!experience) {
      throw new AppError('Experience not found', 404);
    }
    
    const result = await tourismRepository.addExperienceToProperty(experienceId, propertyId);
    
    res.json({
      success: true,
      data: {
        message: 'Experience added to property successfully',
        association: result,
      },
    });
  } catch (error) {
    next(error);
  }
});

// Remove experience from property (admin only)
router.delete('/experiences/:experienceId/properties/:propertyId', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const { experienceId, propertyId } = req.params;
    
    const result = await tourismRepository.removeExperienceFromProperty(experienceId, propertyId);
    
    if (!result) {
      throw new AppError('Association not found', 404);
    }
    
    res.json({
      success: true,
      data: {
        message: 'Experience removed from property successfully',
        removed: result,
      },
    });
  } catch (error) {
    next(error);
  }
});

// Legacy route for backward compatibility - now returns tourist locations
router.get('/spots', async (req, res, next) => {
  try {
    const { taluka, search } = req.query;
    let locations;
    
    if (search) {
      locations = await tourismRepository.searchTouristLocations(search);
    } else if (taluka) {
      locations = await tourismRepository.getTouristLocationsByTaluka(taluka);
    } else {
      locations = await tourismRepository.getAllTouristLocations({ taluka, search });
    }
    
    res.json({
      success: true,
      data: locations,
    });
  } catch (error) {
    next(error);
  }
});

// Legacy route for creating spots (now creates tourist locations)
router.post('/spots', verifyJWT, authorize('admin'), async (req, res, next) => {
  try {
    const {
      sr_no,
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    } = req.body;
    
    // Validation for backward compatibility and new fields
    if (!place_name || !taluka) {
      throw new AppError('Required fields: place_name, taluka', 400);
    }
    
    const locationData = {
      sr_no,
      place_name,
      taluka,
      location,
      latitude_longitude,
      video_link,
      description,
      famous_for,
      best_time_to_visit,
      ideal_duration,
      images_drive_link,
      firebase_storage_images
    };
    
    const newLocation = await tourismRepository.createTouristLocation(locationData);
    
    res.status(201).json({
      success: true,
      data: newLocation,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;