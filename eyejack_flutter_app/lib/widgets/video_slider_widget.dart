import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/collection_model.dart';
import '../screens/collection_screen.dart';

/// Reliable video slider with proper buffering and state management
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
  final Map<int, bool> _isInitializing = {};

  @override
  void initState() {
    super.initState();
    // Initialize first video with delay to ensure widget is mounted
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _initializeFirstVideo();
      }
    });
  }

  void _initializeFirstVideo() {
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    if (videos.isNotEmpty) {
      final firstVideoUrl = videos[0]['videoUrl'] as String? ?? '';
      if (firstVideoUrl.isNotEmpty) {
        _initializeVideo(0, firstVideoUrl);
      }
    }
  }

  Future<void> _initializeVideo(int index, String url) async {
    // Skip if already initializing or initialized
    if (_isInitializing[index] == true || _controllers.containsKey(index)) {
      if (_controllers[index]?.value.isInitialized == true) {
        _controllers[index]?.play();
      }
      return;
    }

    _isInitializing[index] = true;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Initialize with timeout
      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );

      if (!mounted) return;

      // Configure
      await controller.setLooping(true);
      await controller.setVolume(0.0);

      // Store controller
      _controllers[index] = controller;

      // Start playing
      await controller.play();

      if (mounted) {
        setState(() {
          _isInitializing[index] = false;
        });
      }
    } catch (e) {
      debugPrint('Video $index error: $e');
      if (mounted) {
        setState(() {
          _isInitializing[index] = false;
        });
      }
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
    if (!mounted) return;
    
    setState(() {
      _currentIndex = index;
    });

    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    
    // Pause all videos
    _controllers.forEach((key, controller) {
      if (key != index) {
        controller.pause();
      }
    });

    // Play current video
    if (index < videos.length) {
      final videoUrl = videos[index]['videoUrl'] as String? ?? '';
      if (videoUrl.isNotEmpty) {
        _initializeVideo(index, videoUrl);
      }
    }
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
          
          // Video PageView
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: videos.length,
              padEnds: false,  // Remove white space at start
              itemBuilder: (context, index) {
                final video = videos[index];
                final controller = _controllers[index];
                final isInitializing = _isInitializing[index] == true;
                final isActive = index == _currentIndex;
                
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,  // First video aligned to left
                    right: 8,
                  ),
                  child: _VideoCard(
                    video: video,
                    controller: controller,
                    isActive: isActive,
                    isInitializing: isInitializing,
                  ),
                );
              },
            ),
          ),
          
          // Dots
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

class _VideoCard extends StatelessWidget {
  final Map<String, dynamic> video;
  final VideoPlayerController? controller;
  final bool isActive;
  final bool isInitializing;

  const _VideoCard({
    required this.video,
    required this.controller,
    required this.isActive,
    required this.isInitializing,
  });

  @override
  Widget build(BuildContext context) {
    final title = video['title'] as String? ?? '';
    final link = video['link'] as String? ?? '';
    final thumbnail = video['thumbnail'] as String? ?? '';
    final isReady = controller?.value.isInitialized == true;
    
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
              // Thumbnail (always shown as background)
              if (thumbnail.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black),
                  errorWidget: (context, url, error) => Container(color: Colors.black),
                ),
              
              // Video player (on top of thumbnail when ready)
              if (isActive && isReady && controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller!.value.size.height,
                    child: VideoPlayer(controller!),
                  ),
                )
              else if (isInitializing)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              
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
