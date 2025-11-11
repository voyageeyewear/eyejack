const express = require('express');
const router = express.Router();
const bannerController = require('../controllers/bannerController');

// Public routes (for app)
router.get('/collection/:collectionHandle', bannerController.getBannersByCollection);

// Admin routes (for dashboard)
router.get('/', bannerController.getAllBanners);
router.get('/:id', bannerController.getBannerById);
router.post('/', bannerController.createBanner);
router.put('/:id', bannerController.updateBanner);
router.delete('/:id', bannerController.deleteBanner);
router.patch('/:id/toggle', bannerController.toggleBannerStatus);

module.exports = router;

