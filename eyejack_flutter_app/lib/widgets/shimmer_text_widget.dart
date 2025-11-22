import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ShimmerTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const ShimmerTextWidget({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ShimmerTextWidget> createState() => _ShimmerTextWidgetState();
}

class _ShimmerTextWidgetState extends State<ShimmerTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2), 0),
              end: Alignment(1.0 + (_controller.value * 2), 0),
              colors: const [
                Colors.transparent,
                Colors.white,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            widget.text,
            style: widget.style ?? const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

