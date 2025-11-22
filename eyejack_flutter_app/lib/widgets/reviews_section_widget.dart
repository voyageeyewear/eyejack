import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review_model.dart';

class ReviewsSectionWidget extends StatelessWidget {
  final ProductReviews reviewsData;
  final bool isCollapsible;
  final bool initiallyExpanded;

  const ReviewsSectionWidget({
    super.key,
    required this.reviewsData,
    this.isCollapsible = true,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewsData.count == 0 && reviewsData.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCollapsible) {
      return _CollapsibleReviewsSection(
        reviewsData: reviewsData,
        initiallyExpanded: initiallyExpanded,
      );
    } else {
      return _ExpandedReviewsSection(reviewsData: reviewsData);
    }
  }
}

class _CollapsibleReviewsSection extends StatefulWidget {
  final ProductReviews reviewsData;
  final bool initiallyExpanded;

  const _CollapsibleReviewsSection({
    required this.reviewsData,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
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
                  // Star icon
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  // Rating and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.reviewsData.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/ 5.0',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.reviewsData.count} ${widget.reviewsData.count == 1 ? 'review' : 'reviews'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
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
            _ReviewsList(reviews: widget.reviewsData.reviews),
        ],
      ),
    );
  }
}

class _ExpandedReviewsSection extends StatelessWidget {
  final ProductReviews reviewsData;

  const _ExpandedReviewsSection({required this.reviewsData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  reviewsData.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '/ 5.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${reviewsData.count} ${reviewsData.count == 1 ? 'review' : 'reviews'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          // Reviews list
          _ReviewsList(reviews: reviewsData.reviews),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
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
      separatorBuilder: (context, index) => Divider(
        height: 24,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        return _ReviewItem(review: reviews[index]);
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Name, Rating, Verified badge
        Row(
          children: [
            // Name
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
            // Rating stars
            if (review.rating != null) ...[
              ...List.generate(5, (index) {
                return Icon(
                  index < review.rating!.round()
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 8),
            ],
            // Verified badge
            if (review.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
        // Review text
        const SizedBox(height: 8),
        Text(
          review.text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        // Photos
        if (review.photos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.photos.length,
              itemBuilder: (context, photoIndex) {
                return Container(
                  margin: EdgeInsets.only(
                    right: photoIndex < review.photos.length - 1 ? 8 : 0,
                  ),
                  width: 80,
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
      ],
    );
  }
}

