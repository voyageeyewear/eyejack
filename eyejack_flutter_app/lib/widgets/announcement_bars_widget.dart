import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'shimmer_text_widget.dart';

class AnnouncementBarsWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const AnnouncementBarsWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final bars = settings['bars'] as List<dynamic>? ?? [];
    
    // Debug: Print announcement bar colors
    for (var bar in bars) {
      debugPrint('📢 Announcement: "${bar['text']}" - BG: ${bar['backgroundColor']}');
    }
    
    if (bars.isEmpty) return const SizedBox.shrink();

    // Get the background color of the first bar for safe area
    final backgroundColor = _parseColor(bars[0]['backgroundColor'] ?? '#52b1e2');

    return Column(
      children: [
        // Safe area with matching color
        Container(
          color: backgroundColor,
          child: SafeArea(
            bottom: false,
            child: Container(height: 0),
          ),
        ),
        // Announcement bar carousel
        Container(
          height: 32,
          child: FlutterCarousel(
        options: CarouselOptions(
          height: 32,
          viewportFraction: 1.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          showIndicator: false,
        ),
        items: bars.map((bar) {
          return Builder(
            builder: (context) {
              final themeProvider = Provider.of<ThemeProvider>(context);
              
              // Use Black Friday colors if theme is active
              final backgroundColor = themeProvider.blackFridayActive
                  ? ThemeProvider.blackFridayBackground
                  : _parseColor(bar['backgroundColor'] ?? '#52b1e2');
              final textColor = themeProvider.blackFridayActive
                  ? ThemeProvider.blackFridayText
                  : _parseColor(bar['textColor'] ?? '#FFFFFF');
              
              final text = bar['text'] ?? '';
              final isBlackFridayText = text.toUpperCase().contains('BLACK FRIDAY') || 
                                        text.toUpperCase().contains('SALE');
              
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  gradient: themeProvider.blackFridayActive
                      ? LinearGradient(
                          colors: [
                            ThemeProvider.blackFridayBackground,
                            ThemeProvider.blackFridayPrimary.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: themeProvider.blackFridayActive && isBlackFridayText
                    ? ShimmerTextWidget(
                        text: text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: themeProvider.blackFridayActive ? 0.8 : 0,
                        ),
                      ),
              );
            },
          );
        }).toList(),
          ),
        ),
      ],
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

