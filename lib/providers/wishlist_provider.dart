import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  static final WishlistProvider _instance = WishlistProvider._internal();
  factory WishlistProvider() => _instance;
  WishlistProvider._internal();

  final Map<String, Map<String, dynamic>> _wishlistItems = {};

  // Get all wishlist items
  List<Map<String, dynamic>> get wishlistItems => _wishlistItems.values.toList();

  // Get wishlist count
  int get wishlistCount => _wishlistItems.length;

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistItems.containsKey(productId);
  }

  // Add item to wishlist
  void addToWishlist(Map<String, dynamic> product) {
    final productId = product['id'];
    if (!_wishlistItems.containsKey(productId)) {
      _wishlistItems[productId] = {
        'id': productId,
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'icon': product['icon'],
        'color': product['color'],
        'category': product['category'],
        'carbonFootprint': product['carbonFootprint'],
        'material': product['material'],
        'quantity': product['quantity'],
        'addedAt': DateTime.now(),
      };
      notifyListeners();
    }
  }

  // Remove item from wishlist
  void removeFromWishlist(String productId) {
    if (_wishlistItems.containsKey(productId)) {
      _wishlistItems.remove(productId);
      notifyListeners();
    }
  }

  // Clear all wishlist items
  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }

  // Get wishlist items by category
  List<Map<String, dynamic>> getWishlistItemsByCategory(String category) {
    return _wishlistItems.values
        .where((item) => item['category'] == category)
        .toList();
  }

  // Search wishlist items
  List<Map<String, dynamic>> searchWishlistItems(String query) {
    return _wishlistItems.values
        .where((item) =>
            item['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            item['description'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add sample items for testing (remove this in production)
  void addSampleItems() {
    if (_wishlistItems.isEmpty) {
      addToWishlist({
        'id': 'sample1',
        'name': 'Bamboo Water Bottle',
        'description': 'Sustainable bamboo water bottle, perfect for daily use',
        'price': 29.90,
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFFF9E79F),
        'category': 'Accessories',
        'carbonFootprint': 1.8,
        'material': 'Bamboo',
        'quantity': 120,
      });
      
      addToWishlist({
        'id': 'sample2',
        'name': 'Organic Cotton Tote',
        'description': 'Reusable shopping bag made from organic cotton',
        'price': 24.90,
        'icon': Icons.shopping_bag_rounded,
        'color': const Color(0xFFE8D5C4),
        'category': 'Accessories',
        'carbonFootprint': 1.2,
        'material': 'Organic Cotton',
        'quantity': 200,
      });
      
      addToWishlist({
        'id': 'sample3',
        'name': 'Solar Phone Charger',
        'description': 'Portable solar charger for eco-friendly charging',
        'price': 89.90,
        'icon': Icons.solar_power_rounded,
        'color': const Color(0xFFD6EAF8),
        'category': 'Electronics',
        'carbonFootprint': 2.5,
        'material': 'Recycled Plastic',
        'quantity': 45,
      });
    }
  }
}
