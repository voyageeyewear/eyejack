import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/collection_model.dart';
import '../models/product_model.dart';
import '../models/collection_banner_model.dart';
import '../providers/shop_provider.dart';
import '../services/api_service.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/collection_banner_widget.dart';

class CollectionScreen extends StatefulWidget {
  final Collection collection;

  const CollectionScreen({super.key, required this.collection});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> 
    with AutomaticKeepAliveClientMixin {
  List<Product>? _products;
  List<Product>? _filteredProducts;
  List<CollectionBanner> _banners = [];
  bool _isLoading = true;
  bool _bannersLoading = true;
  String? _error;
  bool _isGridView = true;
  String _sortBy = 'featured'; // featured, price_asc, price_desc, name_asc, name_desc
  
  // Filter states
  Map<String, bool> _selectedFilters = {};
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await ApiService().fetchCollectionBanners(widget.collection.handle);
      if (mounted) {
        setState(() {
          _banners = banners;
          _bannersLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading banners: $e');
      if (mounted) {
        setState(() {
          _bannersLoading = false;
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final products = await shopProvider.fetchProductsByCollection(widget.collection.handle);
      
      // Calculate max price for filter
      if (products.isNotEmpty) {
        final prices = products.map((p) {
          final amount = p.priceRange.maxVariantPrice?.amount;
          return double.tryParse(amount ?? '0') ?? 0.0;
        }).toList();
        _maxPrice = prices.reduce((a, b) => a > b ? a : b);
        _priceRange = RangeValues(0, _maxPrice);
      }
      
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (_products == null) return;
    
    List<Product> filtered = List.from(_products!);
    
    // Apply price filter
    filtered = filtered.where((product) {
      final priceStr = product.priceRange.minVariantPrice.amount;
      final price = double.tryParse(priceStr) ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();
    
    // Apply other filters (you can extend this)
    // Filter by tags, availability, etc.
    
    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _applySorting() {
    if (_filteredProducts == null) return;
    
    List<Product> sorted = List.from(_filteredProducts!);
    
    switch (_sortBy) {
      case 'price_asc':
        sorted.sort((a, b) {
          final priceA = double.tryParse(a.priceRange.minVariantPrice.amount) ?? 0.0;
          final priceB = double.tryParse(b.priceRange.minVariantPrice.amount) ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        sorted.sort((a, b) {
          final priceA = double.tryParse(a.priceRange.minVariantPrice.amount) ?? 0.0;
          final priceB = double.tryParse(b.priceRange.minVariantPrice.amount) ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'name_asc':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'name_desc':
        sorted.sort((a, b) => b.title.compareTo(a.title));
        break;
      default:
        // featured - keep original order
        break;
    }
    
    setState(() {
      _filteredProducts = sorted;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSortSheet(),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = RangeValues(0, _maxPrice);
                      _selectedFilters.clear();
                    });
                    _applyFilters();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Filter options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Filter
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: _maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '₹${_priceRange.start.toInt()}',
                      '₹${_priceRange.end.toInt()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${_priceRange.start.toInt()}'),
                      Text('₹${_priceRange.end.toInt()}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Availability Filter
                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('In Stock'),
                    value: _selectedFilters['in_stock'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilters['in_stock'] = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Out of Stock'),
                    value: _selectedFilters['out_of_stock'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilters['out_of_stock'] = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a2332),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSortOption('Featured', 'featured'),
          _buildSortOption('Price: Low to High', 'price_asc'),
          _buildSortOption('Price: High to Low', 'price_desc'),
          _buildSortOption('Name: A to Z', 'name_asc'),
          _buildSortOption('Name: Z to A', 'name_desc'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF27916D) : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF27916D))
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _applySorting();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.collection.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Open cart
            },
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
              const Text(
                'Collection Not Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The collection "${widget.collection.title}" could not be loaded.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
              onPressed: _loadProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27916D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts == null || _filteredProducts!.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return Column(
      children: [
        // Promotional Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: const Color(0xFF5DADE2),
          child: const Text(
            'BUY 1 GET 1 FREE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Filter/Sort/View Toggle Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
        children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune, size: 20),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.swap_vert, size: 20),
                  label: const Text('Sort'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        
        // Results Count
        Container(
          width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
            '${_filteredProducts!.length} Results',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        
        // Product Grid/List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _isGridView
                ? _buildProductGrid()
                : _buildProductList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal columns based on screen width
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 600 ? 3 : 2;
        
        // Woggles-style: VERY tall cards with HUGE images (matching screenshot exactly)
        final aspectRatio = 0.48; // MUCH TALLER than before - like Woggles
        
        // Get banners for different positions
        final topBanners = _banners.where((b) => b.bannerPosition == 'top').toList();
        final after6Banners = _banners.where((b) => b.bannerPosition == 'after_6').toList();
        final after12Banners = _banners.where((b) => b.bannerPosition == 'after_12').toList();
        
        return Column(
          children: [
            // Top banners
            if (topBanners.isNotEmpty)
              ...topBanners.map((banner) => CollectionBannerWidget(banner: banner)),
            
            // Products with interspersed banners
            ..._buildGridWithBanners(
              crossAxisCount: crossAxisCount,
              aspectRatio: aspectRatio,
              after6Banners: after6Banners,
              after12Banners: after12Banners,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildGridWithBanners({
    required int crossAxisCount,
    required double aspectRatio,
    required List<CollectionBanner> after6Banners,
    required List<CollectionBanner> after12Banners,
  }) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _filteredProducts!.length; i += 6) {
      // Add a grid of up to 6 products
      final endIndex = (i + 6) <= _filteredProducts!.length ? i + 6 : _filteredProducts!.length;
      final productsChunk = _filteredProducts!.sublist(i, endIndex);
      
      widgets.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: productsChunk.length,
          itemBuilder: (context, index) {
            return _buildProductCard(productsChunk[index]);
          },
        ),
      );
      
      // Add banner after every 6 products
      if (endIndex < _filteredProducts!.length) {
        if (i == 0 && after6Banners.isNotEmpty) {
          // After first 6 products
          widgets.addAll(after6Banners.map((banner) => CollectionBannerWidget(banner: banner)));
        } else if (i == 6 && after12Banners.isNotEmpty) {
          // After first 12 products
          widgets.addAll(after12Banners.map((banner) => CollectionBannerWidget(banner: banner)));
        }
      }
    }
    
    return widgets;
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProducts!.length,
      itemBuilder: (context, index) {
        return _buildProductListItem(_filteredProducts![index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final imageUrl = product.images.isNotEmpty ? product.images[0].src : '';
    
    // Get compare price from first variant if available
    final compareAtPriceStr = product.variants.isNotEmpty 
        ? product.variants.first.compareAtPrice?.amount 
        : null;
    final salePriceStr = product.priceRange.minVariantPrice.amount;
    
    final originalPrice = double.tryParse(compareAtPriceStr ?? '0') ?? 0.0;
    final salePrice = double.tryParse(salePriceStr) ?? 0.0;
    final hasDiscount = originalPrice > salePrice && originalPrice > 0;
    final discountPercent = hasDiscount
        ? (((originalPrice - salePrice) / originalPrice) * 100).toInt()
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge (BIGGER - like Woggles!)
            Flexible(
              flex: 11, // Was 6, now MUCH BIGGER for Woggles style
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _optimizeImageUrl(imageUrl, 1000),
                              fit: BoxFit.cover,
                              memCacheWidth: 1000,
                              memCacheHeight: 1400,
                              fadeInDuration: const Duration(milliseconds: 100),
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 40),
                              ),
                            )
                          : const Icon(Icons.image, size: 40),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPercent% off',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Details (Compact but fits everything!)
            Flexible(
              flex: 4, // Slightly bigger to fit all content
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    // Star Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = product.reviews?.rating ?? 5.0;
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            size: 12,
                            color: const Color(0xFFFFC107),
                          );
                        }),
                        const SizedBox(width: 3),
                        Text(
                          '${product.reviews?.rating.toStringAsFixed(1) ?? '5.0'} (${product.reviews?.count ?? 1})',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    
                    // Price (Horizontal: Real Price first, then Compare Price)
                    Row(
                      children: [
                        Text(
                          'Rs. ${salePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                        if (hasDiscount && originalPrice > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Rs. ${originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    
                    // EMI Option
                    Row(
                      children: [
                        const Text(
                          'or ',
                          style: TextStyle(fontSize: 8, color: Colors.grey),
                        ),
                        Text(
                          'Rs.${(salePrice / 3).toInt()}/Month',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27916D),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'Buy on EMI >',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(), // Push stock indicator to bottom
                    
                    // In Stock Indicator
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: product.availableForSale
                                ? const Color(0xFF27916D)
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.availableForSale ? 'In stock' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 8,
                            color: product.availableForSale
                                ? const Color(0xFF27916D)
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2), // Tiny space before buttons
                  ],
                ),
              ),
            ),
            
            // Add to Cart Button (Ultra Compact!)
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, top: 1, bottom: 0),
              child: ElevatedButton(
                onPressed: product.availableForSale
                    ? () => _addToCart(product)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 24),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Buy 1 Get 1 Free Button (No bottom padding!)
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, top: 1, bottom: 0),
              child: ElevatedButton(
                onPressed: product.availableForSale
                    ? () => _addToCart(product)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5DADE2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 22),
                ),
                child: const Text(
                  'BUY 1 GET 1 FREE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    final imageUrl = product.images.isNotEmpty ? product.images[0].src : '';
    final originalPriceStr = product.priceRange.maxVariantPrice?.amount ?? '0';
    final salePriceStr = product.priceRange.minVariantPrice.amount;
    final originalPrice = double.tryParse(originalPriceStr) ?? 0.0;
    final salePrice = double.tryParse(salePriceStr) ?? 0.0;
    final hasDiscount = originalPrice > salePrice;
    final discountPercent = hasDiscount
        ? (((originalPrice - salePrice) / originalPrice) * 100).toInt()
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _optimizeImageUrl(imageUrl, 600),
                            fit: BoxFit.cover,
                            memCacheWidth: 600,
                            memCacheHeight: 900,
                            fadeInDuration: const Duration(milliseconds: 100),
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 30),
                            ),
                          )
                        : const Icon(Icons.image, size: 30),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '$discountPercent% off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = product.reviews?.rating ?? 5.0;
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            size: 14,
                            color: const Color(0xFFFFC107),
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${product.reviews?.rating.toStringAsFixed(1) ?? '5.0'} (${product.reviews?.count ?? 1})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasDiscount && originalPrice > 0) ...[
                      Text(
                        'Rs. ${originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      'Rs. ${salePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: product.availableForSale
                                ? const Color(0xFF27916D)
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.availableForSale ? 'In stock' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: product.availableForSale
                                ? const Color(0xFF27916D)
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Future<void> _addToCart(Product product) async {
    try {
      debugPrint('🛒 ADD TO CART: Starting for product: ${product.title}');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Variants count: ${product.variants.length}');
      
      if (product.variants.isEmpty) {
        debugPrint('❌ No variants available for ${product.title}');
        throw Exception('No variants available for this product');
      }
      
      // Find first available variant
      final availableVariant = product.variants.firstWhere(
        (v) => v.availableForSale,
        orElse: () => product.variants.first,
      );
      
      debugPrint('   Selected variant ID: ${availableVariant.id}');
      debugPrint('   Variant title: ${availableVariant.title}');
      debugPrint('   Variant available: ${availableVariant.availableForSale}');
      
      // Show loading state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Adding to cart...'),
              ],
            ),
            backgroundColor: Color(0xFF1a2332),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      await ApiService().addToCart(
        variantId: availableVariant.id,
        quantity: 1,
      );
      
      debugPrint('✅ Successfully added ${product.title} to cart');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${product.title} added to cart!'),
            backgroundColor: const Color(0xFF27916D),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error adding to cart: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ Failed to add to cart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Optimize image URL with size parameter for faster loading
  String _optimizeImageUrl(String url, int width) {
    if (url.contains('cdn.shopify.com')) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}width=$width';
    }
    return url;
  }
}
