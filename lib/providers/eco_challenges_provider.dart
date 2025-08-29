import 'package:flutter/material.dart';
import 'dart:math';

class EcoChallenge {
  final String id;
  final String title;
  final String description;
  final String reward;
  final Color color;
  final IconData icon;
  final int targetValue;
  final String targetUnit;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final bool isActive;
  final bool isCompleted;
  final int currentProgress;
  final double progressPercentage;

  EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.color,
    required this.icon,
    required this.targetValue,
    required this.targetUnit,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.isActive = true,
    this.isCompleted = false,
    this.currentProgress = 0,
    this.progressPercentage = 0.0,
  });

  EcoChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? reward,
    Color? color,
    IconData? icon,
    int? targetValue,
    String? targetUnit,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool? isActive,
    bool? isCompleted,
    int? currentProgress,
    double? progressPercentage,
  }) {
    return EcoChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      currentProgress: currentProgress ?? this.currentProgress,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

class EcoChallengesProvider extends ChangeNotifier {
  static EcoChallengesProvider? _instance;
  
  factory EcoChallengesProvider() {
    _instance ??= EcoChallengesProvider._internal();
    return _instance!;
  }
  
  EcoChallengesProvider._internal() {
    print('EcoChallengesProvider initialized');
    _initializeChallenges();
  }

  final List<EcoChallenge> _challenges = [];
  final Map<String, int> _userProgress = {};
  int _totalEcoPoints = 0;

  List<EcoChallenge> get activeChallenges => _challenges.where((c) => c.isActive && !c.isCompleted).toList();
  List<EcoChallenge> get completedChallenges => _challenges.where((c) => c.isCompleted).toList();
  List<EcoChallenge> get allChallenges => List.from(_challenges);
  int get totalEcoPoints => _totalEcoPoints;

  void _initializeChallenges() {
    print('Initializing challenges...');
    final now = DateTime.now();
    
    _challenges.clear(); // Clear existing challenges first
    _challenges.addAll([
      EcoChallenge(
        id: 'zero_waste_week',
        title: 'Zero Waste Week',
        description: 'Go 7 days without producing any waste. Use reusable containers, avoid single-use plastics, and compost organic waste.',
        reward: '500 Eco Points',
        color: const Color(0xFFB5C7F7),
        icon: Icons.recycling_rounded,
        targetValue: 7,
        targetUnit: 'days',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        category: 'Waste Reduction',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'carbon_footprint_reduction',
        title: 'Carbon Footprint Reduction',
        description: 'Reduce your daily carbon footprint by 20%. Walk or cycle instead of driving, use public transport, and choose eco-friendly products.',
        reward: '300 Eco Points',
        color: const Color(0xFFF9E79F),
        icon: Icons.eco_rounded,
        targetValue: 20,
        targetUnit: '% reduction',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        category: 'Carbon Reduction',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'local_shopping',
        title: 'Local Shopping Spree',
        description: 'Buy from 5 local eco-friendly stores. Support local businesses and reduce transportation emissions.',
        reward: '200 Eco Points',
        color: const Color(0xFFE8D5C4),
        icon: Icons.store_rounded,
        targetValue: 5,
        targetUnit: 'stores',
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        category: 'Local Support',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'water_conservation',
        title: 'Water Conservation',
        description: 'Save 1000 liters of water this month. Take shorter showers, fix leaks, and use water-efficient appliances.',
        reward: '400 Eco Points',
        color: Colors.cyan,
        icon: Icons.water_drop_rounded,
        targetValue: 1000,
        targetUnit: 'liters',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        category: 'Water Conservation',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'energy_saving',
        title: 'Energy Saving Champion',
        description: 'Reduce energy consumption by 15%. Switch to LED bulbs, unplug devices, and use natural light.',
        reward: '350 Eco Points',
        color: Colors.orange,
        icon: Icons.electric_bolt_rounded,
        targetValue: 15,
        targetUnit: '% reduction',
        startDate: now,
        endDate: now.add(const Duration(days: 21)),
        category: 'Energy Conservation',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'plant_based_meals',
        title: 'Plant-Based Meals',
        description: 'Eat 10 plant-based meals this week. Reduce meat consumption and try delicious vegetarian recipes.',
        reward: '250 Eco Points',
        color: Colors.green,
        icon: Icons.restaurant_rounded,
        targetValue: 10,
        targetUnit: 'meals',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        category: 'Diet & Nutrition',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'plastic_free_living',
        title: 'Plastic-Free Living',
        description: 'Go 14 days without using single-use plastics. Use reusable bags, bottles, and containers.',
        reward: '600 Eco Points',
        color: const Color(0xFFD6EAF8),
        icon: Icons.no_drinks_rounded,
        targetValue: 14,
        targetUnit: 'days',
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        category: 'Plastic Reduction',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
      EcoChallenge(
        id: 'eco_transport',
        title: 'Eco Transportation',
        description: 'Use eco-friendly transportation for 20 trips. Walk, cycle, carpool, or use public transport.',
        reward: '450 Eco Points',
        color: const Color(0xFFE8F5E8),
        icon: Icons.directions_bike_rounded,
        targetValue: 20,
        targetUnit: 'trips',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        category: 'Transportation',
        currentProgress: 0,
        progressPercentage: 0.0,
      ),
    ]);
    print('Challenges initialized: ${_challenges.length}');
    notifyListeners(); // Notify listeners after initialization
  }

  void updateProgress(String challengeId, int progress) {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _challenges[challengeIndex];
      final newProgress = (challenge.currentProgress + progress).clamp(0, challenge.targetValue);
      final progressPercentage = (newProgress / challenge.targetValue).clamp(0.0, 1.0);
      final isCompleted = newProgress >= challenge.targetValue;

      _challenges[challengeIndex] = challenge.copyWith(
        currentProgress: newProgress,
        progressPercentage: progressPercentage,
        isCompleted: isCompleted,
      );

      if (isCompleted && !challenge.isCompleted) {
        _awardPoints(challenge);
      }

      notifyListeners();
    }
  }

  void _awardPoints(EcoChallenge challenge) {
    final points = int.parse(challenge.reward.split(' ')[0]);
    _totalEcoPoints += points;
    notifyListeners();
  }

  void resetChallenge(String challengeId) {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
        currentProgress: 0,
        progressPercentage: 0.0,
        isCompleted: false,
      );
      notifyListeners();
    }
  }

  void addCustomChallenge(EcoChallenge challenge) {
    print('Adding custom challenge: ${challenge.title}');
    _challenges.add(challenge);
    print('Total challenges now: ${_challenges.length}');
    print('Active challenges: ${activeChallenges.length}');
    notifyListeners();
  }

  void deleteChallenge(String challengeId) {
    print('Deleting challenge: $challengeId');
    _challenges.removeWhere((challenge) => challenge.id == challengeId);
    print('Total challenges now: ${_challenges.length}');
    print('Active challenges: ${activeChallenges.length}');
    notifyListeners();
  }

  List<EcoChallenge> getChallengesByCategory(String category) {
    return _challenges.where((c) => c.category == category).toList();
  }

  List<String> get categories {
    return _challenges.map((c) => c.category).toSet().toList();
  }

  int getCompletedChallengesCount() {
    return completedChallenges.length;
  }

  int getActiveChallengesCount() {
    return activeChallenges.length;
  }

  double getOverallProgress() {
    if (_challenges.isEmpty) return 0.0;
    final totalProgress = _challenges.fold(0.0, (sum, challenge) => sum + challenge.progressPercentage);
    return totalProgress / _challenges.length;
  }

  // Simulate daily progress updates
  void simulateDailyProgress() {
    for (final challenge in activeChallenges) {
      if (Random().nextDouble() < 0.3) { // 30% chance of progress
        final progress = Random().nextInt(3) + 1; // 1-3 progress points
        updateProgress(challenge.id, progress);
      }
    }
  }

  // Load sample progress for demonstration
  void loadSampleProgress() {
    updateProgress('zero_waste_week', 4);
    updateProgress('carbon_footprint_reduction', 12);
    updateProgress('local_shopping', 2);
    updateProgress('water_conservation', 350);
    updateProgress('energy_saving', 8);
    updateProgress('plant_based_meals', 6);
    updateProgress('plastic_free_living', 8);
    updateProgress('eco_transport', 12);
  }

  // Force initialize challenges (for debugging)
  void forceInitialize() {
    if (_challenges.isEmpty) {
      print('Force initializing challenges...');
      _initializeChallenges();
      print('Challenges initialized: ${_challenges.length}');
    }
  }
}
