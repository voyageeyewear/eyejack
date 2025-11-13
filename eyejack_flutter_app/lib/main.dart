import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shop_provider.dart';
import 'providers/collection_settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/search_screen.dart';
import 'models/product_model.dart';
import 'models/collection_model.dart';
import 'services/gokwik_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GoKwik SDK
  try {
    await GokwikService.initialize();
  } catch (e) {
    debugPrint('⚠️ GoKwik initialization failed: $e');
    // Continue app startup even if GoKwik fails
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CollectionSettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Eyejack Eyewear',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(nextScreen: HomeScreen()),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/product':
              final product = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              );
            
            case '/collection':
              final collection = settings.arguments as Collection;
              return MaterialPageRoute(
                builder: (context) => CollectionScreen(collection: collection),
              );
            
            case '/search':
              return MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              );
            
            default:
              return null;
          }
        },
      ),
    );
  }
}
