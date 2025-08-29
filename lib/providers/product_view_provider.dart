import 'package:flutter/material.dart';
import 'dart:math';

class ProductView {
  final String productId;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String category;
  final IconData icon;
  final Color color;
  final DateTime viewedAt;

  ProductView({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.icon,
    required this.color,
    required this.viewedAt,
  });
}

class ProductViewProvider extends ChangeNotifier {
  static final ProductViewProvider _instance = ProductViewProvider._internal();
  factory ProductViewProvider() => _instance;
  ProductViewProvider._internal();

  final List<ProductView> _viewedProducts = [];
  final Map<String, int> _categoryViewCounts = {};

  List<ProductView> get viewedProducts => List.from(_viewedProducts.reversed);
  
  int get totalProductsViewed => _viewedProducts.length;
  
  Map<String, int> get categoryViewCounts => Map.from(_categoryViewCounts);

  void addProductView(Map<String, dynamic> product) {
    // Check if product already exists in viewed list
    final existingIndex = _viewedProducts.indexWhere((view) => view.productId == product['id']);
    
    if (existingIndex != -1) {
      // Remove existing entry to add it at the top (most recent)
      _viewedProducts.removeAt(existingIndex);
    }

    // Add new product view at the beginning
    _viewedProducts.insert(0, ProductView(
      productId: product['id'],
      name: product['name'],
      description: product['description'],
      price: product['price'].toDouble(),
      rating: 4.0 + (Random().nextDouble() * 1.0), // Random rating between 4.0-5.0
      category: product['category'],
      icon: product['icon'],
      color: product['color'],
      viewedAt: DateTime.now(),
    ));

    // Update category view count
    _categoryViewCounts[product['category']] = (_categoryViewCounts[product['category']] ?? 0) + 1;

    // Keep only last 20 viewed products
    if (_viewedProducts.length > 20) {
      _viewedProducts.removeLast();
    }

    notifyListeners();
  }

  List<ProductView> getRecentlyViewed(int count) {
    return _viewedProducts.take(count).toList();
  }

  List<ProductView> getViewedProductsByCategory(String category) {
    return _viewedProducts.where((view) => view.category == category).toList();
  }

  void clearViewedProducts() {
    _viewedProducts.clear();
    _categoryViewCounts.clear();
    notifyListeners();
  }

  // Get top viewed categories
  List<MapEntry<String, int>> get topViewedCategories {
    final sortedCategories = _categoryViewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedCategories.take(4).toList();
  }

  // Get products viewed today
  List<ProductView> get productsViewedToday {
    final today = DateTime.now();
    return _viewedProducts.where((view) => 
      view.viewedAt.year == today.year &&
      view.viewedAt.month == today.month &&
      view.viewedAt.day == today.day
    ).toList();
  }

  int get productsViewedTodayCount => productsViewedToday.length;
}
