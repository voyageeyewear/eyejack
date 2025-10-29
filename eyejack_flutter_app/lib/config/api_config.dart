class ApiConfig {
  // Change this to your middleware API URL
  // For Android Emulator: 'http://10.0.2.2:3000'
  // For iOS Simulator: 'http://localhost:3000'
  // For Physical Device: 'http://YOUR_IP:3000'
  // For production: 'https://your-deployed-api.com'
  static const String baseUrl = 'https://motivated-intuition-production.up.railway.app';
  
  // API Endpoints
  static const String themeSections = '/api/shopify/theme-sections';
  static const String products = '/api/shopify/products';
  static const String collections = '/api/shopify/collections';
  static const String shopInfo = '/api/shopify/shop';
  static const String search = '/api/shopify/search';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}

