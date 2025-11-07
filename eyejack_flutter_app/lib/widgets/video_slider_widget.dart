import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/collection_model.dart';
import '../screens/collection_screen.dart';

class VideoSliderWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const VideoSliderWidget({super.key, required this.settings});

  @override
  State<VideoSliderWidget> createState() => _VideoSliderWidgetState();
}

class _VideoSliderWidgetState extends State<VideoSliderWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Map<int, VideoPlayerController?> _videoControllers = {};
  Map<int, ChewieController?> _chewieControllers = {};
  Timer? _autoScrollTimer;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    final autoScroll = widget.settings['autoScroll'] as bool? ?? false;
    if (autoScroll) {
      _startAutoScroll();
    }
    // Pre-initialize first video for autoplay
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    if (videos.isNotEmpty) {
      _initializeAndPlayVideo(0, videos[0]['videoUrl'] ?? '');
    }
  }

  void _startAutoScroll() {
    final scrollDuration = widget.settings['scrollDuration'] as int? ?? 5000;
    _autoScrollTimer = Timer.periodic(Duration(milliseconds: scrollDuration), (timer) {
      if (!mounted || !_isAutoScrolling) return;
      
      final videos = widget.settings['videos'] as List<dynamic>? ?? [];
      if (videos.isEmpty) return;

      final nextPage = (_currentPage + 1) % videos.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeVideo(int index, String videoUrl) async {
    if (_videoControllers[index] != null) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      
      // Set looping
      controller.setLooping(true);

      final autoplay = widget.settings['autoplay'] as bool? ?? false;
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: true,
        aspectRatio: 9 / 16,
        showControls: false,
        placeholder: Container(
          color: Colors.black,
        ),
      );

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
          _chewieControllers[index] = chewieController;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
    }
  }

  Future<void> _initializeAndPlayVideo(int index, String videoUrl) async {
    if (_videoControllers[index] != null) {
      _videoControllers[index]?.play();
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      
      // Set looping and play
      controller.setLooping(true);

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: true,
        aspectRatio: 9 / 16,
        showControls: false,
        placeholder: Container(
          color: Colors.black,
        ),
      );

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
          _chewieControllers[index] = chewieController;
        });
        controller.play();
      }
    } catch (e) {
      debugPrint('❌ Error initializing and playing video: $e');
    }
  }

  void _handleVideoTap(int index, String link) {
    if (link.contains('/collections/')) {
      final handle = link.split('/collections/').last.split('/').first;
      final collectionName = handle
          .split('-')
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .join(' ');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CollectionScreen(
            collection: Collection(
              id: handle,
              title: collectionName,
              handle: handle,
              description: null,
              image: null,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.settings['title'] ?? 'Shop By Video';
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
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video slider (horizontal scrolling)
          SizedBox(
            height: 450,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                
                // Pause all other videos
                for (var i = 0; i < videos.length; i++) {
                  if (i != index) {
                    _videoControllers[i]?.pause();
                  }
                }
                
                // Play current video
                final video = videos[index];
                _initializeAndPlayVideo(index, video['videoUrl'] ?? '');
                
                // Pre-load next video
                final nextIndex = (index + 1) % videos.length;
                if (_videoControllers[nextIndex] == null) {
                  final nextVideo = videos[nextIndex];
                  _initializeVideo(nextIndex, nextVideo['videoUrl'] ?? '');
                }
              },
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildVideoCard(
                    index,
                    video['videoUrl'] ?? '',
                    video['thumbnail'] ?? '',
                    video['title'] ?? '',
                    video['link'] ?? '',
                  ),
                );
              },
            ),
          ),
          
          // Page indicators
          if (videos.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(videos.length, (index) {
                  return Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF52b1e2)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    int index,
    String videoUrl,
    String thumbnailUrl,
    String title,
    String link,
  ) {
    final isInitialized = _videoControllers[index]?.value.isInitialized ?? false;
    final isCurrentPage = _currentPage == index;

    return GestureDetector(
      onTap: () {
        // Pause auto-scrolling when user taps
        setState(() {
          _isAutoScrolling = false;
        });
        _handleVideoTap(index, link);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video or thumbnail
              if (isInitialized && isCurrentPage && _chewieControllers[index] != null)
                Chewie(controller: _chewieControllers[index]!)
              else
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF52b1e2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black,
                    child: const Icon(
                      Icons.video_library,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // Gradient overlay (lighter so video is visible)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              
              // Title at bottom
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
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

