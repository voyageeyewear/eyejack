import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class AnnouncementBarsWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const AnnouncementBarsWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final bars = settings['bars'] as List<dynamic>? ?? [];
    
    if (bars.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      child: FlutterCarousel(
        options: CarouselOptions(
          height: 40,
          viewportFraction: 1.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          showIndicator: false,
        ),
        items: bars.map((bar) {
          final backgroundColor = _parseColor(bar['backgroundColor'] ?? '#008060');
          final textColor = _parseColor(bar['textColor'] ?? '#FFFFFF');
          
          return Container(
            width: double.infinity,
            color: backgroundColor,
            alignment: Alignment.center,
            child: Text(
              bar['text'] ?? '',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.teal;
    }
  }
}

