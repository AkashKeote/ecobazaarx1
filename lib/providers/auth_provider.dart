import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

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
    try {
      // Use Firebase authentication
      final userCredential = await FirebaseService.signInWithEmailAndPassword(email, password);
      
      if (userCredential != null && userCredential.user != null) {
        _isAuthenticated = true;
        _userEmail = email;
        _userName = userCredential.user!.displayName ?? email.split('@')[0];
        _userRole = role;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', _userName!);
        await prefs.setString('userRole', role.toString());

        // Log analytics event
        await FirebaseService.logEvent('user_login', {
          'email': email,
          'role': getRoleDisplayName(role),
        });

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
    UserRole role,
  ) async {
    try {
      if (name.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          password == confirmPassword) {
        
        // Use Firebase authentication
        final userCredential = await FirebaseService.signUpWithEmailAndPassword(
          email, 
          password, 
          name, 
          getRoleDisplayName(role),
        );
        
        if (userCredential != null && userCredential.user != null) {
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

          // Log analytics event
          await FirebaseService.logEvent('user_signup', {
            'email': email,
            'role': getRoleDisplayName(role),
          });

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseService.signOut();
      
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      _userRole = null;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Log analytics event
      await FirebaseService.logEvent('user_logout', null);

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
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
