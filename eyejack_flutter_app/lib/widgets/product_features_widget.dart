import 'package:flutter/material.dart';

class ProductFeaturesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> features;

  const ProductFeaturesWidget({super.key, required this.features});

  @override
  State<ProductFeaturesWidget> createState() => _ProductFeaturesWidgetState();
}

class _ProductFeaturesWidgetState extends State<ProductFeaturesWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.features.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
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
                  const Text(
                    'Product Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    color: Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          
          // Content (only shown when expanded)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: widget.features.map((feature) => _buildFeatureItem(
                      feature['icon'] as IconData? ?? Icons.star,
                      feature['title'] as String? ?? '',
                      feature['description'] as String? ?? '',
                    )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF27916D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF27916D),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

