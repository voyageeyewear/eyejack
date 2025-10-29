import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> settings;

  const AppHeaderWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final logo = settings['logo'] ?? '';
    final storeName = settings['storeName'] ?? 'Eyejack Eyewear';
    final showSearch = settings['showSearch'] ?? true;
    final showCart = settings['showCart'] ?? true;

    return Ink(
      decoration: const BoxDecoration(
        color: Colors.black, // INK BLACK BACKGROUND
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
            // Menu Icon
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Open menu/drawer
                Scaffold.of(context).openDrawer();
              },
            ),
            
            const SizedBox(width: 8),
            
            // Logo
            Expanded(
              child: logo.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: logo,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            
            // Search Icon
            if (showSearch)
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            
            // Cart Icon
            if (showCart)
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  // Navigate to cart
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

