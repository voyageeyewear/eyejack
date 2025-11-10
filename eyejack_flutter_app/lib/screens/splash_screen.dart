import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _showSkipButton = false;
  Timer? _skipButtonTimer;
  
  // Splash video URL
  final String _splashVideoUrl = 'https://cdn.shopify.com/videos/c/o/v/6bab26bb066640ee88e75fbdcde5d938.mp4';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startSkipButtonTimer();
  }
  
  void _startSkipButtonTimer() {
    // Show skip button after 5 seconds
    _skipButtonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSkipButton = true;
        });
      }
    });
  }
  
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  
  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(_splashVideoUrl));
    
    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(false);
      await _videoController!.setVolume(0.0); // Muted
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });
      }
      
      // Listen for video completion
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          // Video finished, navigate to home
          _navigateToHome();
        }
      });
    } catch (e) {
      debugPrint('Error initializing splash video: $e');
      // If video fails, navigate after 3 seconds
      Timer(const Duration(seconds: 3), () {
        _navigateToHome();
      });
    }
  }

  @override
  void dispose() {
    _skipButtonTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video - no overlay/opacity
          if (_videoInitialized && _videoController != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Container(
              color: Colors.black,
            ),
          
          // Skip button at top right (appears after 5 seconds)
          if (_showSkipButton)
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: _navigateToHome,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Logo and tagline at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Eyejack logo
                Image.network(
                  'https://eyejack.in/cdn/shop/files/colored-logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'EYEJACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Vision, Our Passion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
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
