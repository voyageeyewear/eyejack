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
          if (_isExpanded)
            Divider(height: 1, color: Colors.grey.shade200),
          if (_isExpanded)
            _ReviewsList(
              reviews: widget.reviewsData.reviews,
              productTitle: widget.productTitle,
              productId: widget.reviewsData.productId,
            ),
        ],
      ),
    );
  }
}

class _ExpandedReviewsSection extends StatelessWidget {
  final ProductReviews reviewsData;
  final String productTitle;

  const _ExpandedReviewsSection({
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
    // If reviews are empty but we have a product ID, try to load Loox widget in WebView
    // This happens when Loox stores reviews on their servers and loads via iframe
    if (reviews.isEmpty) {
      debugPrint('🔍 Reviews list is empty. Checking productId: $productId');
      
      // If we have a product ID, show Loox widget in WebView
      if (productId != null && productId!.isNotEmpty && productId! != '0') {
        debugPrint('✅ Showing Loox WebView for productId: $productId');
        return _LooxWidgetWebView(productId: productId!);
      }
      
      debugPrint('⚠️ No valid productId found. productId: $productId');
      // Otherwise show default message
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

  const _LooxWidgetWebView({required this.productId});

  @override
  State<_LooxWidgetWebView> createState() => _LooxWidgetWebViewState();
}

class _LooxWidgetWebViewState extends State<_LooxWidgetWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Loox widget URL format: https://loox.io/widget/{MERCHANT_ID}/reviews/{PRODUCT_ID}
    const looxMerchantId = 'PmGdDSBYpW'; // Your Loox merchant/widget ID from website
    
    // Clean product ID (remove gid:// prefix if present)
    String cleanProductId = widget.productId;
    if (cleanProductId.contains('gid://shopify/Product/')) {
      cleanProductId = cleanProductId.replaceAll('gid://shopify/Product/', '');
    }
    
    // Load all reviews (no limit) and hide the duplicate header
    final looxWidgetUrl = 'https://loox.io/widget/$looxMerchantId/reviews/$cleanProductId';
    debugPrint('🌐 Loading Loox widget URL: $looxWidgetUrl');
    debugPrint('🌐 Clean productId: $cleanProductId');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView page started: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('🌐 WebView page finished: $url');
            // Inject CSS to hide the duplicate header/rating summary
            _controller.runJavaScript('''
              (function() {
                // Hide the Loox rating summary header (we already show it)
                var style = document.createElement('style');
                style.innerHTML = `
                  .loox-rating, 
                  .loox-rating-content,
                  [class*="loox-rating"],
                  [id*="loox-rating"] {
                    display: none !important;
                  }
                  /* Hide filter button if present */
                  [class*="filter"],
                  button[class*="filter"] {
                    display: none !important;
                  }
                  /* Make reviews container scrollable within our fixed height */
                  body {
                    margin: 0;
                    padding: 0;
                    overflow-y: auto;
                  }
                `;
                document.head.appendChild(style);
              })();
            ''');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ Loox widget WebView error: ${error.description}');
            debugPrint('❌ Error code: ${error.errorCode}, Error type: ${error.errorType}');
          },
        ),
      )
      ..loadRequest(Uri.parse(looxWidgetUrl));
  }

  @override
  Widget build(BuildContext context) {
    // Use a very large height to show all reviews without scrolling
    // The WebView will handle internal scrolling if needed
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
            WebViewWidget(controller: _controller),
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
