import 'package:flutter/material.dart';

class AnnouncementWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const AnnouncementWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final text = settings['text'] ?? '';
    final backgroundColor = _parseColor(settings['backgroundColor'] ?? '#008060');
    final textColor = _parseColor(settings['textColor'] ?? '#FFFFFF');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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

