import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { customer, shopkeeper, admin }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;

  // Static list to store all registered users (accessible by admin)
  static List<Map<String, dynamic>> _allUsers = [
    // Default admin user
    {
      'id': 'admin_1',
      'name': 'Admin User',
      'email': 'admin@ecobazaar.com',
      'role': UserRole.admin,
      'status': 'Active',
      'joinDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0],
    },
  ];

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;
  
  // Getter for all users (for admin access)
  static List<Map<String, dynamic>> get allUsers => _allUsers;

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
      
      // Check if user already exists
      if (_allUsers.any((user) => user['email'] == email)) {
        return false; // User already exists
      }

      // Add new user to the static list
      final newUser = {
        'id': 'user_${_allUsers.length + 1}',
        'name': name,
        'email': email,
        'role': role,
        'status': 'Active',
        'joinDate': DateTime.now().toIso8601String().split('T')[0],
      };
      _allUsers.add(newUser);

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

  // Method to get users filtered by role (for admin dashboard)
  static List<Map<String, dynamic>> getUsersByRole(UserRole? role) {
    if (role == null) return _allUsers;
    return _allUsers.where((user) => user['role'] == role).toList();
  }

  // Method to update user status (for admin dashboard)
  static void updateUserStatus(String userId, String status) {
    final userIndex = _allUsers.indexWhere((user) => user['id'] == userId);
    if (userIndex != -1) {
      _allUsers[userIndex]['status'] = status;
    }
  }
}
