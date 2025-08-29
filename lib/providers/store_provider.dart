import 'package:flutter/material.dart';
import 'dart:math';

class StoreProvider extends ChangeNotifier {
  // Centralized store data that both admin and shopkeeper can access
  List<Map<String, dynamic>> _allStores = [];
  
  StoreProvider() {
    // Initialize with default stores
    _allStores = [
      {
        'id': '1',
        'name': 'GreenMart',
        'category': 'Food & Beverages',
        'performance': 0.85,
        'rating': 4.2,
        'status': 'Active',
        'products': 156,
        'revenue': 45000,
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 5)),
        'onlineUsers': 45,
        'ordersToday': 23,
        'carbonSaved': 12.5,
        'trend': 'up',
        'lastOrder': DateTime.now().subtract(const Duration(minutes: 2)),
        'ownerId': 'admin', // To track who owns the store
        'description': 'A sustainable store offering eco-friendly food and beverage products.',
      },
      {
        'id': '2',
        'name': 'EcoShop',
        'category': 'Clothing & Fashion',
        'performance': 0.72,
        'rating': 4.1,
        'status': 'Active',
        'products': 89,
        'revenue': 32000,
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 3)),
        'onlineUsers': 32,
        'ordersToday': 18,
        'carbonSaved': 8.7,
        'trend': 'stable',
        'lastOrder': DateTime.now().subtract(const Duration(minutes: 5)),
        'ownerId': 'admin',
        'description': 'Eco-friendly clothing and fashion store.',
      },
      {
        'id': '3',
        'name': 'Sustainable Store',
        'category': 'Electronics',
        'performance': 0.68,
        'rating': 3.9,
        'status': 'Inactive',
        'products': 67,
        'revenue': 28000,
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 8)),
        'onlineUsers': 28,
        'ordersToday': 15,
        'carbonSaved': 6.3,
        'trend': 'down',
        'lastOrder': DateTime.now().subtract(const Duration(minutes: 12)),
        'ownerId': 'admin',
        'description': 'Sustainable electronics and gadgets store.',
      },
      {
        'id': '4',
        'name': 'Green Corner',
        'category': 'Home & Garden',
        'performance': 0.91,
        'rating': 4.5,
        'status': 'Active',
        'products': 234,
        'revenue': 67000,
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 2)),
        'onlineUsers': 67,
        'ordersToday': 34,
        'carbonSaved': 18.2,
        'trend': 'up',
        'lastOrder': DateTime.now().subtract(const Duration(minutes: 1)),
        'ownerId': 'admin',
        'description': 'Home and garden eco-friendly products.',
      },
      {
        'id': '5',
        'name': 'EcoTech Solutions',
        'category': 'Electronics',
        'performance': 0.78,
        'rating': 4.0,
        'status': 'Inactive',
        'products': 123,
        'revenue': 38000,
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 12)),
        'onlineUsers': 41,
        'ordersToday': 22,
        'carbonSaved': 9.8,
        'trend': 'up',
        'lastOrder': DateTime.now().subtract(const Duration(minutes: 8)),
        'ownerId': 'admin',
        'description': 'Eco-friendly technology solutions.',
      },
    ];
  }

  // Getter for all stores
  List<Map<String, dynamic>> get allStores => _allStores;

  // Get stores by owner
  List<Map<String, dynamic>> getStoresByOwner(String ownerId) {
    return _allStores.where((store) => store['ownerId'] == ownerId).toList();
  }

  // Get active stores
  List<Map<String, dynamic>> get activeStores {
    return _allStores.where((store) => store['status'] == 'Active').toList();
  }

  // Get total stores count
  int get totalStores => _allStores.length;

  // Get active stores count
  int get activeStoresCount => activeStores.length;

  // Add new store
  void addStore(Map<String, dynamic> store) {
    store['id'] = '${_allStores.length + 1}';
    store['lastUpdated'] = DateTime.now();
    store['performance'] = 0.5 + (Random().nextDouble() * 0.4);
    store['rating'] = 3.5 + (Random().nextDouble() * 1.5);
    store['products'] = 50 + Random().nextInt(200);
    store['revenue'] = 10000 + Random().nextInt(50000);
    store['onlineUsers'] = 10 + Random().nextInt(50);
    store['ordersToday'] = 5 + Random().nextInt(20);
    store['carbonSaved'] = 2.0 + (Random().nextDouble() * 10.0);
    store['trend'] = ['up', 'stable', 'down'][Random().nextInt(3)];
    store['lastOrder'] = DateTime.now().subtract(Duration(minutes: Random().nextInt(30)));
    
    _allStores.add(store);
    notifyListeners();
  }

  // Update store
  void updateStore(String storeId, Map<String, dynamic> updatedData) {
    final index = _allStores.indexWhere((store) => store['id'] == storeId);
    if (index != -1) {
      _allStores[index].addAll(updatedData);
      _allStores[index]['lastUpdated'] = DateTime.now();
      notifyListeners();
    }
  }

  // Delete store
  void deleteStore(String storeId) {
    _allStores.removeWhere((store) => store['id'] == storeId);
    notifyListeners();
  }

  // Toggle store status
  void toggleStoreStatus(String storeId) {
    final index = _allStores.indexWhere((store) => store['id'] == storeId);
    if (index != -1) {
      _allStores[index]['status'] = _allStores[index]['status'] == 'Active' ? 'Inactive' : 'Active';
      _allStores[index]['lastUpdated'] = DateTime.now();
      notifyListeners();
    }
  }

  // Get store by ID
  Map<String, dynamic>? getStoreById(String storeId) {
    try {
      return _allStores.firstWhere((store) => store['id'] == storeId);
    } catch (e) {
      return null;
    }
  }

  // Get stores by category
  List<Map<String, dynamic>> getStoresByCategory(String category) {
    return _allStores.where((store) => store['category'] == category).toList();
  }

  // Get stores by status
  List<Map<String, dynamic>> getStoresByStatus(String status) {
    return _allStores.where((store) => store['status'] == status).toList();
  }

  // Search stores by name
  List<Map<String, dynamic>> searchStores(String query) {
    return _allStores.where((store) => 
      store['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
      store['category'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

