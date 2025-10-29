const shopifyService = require('../services/shopifyService');

// Get theme sections for homepage
exports.getThemeSections = async (req, res, next) => {
  try {
    const sections = await shopifyService.fetchThemeSections();
    res.json({
      success: true,
      data: sections
    });
  } catch (error) {
    next(error);
  }
};

// Get all products
exports.getProducts = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const products = await shopifyService.fetchProducts(limit);
    res.json({
      success: true,
      data: products
    });
  } catch (error) {
    next(error);
  }
};

// Get product by ID
exports.getProductById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const product = await shopifyService.fetchProductById(id);
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
};

// Get products by collection
exports.getProductsByCollection = async (req, res, next) => {
  try {
    const { handle } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const products = await shopifyService.fetchProductsByCollection(handle, limit);
    res.json({
      success: true,
      data: products
    });
  } catch (error) {
    next(error);
  }
};

// Get all collections
exports.getCollections = async (req, res, next) => {
  try {
    const collections = await shopifyService.fetchCollections();
    res.json({
      success: true,
      data: collections
    });
  } catch (error) {
    next(error);
  }
};

// Get collection by handle
exports.getCollectionByHandle = async (req, res, next) => {
  try {
    const { handle } = req.params;
    const collection = await shopifyService.fetchCollectionByHandle(handle);
    res.json({
      success: true,
      data: collection
    });
  } catch (error) {
    next(error);
  }
};

// Get shop information
exports.getShopInfo = async (req, res, next) => {
  try {
    const shopInfo = await shopifyService.fetchShopInfo();
    res.json({
      success: true,
      data: shopInfo
    });
  } catch (error) {
    next(error);
  }
};

// Search products
exports.searchProducts = async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({
        success: false,
        error: 'Search query is required'
      });
    }
    const results = await shopifyService.searchProducts(q);
    res.json({
      success: true,
      data: results
    });
  } catch (error) {
    next(error);
  }
};

