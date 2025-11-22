import 'package:flutter/material.dart';

class ReviewBadgeWidget extends StatelessWidget {
  final int reviewCount;
  final double? rating;
  final bool showRating;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;

  const ReviewBadgeWidget({
    super.key,
    required this.reviewCount,
    this.rating,
    this.showRating = true,
    this.fontSize = 11,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRating && rating != null && rating! > 0) ...[
            // Star icon
            Icon(
              Icons.star,
              size: fontSize,
              color: Colors.amber,
            ),
            const SizedBox(width: 2),
            // Rating number
            Text(
              rating!.toStringAsFixed(1),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            // Separator
            Container(
              width: 1,
              height: fontSize,
              color: textColor ?? Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
          ],
          // Review count
          Text(
            '$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

