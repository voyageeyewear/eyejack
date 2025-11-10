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
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    debugPrint('🎬 VIDEO SLIDER: Initializing with ${videos.length} videos');
    
    // Only initialize and play the FIRST video
    if (videos.isNotEmpty) {
      _initializeAndPlayVideo(0);
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing video controllers');
    _pageController.dispose();
    
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  Future<void> _initializeAndPlayVideo(int index) async {
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    if (index >= videos.length) return;
    
    // If already initialized, just play it
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]?.play();
      debugPrint('▶️ Playing existing video $index');
      return;
    }
    
    final video = videos[index];
    final videoUrl = video['videoUrl'] as String? ?? '';
    
    if (videoUrl.isEmpty) {
      debugPrint('❌ Video $index has no URL');
      return;
    }
    
    try {
      debugPrint('⏳ Initializing video $index: $videoUrl');
      
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await controller.initialize();
      
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: true,
        aspectRatio: 250 / 400,
        showControls: false,
        allowFullScreen: false,
        showControlsOnInitialize: false,
      );
      
      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
          _chewieControllers[index] = chewieController;
        });
        
        await controller.play();
        debugPrint('✅ Video $index initialized and PLAYING');
      }
      
    } catch (e) {
      debugPrint('❌ ERROR initializing video $index: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    
    debugPrint('📄 Page changed to $index');
    
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    
    // Pause ALL other videos
    for (var i = 0; i < videos.length; i++) {
      if (i != index) {
        _videoControllers[i]?.pause();
        debugPrint('⏸️ Paused video $i');
      }
    }
    
    // Play current video (initialize if needed)
    _initializeAndPlayVideo(index);
    
    // Pre-load next video
    if (index + 1 < videos.length) {
      _initializeAndPlayVideo(index + 1);
    }
    
    // Pre-load previous video
    if (index - 1 >= 0) {
      _initializeAndPlayVideo(index - 1);
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
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];

    if (videos.isEmpty) {
      debugPrint('⚠️ No videos to display');
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title - same size as other sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Shop By Video',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video slider with PageView (ONE video plays at a time)
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
    final controller = _videoControllers[index];
    final chewieController = _chewieControllers[index];
    final isInitialized = controller?.value.isInitialized ?? false;
    final isCurrentPage = _currentPage == index;

    return GestureDetector(
      onTap: () => _handleVideoTap(index, link),
      child: Container(
        width: 250,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black,
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
              // Video player (only shows if this is the current page)
              if (isInitialized && isCurrentPage && chewieController != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller.value.size.height,
                    child: Chewie(controller: chewieController),
                  ),
                )
              else if (thumbnailUrl.isNotEmpty)
                // Show thumbnail for non-current pages
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.black,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black,
                  ),
                )
              else
                // Black background
                Container(
                  color: Colors.black,
                ),
              
              // Gradient overlay
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
              
              // Title
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
              
              // Play indicator (only on current playing video)
              if (isInitialized && isCurrentPage && controller!.value.isPlaying)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
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
