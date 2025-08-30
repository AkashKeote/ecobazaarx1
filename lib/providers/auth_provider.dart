import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';

enum UserRole { customer, shopkeeper, admin }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;
  User? _firebaseUser;

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
  User? get firebaseUser => _firebaseUser;
  
  // Getter for all users (for admin access)
  static List<Map<String, dynamic>> get allUsers => _allUsers;

  AuthProvider() {
    _checkAuthStatus();
    _setupAuthStateListener();
  }

  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _firebaseUser = user;
        _loadUserDataFromFirestore(user.uid);
      } else {
        _firebaseUser = null;
        _isAuthenticated = false;
        _userEmail = null;
        _userName = null;
        _userRole = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserDataFromFirestore(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _userEmail = data['email'] ?? _firebaseUser?.email;
        _userName = data['name'];
        _userRole = _stringToUserRole(data['role']);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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

  Future<Map<String, dynamic>> login(String email, String password, UserRole role) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final doc = await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final userRole = _stringToUserRole(data['role']);
          
          // Check if the user role matches the selected role
          if (userRole == role) {
            _firebaseUser = userCredential.user;
            _userEmail = email;
            _userName = data['name'];
            _userRole = role;
            _isAuthenticated = true;

            // Save to local storage
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isAuthenticated', true);
            await prefs.setString('userEmail', email);
            await prefs.setString('userName', _userName!);
            await prefs.setString('userRole', role.toString());

            notifyListeners();
            
            return {
              'success': true,
              'message': FirebaseConfig.successMessages['auth/login-success'] ?? 'Login successful!',
            };
          } else {
            // Role mismatch
            await _auth.signOut();
            return {
              'success': false,
              'message': 'Invalid role selected for this account.',
            };
          }
        } else {
          // User document doesn't exist in Firestore
          await _auth.signOut();
          return {
            'success': false,
            'message': 'User data not found. Please contact support.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please try again.',
        };
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = FirebaseConfig.errorMessages[e.code] ?? 'An error occurred during login.';
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
    UserRole role,
  ) async {
    try {
      // Validate input
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill in all fields.',
        };
      }

      if (password != confirmPassword) {
        return {
          'success': false,
          'message': 'Passwords do not match.',
        };
      }

      if (password.length < 8) {
        return {
          'success': false,
          'message': FirebaseConfig.errorMessages['auth/weak-password'] ?? 'Password is too weak.',
        };
      }

      // Check if user already exists in Firestore
      final existingUsers = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('email', isEqualTo: email)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        return {
          'success': false,
          'message': FirebaseConfig.errorMessages['auth/email-already-in-use'] ?? 'An account already exists with this email.',
        };
      }

      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userData = {
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'role': _userRoleToString(role),
          'status': 'Active',
          'joinDate': DateTime.now().toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profileImage': '',
          'phone': '',
          'address': '',
          'preferences': {
            'notifications': true,
            'emailNotifications': true,
            'darkMode': false,
          },
          'stats': {
            'totalOrders': 0,
            'totalSpent': 0.0,
            'carbonSaved': 0.0,
            'ecoPoints': 0,
            'streakDays': 0,
          },
        };

        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .set(userData);

        // Add to local list for admin access
        _allUsers.add({
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'role': role,
          'status': 'Active',
          'joinDate': DateTime.now().toIso8601String().split('T')[0],
        });

        _firebaseUser = userCredential.user;
        _userEmail = email;
        _userName = name;
        _userRole = role;
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', name);
        await prefs.setString('userRole', role.toString());

        notifyListeners();
        
        return {
          'success': true,
          'message': FirebaseConfig.successMessages['auth/signup-success'] ?? 'Account created successfully!',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
        };
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = FirebaseConfig.errorMessages[e.code] ?? 'An error occurred during signup.';
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      _userRole = null;
      _firebaseUser = null;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'customer';
      case UserRole.shopkeeper:
        return 'shopkeeper';
      case UserRole.admin:
        return 'admin';
    }
  }

  UserRole _stringToUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'shopkeeper':
        return UserRole.shopkeeper;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
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

  // Method to reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully!',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = FirebaseConfig.errorMessages[e.code] ?? 'Failed to send reset email.';
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Method to update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      if (_firebaseUser != null) {
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(_firebaseUser!.uid)
            .update({
          'name': name,
          'phone': phone ?? '',
          'address': address ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _userName = name;
        notifyListeners();

        return {
          'success': true,
          'message': FirebaseConfig.successMessages['profile/update-success'] ?? 'Profile updated successfully!',
        };
      } else {
        return {
          'success': false,
          'message': 'User not authenticated.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile. Please try again.',
      };
    }
  }
}
