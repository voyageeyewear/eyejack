import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _blackFridayActive = false;
  Map<String, dynamic> _themeSettings = {};
  bool _isLoading = false;

  // Black Friday Theme Colors
  static const Color blackFridayPrimary = Color(0xFFFF0000); // Red
  static const Color blackFridaySecondary = Color(0xFFFFD700); // Gold
  static const Color blackFridayBackground = Color(0xFF000000); // Black
  static const Color blackFridayText = Color(0xFFFFFFFF); // White
  static const Color blackFridayAccent = Color(0xFF1A1A1A); // Dark Gray

  // Normal Theme Colors (default)
  static const Color normalPrimary = Color(0xFF000000); // Black
  static const Color normalSecondary = Color(0xFF27916D); // Green
  static const Color normalBackground = Color(0xFFFFFFFF); // White
  static const Color normalText = Color(0xFF000000); // Black

  bool get blackFridayActive => _blackFridayActive;
  Map<String, dynamic> get themeSettings => _themeSettings;
  bool get isLoading => _isLoading;

  // Get current primary color based on theme
  Color get primaryColor => _blackFridayActive ? blackFridayPrimary : normalPrimary;
  Color get secondaryColor => _blackFridayActive ? blackFridaySecondary : normalSecondary;
  Color get backgroundColor => _blackFridayActive ? blackFridayBackground : normalBackground;
  Color get textColor => _blackFridayActive ? blackFridayText : normalText;

  // Load theme settings from API
  Future<void> loadThemeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Add API endpoint to fetch theme settings
      // For now, check if Black Friday should be active based on date
      final now = DateTime.now();
      final blackFridayDate = DateTime(now.year, 11, 24); // November 24
      final blackFridayStart = blackFridayDate.subtract(const Duration(days: 7)); // Start 1 week before
      final blackFridayEnd = blackFridayDate.add(const Duration(days: 3)); // End 3 days after

      // Check if current date is within Black Friday period
      // For testing: Enable Black Friday theme (set to true to test)
      _blackFridayActive = true; // Set to true for testing, or use date check: now.isAfter(blackFridayStart) && now.isBefore(blackFridayEnd);

      // Load theme settings from backend (when API is ready)
      // final settings = await ApiService().getThemeSettings();
      // _blackFridayActive = settings['black_friday_active'] == true || settings['black_friday_active'] == 'true';
      // _themeSettings = settings;

      debugPrint('🎨 Theme loaded: Black Friday Active = $_blackFridayActive');
    } catch (e) {
      debugPrint('⚠️ Error loading theme settings: $e');
      _blackFridayActive = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Black Friday theme (for testing)
  void toggleBlackFridayTheme() {
    _blackFridayActive = !_blackFridayActive;
    notifyListeners();
    debugPrint('🎨 Black Friday theme toggled: $_blackFridayActive');
  }

  // Set Black Friday theme manually
  void setBlackFridayTheme(bool active) {
    _blackFridayActive = active;
    notifyListeners();
  }

  // Get gradient colors for buttons
  List<Color> get buttonGradientColors {
    if (_blackFridayActive) {
      return [blackFridayPrimary, Color(0xFFFF4500)]; // Red to Orange-Red
    }
    return [normalPrimary, normalSecondary];
  }

  // Get sale badge color
  Color get saleBadgeColor => _blackFridayActive ? blackFridayPrimary : Color(0xFFE74C3C);

  // Get sale badge border color
  Color get saleBadgeBorderColor => _blackFridayActive ? blackFridaySecondary : Colors.transparent;

  // Check if animations should be enabled
  bool get animationsEnabled => _blackFridayActive;

  // Get countdown end date (Black Friday)
  DateTime get countdownEndDate {
    final now = DateTime.now();
    return DateTime(now.year, 11, 24, 23, 59, 59); // November 24, 11:59 PM
  }
}

