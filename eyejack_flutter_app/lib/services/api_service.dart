import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';
import '../models/collection_model.dart';
import '../models/section_model.dart';
import '../models/collection_banner_model.dart';

class ApiService {
  // Fetch theme sections
  Future<ThemeData> fetchThemeSections() async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.themeSections}';
      
      print('🔄 Fetching theme sections from: $url');
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Theme sections loaded successfully');
        print('   Total sections: ${data['data']['layout']?.length ?? 0}');
        
        // Log circular categories specifically
        final circularSection = (data['data']['layout'] as List?)?.firstWhere(
          (s) => s['id'] == 'circular-categories',
          orElse: () => null,
        );
        if (circularSection != null) {
          print('🔍 Circular categories found:');
          final categories = circularSection['settings']['categories'] as List?;
          categories?.forEach((cat) {
            print('   - ${cat['name']}: type=${cat['type']}, image=${cat['image']?.substring(0, 50)}...');
          });
        }
        
        return ThemeData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load theme sections: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching theme sections: $e');
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

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String variantId,
    required int quantity,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final body = {
        'variantId': variantId,
        'quantity': quantity,
        if (properties != null) 'properties': properties,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Add multiple items to cart (lens + frame together)
  Future<Map<String, dynamic>> addMultipleToCart({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      print('🛒 ADDING MULTIPLE ITEMS: ${json.encode(items)}');
      
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart/add-multiple'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'items': items}),
          )
          .timeout(ApiConfig.timeout);

      print('🔍 RESPONSE STATUS: ${response.statusCode}');
      print('🔍 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to add multiple items: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      throw Exception('Error adding multiple items: $e');
    }
  }

  // Create checkout with cart items
  Future<String> createCheckout({
    required List<Map<String, dynamic>> lineItems,
  }) async {
    try {
      final body = {'lineItems': lineItems};

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/checkout/create'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['webUrl'] as String;
      } else {
        throw Exception('Failed to create checkout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating checkout: $e');
    }
  }

  // Create Gokwik checkout
  Future<Map<String, dynamic>> createGokwikCheckout() async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/checkout/gokwik'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create Gokwik checkout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating Gokwik checkout: $e');
    }
  }

  // Get current cart
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to get cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cart: $e');
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCart({
    required String variantId,
    required int quantity,
  }) async {
    try {
      final body = {
        'variantId': variantId,
        'quantity': quantity,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart/update'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart({
    required String variantId,
  }) async {
    try {
      final body = {'variantId': variantId};

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart/remove'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  // Clear all items from cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await http
          .post(Uri.parse('${ApiConfig.baseUrl}/api/shopify/cart/clear'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  // Fetch lens options from Shopify (categorized by type)
  Future<Map<String, dynamic>> fetchLensOptions() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/shopify/lens-options'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Return categorized lenses
        return {
          'antiGlareLenses': List<Map<String, dynamic>>.from(data['data']['antiGlareLenses'] ?? []),
          'blueBlockLenses': List<Map<String, dynamic>>.from(data['data']['blueBlockLenses'] ?? []),
          'colourLenses': List<Map<String, dynamic>>.from(data['data']['colourLenses'] ?? []),
          'allLenses': List<Map<String, dynamic>>.from(data['data']['lenses'] ?? []),
        };
      } else {
        throw Exception('Failed to load lens options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lens options: $e');
    }
  }

  // Fetch collection banners
  Future<List<CollectionBanner>> fetchCollectionBanners(String collectionHandle) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/banners/collection/$collectionHandle'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final bannersJson = data['data'] as List;
          return bannersJson
              .map((json) => CollectionBanner.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        debugPrint('Failed to load banners: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      return [];
    }
  }
}

