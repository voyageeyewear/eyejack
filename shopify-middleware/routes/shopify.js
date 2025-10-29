const express = require('express');
const router = express.Router();
const shopifyController = require('../controllers/shopifyController');

// Theme and homepage sections
router.get('/theme-sections', shopifyController.getThemeSections);

// Products
router.get('/products', shopifyController.getProducts);
router.get('/products/:id', shopifyController.getProductById);
router.get('/products/collection/:handle', shopifyController.getProductsByCollection);

// Collections
router.get('/collections', shopifyController.getCollections);
router.get('/collections/:handle', shopifyController.getCollectionByHandle);

// Shop Info
router.get('/shop', shopifyController.getShopInfo);

// Search
router.get('/search', shopifyController.searchProducts);

module.exports = router;

