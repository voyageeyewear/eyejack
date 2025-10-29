import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/collection_model.dart';
import '../models/section_model.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  ThemeData? _themeData;
  List<Product> _products = [];
  List<Collection> _collections = [];
  bool _isLoading = false;
  String? _error;

  ThemeData? get themeData => _themeData;
  List<Product> get products => _products;
  List<Collection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch theme sections
  Future<void> fetchThemeSections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _themeData = await _apiService.fetchThemeSections();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch products
  Future<void> fetchProducts({int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts(limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch collections
  Future<void> fetchCollections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await _apiService.fetchCollections();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _apiService.searchProducts(query);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Fetch products by collection
  Future<List<Product>> fetchProductsByCollection(String handle) async {
    try {
      return await _apiService.fetchProductsByCollection(handle);
    } catch (e) {
      throw Exception('Failed to load collection: $e');
    }
  }
}

