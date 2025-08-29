import 'package:flutter/material.dart';

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

  // Notification Settings Methods
  void setPushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    print('Push notifications: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setOrderNotifications(bool value) {
    _orderNotificationsEnabled = value;
    print('Order notifications: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setEcoTips(bool value) {
    _ecoTipsEnabled = value;
    print('Eco tips: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setPromotionalNotifications(bool value) {
    _promotionalNotificationsEnabled = value;
    print('Promotional notifications: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setCarbonTracking(bool value) {
    _carbonTrackingEnabled = value;
    print('Carbon tracking notifications: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  // Privacy & Security Methods
  void setLocationEnabled(bool value) {
    _locationEnabled = value;
    print('Location services: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setDataCollection(bool value) {
    _dataCollectionEnabled = value;
    print('Data collection: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    print('Biometric login: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  // App Preferences Methods
  void setDarkMode(bool value) {
    _darkModeEnabled = value;
    print('Dark mode: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _autoSaveEnabled = value;
    print('Auto-save: ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  void setHapticFeedback(bool value) {
    _hapticFeedbackEnabled = value;
    print('Haptic feedback: ${value ? 'enabled' : 'disabled'}');
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
}
