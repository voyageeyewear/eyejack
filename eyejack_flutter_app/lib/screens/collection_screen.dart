import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection_model.dart';
import '../models/product_model.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_grid_widget.dart';

class CollectionScreen extends StatefulWidget {
  final Collection collection;

  const CollectionScreen({super.key, required this.collection});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Product>? _products;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final products = await shopProvider.fetchProductsByCollection(widget.collection.handle);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products == null || _products!.isEmpty) {
      return const Center(
        child: Text('No products found in this collection'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.collection.description != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.collection.description!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ProductGridWidget(
            settings: {
              'title': '',
              'products': _products,
              'columns': 2,
            },
          ),
        ],
      ),
    );
  }
}

