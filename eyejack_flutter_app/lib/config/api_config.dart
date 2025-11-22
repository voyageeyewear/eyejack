class ApiConfig {
  // Production Railway URL (works everywhere - emulator AND real devices)
  static const String baseUrl = 'https://motivated-intuition-production.up.railway.app';
  
  // API Endpoints
  static const String themeSections = '/api/shopify/theme-sections';
  static const String products = '/api/shopify/products';
  static const String collections = '/api/shopify/collections';
  static const String shopInfo = '/api/shopify/shop';
  static const String search = '/api/shopify/search';
  
  // Loox Reviews endpoints
  static const String looxProductReviews = '/api/shopify/loox/product';
  static const String looxProductReviewCount = '/api/shopify/loox/product';
  static const String looxBulkReviewCounts = '/api/shopify/loox/products/review-counts';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}

