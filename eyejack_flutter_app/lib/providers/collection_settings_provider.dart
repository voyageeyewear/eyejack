import 'package:flutter/foundation.dart';
import '../models/collection_settings_model.dart';
import '../services/api_service.dart';

class CollectionSettingsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  CollectionPageSettings _settings = CollectionPageSettings.defaults();
  bool _isLoading = false;
  bool _hasError = false;
  
  CollectionPageSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  
  CollectionSettingsProvider() {
    // Automatically load settings when provider is created
    fetchSettings();
  }
  
  Future<void> fetchSettings() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      debugPrint('🔄 Loading collection settings...');
      _settings = await _apiService.fetchCollectionSettings();
      _isLoading = false;
      _hasError = false;
      debugPrint('✅ Collection settings loaded successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading collection settings: $e');
      debugPrint('   Using default settings');
      _settings = CollectionPageSettings.defaults();
      _isLoading = false;
      _hasError = true;
      notifyListeners();
    }
  }
  
  // Refresh settings (call this when you want to reload from API)
  Future<void> refresh() async {
    await fetchSettings();
  }
}

