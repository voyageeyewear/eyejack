const express = require('express');
const router = express.Router();
const shopifyController = require('../controllers/shopifyController');

// Theme and homepage sections
router.get('/theme-sections', shopifyController.getThemeSections);
router.get('/theme-files', shopifyController.getThemeFiles);
router.get('/theme-assets', shopifyController.getAllThemeAssets);

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

// Cart endpoints
router.post('/cart/add', shopifyController.addToCart);
router.post('/cart/add-multiple', shopifyController.addMultipleToCart);
router.post('/cart/update', shopifyController.updateCart);
router.post('/cart/remove', shopifyController.removeFromCart);
router.get('/cart', shopifyController.getCart);
router.post('/cart/clear', shopifyController.clearCart);

// Checkout endpoints
router.post('/checkout/create', shopifyController.createCheckout);
router.post('/checkout/gokwik', shopifyController.createGokwikCheckout);

// Lens options endpoint (fetch lens data from product metafields)
router.get('/lens-options', shopifyController.getLensOptions);

// Loox Reviews endpoints
router.get('/loox/product/:productId/reviews', shopifyController.getProductReviews);
router.get('/loox/product/:productId/review-count', shopifyController.getProductReviewCount);
router.post('/loox/products/review-counts', shopifyController.getBulkReviewCounts);

module.exports = router;

