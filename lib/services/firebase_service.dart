import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../config/firebase_config.dart';

enum UserRole { customer, shopkeeper, admin }

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  FirebasePerformance get performance => _performance;
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  // Current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize Firebase services
  Future<void> initialize() async {
    try {
      // Initialize Remote Config
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults(FirebaseConfig.remoteConfigDefaults);

      // Fetch and activate remote config
      await _remoteConfig.fetchAndActivate();

      // Enable Crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Set user ID for analytics and crashlytics
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _analytics.setUserId(id: user.uid);
          _crashlytics.setUserIdentifier(user.uid);
        }
      });

      print('Firebase services initialized successfully');
    } catch (e) {
      print('Error initializing Firebase services: $e');
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Authentication Methods
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update user profile
        await credential.user!.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: role,
        );

        // Log analytics event
        await _analytics.logEvent(
          name: FirebaseConfig.analyticsEvents['user_signup']!,
          parameters: {
            'user_id': credential.user!.uid,
            'user_role': role.toString(),
            'signup_method': 'email',
          },
        );

        return credential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw _getAuthExceptionMessage(e.code);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Log analytics event
        await _analytics.logEvent(
          name: FirebaseConfig.analyticsEvents['user_login']!,
          parameters: {
            'user_id': credential.user!.uid,
            'login_method': 'email',
          },
        );

        return credential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw _getAuthExceptionMessage(e.code);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Log analytics event
      await _analytics.logEvent(
        name: FirebaseConfig.analyticsEvents['user_logout']!,
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error signing out. Please try again.';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw _getAuthExceptionMessage(e.code);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Firestore Methods
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role.toString(),
        'status': 'Active',
        'joinDate': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'profileImage': '',
        'phone': '',
        'address': '',
        'preferences': {
          'notifications': true,
          'emailNotifications': true,
          'darkMode': false,
        },
        'carbonFootprint': 0.0,
        'ecoPoints': 0,
        'completedChallenges': 0,
        'totalOrders': 0,
        'totalSpent': 0.0,
      };

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .set(userData);
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error creating user profile. Please try again.';
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error fetching user data. Please try again.';
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error updating user data. Please try again.';
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error fetching users. Please try again.';
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .where('role', isEqualTo: role.toString())
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error fetching users by role. Please try again.';
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
      throw 'Error updating user status. Please try again.';
    }
  }

  // Validation Methods
  bool validateEmail(String email) {
    final pattern = RegExp(FirebaseConfig.validationRules['email']['pattern']);
    return pattern.hasMatch(email);
  }

  bool validatePassword(String password) {
    final rules = FirebaseConfig.validationRules['password'];
    if (password.length < rules['minLength']) return false;
    if (rules['requireUppercase'] && !password.contains(RegExp(r'[A-Z]'))) return false;
    if (rules['requireLowercase'] && !password.contains(RegExp(r'[a-z]'))) return false;
    if (rules['requireNumbers'] && !password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  bool validateName(String name) {
    final rules = FirebaseConfig.validationRules['name'];
    return name.length >= rules['minLength'] && name.length <= rules['maxLength'];
  }

  // Helper Methods
  String _getAuthExceptionMessage(String code) {
    return FirebaseConfig.errorMessages[code] ?? 'An error occurred. Please try again.';
  }

  String getSuccessMessage(String key) {
    return FirebaseConfig.successMessages[key] ?? 'Operation completed successfully!';
  }

  // Analytics Methods
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Remote Config Methods
  String getRemoteConfigString(String key) {
    return _remoteConfig.getString(key);
  }

  bool getRemoteConfigBool(String key) {
    return _remoteConfig.getBool(key);
  }

  int getRemoteConfigInt(String key) {
    return _remoteConfig.getInt(key);
  }

  double getRemoteConfigDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  // Performance Monitoring
  Future<void> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> stopTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.stop();
    } catch (e) {
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  // Error Reporting
  void reportError(dynamic error, StackTrace stackTrace) {
    _crashlytics.recordError(error, stackTrace);
  }

  void log(String message) {
    _crashlytics.log(message);
  }
}
