import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _analytics = FirebaseAnalytics.instance;
  }

  // Authentication methods
  static FirebaseAuth get auth => _auth!;
  static FirebaseFirestore get firestore => _firestore!;
  static FirebaseStorage get storage => _storage!;
  static FirebaseAnalytics get analytics => _analytics!;

  // User authentication
  static Future<UserCredential?> signUpWithEmailAndPassword(
    String email, 
    String password,
    String userName,
    String role,
  ) async {
    try {
      UserCredential userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore!.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'userName': userName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Active',
      });

      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth!.signOut();
  }

  static User? get currentUser => _auth!.currentUser;

  // Firestore methods for users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore!.collection('users').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  static Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _firestore!.collection('users').add({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore!.collection('users').doc(userId).update(userData);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore!.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Firestore methods for stores
  static Future<List<Map<String, dynamic>>> getAllStores() async {
    try {
      QuerySnapshot querySnapshot = await _firestore!.collection('stores').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting stores: $e');
      return [];
    }
  }

  static Future<void> addStore(Map<String, dynamic> storeData) async {
    try {
      await _firestore!.collection('stores').add({
        ...storeData,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding store: $e');
    }
  }

  // Firestore methods for products
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore!.collection('products').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  static Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore!.collection('products').add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  // Analytics methods
  static Future<void> logEvent(String eventName, Map<String, Object>? parameters) async {
    try {
      await _analytics!.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  // Real-time listeners
  static Stream<QuerySnapshot> getUsersStream() {
    return _firestore!.collection('users').snapshots();
  }

  static Stream<QuerySnapshot> getStoresStream() {
    return _firestore!.collection('stores').snapshots();
  }

  static Stream<QuerySnapshot> getProductsStream() {
    return _firestore!.collection('products').snapshots();
  }
} 
