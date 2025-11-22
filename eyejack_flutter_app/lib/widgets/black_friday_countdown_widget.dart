import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BlackFridayCountdownWidget extends StatefulWidget {
  final DateTime endDate;
  final bool showLabel;

  const BlackFridayCountdownWidget({
    super.key,
    required this.endDate,
    this.showLabel = true,
  });

  @override
  State<BlackFridayCountdownWidget> createState() => _BlackFridayCountdownWidgetState();
}

class _BlackFridayCountdownWidgetState extends State<BlackFridayCountdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.endDate.difference(now);

    if (difference.isNegative) {
      return 'Sale Ended';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  bool _isUrgent() {
    final now = DateTime.now();
    final difference = widget.endDate.difference(now);
    return difference.inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (!themeProvider.blackFridayActive) {
      return const SizedBox.shrink();
    }

    final isUrgent = _isUrgent();
    final timeRemaining = _getTimeRemaining();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeProvider.blackFridayPrimary,
                  ThemeProvider.blackFridayPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isUrgent
                  ? [
                      BoxShadow(
                        color: ThemeProvider.blackFridayPrimary.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showLabel) ...[
                  Icon(
                    Icons.timer,
                    color: ThemeProvider.blackFridayText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BLACK FRIDAY SALE',
                    style: TextStyle(
                      color: ThemeProvider.blackFridayText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 20,
                    color: ThemeProvider.blackFridayText.withOpacity(0.3),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  timeRemaining,
                  style: TextStyle(
                    color: ThemeProvider.blackFridaySecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

