import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class EcoChallengesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _challengesCollection = _firestore.collection('eco_challenges');
  static final CollectionReference _userChallengesCollection = _firestore.collection('user_challenges');
  static final CollectionReference _userProgressCollection = _firestore.collection('user_progress');

  // Generate unique challenge ID
  static String _generateChallengeId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'CHL_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$random';
  }

  // Create new eco challenge
  static Future<Map<String, dynamic>> createChallenge({
    required String title,
    required String description,
    required String category,
    required int targetValue,
    required String targetUnit,
    required int rewardPoints,
    required String icon,
    required Color color,
    required int duration,
    String? difficulty,
  }) async {
    try {
      final challengeId = _generateChallengeId();
      final now = DateTime.now();

      final challengeData = {
        'id': challengeId,
        'title': title,
        'description': description,
        'category': category,
        'targetValue': targetValue,
        'targetUnit': targetUnit,
        'rewardPoints': rewardPoints,
        'icon': icon,
        'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
        'duration': duration,
        'difficulty': difficulty ?? 'medium',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _challengesCollection.doc(challengeId).set(challengeData);

      return {
        'success': true,
        'challengeId': challengeId,
        'message': 'Challenge created successfully!',
        'challengeData': challengeData,
      };
    } catch (e) {
      print('Error creating challenge: $e');
      return {
        'success': false,
        'message': 'Failed to create challenge: ${e.toString()}',
      };
    }
  }

  // Get all active challenges
  static Future<List<Map<String, dynamic>>> getAllChallenges() async {
    try {
      final snapshot = await _challengesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final challenges = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      return challenges;
    } catch (e) {
      print('Error getting challenges: $e');
      return [];
    }
  }

  // Get challenges by category
  static Future<List<Map<String, dynamic>>> getChallengesByCategory(String category) async {
    try {
      final snapshot = await _challengesCollection
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();

      final challenges = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      return challenges;
    } catch (e) {
      print('Error getting challenges by category: $e');
      return [];
    }
  }

  // Get user's active challenges
  static Future<List<Map<String, dynamic>>> getUserChallenges(String userId) async {
    try {
      final snapshot = await _userChallengesCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('startedAt', descending: true)
          .get();

      final userChallenges = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      // Get challenge details for each user challenge
      final detailedChallenges = <Map<String, dynamic>>[];
      for (var userChallenge in userChallenges) {
        final challengeDoc = await _challengesCollection.doc(userChallenge['challengeId']).get();
        if (challengeDoc.exists) {
          final challengeData = challengeDoc.data() as Map<String, dynamic>;
          detailedChallenges.add({
            ...userChallenge,
            'challengeDetails': challengeData,
          });
        }
      }

      return detailedChallenges;
    } catch (e) {
      print('Error getting user challenges: $e');
      return [];
    }
  }

  // Start a challenge for user
  static Future<Map<String, dynamic>> startChallenge({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final now = DateTime.now();
      final challengeDoc = await _challengesCollection.doc(challengeId).get();
      
      if (!challengeDoc.exists) {
        return {
          'success': false,
          'message': 'Challenge not found!',
        };
      }

      final challengeData = challengeDoc.data() as Map<String, dynamic>;
      final duration = challengeData['duration'] ?? 7;
      final endDate = now.add(Duration(days: duration));

      final userChallengeData = {
        'userId': userId,
        'challengeId': challengeId,
        'startedAt': now,
        'endDate': endDate,
        'currentProgress': 0,
        'targetValue': challengeData['targetValue'],
        'targetUnit': challengeData['targetUnit'],
        'rewardPoints': challengeData['rewardPoints'],
        'isCompleted': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _userChallengesCollection.add(userChallengeData);

      return {
        'success': true,
        'message': 'Challenge started successfully!',
        'userChallengeData': userChallengeData,
      };
    } catch (e) {
      print('Error starting challenge: $e');
      return {
        'success': false,
        'message': 'Failed to start challenge: ${e.toString()}',
      };
    }
  }

  // Update user's challenge progress
  static Future<Map<String, dynamic>> updateChallengeProgress({
    required String userId,
    required String challengeId,
    required int progress,
  }) async {
    try {
      // Find user challenge
      final userChallengeSnapshot = await _userChallengesCollection
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .where('isActive', isEqualTo: true)
          .get();

      if (userChallengeSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Challenge not found for user!',
        };
      }

      final userChallengeDoc = userChallengeSnapshot.docs.first;
      final userChallengeData = userChallengeDoc.data() as Map<String, dynamic>;
      final currentProgress = userChallengeData['currentProgress'] ?? 0;
      final targetValue = userChallengeData['targetValue'] ?? 1;
      final newProgress = currentProgress + progress;
      final isCompleted = newProgress >= targetValue;

      // Update user challenge progress
      await userChallengeDoc.reference.update({
        'currentProgress': newProgress,
        'isCompleted': isCompleted,
        'isActive': !isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Record progress update
      await _userProgressCollection.add({
        'userId': userId,
        'challengeId': challengeId,
        'progress': progress,
        'totalProgress': newProgress,
        'isCompleted': isCompleted,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': isCompleted 
            ? 'Challenge completed! You earned ${userChallengeData['rewardPoints']} Eco Points!' 
            : 'Progress updated successfully!',
        'newProgress': newProgress,
        'isCompleted': isCompleted,
        'rewardPoints': isCompleted ? userChallengeData['rewardPoints'] : 0,
      };
    } catch (e) {
      print('Error updating challenge progress: $e');
      return {
        'success': false,
        'message': 'Failed to update progress: ${e.toString()}',
      };
    }
  }

  // Get user's challenge statistics
  static Future<Map<String, dynamic>> getUserChallengeStats(String userId) async {
    try {
      final userChallengesSnapshot = await _userChallengesCollection
          .where('userId', isEqualTo: userId)
          .get();

      final userChallenges = userChallengesSnapshot.docs;
      
      int totalChallenges = userChallenges.length;
      int completedChallenges = 0;
      int totalEcoPoints = 0;
      int activeChallenges = 0;

             for (var doc in userChallenges) {
         final data = doc.data() as Map<String, dynamic>;
         if (data['isCompleted'] == true) {
           completedChallenges++;
           totalEcoPoints += (data['rewardPoints'] ?? 0) as int;
         }
         if (data['isActive'] == true) {
           activeChallenges++;
         }
       }

      return {
        'totalChallenges': totalChallenges,
        'completedChallenges': completedChallenges,
        'activeChallenges': activeChallenges,
        'totalEcoPoints': totalEcoPoints,
        'completionRate': totalChallenges > 0 ? (completedChallenges / totalChallenges) * 100 : 0.0,
      };
    } catch (e) {
      print('Error getting user challenge stats: $e');
      return {
        'totalChallenges': 0,
        'completedChallenges': 0,
        'activeChallenges': 0,
        'totalEcoPoints': 0,
        'completionRate': 0.0,
      };
    }
  }

  // Delete challenge
  static Future<Map<String, dynamic>> deleteChallenge(String challengeId) async {
    try {
      await _challengesCollection.doc(challengeId).delete();
      
      return {
        'success': true,
        'message': 'Challenge deleted successfully!',
      };
    } catch (e) {
      print('Error deleting challenge: $e');
      return {
        'success': false,
        'message': 'Failed to delete challenge: ${e.toString()}',
      };
    }
  }

  // Initialize sample challenges
  static Future<void> initializeSampleChallenges() async {
    try {
      final snapshot = await _challengesCollection.get();
      if (snapshot.docs.isNotEmpty) {
        print('Challenges already exist, skipping initialization');
        return;
      }

      final sampleChallenges = [
        {
          'title': 'Zero Waste Week',
          'description': 'Go 7 days without producing any waste. Use reusable containers, avoid single-use plastics, and compost organic waste.',
          'category': 'Waste Reduction',
          'targetValue': 7,
          'targetUnit': 'days',
          'rewardPoints': 500,
          'icon': 'recycling_rounded',
          'color': '#B5C7F7',
          'duration': 7,
          'difficulty': 'hard',
        },
        {
          'title': 'Carbon Footprint Reduction',
          'description': 'Reduce your daily carbon footprint by 20%. Walk or cycle instead of driving, use public transport, and conserve energy.',
          'category': 'Transportation',
          'targetValue': 20,
          'targetUnit': '% reduction',
          'rewardPoints': 300,
          'icon': 'eco_rounded',
          'color': '#F9E79F',
          'duration': 14,
          'difficulty': 'medium',
        },
        {
          'title': 'Local Shopping Spree',
          'description': 'Buy from 5 local eco-friendly stores. Support local businesses and reduce transportation emissions.',
          'category': 'Shopping',
          'targetValue': 5,
          'targetUnit': 'stores',
          'rewardPoints': 200,
          'icon': 'store_rounded',
          'color': '#E8D5C4',
          'duration': 30,
          'difficulty': 'easy',
        },
        {
          'title': 'Plant-Based Meals',
          'description': 'Eat 10 plant-based meals this week. Reduce meat consumption and try delicious vegetarian recipes.',
          'category': 'Diet & Nutrition',
          'targetValue': 10,
          'targetUnit': 'meals',
          'rewardPoints': 250,
          'icon': 'restaurant_rounded',
          'color': '#D6EAF8',
          'duration': 7,
          'difficulty': 'medium',
        },
        {
          'title': 'Plastic-Free Living',
          'description': 'Go 14 days without using single-use plastics. Use reusable bags, bottles, and containers.',
          'category': 'Plastic Reduction',
          'targetValue': 14,
          'targetUnit': 'days',
          'rewardPoints': 600,
          'icon': 'local_drink_rounded',
          'color': '#B5C7F7',
          'duration': 14,
          'difficulty': 'hard',
        },
        {
          'title': 'Eco Transportation',
          'description': 'Use eco-friendly transportation for 20 trips. Walk, cycle, carpool, or use public transport.',
          'category': 'Transportation',
          'targetValue': 20,
          'targetUnit': 'trips',
          'rewardPoints': 450,
          'icon': 'directions_bike_rounded',
          'color': '#D6EAF8',
          'duration': 30,
          'difficulty': 'medium',
        },
      ];

             for (var challenge in sampleChallenges) {
         await createChallenge(
           title: challenge['title'] as String,
           description: challenge['description'] as String,
           category: challenge['category'] as String,
           targetValue: challenge['targetValue'] as int,
           targetUnit: challenge['targetUnit'] as String,
           rewardPoints: challenge['rewardPoints'] as int,
           icon: challenge['icon'] as String,
           color: _parseColor(challenge['color'] as String),
           duration: challenge['duration'] as int,
           difficulty: challenge['difficulty'] as String?,
         );
       }

      print('Sample challenges initialized successfully');
    } catch (e) {
      print('Error initializing sample challenges: $e');
    }
  }

  // Helper method to parse color string to Color object
  static Color _parseColor(String colorString) {
    try {
      String hex = colorString.startsWith('#') ? colorString.substring(1) : colorString;
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return const Color(0xFFB5C7F7);
    } catch (e) {
      return const Color(0xFFB5C7F7);
    }
  }
}
