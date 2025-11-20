import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';
import '../models/collection_model.dart';
import '../services/api_service.dart';
import '../screens/kp_checkout_screen.dart';
import '../widgets/lens_selector_drawer.dart';
import '../widgets/sticky_cart_widget.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/variant_selector_widget.dart';
import '../widgets/product_features_widget.dart';
import '../widgets/product_specs_widget.dart';
import '../widgets/product_faq_widget.dart';
import '../widgets/product_video_widget.dart';
import '../widgets/color_swatch_widget.dart';
import 'collection_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  ProductVariant? _selectedVariant;
  Map<String, dynamic>? _selectedLensOptions;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyCart = false;
  bool _isDescriptionExpanded = false;
  bool _isFrameMeasurementsExpanded = false;
  bool _isProductHighlightsExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }

    // Show sticky cart when scrolled down
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showStickyCart) {
        setState(() {
          _showStickyCart = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBreadcrumbNavigation(String category) {
    // Navigate to collection in-app
    final handle = category.toLowerCase().replaceAll(' ', '-');
    debugPrint('🔗 Breadcrumb tapped: $handle');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectionScreen(
          collection: Collection(
            id: handle,
            title: category,
            handle: handle,
            description: null,
            image: null,
          ),
        ),
      ),
    );
  }

  void _showCartDrawer() {
    // Store the parent context and navigator before opening modal
    final parentContext = context;
    final parentNavigator = Navigator.of(context);
    final parentScaffoldMessenger = ScaffoldMessenger.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => CartDrawer(
        onCheckout: () async {
          // Close the modal first
          Navigator.pop(modalContext);
          
          // Wait a bit for modal to close completely
          await Future.delayed(const Duration(milliseconds: 300));
          
          try {
            debugPrint('🛒 Opening Kwikpass checkout...');
            
            // Show loading indicator using the parent context
            parentScaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Opening checkout...'),
                  ],
                ),
                backgroundColor: Color(0xFF27916D),
                duration: Duration(seconds: 2),
              ),
            );
            
            // Create GoKwik checkout through backend API (this handles the proper integration)
            debugPrint('📞 Calling backend API to create GoKwik checkout...');
            final gokwikCheckoutData = await ApiService().createGokwikCheckout();
            
            debugPrint('✅ GoKwik checkout data: $gokwikCheckoutData');
            
            // Extract checkout URL from backend response
            final checkoutUrl = gokwikCheckoutData['checkoutUrl']?.toString();
            final cartId = gokwikCheckoutData['cartId']?.toString();
            final merchantId = gokwikCheckoutData['merchantId']?.toString() ?? '19g6iluwldmy4';
            
            debugPrint('✅ Checkout URL: $checkoutUrl');
            debugPrint('✅ Cart ID: $cartId');
            debugPrint('✅ Merchant ID: $merchantId');
            
            if (checkoutUrl == null || checkoutUrl.isEmpty) {
              throw Exception('Failed to create checkout URL. Please try again.');
            }
            
            // Extract clean cart ID if needed
            String cleanCartId = cartId ?? '';
            if (cleanCartId.contains('gid://shopify/Cart/')) {
              final match = RegExp(r'gid://shopify/Cart/([^?]+)').firstMatch(cleanCartId);
              if (match != null && match.group(1) != null) {
                cleanCartId = match.group(1)!;
              }
            }
            
            debugPrint('🚀 Navigating to checkout with URL: $checkoutUrl');
            
            // Navigate to Kwikpass Checkout screen using the parent navigator
            // Use a post-frame callback to ensure navigation happens after modal is fully closed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && parentContext.mounted) {
                debugPrint('✅ Context is valid, pushing checkout screen...');
                parentNavigator.push(
                  MaterialPageRoute(
                    builder: (context) => KPCheckoutScreen(
                      cartId: cleanCartId.isNotEmpty ? cleanCartId : null,
                      storefrontToken: '0032c089ead422dfbfaa0ffcbbddcc97', // Storefront API token
                      storeId: merchantId, // Merchant ID from backend
                      checkoutUrl: checkoutUrl, // Use checkout URL from backend
                    ),
                  ),
                ).then((result) {
                  // Handle checkout result
                  if (result == true && mounted && parentContext.mounted) {
                    parentScaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Order placed successfully!'),
                        backgroundColor: Color(0xFF27916D),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error) {
                  debugPrint('❌ Navigation error: $error');
                  if (mounted && parentContext.mounted) {
                    parentScaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error navigating to checkout: $error'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                });
              } else {
                debugPrint('❌ Context not valid for navigation');
              }
            });
          } catch (e, stackTrace) {
            debugPrint('❌ Error opening checkout: $e');
            debugPrint('❌ Stack trace: $stackTrace');
            
            if (mounted && parentContext.mounted) {
              parentScaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNoPowerTag = widget.product.tags.contains('no-power');

    // Check for 'spec' tag (case-insensitive)
    final hasSpecTag = widget.product.tags.any((tag) => tag.toLowerCase() == 'spec');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Add to favorites
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Share product
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: _showCartDrawer,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                _buildBreadcrumbs(),
                
                // Image Gallery
                _buildImageGallery(),
                
                // Product Info Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        widget.product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Review Stars
                      _buildReviewStars(),
                      const SizedBox(height: 16),

                      // Trust Badges
                      _buildTrustBadges(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),

                // Color Swatches
                ColorSwatchWidget(
                  currentProduct: widget.product,
                  onColorSelected: (product) {
                    // Navigate to the selected color variant product
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 8),

                // Variant Selector (new component)
                if (widget.product.variants.length > 1)
                  VariantSelectorWidget(
                    variants: widget.product.variants,
                    selectedVariant: _selectedVariant,
                    onVariantSelected: (variant) {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    },
                  ),

                const SizedBox(height: 8),

                // Product Features (new component)
                ProductFeaturesWidget(
                  features: _buildFeaturesList(),
                ),

                const SizedBox(height: 8),

                // Product Description
                _buildDescriptionSection(),

                const SizedBox(height: 8),

                // Frame Measurements
                _buildFrameMeasurements(),

                const SizedBox(height: 8),

                // Product Videos (if available)
                ProductVideoWidget(
                  videoUrls: _extractVideoUrls(),
                ),

                const SizedBox(height: 8),

                // Product Highlights Image Collage (only if multiple images)
                if (widget.product.images.length > 1)
                  _buildProductHighlights(),

                const SizedBox(height: 8),

                // Product Specifications (new component) - Only show if product has 'spec' tag
                if (hasSpecTag) ...[
                ProductSpecsWidget(
                  specs: _buildSpecsData(),
                ),
                const SizedBox(height: 8),
                ],

                // Product FAQs (new component)
                ProductFAQWidget(
                  faqs: _buildFAQs(),
                ),
                
                // Bottom padding to account for sticky cart
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Sticky Cart - Modern redesign
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildModernStickyCart(hasNoPowerTag),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    // Extract collection/category from product tags or type
    final productType = widget.product.productType ?? '';
    final category = productType.isNotEmpty 
        ? productType 
        : (widget.product.tags.isNotEmpty ? widget.product.tags.first : 'Products');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right, size: 12, color: Colors.grey[400]),
          ),
          GestureDetector(
            onTap: () => _handleBreadcrumbNavigation(category),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right, size: 12, color: Colors.grey[400]),
          ),
          Flexible(
            child: Text(
              widget.product.title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images;
    
    // Debug logging
    debugPrint('📸 Product Images Debug:');
    debugPrint('   Product: ${widget.product.title}');
    debugPrint('   Total Images: ${images.length}');
    for (int i = 0; i < images.length; i++) {
      debugPrint('   Image $i: ${images[i].src.substring(0, 60)}...');
    }
    
    if (images.isEmpty) {
      return Container(
        height: 400,
        color: Colors.white,
        child: Center(
          child: Icon(Icons.image_outlined, size: 100, color: Colors.grey[300]),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main Image Carousel
          Stack(
            children: [
              FlutterCarousel(
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: images.length > 1,
                  showIndicator: false,
                  slideIndicator: null,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: images.map((image) {
                  return Hero(
                    tag: 'product_${widget.product.id}_${image.src}',
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: CachedNetworkImage(
                        imageUrl: image.src,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[50],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF27916D),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[50],
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Image counter
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Thumbnail Navigation
          if (images.length > 1)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length, // Shows ALL images
                  itemBuilder: (context, index) {
                    debugPrint('🖼️ Rendering thumbnail $index of ${images.length}');
                    final isSelected = _currentImageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF27916D)
                                : Colors.grey[300]!,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: images[index].src,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final price = _selectedVariant?.price ?? widget.product.priceRange.minVariantPrice;
    final compareAtPrice = _selectedVariant?.compareAtPrice;
    
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          price.formatted,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF27916D),
          ),
        ),
        if (compareAtPrice != null) ...[
          Text(
            compareAtPrice.formatted,
            style: TextStyle(
              fontSize: 20,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_calculateDiscount(compareAtPrice, price)}% OFF',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  int _calculateDiscount(Price compareAt, Price current) {
    final compareAmount = double.parse(compareAt.amount);
    final currentAmount = double.parse(current.amount);
    final discount = ((compareAmount - currentAmount) / compareAmount * 100);
    return discount.round();
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF27916D).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrustBadge(Icons.local_shipping_outlined, 'Free\nShipping'),
          _buildTrustBadge(Icons.swap_horiz, 'Easy\nReturns'),
          _buildTrustBadge(Icons.verified_outlined, 'Authentic\nProducts'),
          _buildTrustBadge(Icons.support_agent_outlined, '24/7\nSupport'),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF27916D), size: 24),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildVariantSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.product.variants.map((variant) {
            final isSelected = _selectedVariant?.id == variant.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariant = variant;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  variant.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.product.description;
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.description_outlined, color: Color(0xFF27916D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Product Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isDescriptionExpanded ? Icons.remove : Icons.add,
                    color: Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          
          // Content (only shown when expanded)
          if (_isDescriptionExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {'icon': Icons.remove_red_eye_outlined, 'title': 'UV Protection', 'subtitle': '100% UV400 Protection'},
      {'icon': Icons.layers_outlined, 'title': 'Premium Material', 'subtitle': 'High-quality acetate frame'},
      {'icon': Icons.support_agent_outlined, 'title': 'Warranty', 'subtitle': '1 Year Manufacturer Warranty'},
      {'icon': Icons.local_shipping_outlined, 'title': 'Delivery', 'subtitle': 'Free delivery across India'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: const Color(0xFF27916D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFrameMeasurements() {
    // Extract measurements from description
    final description = widget.product.description;
    String lensWidth = '--';
    String bridge = '--';
    String temple = '--';
    
    // Try to extract measurements from description
    // Pattern: "Lens Width (mm): 52mm" or "52mm"
    final lensMatch = RegExp(r'Lens Width[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (lensMatch != null) {
      lensWidth = '${lensMatch.group(1)}mm';
    }
    
    final bridgeMatch = RegExp(r'Bridge[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (bridgeMatch != null) {
      bridge = '${bridgeMatch.group(1)}mm';
    }
    
    final templeMatch = RegExp(r'Temple[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (templeMatch != null) {
      temple = '${templeMatch.group(1)}mm';
    }
    
    // Also try alternative patterns like "52-18-145"
    final compactMatch = RegExp(r'(\d{2})-(\d{2})-(\d{3})').firstMatch(description);
    if (compactMatch != null && lensWidth == '--') {
      lensWidth = '${compactMatch.group(1)}mm';
      bridge = '${compactMatch.group(2)}mm';
      temple = '${compactMatch.group(3)}mm';
    }
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isFrameMeasurementsExpanded = !_isFrameMeasurementsExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.straighten, color: Color(0xFF27916D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Frame Measurements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isFrameMeasurementsExpanded ? Icons.remove : Icons.add,
                    color: Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          
          // Content (only shown when expanded)
          if (_isFrameMeasurementsExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMeasurement('Lens Width', lensWidth),
                  _buildMeasurement('Bridge', bridge),
                  _buildMeasurement('Temple', temple),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeasurement(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showLensSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LensSelectorDrawer(
        product: widget.product,
        onLensSelected: (lensOptions) {
          setState(() {
            _selectedLensOptions = lensOptions;
          });
          
          // Open cart drawer after lens selector closes (lens selector closes after 500ms)
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              _showCartDrawer();
            }
          });
        },
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a variant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Prepare line items with lens options as properties
      final variantId = _selectedVariant!.id;
      
      // If lens is selected, add BOTH lens AND frame together
      if (_selectedLensOptions != null && _selectedLensOptions!['lens'] != null) {
        final lensId = _selectedLensOptions!['lens'] as String;
        
        debugPrint('🔍 Adding lens + frame to cart together:');
        debugPrint('   Lens ID: $lensId');
        debugPrint('   Frame ID: $variantId');
        debugPrint('   Lens Type: ${_selectedLensOptions!['lensType']}');
        debugPrint('   Power Type: ${_selectedLensOptions!['powerType']}');
        debugPrint('   Power Range: ${_selectedLensOptions!['powerRange']}');
        debugPrint('   Prescription Type: ${_selectedLensOptions!['prescriptionType']}');
        
        final lensProperties = <String, dynamic>{
          '1. Lens Type': _selectedLensOptions!['lensType'] ?? '',
          '2. Power Type': _selectedLensOptions!['powerType'] ?? '',
          '3. Lens Name': _selectedLensOptions!['powerType'] ?? '', // Use power type as lens name
          'Power Range': _selectedLensOptions!['powerRange'] ?? '',
          'Associated Frame': widget.product.id, // Link to frame
          'Frame SKU': _selectedVariant!.id, // Use variant ID as SKU
          '4. Prescription Type': _selectedLensOptions!['prescriptionType'] ?? '',
        };

        // Add power values if available
        if (_selectedLensOptions!['powerValues'] != null) {
          final powerValues = _selectedLensOptions!['powerValues'] as Map<String, String>;
          powerValues.forEach((key, value) {
            lensProperties[key] = value;
          });
        }

        // Create items array (lens first, then frame - matching Shopify theme)
        final items = [
          {
            'variantId': lensId,
            'quantity': 1,
            'properties': lensProperties,
          },
          {
            'variantId': variantId,
            'quantity': 1,
            'properties': null, // Frame has no extra properties
          }
        ];

        // Add both items to cart in a single API call
        debugPrint('📦 Calling add multiple to cart...');
        await ApiService().addMultipleToCart(items: items);
        debugPrint('✅ Lens + Frame added to cart successfully!');
      } else {
        // No lens selected, just add frame
        debugPrint('📦 Adding frame only (no lens selected)...');
        await ApiService().addToCart(
          variantId: variantId,
          quantity: 1,
          properties: null,
        );
        debugPrint('✅ Frame added to cart successfully!');
      }

      if (mounted) {
        // Show success message
        final itemsAdded = _selectedLensOptions != null && _selectedLensOptions!['lens'] != null 
            ? 'Frame & Lens added' 
            : 'Added';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $itemsAdded to cart successfully!'),
            backgroundColor: const Color(0xFF27916D),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Wait a moment, then show cart drawer
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          _showCartDrawer();
        }
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  // NEW HELPER METHODS FOR FIRELENS-STYLE DESIGN

  Widget _buildReviewStars() {
    final rating = widget.product.reviews?.rating ?? 5.0;
    final count = widget.product.reviews?.count ?? 1;

    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            size: 18,
            color: const Color(0xFFFFC107),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$rating (${count} reviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildFeaturesList() {
    return [
      {
        'icon': Icons.shield_outlined,
        'title': '100% UV Protection',
        'description': 'Complete protection from harmful UV rays with UV400 certified lenses',
      },
      {
        'icon': Icons.diamond_outlined,
        'title': 'Premium Materials',
        'description': 'Made with high-quality acetate and stainless steel components',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Anti-Glare Coating',
        'description': 'Advanced coating reduces glare and reflections for better clarity',
      },
      {
        'icon': Icons.water_drop_outlined,
        'title': 'Scratch Resistant',
        'description': 'Durable coating protects lenses from scratches and daily wear',
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Comfortable Fit',
        'description': 'Ergonomically designed for all-day comfort and style',
      },
      {
        'icon': Icons.verified_outlined,
        'title': '1 Year Warranty',
        'description': 'Comprehensive manufacturer warranty covering defects',
      },
    ];
  }

  List<String> _extractVideoUrls() {
    // Extract video URLs from product media if available
    // For now, return empty list - can be enhanced later with actual video URLs from Shopify
    return [];
  }

  Map<String, Map<String, dynamic>> _buildSpecsData() {
    final description = widget.product.description;
    
    // Extract measurements
    String lensWidth = '--';
    String bridge = '--';
    String temple = '--';
    
    final lensMatch = RegExp(r'Lens Width[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (lensMatch != null) lensWidth = '${lensMatch.group(1)}mm';
    
    final bridgeMatch = RegExp(r'Bridge[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (bridgeMatch != null) bridge = '${bridgeMatch.group(1)}mm';
    
    final templeMatch = RegExp(r'Temple[^\d]*(\d+)\s*mm', caseSensitive: false).firstMatch(description);
    if (templeMatch != null) temple = '${templeMatch.group(1)}mm';
    
    final compactMatch = RegExp(r'(\d{2})-(\d{2})-(\d{3})').firstMatch(description);
    if (compactMatch != null && lensWidth == '--') {
      lensWidth = '${compactMatch.group(1)}mm';
      bridge = '${compactMatch.group(2)}mm';
      temple = '${compactMatch.group(3)}mm';
    }

    return {
      'frame': {
        'Material': 'Premium Acetate',
        'Shape': widget.product.productType ?? 'Eyeglasses',
        'Gender': 'Unisex',
        'Style': 'Modern',
      },
      'lens': {
        'Material': 'Polycarbonate',
        'Coating': 'Anti-Glare, UV Protection',
        'Protection': 'UV400',
      },
      'dimensions': {
        'Lens Width': lensWidth,
        'Bridge Width': bridge,
        'Temple Length': temple,
        'Frame Width': 'Standard',
      },
      'inTheBox': {
        'Frame': '1 Unit',
        'Case': 'Hard Case Included',
        'Cleaning Cloth': '1 Unit',
        'Warranty Card': 'Yes',
      },
    };
  }

  List<Map<String, String>> _buildFAQs() {
    return [
      {
        'question': 'Do I need a prescription to order?',
        'answer': 'You can order without a prescription for sunglasses. For prescription eyeglasses, you\'ll need to provide your prescription details during checkout.',
      },
      {
        'question': 'How long does delivery take?',
        'answer': 'Standard delivery takes 5-7 business days. Express shipping options are available at checkout for faster delivery.',
      },
      {
        'question': 'What is your return policy?',
        'answer': 'We offer a 30-day return policy. If you\'re not satisfied, you can return the product in its original condition for a full refund.',
      },
      {
        'question': 'Are the lenses scratch-resistant?',
        'answer': 'Yes, all our lenses come with a scratch-resistant coating as standard. We also offer additional premium coatings.',
      },
      {
        'question': 'Do you offer warranty?',
        'answer': 'Yes, all products come with a 1-year manufacturer warranty covering manufacturing defects.',
      },
      {
        'question': 'Can I add prescription lenses later?',
        'answer': 'Yes, you can purchase the frame now and add prescription lenses later by contacting our support team.',
      },
    ];
  }

  Widget _buildProductHighlights() {
    final images = widget.product.images;
    
    // Skip first image (main product image) and use images 2-7
    final highlightImages = images.skip(1).take(6).toList();
    
    if (highlightImages.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isProductHighlightsExpanded = !_isProductHighlightsExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.collections_outlined, color: Color(0xFF27916D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Product Highlights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isProductHighlightsExpanded ? Icons.remove : Icons.add,
                    color: Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          
          // Content (only shown when expanded)
          if (_isProductHighlightsExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Create collage based on number of images
                  if (highlightImages.length == 1)
                    _buildSingleImageLayout(highlightImages[0])
                  else if (highlightImages.length == 2)
                    _buildTwoImageLayout(highlightImages)
                  else if (highlightImages.length == 3)
                    _buildThreeImageLayout(highlightImages)
                  else
                    _buildMultiImageLayout(highlightImages),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImageLayout(ProductImage image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: image.src,
          width: double.infinity,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTwoImageLayout(List<ProductImage> images) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: images[0].src,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              height: 250,
              child: CachedNetworkImage(
                imageUrl: images[1].src,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImageLayout(List<ProductImage> images) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 300,
            child: CachedNetworkImage(
              imageUrl: images[0].src,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 180,
                  child: CachedNetworkImage(
                    imageUrl: images[1].src,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 180,
                  child: CachedNetworkImage(
                    imageUrl: images[2].src,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiImageLayout(List<ProductImage> images) {
    return Column(
      children: [
        // Top large image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 300,
            child: CachedNetworkImage(
              imageUrl: images[0].src,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Two medium images
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 200,
                  child: CachedNetworkImage(
                    imageUrl: images[1].src,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 200,
                  child: CachedNetworkImage(
                    imageUrl: images[2].src,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Bottom row - 3 small images if available
        if (images.length > 3) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (images.length > 3)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white,
                      height: 140,
                      child: CachedNetworkImage(
                        imageUrl: images[3].src,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              if (images.length > 4) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white,
                      height: 140,
                      child: CachedNetworkImage(
                        imageUrl: images[4].src,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
              if (images.length > 5) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white,
                      height: 140,
                      child: CachedNetworkImage(
                        imageUrl: images[5].src,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildModernStickyCart(bool hasNoPowerTag) {
    final price = _selectedVariant?.price ?? widget.product.priceRange.minVariantPrice;
    final compareAtPrice = _selectedVariant?.compareAtPrice;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF27916D).withOpacity(0.15),
                const Color(0xFFA8E6CF).withOpacity(0.25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Price Row - ALL IN ONE LINE (2px top padding)
                Row(
                  children: [
                    // Current Price
                    Text(
                      price.formatted,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    
                    // Original Price
                    if (compareAtPrice != null)
                      Text(
                        compareAtPrice.formatted,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    
                    const SizedBox(width: 4),
                    
                    // Discount percentage
                    if (compareAtPrice != null)
                      Text(
                        '${_calculateDiscount(compareAtPrice, price)}% Off',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF27916D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    
                    const SizedBox(width: 8),
                    
                    // Tax info - inline
                    Expanded(
                      child: Text(
                        'Inclusive of all taxes',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4), // 4px gap between price and buttons
                
                // Buttons Row - Side by Side with 12px gap
                Row(
                  children: [
                    // Add To Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: hasNoPowerTag ? _addToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add To Cart',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12), // 12px gap between buttons
                    
                    // Buy Now / Select Lens Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: hasNoPowerTag ? _addToCart : _showLensSelector,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27916D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          hasNoPowerTag ? 'Buy Now' : 'Select Lens',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // 2px bottom padding (already in EdgeInsets.fromLTRB)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
