import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BestSellingCollectionWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const BestSellingCollectionWidget({
    super.key,
    required this.settings,
  });

  @override
  State<BestSellingCollectionWidget> createState() => _BestSellingCollectionWidgetState();
}

class _BestSellingCollectionWidgetState extends State<BestSellingCollectionWidget> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final collectionHandle = widget.settings['collectionHandle'] ?? 'best-selling';
      
      // Fetch products from the specified collection
      final products = await shopProvider.fetchProductsByCollection(collectionHandle);
      
      // Limit to specified number of products (default 6)
      final limit = widget.settings['productsLimit'] ?? 6;
      
      setState(() {
        _products = products.take(limit).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading best selling products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.settings['title'] ?? 'Best Selling';
    final subtitle = widget.settings['subtitle'] ?? 'Our most popular products';
    final showViewAll = widget.settings['showViewAll'] ?? true;
    final backgroundColor = widget.settings['backgroundColor'] ?? '#FFFFFF';
    final collectionHandle = widget.settings['collectionHandle'] ?? 'best-selling';

    return Container(
      color: _parseColor(backgroundColor),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    // Navigate to collection page
                    Navigator.pushNamed(
                      context,
                      '/collection',
                      arguments: collectionHandle,
                    );
                  },
                  child: const Text(
                    'View All →',
                    style: TextStyle(
                      color: Color(0xFF52b1e2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Products Grid
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF52b1e2),
                    ),
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(_products[index]);
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    // Get first variant's compare at price for discount calculation
    final firstVariant = product.variants.isNotEmpty ? product.variants.first : null;
    final compareAtPrice = firstVariant?.compareAtPrice;
    final price = product.priceRange.minVariantPrice;
    
    final hasDiscount = compareAtPrice != null &&
        double.parse(compareAtPrice.amount) > double.parse(price.amount);
    final discountPercentage = hasDiscount
        ? (((double.parse(compareAtPrice!.amount) - double.parse(price.amount)) / 
            double.parse(compareAtPrice.amount)) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: product.images.isNotEmpty 
                          ? product.images.first.src 
                          : '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF52b1e2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52b1e2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EYEJACK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52b1e2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Product Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Row(
                      children: [
                        Text(
                          price.formatted,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (hasDiscount && compareAtPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            compareAtPrice.formatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }
}

