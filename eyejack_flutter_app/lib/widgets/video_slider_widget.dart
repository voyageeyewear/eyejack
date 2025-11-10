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
  final ScrollController _scrollController = ScrollController();
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    debugPrint('========================================');
    debugPrint('🎬 VIDEO SLIDER WIDGET INITIALIZED');
    debugPrint('📊 Total videos to load: ${videos.length}');
    debugPrint('========================================');
    
    // Initialize ALL videos at once
    _initializeAllVideos();
  }

  void _initializeAllVideos() {
    final videos = widget.settings['videos'] as List<dynamic>? ?? [];
    
    if (videos.isEmpty) {
      debugPrint('⚠️  WARNING: No videos found in settings!');
      return;
    }
    
    debugPrint('🎥 Starting to initialize ${videos.length} videos simultaneously...');
    
    for (var i = 0; i < videos.length; i++) {
      final video = videos[i];
      final videoUrl = video['videoUrl'] as String? ?? '';
      final title = video['title'] as String? ?? 'Video $i';
      
      debugPrint('---');
      debugPrint('🎬 Video $i: $title');
      debugPrint('🔗 URL: $videoUrl');
      
      if (videoUrl.isEmpty) {
        debugPrint('❌ SKIP: Video $i has no URL');
        continue;
      }
      
      _initializeVideo(i, videoUrl, title);
    }
  }

  Future<void> _initializeVideo(int index, String videoUrl, String title) async {
    try {
      debugPrint('⏳ Initializing video $index ($title)...');
      
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,  // Allow multiple videos
          allowBackgroundPlayback: false,
        ),
      );

      // Store controller before initialization
      _videoControllers[index] = controller;
      
      await controller.initialize();
      
      debugPrint('✅ Video $index initialized successfully!');
      debugPrint('   Duration: ${controller.value.duration}');
      debugPrint('   Size: ${controller.value.size.width}x${controller.value.size.height}');
      
      // Configure video
      await controller.setLooping(true);
      await controller.setVolume(0.0);  // Muted
      
      // Create Chewie controller
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: true,
        aspectRatio: 250 / 400,
        showControls: false,
        allowFullScreen: false,
        allowMuting: false,
        showControlsOnInitialize: false,
      );
      
      _chewieControllers[index] = chewieController;
      
      // Start playing
      await controller.play();
      debugPrint('▶️  Video $index is now PLAYING!');
      
      if (mounted) {
        setState(() {});
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR initializing video $index: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️  Disposing Video Slider Widget...');
    _scrollController.dispose();
    
    for (var entry in _videoControllers.entries) {
      debugPrint('   Disposing video ${entry.key}');
      entry.value.dispose();
    }
    
    for (var entry in _chewieControllers.entries) {
      entry.value.dispose();
    }
    
    super.dispose();
  }

  void _handleVideoTap(int index, String link) {
    debugPrint('👆 Video $index tapped, link: $link');
    
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
      debugPrint('⚠️  No videos to display');
      return const SizedBox.shrink();
    }

    debugPrint('🎨 Building video slider with ${videos.length} videos');
    debugPrint('   Initialized: ${_videoControllers.length} controllers');

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
                fontSize: 20,  // Matches other sections
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Horizontal scrolling list
          SizedBox(
            height: 400,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
              // Video player
              if (isInitialized && chewieController != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller.value.size.height,
                    child: Chewie(controller: chewieController),
                  ),
                )
              else
                // Loading state
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading video $index...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              
              // Debug indicator (shows if video is playing)
              if (isInitialized && controller!.value.isPlaying)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
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
