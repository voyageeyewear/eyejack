import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/review_model.dart';

class ReviewsSectionWidget extends StatelessWidget {
  final ProductReviews reviewsData;
  final bool isCollapsible;
  final bool initiallyExpanded;
  final String? productTitle; // Product title for display

  const ReviewsSectionWidget({
    super.key,
    required this.reviewsData,
    this.isCollapsible = true,
    this.initiallyExpanded = false,
    this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewsData.count == 0 && reviewsData.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCollapsible) {
      return _CollapsibleReviewsSection(
        reviewsData: reviewsData,
        productTitle: productTitle ?? reviewsData.productTitle,
        initiallyExpanded: initiallyExpanded,
      );
    } else {
      return _ExpandedReviewsSection(
        reviewsData: reviewsData,
        productTitle: productTitle ?? reviewsData.productTitle,
      );
    }
  }
}

class _CollapsibleReviewsSection extends StatefulWidget {
  final ProductReviews reviewsData;
  final String productTitle;
  final bool initiallyExpanded;

  const _CollapsibleReviewsSection({
    super.key,
    required this.reviewsData,
    required this.productTitle,
    this.initiallyExpanded = false,
  });

  @override
  State<_CollapsibleReviewsSection> createState() => _CollapsibleReviewsSectionState();
}

class _CollapsibleReviewsSectionState extends State<_CollapsibleReviewsSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Rating Summary
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Star rating display
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Review count
                  Text(
                    '${widget.reviewsData.count} Reviews',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          // Reviews list (when expanded)
          if (_isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            _ReviewsList(
              reviews: widget.reviewsData.reviews,
              productTitle: widget.productTitle,
              productId: widget.reviewsData.productId,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandedReviewsSection extends StatelessWidget {
  final ProductReviews reviewsData;
  final String productTitle;

  const _ExpandedReviewsSection({
    super.key,
    required this.reviewsData,
    required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Text(
                  '${reviewsData.count} Reviews',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          // Reviews list - Use Expanded for WebView to fill space
          Expanded(
            child: _ReviewsList(
              reviews: reviewsData.reviews,
              productTitle: productTitle,
              productId: reviewsData.productId,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;
  final String productTitle;
  final String? productId; // Add productId for Loox widget fallback

  const _ReviewsList({
    required this.reviews,
    required this.productTitle,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // Always show WebView if we have a product ID, even if reviews array is empty
    // This ensures Loox reviews are always displayed from their servers
    if (productId != null && productId!.isNotEmpty && productId! != '0') {
      debugPrint('✅ Showing Loox WebView for productId: $productId (reviews count: ${reviews.length})');
      // Use key to prevent widget recreation on rebuilds
      return _LooxWidgetWebView(
        key: ValueKey('loox_webview_$productId'),
        productId: productId!,
      );
    }
    
    // If we have parsed reviews and no productId, show them
    if (reviews.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ReviewCard(
            review: reviews[index],
            productTitle: productTitle,
          );
        },
      );
    }
    
    // Otherwise show default message
    debugPrint('⚠️ No valid productId found and no reviews available.');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'No reviews available yet.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final String productTitle;

  const _ReviewCard({
    required this.review,
    required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture (if available) or video/image
          if (review.videoUrl != null || review.photos.isNotEmpty || review.profilePicture != null)
            _ReviewMedia(
              review: review,
            ),
          
          // Review content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Verified badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (review.isVerified) ...[
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Date
                if (review.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    review.date!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                
                // Star rating
                if (review.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating!.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 18,
                        color: Colors.black,
                      );
                    }),
                  ),
                ],
                
                // Review text
                if (review.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
                
                // User-submitted photos (if not shown at top)
                if (review.photos.isNotEmpty && review.videoUrl == null && review.profilePicture == null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photos.length,
                      itemBuilder: (context, photoIndex) {
                        return Container(
                          margin: EdgeInsets.only(
                            right: photoIndex < review.photos.length - 1 ? 8 : 0,
                          ),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: review.photos[photoIndex],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, size: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                // Product image and name at bottom
                if (review.productImage != null || review.productName != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (review.productImage != null) ...[
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: review.productImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          review.productName ?? productTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMedia extends StatelessWidget {
  final Review review;

  const _ReviewMedia({required this.review});

  @override
  Widget build(BuildContext context) {
    // Priority: Video > Profile Picture > First Photo
    if (review.videoUrl != null) {
      // Video review with play button overlay
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.grey.shade200,
            child: CachedNetworkImage(
              imageUrl: review.videoUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade300,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade300,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      );
    } else if (review.profilePicture != null) {
      // Profile picture
      return Container(
        width: double.infinity,
        height: 250,
        child: CachedNetworkImage(
          imageUrl: review.profilePicture!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
          ),
        ),
      );
    } else if (review.photos.isNotEmpty) {
      // First photo from user-submitted photos
      return Container(
        width: double.infinity,
        height: 250,
        child: CachedNetworkImage(
          imageUrl: review.photos.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// WebView widget to embed Loox reviews widget
class _LooxWidgetWebView extends StatefulWidget {
  final String productId;

  const _LooxWidgetWebView({super.key, required this.productId});

  @override
  State<_LooxWidgetWebView> createState() => _LooxWidgetWebViewState();
}

class _LooxWidgetWebViewState extends State<_LooxWidgetWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(_LooxWidgetWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reinitialize if productId changed
    if (oldWidget.productId != widget.productId && !_isInitialized) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    if (_isInitialized && _controller != null) {
      debugPrint('⚠️ WebView already initialized, skipping...');
      return;
    }
    
    // Loox widget URL format: https://loox.io/widget/{MERCHANT_ID}/reviews/{PRODUCT_ID}
    const looxMerchantId = 'PmGdDSBYpW'; // Your Loox merchant/widget ID from website
    
    // Clean product ID (remove gid:// prefix if present)
    String cleanProductId = widget.productId;
    if (cleanProductId.contains('gid://shopify/Product/')) {
      cleanProductId = cleanProductId.replaceAll('gid://shopify/Product/', '');
    }
    
    // Load all reviews (no limit parameter = loads all) and hide the duplicate header
    final looxWidgetUrl = 'https://loox.io/widget/$looxMerchantId/reviews/$cleanProductId?limit=999';
    debugPrint('🌐 Initializing Loox WebView - URL: $looxWidgetUrl');
    debugPrint('🌐 Clean productId: $cleanProductId');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView page started: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            debugPrint('🌐 WebView page finished: $url');
            // Inject CSS to hide the duplicate header, filter button, and "Write a review" button
            _controller.runJavaScript('''
              (function() {
                // Hide the Loox rating summary header (we already show it)
                var style = document.createElement('style');
                style.innerHTML = `
                  /* Hide duplicate rating header */
                  .loox-rating, 
                  .loox-rating-content,
                  [class*="loox-rating"],
                  [id*="loox-rating"],
                  [class*="rating-summary"],
                  [id*="rating-summary"] {
                    display: none !important;
                  }
                  /* Hide filter button */
                  [class*="filter"],
                  button[class*="filter"],
                  [class*="loox-filter"] {
                    display: none !important;
                  }
                  /* Hide "Write a review" button */
                  [class*="write-review"],
                  button[class*="write-review"],
                  a[class*="write-review"],
                  [class*="write_review"],
                  button:contains("Write a review"),
                  a:contains("Write a review") {
                    display: none !important;
                  }
                  /* Remove any top padding/margin */
                  body {
                    margin: 0 !important;
                    padding: 0 !important;
                  }
                `;
                document.head.appendChild(style);
                
                // Also try to hide elements by text content after page loads
                setTimeout(function() {
                  var allElements = document.querySelectorAll('*');
                  allElements.forEach(function(el) {
                    var text = el.textContent || '';
                    if (text.includes('Write a review') || text.includes('write a review')) {
                      el.style.display = 'none';
                    }
                  });
                  
                  // Hide elements by class/id
                  var elementsToHide = document.querySelectorAll(
                    '.loox-rating, [class*="loox-rating"], [id*="loox-rating"], ' +
                    '[class*="filter"], button[class*="filter"], ' +
                    '[class*="write-review"], button[class*="write-review"], a[class*="write-review"]'
                  );
                  elementsToHide.forEach(function(el) {
                    el.style.display = 'none';
                  });
                }, 1000);
              })();
            ''');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ Loox widget WebView error: ${error.description}');
            debugPrint('❌ Error code: ${error.errorCode}, Error type: ${error.errorType}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(looxWidgetUrl));
    
    _isInitialized = true;
    debugPrint('✅ WebView initialized and loading started');
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing Loox WebView');
    // Don't dispose controller - let it persist
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (_controller == null) {
      debugPrint('⚠️ WebView controller is null, initializing...');
      _initializeWebView();
      return Container(
        height: 2000,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Use a very large height to show all reviews without scrolling
    // The WebView will handle internal scrolling if needed
    debugPrint('🎨 Building Loox WebView widget (isLoading: $_isLoading)');
    return Container(
      height: 2000, // Large height to show all reviews
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
