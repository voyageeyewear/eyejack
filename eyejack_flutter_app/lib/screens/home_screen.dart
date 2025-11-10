import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/section_renderer.dart';
import '../widgets/cart_drawer.dart';
import '../services/api_service.dart';
import '../services/gokwik_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch theme sections on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchThemeSections();
    });
  }

  void _showCartDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartDrawer(
        onCheckout: () async {
          Navigator.pop(context); // Close cart drawer
          
          try {
            debugPrint('🛒 Opening GoKwik checkout...');
            
            // Show loading indicator
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Opening GoKwik checkout...'),
                    ],
                  ),
                  backgroundColor: Color(0xFF27916D),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            
            // Create GoKwik checkout
            final checkoutData = await ApiService().createGokwikCheckout();
            final checkoutUrl = checkoutData['checkoutUrl'] as String;
            
            debugPrint('✅ GoKwik checkout URL: $checkoutUrl');
            debugPrint('✅ Cart data: $checkoutData');
            
            // Open GoKwik native checkout
            if (mounted) {
              final success = await GokwikService.openCheckout(
                context: context,
                checkoutUrl: checkoutUrl,
                cartData: checkoutData,
              );

              // Handle checkout result
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Order placed successfully!'),
                      backgroundColor: Color(0xFF27916D),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Checkout was not completed'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('❌ Error opening GoKwik checkout: $e');
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          Expanded(
            child: Center(
              child: Image.network(
                'https://eyejack.in/cdn/shop/files/colored-logo.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Eyejack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: _showCartDrawer,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Eyejack Eyewear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sunny),
              title: const Text('Sunglasses'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Eyeglasses'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.new_releases),
              title: const Text('New Arrivals'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Offers'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (shopProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Store',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      shopProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      shopProvider.fetchThemeSections();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final themeData = shopProvider.themeData;
          if (themeData == null || themeData.layout.isEmpty) {
            return const Center(
              child: Text('No content available'),
            );
          }

          // Separate announcement bars from other sections
          final announcementBars = themeData.layout
              .where((section) => section.type == 'announcement_bars')
              .toList();
          final otherSections = themeData.layout
              .where((section) => section.type != 'announcement_bars')
              .toList();

          return RefreshIndicator(
            onRefresh: () => shopProvider.fetchThemeSections(),
            child: CustomScrollView(
              slivers: [
                // 1. Announcement bars - sticky at the top
                ...announcementBars.map((section) => SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyAnnouncementDelegate(
                        child: SectionRenderer(section: section),
                      ),
                    )),
                
                // 2. Custom header (AppBar)
                SliverToBoxAdapter(
                  child: _buildCustomAppBar(context),
                ),
                
                // 3. All other sections
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SectionRenderer(section: otherSections[index]);
                    },
                    childCount: otherSections.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Delegate for sticky announcement bar
class _StickyAnnouncementDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyAnnouncementDelegate({required this.child});

  @override
  double get minExtent => 32.0; // Height of announcement bar + safe area

  @override
  double get maxExtent => 32.0 + MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).padding.top;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

