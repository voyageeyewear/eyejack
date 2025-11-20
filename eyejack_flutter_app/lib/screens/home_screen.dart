import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/section_renderer.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/footer_widget.dart';
import '../services/api_service.dart';
import '../screens/kp_checkout_screen.dart';

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
    // Store the parent context and navigator before opening modal
    final parentContext = context;
    final parentNavigator = Navigator.of(context);
    final parentScaffoldMessenger = ScaffoldMessenger.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => CartDrawer(
        onCheckout: () async {
          // Close the modal first
          Navigator.pop(modalContext);
          
          // Wait a bit for modal to close completely
          await Future.delayed(const Duration(milliseconds: 300));
          
          try {
            debugPrint('🛒 Opening Kwikpass checkout...');
            
            // Show loading indicator using the parent context
            parentScaffoldMessenger.showSnackBar(
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
                    Text('Opening checkout...'),
                  ],
                ),
                backgroundColor: Color(0xFF27916D),
                duration: Duration(seconds: 2),
              ),
            );
            
            // Create GoKwik checkout through backend API (this handles the proper integration)
            debugPrint('📞 Calling backend API to create GoKwik checkout...');
            final gokwikCheckoutData = await ApiService().createGokwikCheckout();
            
            debugPrint('✅ GoKwik checkout data: $gokwikCheckoutData');
            
            // Extract checkout URL from backend response
            final checkoutUrl = gokwikCheckoutData['checkoutUrl']?.toString();
            final cartId = gokwikCheckoutData['cartId']?.toString();
            final merchantId = gokwikCheckoutData['merchantId']?.toString() ?? '19g6iluwldmy4';
            
            debugPrint('✅ Checkout URL: $checkoutUrl');
            debugPrint('✅ Cart ID: $cartId');
            debugPrint('✅ Merchant ID: $merchantId');
            
            if (checkoutUrl == null || checkoutUrl.isEmpty) {
              throw Exception('Failed to create checkout URL. Please try again.');
            }
            
            // Extract clean cart ID if needed
            String cleanCartId = cartId ?? '';
            if (cleanCartId.contains('gid://shopify/Cart/')) {
              final match = RegExp(r'gid://shopify/Cart/([^?]+)').firstMatch(cleanCartId);
              if (match != null && match.group(1) != null) {
                cleanCartId = match.group(1)!;
              }
            }
            
            debugPrint('🚀 Navigating to checkout with URL: $checkoutUrl');
            
            // Navigate to Kwikpass Checkout screen using the parent navigator
            // Use a post-frame callback to ensure navigation happens after modal is fully closed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && parentContext.mounted) {
                debugPrint('✅ Context is valid, pushing checkout screen...');
                parentNavigator.push(
                  MaterialPageRoute(
                    builder: (context) => KPCheckoutScreen(
                      cartId: cleanCartId.isNotEmpty ? cleanCartId : null,
                      storefrontToken: '0032c089ead422dfbfaa0ffcbbddcc97', // Storefront API token
                      storeId: merchantId, // Merchant ID from backend
                      checkoutUrl: checkoutUrl, // Use checkout URL from backend
                    ),
                  ),
                ).then((result) {
                  // Handle checkout result
                  if (result == true && mounted && parentContext.mounted) {
                    parentScaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Order placed successfully!'),
                        backgroundColor: Color(0xFF27916D),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error) {
                  debugPrint('❌ Navigation error: $error');
                  if (mounted && parentContext.mounted) {
                    parentScaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error navigating to checkout: $error'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                });
              } else {
                debugPrint('❌ Context not valid for navigation');
              }
            });
          } catch (e, stackTrace) {
            debugPrint('❌ Error opening checkout: $e');
            debugPrint('❌ Stack trace: $stackTrace');
            
            if (mounted && parentContext.mounted) {
              parentScaffoldMessenger.showSnackBar(
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

  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          // Get collections from provider
          final collections = shopProvider.collections ?? [];
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Eyejack Eyewear',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Premium Eyewear Collection',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...collections.map((collection) {
                return ListTile(
                  leading: const Icon(Icons.category, size: 20),
                  title: Text(collection.title),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/collection',
                      arguments: collection,
                    );
                  },
                );
              }).toList(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text('Offers'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Us'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://eyejack.in/cdn/shop/files/colored-logo.png',
                    height: 28,
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
                  // Version display
                  const Text(
                    'v12.24.0 (156)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
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
      drawer: _buildDrawer(),
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
                
                // 4. Footer at the bottom
                const SliverToBoxAdapter(
                  child: FooterWidget(),
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

