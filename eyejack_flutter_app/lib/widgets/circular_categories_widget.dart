import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/collection_model.dart';
import '../screens/collection_screen.dart';

class CircularCategoriesWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const CircularCategoriesWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final categories = settings['categories'] as List<dynamic>? ?? [];
    
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildCircularCategory(
                context,
                category['name'] ?? '',
                category['handle'] ?? '',
                category['image'] ?? '',
                category['badge'] as String?,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCircularCategory(
    BuildContext context,
    String name,
    String handle,
    String imageUrl,
    String? badge,
  ) {
    return GestureDetector(
      onTap: () {
        debugPrint('🔗 Circular category tapped: $handle');
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CollectionScreen(
              collection: Collection(
                id: handle,
                title: name,
                handle: handle,
                description: null,
                image: imageUrl.isNotEmpty 
                    ? CollectionImage(src: imageUrl) 
                    : null,
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular image with border
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF52b1e2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF52b1e2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_outlined,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.category_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              
              // Badge (e.g., "SALE LIVE" for BOGO)
              if (badge != null && badge.isNotEmpty)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Category name (single line, no wrap)
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

