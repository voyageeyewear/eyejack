import 'package:flutter/material.dart';
import 'dart:async';

class MovingUspStripWidget extends StatefulWidget {
  final Map<String, dynamic> settings;

  const MovingUspStripWidget({super.key, required this.settings});

  @override
  State<MovingUspStripWidget> createState() => _MovingUspStripWidgetState();
}

class _MovingUspStripWidgetState extends State<MovingUspStripWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late Timer _scrollTimer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Start auto-scroll animation
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1;
        
        // Reset position when reaching the end
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
        }
        
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(widget.settings['backgroundColor'] ?? '#52b1e2');
    final textColor = _parseColor(widget.settings['textColor'] ?? '#ffffff');
    final items = widget.settings['items'] as List<dynamic>? ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

    // Duplicate items for seamless loop
    final duplicatedItems = [...items, ...items, ...items];

    return Container(
      height: 40,
      color: backgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: duplicatedItems.length,
        itemBuilder: (context, index) {
          final item = duplicatedItems[index];
          final icon = _getIconData(item['icon'] ?? '');
          final text = item['text'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: textColor,
                ),
                const SizedBox(width: 8),
                Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF52b1e2);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'support_agent':
        return Icons.support_agent_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
}

