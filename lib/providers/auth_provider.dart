import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { customer, shopkeeper, admin }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');

    final roleString = prefs.getString('userRole');
    if (roleString != null) {
      _userRole = UserRole.values.firstWhere(
        (role) => role.toString() == roleString,
        orElse: () => UserRole.customer,
      );
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password, UserRole role) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, accept any email/password combination
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = email;
      _userName = email.split('@')[0]; // Use email prefix as username
      _userRole = role;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userRole', role.toString());

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
    UserRole role,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, accept any valid input
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword) {
      _isAuthenticated = true;
      _userEmail = email;
      _userName = name;
      _userRole = role;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);
      await prefs.setString('userRole', role.toString());

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _userRole = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.shopkeeper:
        return 'Shopkeeper';
      case UserRole.admin:
        return 'Admin';
    }
  }

  IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.shopkeeper:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
