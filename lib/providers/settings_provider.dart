import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Notification Settings
  bool _pushNotificationsEnabled = true;
  bool _orderNotificationsEnabled = true;
  bool _ecoTipsEnabled = true;
  bool _promotionalNotificationsEnabled = true;
  bool _carbonTrackingEnabled = true;

  // Privacy & Security Settings
  bool _locationEnabled = true;
  bool _dataCollectionEnabled = true;
  bool _biometricEnabled = false;

  // App Preferences
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  bool _hapticFeedbackEnabled = true;

  // Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get orderNotificationsEnabled => _orderNotificationsEnabled;
  bool get ecoTipsEnabled => _ecoTipsEnabled;
  bool get promotionalNotificationsEnabled => _promotionalNotificationsEnabled;
  bool get carbonTrackingEnabled => _carbonTrackingEnabled;
  bool get locationEnabled => _locationEnabled;
  bool get dataCollectionEnabled => _dataCollectionEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _pushNotificationsEnabled = prefs.getBool('pushNotificationsEnabled') ?? true;
      _orderNotificationsEnabled = prefs.getBool('orderNotificationsEnabled') ?? true;
      _ecoTipsEnabled = prefs.getBool('ecoTipsEnabled') ?? true;
      _promotionalNotificationsEnabled = prefs.getBool('promotionalNotificationsEnabled') ?? true;
      _carbonTrackingEnabled = prefs.getBool('carbonTrackingEnabled') ?? true;
      
      _locationEnabled = prefs.getBool('locationEnabled') ?? true;
      _dataCollectionEnabled = prefs.getBool('dataCollectionEnabled') ?? true;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _autoSaveEnabled = prefs.getBool('autoSaveEnabled') ?? true;
      _hapticFeedbackEnabled = prefs.getBool('hapticFeedbackEnabled') ?? true;
      
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('pushNotificationsEnabled', _pushNotificationsEnabled);
      await prefs.setBool('orderNotificationsEnabled', _orderNotificationsEnabled);
      await prefs.setBool('ecoTipsEnabled', _ecoTipsEnabled);
      await prefs.setBool('promotionalNotificationsEnabled', _promotionalNotificationsEnabled);
      await prefs.setBool('carbonTrackingEnabled', _carbonTrackingEnabled);
      
      await prefs.setBool('locationEnabled', _locationEnabled);
      await prefs.setBool('dataCollectionEnabled', _dataCollectionEnabled);
      await prefs.setBool('biometricEnabled', _biometricEnabled);
      
      await prefs.setBool('darkModeEnabled', _darkModeEnabled);
      await prefs.setBool('autoSaveEnabled', _autoSaveEnabled);
      await prefs.setBool('hapticFeedbackEnabled', _hapticFeedbackEnabled);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Notification Settings Methods
  void setPushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    print('Push notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setOrderNotifications(bool value) {
    _orderNotificationsEnabled = value;
    print('Order notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setEcoTips(bool value) {
    _ecoTipsEnabled = value;
    print('Eco tips: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setPromotionalNotifications(bool value) {
    _promotionalNotificationsEnabled = value;
    print('Promotional notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setCarbonTracking(bool value) {
    _carbonTrackingEnabled = value;
    print('Carbon tracking notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  // Privacy & Security Methods
  void setLocationEnabled(bool value) {
    _locationEnabled = value;
    print('Location services: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setDataCollection(bool value) {
    _dataCollectionEnabled = value;
    print('Data collection: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    print('Biometric login: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  // App Preferences Methods
  void setDarkMode(bool value) {
    _darkModeEnabled = value;
    print('Dark mode: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _autoSaveEnabled = value;
    print('Auto-save: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  void setHapticFeedback(bool value) {
    _hapticFeedbackEnabled = value;
    print('Haptic feedback: ${value ? 'enabled' : 'disabled'}');
    _saveSettings();
    notifyListeners();
  }

  // Check if any notifications are enabled
  bool get anyNotificationsEnabled {
    return _pushNotificationsEnabled ||
           _orderNotificationsEnabled ||
           _ecoTipsEnabled ||
           _promotionalNotificationsEnabled ||
           _carbonTrackingEnabled;
  }

  // Disable all notifications
  void disableAllNotifications() {
    _pushNotificationsEnabled = false;
    _orderNotificationsEnabled = false;
    _ecoTipsEnabled = false;
    _promotionalNotificationsEnabled = false;
    _carbonTrackingEnabled = false;
    print('All notifications disabled');
    _saveSettings();
    notifyListeners();
  }

  // Enable all notifications
  void enableAllNotifications() {
    _pushNotificationsEnabled = true;
    _orderNotificationsEnabled = true;
    _ecoTipsEnabled = true;
    _promotionalNotificationsEnabled = true;
    _carbonTrackingEnabled = true;
    print('All notifications enabled');
    _saveSettings();
    notifyListeners();
  }

  // Reset all settings to default
  void resetToDefaults() {
    _pushNotificationsEnabled = true;
    _orderNotificationsEnabled = true;
    _ecoTipsEnabled = true;
    _promotionalNotificationsEnabled = true;
    _carbonTrackingEnabled = true;
    _locationEnabled = true;
    _dataCollectionEnabled = true;
    _biometricEnabled = false;
    _darkModeEnabled = false;
    _autoSaveEnabled = true;
    _hapticFeedbackEnabled = true;
    print('Settings reset to defaults');
    _saveSettings();
    notifyListeners();
  }

  // Get settings summary
  Map<String, dynamic> getSettingsSummary() {
    return {
      'notifications': {
        'push': _pushNotificationsEnabled,
        'orders': _orderNotificationsEnabled,
        'eco_tips': _ecoTipsEnabled,
        'promotional': _promotionalNotificationsEnabled,
        'carbon_tracking': _carbonTrackingEnabled,
      },
      'privacy': {
        'location': _locationEnabled,
        'data_collection': _dataCollectionEnabled,
        'biometric': _biometricEnabled,
      },
      'preferences': {
        'dark_mode': _darkModeEnabled,
        'auto_save': _autoSaveEnabled,
        'haptic_feedback': _hapticFeedbackEnabled,
      },
    };
  }

  // Export settings for backup
  Map<String, dynamic> exportSettings() {
    return {
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'settings': getSettingsSummary(),
    };
  }

  // Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> data) async {
    try {
      if (data['version'] != '1.0.0') {
        print('Unsupported settings version');
        return false;
      }

      final settings = data['settings'] as Map<String, dynamic>;
      
      // Import notification settings
      final notifications = settings['notifications'] as Map<String, dynamic>;
      _pushNotificationsEnabled = notifications['push'] ?? true;
      _orderNotificationsEnabled = notifications['orders'] ?? true;
      _ecoTipsEnabled = notifications['eco_tips'] ?? true;
      _promotionalNotificationsEnabled = notifications['promotional'] ?? true;
      _carbonTrackingEnabled = notifications['carbon_tracking'] ?? true;

      // Import privacy settings
      final privacy = settings['privacy'] as Map<String, dynamic>;
      _locationEnabled = privacy['location'] ?? true;
      _dataCollectionEnabled = privacy['data_collection'] ?? true;
      _biometricEnabled = privacy['biometric'] ?? false;

      // Import app preferences
      final preferences = settings['preferences'] as Map<String, dynamic>;
      _darkModeEnabled = preferences['dark_mode'] ?? false;
      _autoSaveEnabled = preferences['auto_save'] ?? true;
      _hapticFeedbackEnabled = preferences['haptic_feedback'] ?? true;

      await _saveSettings();
      notifyListeners();
      print('Settings imported successfully');
      return true;
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }
}
