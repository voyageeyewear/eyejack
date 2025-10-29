import 'package:flutter/material.dart';

class TrustBadgesWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const TrustBadgesWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final badges = settings['badges'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((badge) {
          final icon = badge['icon'] ?? '';
          final text = badge['text'] ?? '';
          return _buildBadge(icon, text);
        }).toList(),
      ),
    );
  }

  Widget _buildBadge(String iconType, String text) {
    IconData icon;
    switch (iconType) {
      case 'shipping':
        icon = Icons.local_shipping_outlined;
        break;
      case 'return':
        icon = Icons.swap_horiz;
        break;
      case 'rating':
        icon = Icons.star_border;
        break;
      case 'secure':
        icon = Icons.lock_outline;
        break;
      default:
        icon = Icons.check_circle_outline;
    }

    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green[700]),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

