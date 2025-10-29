import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';
import '../models/collection_model.dart';
import '../models/section_model.dart';

class ApiService {
  // Fetch theme sections
  Future<ThemeData> fetchThemeSections() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.themeSections}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ThemeData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load theme sections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching theme sections: $e');
    }
  }

  // Fetch products
  Future<List<Product>> fetchProducts({int limit = 50}) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}?limit=$limit'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['data'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch product by ID
  Future<Product> fetchProductById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}/$id'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['data']);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Fetch collections
  Future<List<Collection>> fetchCollections() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.collections}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final collections = (data['data'] as List)
            .map((collection) => Collection.fromJson(collection))
            .toList();
        return collections;
      } else {
        throw Exception('Failed to load collections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching collections: $e');
    }
  }

  // Fetch products by collection
  Future<List<Product>> fetchProductsByCollection(String handle, {int limit = 50}) async {
    try {
      final response = await http
          .get(Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.products}/collection/$handle?limit=$limit'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final collectionData = data['data'];
        final products = (collectionData['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load collection products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching collection products: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.search}?q=$query'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['data'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
        return products;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}

