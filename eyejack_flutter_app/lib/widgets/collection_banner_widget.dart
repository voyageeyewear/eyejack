import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/collection_banner_model.dart';

class CollectionBannerWidget extends StatelessWidget {
  final CollectionBanner banner;
  final VoidCallback? onTap;

  const CollectionBannerWidget({
    super.key,
    required this.banner,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // Handle banner click
        if (banner.clickUrl != null && banner.clickUrl!.isNotEmpty) {
          debugPrint('Banner clicked: ${banner.clickUrl}');
          // Navigator.pushNamed(context, banner.clickUrl!);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // FULL WIDTH - No horizontal margin
        child: Stack(
          children: [
            // Banner Image - FULL WIDTH & RESPONSIVE
            AspectRatio(
              aspectRatio: 16 / 9, // Standard responsive ratio
              child: CachedNetworkImage(
                imageUrl: banner.bannerUrl,
                fit: BoxFit.cover, // Cover maintains aspect ratio without stretching
                memCacheWidth: 1400,
                memCacheHeight: 800,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Optional: Text Overlay
            if (banner.title != null || banner.subtitle != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (banner.title != null)
                          Text(
                            banner.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        if (banner.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            banner.subtitle!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

