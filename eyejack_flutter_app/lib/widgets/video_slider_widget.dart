import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/collection_model.dart';
import '../screens/collection_screen.dart';

/// Simple video slider based on live Shopify theme pattern
/// Videos auto-play, muted, looping - just like the website
class VideoSliderWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const VideoSliderWidget({super.key, required this.settings});

  @override
  State<VideoSliderWidget> createState() => _VideoSliderWidgetState();
}

class _VideoSliderWidgetState extends State<VideoSliderWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.68);
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeFirstVideo();
  }

  void _initializeFirstVideo() {
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    if (videos.isNotEmpty) {
      final firstVideoUrl = videos[0]['videoUrl'] as String? ?? '';
      if (firstVideoUrl.isNotEmpty) {
        _createAndPlayVideo(0, firstVideoUrl);
      }
    }
  }

  Future<void> _createAndPlayVideo(int index, String url) async {
    // Don't recreate if already exists
    if (_controllers.containsKey(index)) {
      _controllers[index]?.play();
      return;
    }

    try {
      // Create controller - simple approach
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      
      // Initialize
      await controller.initialize();
      
      // Configure exactly like website: autoplay, muted, loop
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      
      // Store
      _controllers[index] = controller;
      
      // Start playing
      await controller.play();
      
      // Update UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    if (index < videos.length) {
      final videoUrl = videos[index]['videoUrl'] as String? ?? '';
      if (videoUrl.isNotEmpty) {
        _createAndPlayVideo(index, videoUrl);
      }
    }

    // Pause others
    _controllers.forEach((key, controller) {
      if (key != index) {
        controller.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    
    if (videos.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Shop By Video',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video PageView - Simple slider
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _VideoCard(
                    index: index,
                    video: video,
                    controller: _controllers[index],
                    isActive: index == _currentIndex,
                  ),
                );
              },
            ),
          ),
          
          // Dots indicator
          if (videos.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(videos.length, (index) {
                return Container(
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF52b1e2)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple video card - shows video when active, black when not
class _VideoCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> video;
  final VideoPlayerController? controller;
  final bool isActive;

  const _VideoCard({
    required this.index,
    required this.video,
    required this.controller,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final title = video['title'] as String? ?? '';
    final link = video['link'] as String? ?? '';
    
    return GestureDetector(
      onTap: () => _handleTap(context, link),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video - simple native player
              if (isActive && controller != null && controller!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller!.value.size.height,
                    child: VideoPlayer(controller!),
                  ),
                )
              else
                Container(color: Colors.black),
              
              // Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              
              // Title
              if (title.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String link) {
    if (link.contains('/collections/')) {
      final handle = link.split('/collections/').last.split('/').first;
      final name = handle.split('-').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CollectionScreen(
            collection: Collection(
              id: handle,
              title: name,
              handle: handle,
              description: null,
              image: null,
            ),
          ),
        ),
      );
    }
  }
}
