import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/collection_model.dart';
import '../screens/collection_screen.dart';

class CircularCategoriesWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const CircularCategoriesWidget({super.key, required this.settings});

  @override
  State<CircularCategoriesWidget> createState() => _CircularCategoriesWidgetState();
}

class _CircularCategoriesWidgetState extends State<CircularCategoriesWidget> {
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  void _initializeVideos() {
    final categories = widget.settings['categories'] as List<dynamic>? ?? [];
    
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final type = category['type'] as String? ?? 'image';
      final videoUrl = category['video'] as String? ?? '';
      final handle = category['handle'] as String? ?? '';
      
      debugPrint('🎥 Category $i: name=${category['name']}, type=$type, video=$videoUrl');
      
      if (type == 'video' && videoUrl.isNotEmpty && handle.isNotEmpty) {
        debugPrint('🎬 Initializing video for: $handle');
        final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        
        // Store controller immediately so it can be accessed
        _videoControllers[handle] = controller;
        
        controller.initialize().then((_) {
          debugPrint('✅ Video initialized successfully for: $handle');
          if (mounted) {
            controller.setLooping(true);
            controller.setVolume(0.0); // Muted
            controller.play();
            debugPrint('▶️ Video playing for: $handle');
            setState(() {});
          }
        }).catchError((error) {
          debugPrint('❌ Error initializing video for $handle: $error');
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.settings['categories'] as List<dynamic>? ?? [];
    
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),  // Minimal padding
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
                category['type'] as String? ?? 'image',
                category['image'] ?? '',
                category['video'] as String? ?? '',
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
    String type,
    String imageUrl,
    String videoUrl,
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
          // Circular image/video with border
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF52b1e2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),  // Padding between border and image
                  child: ClipOval(
                    child: _buildContent(type, imageUrl, videoUrl, handle),
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
          
          const SizedBox(height: 4),
          
          // Category name - allow 2 lines for longer text like "New Arrivals"
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String type, String imageUrl, String videoUrl, String handle) {
    if (type == 'video' && videoUrl.isNotEmpty) {
      final controller = _videoControllers[handle];
      
      if (controller != null && controller.value.isInitialized) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        );
      } else {
        // Show placeholder image while video loads
        return imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.video_library,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
                memCacheWidth: 200,
                memCacheHeight: 200,
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.video_library,
                  size: 30,
                  color: Colors.grey,
                ),
              );
      }
    } else {
      // Regular image
      return imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_outlined,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              memCacheWidth: 200,
              memCacheHeight: 200,
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.category_outlined,
                size: 30,
                color: Colors.grey,
              ),
            );
    }
  }
}
