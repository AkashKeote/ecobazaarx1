import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../config/firebase_config.dart';

// Import UserRole from FirebaseService
import '../services/firebase_service.dart' show UserRole;

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;
  String? _userId;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;
  String? get userId => _userId;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Listen to Firebase auth state changes
    _firebaseService.authStateChanges.listen((dynamic user) async {
      if (user != null && user.uid != null) {
        await _loadUserData(user.uid);
      } else {
        await _clearUserData();
      }
    });

    // Check if user is already signed in
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      await _loadUserData(currentUser.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userData = await _firebaseService.getUserData(uid);
      if (userData != null) {
        _userId = uid;
        _userEmail = userData['email'];
        _userName = userData['name'];
        _userRole = _parseUserRole(userData['role']);
        _userData = userData;
        _isAuthenticated = true;

        // Save to local storage for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', _userEmail!);
        await prefs.setString('userName', _userName!);
        await prefs.setString('userRole', _userRole.toString());
        await prefs.setString('userId', uid);

        notifyListeners();
      }
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      print('Error loading user data: $e');
    }
  }

  Future<void> _clearUserData() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _userId = null;
    _userData = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  UserRole _parseUserRole(String roleString) {
    switch (roleString) {
      case 'UserRole.customer':
        return UserRole.customer;
      case 'UserRole.shopkeeper':
        return UserRole.shopkeeper;
      case 'UserRole.admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    try {
      // Validate email format
      if (!_firebaseService.validateEmail(email)) {
        throw FirebaseConfig.validationRules['email']['message'];
      }

      // Validate password
      if (!_firebaseService.validatePassword(password)) {
        throw FirebaseConfig.validationRules['password']['message'];
      }

      // Sign in with Firebase
      final credential = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential != null && credential.user != null) {
        // Load user data from Firestore
        await _loadUserData(credential.user!.uid);
        
        // Verify user role matches
        if (_userRole != role) {
          await logout();
          throw 'Invalid role selected for this account.';
        }

        return true;
      }
      return false;
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
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
      // Validate inputs
      if (!_firebaseService.validateName(name)) {
        throw FirebaseConfig.validationRules['name']['message'];
      }

      if (!_firebaseService.validateEmail(email)) {
        throw FirebaseConfig.validationRules['email']['message'];
      }

      if (!_firebaseService.validatePassword(password)) {
        throw FirebaseConfig.validationRules['password']['message'];
      }

      if (password != confirmPassword) {
        throw 'Passwords do not match';
      }

      // Create user with Firebase
      final credential = await _firebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      if (credential != null && credential.user != null) {
        // Load user data from Firestore
        await _loadUserData(credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      await _clearUserData();
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!_firebaseService.validateEmail(email)) {
        throw FirebaseConfig.validationRules['email']['message'];
      }

      await _firebaseService.resetPassword(email);
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (_userId != null) {
        await _firebaseService.updateUserData(_userId!, data);
        
        // Update local data
        if (data.containsKey('name')) {
          _userName = data['name'];
        }
        _userData = {...?_userData, ...data};

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('name')) {
          await prefs.setString('userName', _userName!);
        }

        notifyListeners();
      }
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
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

  // Admin methods for user management
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _firebaseService.getAllUsers();
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(UserRole role) async {
    try {
      return await _firebaseService.getUsersByRole(role);
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _firebaseService.updateUserStatus(userId, status);
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
      rethrow;
    }
  }

  // Analytics methods
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      await _firebaseService.logEvent(eventName, parameters: parameters);
    } catch (e) {
      _firebaseService.reportError(e, StackTrace.current);
    }
  }
}
