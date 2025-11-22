import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PulsingSaleBadge extends StatefulWidget {
  final String text;
  final double? fontSize;
  final EdgeInsets? padding;

  const PulsingSaleBadge({
    super.key,
    required this.text,
    this.fontSize,
    this.padding,
  });

  @override
  State<PulsingSaleBadge> createState() => _PulsingSaleBadgeState();
}

class _PulsingSaleBadgeState extends State<PulsingSaleBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (!themeProvider.blackFridayActive) {
      return Container(
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: themeProvider.saleBadgeColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.fontSize ?? 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeProvider.blackFridayPrimary,
              border: Border.all(
                color: ThemeProvider.blackFridaySecondary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.blackFridayPrimary.withOpacity(_glowAnimation.value * 0.8),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: ThemeProvider.blackFridayText,
                fontSize: widget.fontSize ?? 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

