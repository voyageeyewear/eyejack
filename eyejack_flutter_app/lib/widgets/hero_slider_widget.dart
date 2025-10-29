import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class HeroSliderWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const HeroSliderWidget({super.key, required this.settings});

  @override
  State<HeroSliderWidget> createState() => _HeroSliderWidgetState();
}

class _HeroSliderWidgetState extends State<HeroSliderWidget> {
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, ChewieController?> _chewieControllers = {};
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  @override
  void didUpdateWidget(covariant HeroSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      // Recreate controllers when slides/settings change
      for (var controller in _videoControllers.values) {
        controller?.dispose();
      }
      _videoControllers.clear();
      _currentSlideIndex = 0;
      _initializeVideos();
      setState(() {});
    }
  }

  void _initializeVideos() {
    final slides = widget.settings['slides'] as List<dynamic>? ?? [];
    
    for (int i = 0; i < slides.length; i++) {
      final slide = slides[i];
      final slideType = slide['type'] ?? 'image';
      
      if (slideType == 'video') {
        final videoUrl = slide['videoUrl'] ?? '';
        if (videoUrl.isNotEmpty) {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
          );
          
          controller.initialize().then((_) {
            controller.setLooping(true);
            controller.setVolume(0); // Muted by default

            // Create Chewie controller for better auto-initialize/autoplay
            final chewie = ChewieController(
              videoPlayerController: controller,
              autoInitialize: true,
              autoPlay: i == _currentSlideIndex,
              looping: true,
              showControls: false,
              allowFullScreen: false,
              allowMuting: false,
              allowPlaybackSpeedChanging: false,
              aspectRatio: controller.value.aspectRatio == 0
                  ? 16 / 9
                  : controller.value.aspectRatio,
            );
            _chewieControllers[i] = chewie;

            if (mounted) setState(() {});
          }).catchError((error) {
            debugPrint('Error loading video $i: $error');
          });
          
          _videoControllers[i] = controller;
        }
      }
    }
  }

  Future<void> _onSlideChanged(int index) async {
    if (_currentSlideIndex == index) return;

    // Pause previous video (if any)
    _videoControllers[_currentSlideIndex]?.pause();
    _chewieControllers[_currentSlideIndex]?.pause();

    // Ensure the new video's controller is initialized before playing
    final controller = _videoControllers[index];
    if (controller != null) {
      if (!controller.value.isInitialized) {
        try {
          await controller.initialize();
          controller.setLooping(true);
          controller.setVolume(0);
        } catch (e) {
          debugPrint('Video init error on slide $index: $e');
        }
      }
      if (controller.value.isInitialized) {
        // Create Chewie controller if missing
        _chewieControllers[index] ??= ChewieController(
          videoPlayerController: controller,
          autoInitialize: true,
          autoPlay: true,
          looping: true,
          showControls: false,
          allowFullScreen: false,
          allowMuting: false,
          allowPlaybackSpeedChanging: false,
          aspectRatio: controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio,
        );
        _chewieControllers[index]?.play();
      }
    }

    if (mounted) {
      setState(() {
        _currentSlideIndex = index;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    for (var c in _chewieControllers.values) {
      c?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.settings['slides'] as List<dynamic>? ?? [];
    final autoplay = widget.settings['autoplay'] ?? true;
    final autoplaySpeed = widget.settings['autoplaySpeed'] ?? 5000;
    final showDots = widget.settings['showDots'] ?? true;
    
    if (slides.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SizedBox(
      height: isMobile ? 400 : 500,
      width: double.infinity,
      child: Stack(
        children: [
          FlutterCarousel(
            options: CarouselOptions(
              height: isMobile ? 400 : 500,
              viewportFraction: 1.0,
              autoPlay: autoplay,
              autoPlayInterval: Duration(milliseconds: autoplaySpeed),
              showIndicator: false,
              enableInfiniteScroll: slides.length > 1,
              onPageChanged: (index, reason) {
                // Fire-and-forget async slide change handler
                _onSlideChanged(index);
              },
            ),
            items: slides.asMap().entries.map((entry) {
              final index = entry.key;
              final slide = entry.value;
              final slideType = slide['type'] ?? 'image';

              if (slideType == 'video') {
                return _buildVideoSlide(index, slide, isMobile);
              } else {
                return _buildImageSlide(slide, isMobile);
              }
            }).toList(),
          ),
          
          // Dot Indicators
          if (showDots && slides.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentSlideIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSlide(int index, Map<String, dynamic> slide, bool isMobile) {
    final controller = _videoControllers[index];
    final chewie = _chewieControllers[index];
    final posterImage = slide['posterImage'] ?? '';
    
    return Stack(
      fit: StackFit.expand,
      children: [
        if (chewie != null && (controller?.value.isInitialized ?? false))
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller.value.size.height,
              child: Chewie(controller: chewie),
            ),
          )
        else
          // Show poster image while loading
          CachedNetworkImage(
            imageUrl: posterImage,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.video_library, size: 80, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildImageSlide(Map<String, dynamic> slide, bool isMobile) {
    final desktopImage = slide['desktopImage'] ?? slide['image'] ?? '';
    final mobileImage = slide['mobileImage'] ?? slide['image'] ?? '';
    final imageUrl = isMobile ? mobileImage : desktopImage;
    final heading = slide['heading'] ?? '';
    final subheading = slide['subheading'] ?? '';
    final ctaText = slide['ctaText'] ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 80, color: Colors.grey),
          ),
        ),
        
        // Text Overlay (if any)
        if (heading.isNotEmpty || subheading.isNotEmpty || ctaText.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (heading.isNotEmpty)
                    Text(
                      heading,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  if (subheading.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subheading,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                  if (ctaText.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to link
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        ctaText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
