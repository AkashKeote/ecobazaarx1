import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/spring_auth_provider.dart';
import '../../providers/carbon_tracking_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/product_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Real-time data variables
  Timer? _realTimeTimer;
  int _activeSessions = 347;
  double _systemUptime = 99.8;
  
    // Get real active stores count from centralized store data
  int get _activeStores {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    return storeProvider.getStoresByStatus(true).length;
  }

  // Get total stores count from centralized store data
  int get _totalStores {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    return storeProvider.allStores.length;
  }
  
  // Get real total users count from SpringAuthProvider
  int get _totalUsers => SpringAuthProvider.allUsers.length;
  
  // Get new users registered today
  int get _newUsersToday {
    final today = DateTime.now();
    return SpringAuthProvider.allUsers.where((user) {
      final joinDate = DateTime.parse(user['joinDate']);
      return joinDate.year == today.year && 
             joinDate.month == today.month && 
             joinDate.day == today.day;
    }).length;
  }
  
  // Store Analytics real-time data with enhanced tracking
  // Now using centralized StoreProvider instead of local _stores list
  
  // Real-time store activity feed
  final List<Map<String, dynamic>> _storeActivities = [
    {
      'store': 'GreenMart',
      'action': 'New order received',
      'amount': '₹2,450',
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
      'type': 'order',
    },
    {
      'store': 'EcoShop',
      'action': 'Product inventory updated',
      'amount': '+15 items',
      'time': DateTime.now().subtract(const Duration(minutes: 4)),
      'type': 'inventory',
    },
    {
      'store': 'Green Corner',
      'action': 'Customer review added',
      'amount': '5★ rating',
      'time': DateTime.now().subtract(const Duration(minutes: 6)),
      'type': 'review',
    },
  ];
  
  // Store categories with real-time counts
  final Map<String, int> _storeCategories = {
    'Food & Beverages': 35,
    'Clothing & Fashion': 28,
    'Electronics': 18,
    'Home & Garden': 19,
  };
  
     // User management data - now dynamically loaded from SpringAuthProvider
   List<Map<String, dynamic>> get _users {
     final allUsers = SpringAuthProvider.allUsers;
     return allUsers.map((user) => {
       'id': user['id'],
       'name': user['name'],
       'email': user['email'],
       'role': _getRoleDisplayName(user['role']),
       'status': user['status'],
       'joinDate': user['joinDate'],
     }).toList();
   }
  
  // Filter variables
  String _currentFilter = 'All';
  String _searchQuery = '';
  
  // Recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'New shop registered: GreenMart',
      'time': '2 hours ago',
      'icon': Icons.store_rounded,
      'color': const Color(0xFFB5C7F7),
    },
    {
      'title': 'User completed carbon assessment',
      'time': '4 hours ago',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFFD6EAF8),
    },
    {
      'title': 'New eco-friendly product added',
      'time': '6 hours ago',
      'icon': Icons.add_shopping_cart_rounded,
      'color': const Color(0xFFF9E79F),
    },
    {
      'title': 'Monthly sustainability report generated',
      'time': '1 day ago',
      'icon': Icons.assessment_rounded,
      'color': const Color(0xFFE8D5C4),
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
    
    // Start real-time updates
    _startRealTimeUpdates();
    
    // Load sample carbon data for demonstration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carbonProvider = Provider.of<CarbonTrackingProvider>(context, listen: false);
      carbonProvider.loadSampleData();
    });
    
    // Debug: Print user count
    print('AdminDashboard: Initialized with ${_users.length} users');
    
    // Refresh user data when admin dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // This will trigger a rebuild and refresh the user list
      });
    });
  }
  
  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Update real-time data with realistic increments
          // _totalUsers is now real-time from SpringAuthProvider
          // _activeStores is now real-time from stores data
          _activeSessions += Random().nextInt(10) - 5;
          _systemUptime = 99.8 + (Random().nextDouble() * 0.2);
          
          // Update store analytics in real-time
          _updateStoreAnalytics();
        });
      }
    });
  }
  
  void _updateStoreAnalytics() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    bool hasUpdates = false;
    
    // Update store performance randomly
    for (var store in storeProvider.allStores) {
      // Randomly update performance
      if (Random().nextBool()) {
        store['performance'] = (store['performance'] + (Random().nextDouble() * 0.1 - 0.05)).clamp(0.0, 1.0);
        hasUpdates = true;
      }
      
      // Randomly update revenue
      if (Random().nextBool()) {
        store['revenue'] += Random().nextInt(1000) - 500;
        store['revenue'] = store['revenue'].clamp(0, 100000);
        hasUpdates = true;
      }
      
      // Randomly update products count
      if (Random().nextBool()) {
        store['products'] += Random().nextInt(5) - 2;
        store['products'] = store['products'].clamp(0, 500);
        hasUpdates = true;
      }
      
      // Update online users
      if (Random().nextBool()) {
        store['onlineUsers'] += Random().nextInt(5) - 2;
        store['onlineUsers'] = store['onlineUsers'].clamp(0, 100);
        hasUpdates = true;
      }
      
      // Update orders today
      if (Random().nextBool()) {
        store['ordersToday'] += Random().nextInt(3);
        hasUpdates = true;
      }
      
      // Update carbon saved
      if (Random().nextBool()) {
        store['carbonSaved'] += Random().nextDouble() * 0.5;
        store['carbonSaved'] = store['carbonSaved'].clamp(0.0, 50.0);
        hasUpdates = true;
      }
      
      // Update trend based on performance
      if (store['performance'] > 0.8) {
        store['trend'] = 'up';
      } else if (store['performance'] < 0.6) {
        store['trend'] = 'down';
      } else {
        store['trend'] = 'stable';
      }
      
      // Update last order time
      if (Random().nextBool()) {
        store['lastOrder'] = DateTime.now().subtract(Duration(minutes: Random().nextInt(15)));
        hasUpdates = true;
      }
      
      // Occasionally change store status (very rarely to keep it realistic)
      if (Random().nextDouble() < 0.02) { // 2% chance every 5 seconds
        if (store['status'] == 'Active') {
          store['status'] = 'Inactive';
        } else {
          store['status'] = 'Active';
        }
        hasUpdates = true;
      }
      
      // Update last updated time
      store['lastUpdated'] = DateTime.now();
    }
    
    // Update store categories randomly
    for (var category in _storeCategories.keys) {
      if (Random().nextBool()) {
        _storeCategories[category] = (_storeCategories[category]! + Random().nextInt(3) - 1).clamp(0, 100);
        hasUpdates = true;
      }
    }
    
    // Add new store activities
    _addStoreActivity();
    
    // Occasionally add a new store (very rarely to keep it realistic)
    _addNewStore();
    
    // Notify listeners if there were updates
    if (hasUpdates) {
      // Trigger UI update by calling setState
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  void _addNewStore() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    // Very low probability to add a new store (0.1% chance every 5 seconds)
          if (Random().nextDouble() < 0.001 && storeProvider.allStores.length < 20) {
      List<String> storeNames = [
        'EcoFresh Market',
        'Green Living Store',
        'Sustainable Solutions',
        'Eco-Friendly Corner',
        'Green Tech Hub',
        'Organic Paradise',
        'Eco Essentials',
        'Green Lifestyle',
        'Sustainable Living',
        'Eco Corner',
      ];
      
      List<String> categories = [
        'Food & Beverages',
        'Clothing & Fashion',
        'Electronics',
        'Home & Garden',
        'Personal Care',
      ];
      
      final newStore = {
        'name': storeNames[Random().nextInt(storeNames.length)],
        'category': categories[Random().nextInt(categories.length)],
        'status': 'Active',
        'ownerId': 'admin',
        'description': 'Auto-generated store for analytics.',
      };
      
      storeProvider.addStore(newStore);
      
      // Add store activity for the new store
      _storeActivities.insert(0, {
        'store': newStore['name'],
        'action': 'New store registered',
        'amount': 'Welcome!',
        'time': DateTime.now(),
        'type': 'milestone',
      });
    }
  }
  
  void _addStoreActivity() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    List<String> actions = [
      'New order received',
      'Product inventory updated',
      'Customer review added',
      'Revenue milestone reached',
      'New product added',
      'Store performance improved',
      'Carbon savings milestone',
      'Customer engagement increased',
    ];
    
    List<String> storeNames = storeProvider.allStores.map((store) => store['name'] as String).toList();
    List<String> types = ['order', 'inventory', 'review', 'milestone', 'product', 'performance', 'carbon', 'engagement'];
    
    if (_storeActivities.length < 10) {
      final newActivity = {
        'store': storeNames[Random().nextInt(storeNames.length)],
        'action': actions[Random().nextInt(actions.length)],
        'amount': Random().nextBool() ? '₹${Random().nextInt(5000) + 500}' : '+${Random().nextInt(20) + 1} items',
        'time': DateTime.now(),
        'type': types[Random().nextInt(types.length)],
      };
      
      _storeActivities.insert(0, newActivity);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _realTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D5C4),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8D5C4).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 30,
                        color: Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<SpringAuthProvider>(
                            builder: (context, authProvider, child) {
                              return Text(
                                'Admin Dashboard\nHello, ${authProvider.userName ?? 'Admin'}!',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                  height: 1.2,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final authProvider = Provider.of<SpringAuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5C4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFF22223B),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5C7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Color(0xFF22223B),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _PastelStatCard(
                      title: 'Total Users',
                      value: _totalUsers.toStringAsFixed(0),
                      color: const Color(0xFFB5C7F7),
                      icon: Icons.people_rounded,
                      isLive: true,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Active Stores',
                      value: _activeStores.toStringAsFixed(0),
                      color: const Color(0xFFF9E79F),
                      icon: Icons.store_rounded,
                      isLive: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return _PastelStatCard(
                          title: 'Carbon Saved',
                          value: '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)}kg',
                          color: const Color(0xFFD6EAF8),
                          icon: Icons.eco_rounded,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return _PastelStatCard(
                          title: 'Revenue',
                          value: '₹${(carbonProvider.totalRevenue / 100000).toStringAsFixed(1)}L',
                          color: const Color(0xFFE8D5C4),
                          icon: Icons.currency_rupee_rounded,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Admin Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Admin Controls',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.people_rounded,
                            label: 'Manage Users',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _showUserManagement(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.store_rounded,
                            label: 'Store Analytics',
                            color: const Color(0xFFF9E79F),
                            onTap: () => _showStoreAnalytics(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.add_business_rounded,
                            label: 'Add Store',
                            color: const Color(0xFFE8D5C4),
                            onTap: () => _showAddStoreDialog(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.eco_rounded,
                            label: 'Carbon Reports',
                            color: const Color(0xFFD6EAF8),
                            onTap: () => _showCarbonReports(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Second row of action cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.inventory_rounded,
                            label: 'Manage Products',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _showProductManagement(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.analytics_rounded,
                            label: 'Product Analytics',
                            color: const Color(0xFFF9E79F),
                            onTap: () => _showProductAnalytics(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.category_rounded,
                            label: 'Categories',
                            color: const Color(0xFFE8D5C4),
                            onTap: () => _showCategoryManagement(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.add_box_rounded,
                            label: 'Add Product',
                            color: const Color(0xFFD6EAF8),
                            onTap: () => _showAddProductAdmin(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent Activities Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    Text(
                      'Recent Activities',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showAllActivities(),
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB5C7F7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Recent Activities List
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recentActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return _buildActivityCard(activity);
                  },
                ),
              ),

              const SizedBox(height: 28),

              // System Overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'System Overview',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // System Status Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                      Text(
                        'System Status: Operational',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uptime: ${_systemUptime.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB5C7F7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active Sessions: ${_activeSessions.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: const Color(0xFFF7F6F2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFB5C7F7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Platform Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.settings_rounded,
                        label: 'System Config',
                        color: const Color(0xFFE8D5C4),
                        onTap: () => _showSystemSettings(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.security_rounded,
                        label: 'Security',
                        color: const Color(0xFFD6EAF8),
                        onTap: () => _showSecuritySettings(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.backup_rounded,
                        label: 'Backup',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showBackupSettings(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage EcoBazaarX platform and monitor sustainability metrics',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '1,247',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Shops',
                  '89',
                  Icons.store,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Carbon Saved (kg)',
                  '2,847',
                  Icons.eco,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Products Listed',
                  '5,632',
                  Icons.inventory,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 16),
          _buildActivityItem(
            'New shop registered: GreenMart',
            '2 hours ago',
            Icons.store,
          ),
          _buildActivityItem(
            'User completed carbon footprint assessment',
            '4 hours ago',
            Icons.eco,
          ),
          _buildActivityItem(
            'New eco-friendly product added',
            '6 hours ago',
            Icons.add_shopping_cart,
          ),
          _buildActivityItem(
            'Monthly sustainability report generated',
            '1 day ago',
            Icons.assessment,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('User Management'),
          const SizedBox(height: 16),

          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User List
          _buildUserCard(
            'John Doe',
            'john@example.com',
            'Customer',
            'Active',
            Colors.green,
          ),
          _buildUserCard(
            'Jane Smith',
            'jane@example.com',
            'Shopkeeper',
            'Active',
            Colors.green,
          ),
          _buildUserCard(
            'Bob Wilson',
            'bob@example.com',
            'Customer',
            'Inactive',
            Colors.red,
          ),
          _buildUserCard(
            'Alice Brown',
            'alice@example.com',
            'Admin',
            'Active',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildCarbonFootprintTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Carbon Footprint Analytics'),
          const SizedBox(height: 16),

          // Carbon Savings Overview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Carbon Saved',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Icon(Icons.eco, color: Colors.green.shade600, size: 32),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '2,847 kg CO₂',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Equivalent to planting 142 trees',
                  style: TextStyle(color: Colors.green.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Breakdown
          _buildSectionTitle('Carbon Savings by Category'),
          const SizedBox(height: 16),
          _buildCategoryCard(
            'Food & Beverages',
            '45%',
            '1,281 kg',
            Colors.orange,
          ),
          _buildCategoryCard(
            'Clothing & Fashion',
            '28%',
            '797 kg',
            Colors.purple,
          ),
          _buildCategoryCard('Electronics', '15%', '427 kg', Colors.blue),
          _buildCategoryCard('Home & Garden', '12%', '342 kg', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Platform Settings'),
          const SizedBox(height: 16),

          _buildSettingItem(
            'Carbon Calculation Algorithm',
            'Configure how carbon footprint is calculated',
            Icons.calculate,
            () {},
          ),
          _buildSettingItem(
            'Sustainability Thresholds',
            'Set minimum sustainability requirements',
            Icons.trending_up,
            () {},
          ),
          _buildSettingItem(
            'User Verification',
            'Manage user verification processes',
            Icons.verified_user,
            () {},
          ),
          _buildSettingItem(
            'Data Export',
            'Export platform data and reports',
            Icons.download,
            () {},
          ),
          _buildSettingItem(
            'System Maintenance',
            'Schedule maintenance and updates',
            Icons.build,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    String name,
    String email,
    String role,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String category,
    String percentage,
    String savings,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  savings,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

    // Enhanced Admin action methods
  void _showUserManagement(BuildContext context) {
    // Refresh user data before showing management
    setState(() {
      // This will refresh the user list
    });
    print('AdminDashboard: Opening user management with ${_users.length} users');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'User Management',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                                         // User Statistics Cards
                     Column(
                       children: [
                         _buildUserManagementCard('Total Users', '${_getFilteredUsers().length}', Icons.people_rounded, const Color(0xFFB5C7F7), isLive: true),
                         const SizedBox(height: 12),
                         _buildUserManagementCard('Active Users', '${_getFilteredUsers().where((user) => user['status'] == 'Active').length}', Icons.person_rounded, const Color(0xFFD6EAF8), isLive: true),
                         const SizedBox(height: 12),
                         _buildUserManagementCard('New Users (Today)', '$_newUsersToday', Icons.person_add_rounded, const Color(0xFFF9E79F), isLive: true),
                         const SizedBox(height: 12),
                         _buildUserManagementCard('Premium Users', '${(_totalUsers * 0.15).round()}', Icons.star_rounded, const Color(0xFFE8D5C4), isLive: true),
                       ],
                     ),
                    const SizedBox(height: 24),
                    
                    // Search and Filter Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search & Filter',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                                                     TextField(
                             controller: TextEditingController(text: _searchQuery),
                             onChanged: (value) {
                               setState(() {
                                 _searchQuery = value;
                               });
                             },
                             decoration: InputDecoration(
                               hintText: 'Search users by name, email, or role...',
                               prefixIcon: const Icon(Icons.search_rounded),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               filled: true,
                               fillColor: const Color(0xFFF7F6F2),
                             ),
                           ),
                                                     const SizedBox(height: 16),
                           Column(
                             children: [
                               Row(
                                 children: [
                                   Expanded(
                                     child: ElevatedButton.icon(
                                       onPressed: () => _showUserFilterDialog(context),
                                       icon: const Icon(Icons.filter_list_rounded),
                                       label: Text('Filter', style: GoogleFonts.poppins()),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: const Color(0xFFB5C7F7),
                                         foregroundColor: const Color(0xFF22223B),
                                       ),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: ElevatedButton.icon(
                                       onPressed: () => _showAddUserDialog(context),
                                       icon: const Icon(Icons.person_add_rounded),
                                       label: Text('Add User', style: GoogleFonts.poppins()),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: const Color(0xFFF9E79F),
                                         foregroundColor: const Color(0xFF22223B),
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                               if (_currentFilter != 'All' || _searchQuery.isNotEmpty) ...[
                                 const SizedBox(height: 8),
                                 SizedBox(
                                   width: double.infinity,
                                   child: ElevatedButton.icon(
                                     onPressed: () {
                                       setState(() {
                                         _currentFilter = 'All';
                                         _searchQuery = '';
                                       });
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(content: Text('Filters cleared', style: GoogleFonts.poppins())),
                                       );
                                     },
                                     icon: const Icon(Icons.clear_rounded),
                                     label: Text('Clear Filters', style: GoogleFonts.poppins()),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.red[400],
                                       foregroundColor: Colors.white,
                                     ),
                                   ),
                                 ),
                               ],
                             ],
                           ),
                        ],
                      ),
                    ),
                                         const SizedBox(height: 24),
                     
                     // User List Section
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.1),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Text(
                                 'Recent Users',
                                 style: GoogleFonts.poppins(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFF22223B),
                                 ),
                               ),
                               const Spacer(),
                               TextButton(
                                 onPressed: () => _showAllUsersDialog(context),
                                 child: Text(
                                   'View All',
                                   style: GoogleFonts.poppins(
                                     color: const Color(0xFFB5C7F7),
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                                                      const SizedBox(height: 16),
                           if (_users.isEmpty)
                             Container(
                               padding: const EdgeInsets.all(20),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFF7F6F2),
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Colors.grey.withOpacity(0.2)),
                               ),
                               child: Center(
                                 child: Column(
                                   children: [
                                     Icon(
                                       Icons.people_outline_rounded,
                                       size: 48,
                                       color: Colors.grey[400],
                                     ),
                                     const SizedBox(height: 12),
                                     Text(
                                       'No users found',
                                       style: GoogleFonts.poppins(
                                         fontSize: 16,
                                         color: Colors.grey[600],
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                     const SizedBox(height: 8),
                                     Text(
                                       'Add your first user using the "Add User" button above',
                                       style: GoogleFonts.poppins(
                                         fontSize: 12,
                                         color: Colors.grey[500],
                                       ),
                                       textAlign: TextAlign.center,
                                     ),
                                   ],
                                 ),
                               ),
                             )
                                                      else
                              ..._getFilteredUsers().reversed.take(4).map((user) => _buildUserListItem(
                                user['name'],
                                user['email'],
                                user['role'],
                                user['status'],
                                user['status'] == 'Active' ? Colors.green : Colors.red,
                              )),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 24),
                     
                     // Customer Dashboard Users Section
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.1),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Icon(Icons.dashboard_rounded, color: const Color(0xFFB5C7F7), size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 'Customer Dashboard Users',
                                 style: GoogleFonts.poppins(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFF22223B),
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFFB5C7F7).withOpacity(0.2),
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: Text(
                                   '${_users.where((user) => user['role'] == 'Customer').length} users',
                                   style: GoogleFonts.poppins(
                                     fontSize: 11,
                                     color: const Color(0xFF22223B),
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           ..._users.where((user) => user['role'] == 'Customer').take(3).map((user) => _buildUserListItem(
                             user['name'],
                             user['email'],
                             user['role'],
                             user['status'],
                             user['status'] == 'Active' ? Colors.green : Colors.red,
                           )),
                           if (_users.where((user) => user['role'] == 'Customer').length > 3)
                             Padding(
                               padding: const EdgeInsets.only(top: 12),
                               child: Center(
                                 child: TextButton(
                                   onPressed: () => _showCustomerUsersDialog(context),
                                   child: Text(
                                     'View All Customer Users',
                                     style: GoogleFonts.poppins(
                                       color: const Color(0xFFB5C7F7),
                                       fontWeight: FontWeight.bold,
                                       fontSize: 12,
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                         ],
                       ),
                     ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showExportDialog(context),
                            icon: const Icon(Icons.download_rounded),
                            label: Text('Export Data', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5C7F7),
                              foregroundColor: const Color(0xFF22223B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showUserAnalyticsDialog(context),
                            icon: const Icon(Icons.analytics_rounded),
                            label: Text('Analytics', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9E79F),
                              foregroundColor: const Color(0xFF22223B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



    void _showStoreManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer<StoreProvider>(
                                    builder: (context, storeProvider, child) {
                          print('Admin Consumer rebuilding - Total stores: ${storeProvider.allStores.length}');
                          print('All stores: ${storeProvider.allStores.map((s) => s['name']).join(', ')}');
                          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F6F2),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Store Management',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {}); // Force rebuild
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        color: Colors.grey[600],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Store Statistics
                        Row(
                          children: [
                            Expanded(
                              child: _buildStoreManagementCard('Total Stores', '${storeProvider.allStores.length}', Icons.store_rounded, const Color(0xFFB5C7F7)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStoreManagementCard('Active Stores', '${storeProvider.getStoresByStatus(true).length}', Icons.storefront_rounded, const Color(0xFFD6EAF8)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddStoreDialog(context),
                                icon: const Icon(Icons.add_business_rounded),
                                label: Text('Add Store', style: GoogleFonts.poppins()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB5C7F7),
                                  foregroundColor: const Color(0xFF22223B),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showManageStoresDialog(context),
                                icon: const Icon(Icons.manage_accounts_rounded),
                                label: Text('Manage Stores', style: GoogleFonts.poppins()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6EAF8),
                                  foregroundColor: const Color(0xFF22223B),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Filter Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showStoreFilterDialog(context),
                            icon: const Icon(Icons.filter_list_rounded),
                            label: Text('Filter Stores', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9E79F),
                              foregroundColor: const Color(0xFF22223B),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Debug section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Info',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Stores: ${storeProvider.allStores.length}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                'Store Names: ${storeProvider.allStores.map((s) => s['name']).join(', ')}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  print('Admin debug button pressed!');
                                  print('Current store count before adding: ${storeProvider.allStores.length}');
                                  print('All stores before: ${storeProvider.allStores.map((s) => s['name']).join(', ')}');
                                  
                                  final newStore = {
                                    'name': 'Debug Store ${DateTime.now().millisecondsSinceEpoch}',
                                    'category': 'Test',
                                    'status': 'Active',
                                    'ownerId': 'admin',
                                    'description': 'Debug store',
                                  };
                                  
                                  storeProvider.addStore(newStore);
                                  
                                                                      print('Store count after adding: ${storeProvider.allStores.length}');
                                  print('All stores after: ${storeProvider.allStores.map((s) => s['name']).join(', ')}');
                                  
                                  setState(() {}); // Force rebuild
                                },
                                child: const Text('Add Debug Store'),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Store List
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Stores',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...storeProvider.allStores.map((store) {
                                print('Building store item: ${store['name']}');
                                return _buildStoreManagementItem(store, context);
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStoreAnalytics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Store Analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Real-time',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _updateStoreAnalytics();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Store analytics refreshed!', style: GoogleFonts.poppins()),
                          backgroundColor: const Color(0xFFB5C7F7),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    color: const Color(0xFFB5C7F7),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                                         // Store Statistics Cards
                     Column(
                       children: [
                         _buildStoreStatCard('Total Stores', '$_totalStores', Icons.store_rounded, const Color(0xFFB5C7F7)),
                         const SizedBox(height: 12),
                         _buildStoreStatCard('Active Stores', '$_activeStores', Icons.storefront_rounded, const Color(0xFFD6EAF8)),
                         const SizedBox(height: 12),
                         Consumer<StoreProvider>(
                           builder: (context, storeProvider, child) {
                             final totalProducts = storeProvider.allStores.fold<int>(0, (sum, store) => sum + ((store['products'] as num?) ?? 0).toInt());
                             return _buildStoreStatCard('Total Products', '$totalProducts', Icons.inventory_rounded, const Color(0xFFF9E79F));
                           },
                         ),
                         const SizedBox(height: 12),
                         Consumer<StoreProvider>(
                           builder: (context, storeProvider, child) {
                             if (storeProvider.allStores.isEmpty) {
                               return _buildStoreStatCard('Avg. Rating', '0.0★', Icons.star_rounded, const Color(0xFFE8D5C4));
                             }
                             final totalRating = storeProvider.allStores.fold<double>(0.0, (sum, store) => sum + ((store['rating'] as num?) ?? 0.0).toDouble());
                             final avgRating = totalRating / storeProvider.allStores.length;
                             return _buildStoreStatCard('Avg. Rating', '${avgRating.toStringAsFixed(1)}★', Icons.star_rounded, const Color(0xFFE8D5C4));
                           },
                         ),
                       ],
                     ),
                    const SizedBox(height: 24),
                    
                    // Real-time Store Performance Chart
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                        children: [
                          Text(
                                'Live Store Performance',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                              ),
                              const Spacer(),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Live',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                                                     Consumer<StoreProvider>(
                             builder: (context, storeProvider, child) {
                               return Column(
                                 children: storeProvider.allStores.map((store) => Column(
                                   children: [
                                    _buildEnhancedStorePerformanceBar(store),
                                     const SizedBox(height: 12),
                                   ],
                                 )).toList(),
                               );
                             },
                           ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Store Categories
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Categories',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                                                     ..._storeCategories.entries.map((entry) => _buildCategoryItem(entry.key, entry.value, _getCategoryColor(entry.key))),
                        ],
                      ),
                                         ),
                     const SizedBox(height: 24),
                     
                     // Real-time Store Activity Feed
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.1),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Text(
                                 'Live Store Activity Feed',
                                 style: GoogleFonts.poppins(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFF22223B),
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 width: 8,
                                 height: 8,
                                 decoration: const BoxDecoration(
                                   color: Colors.green,
                                   shape: BoxShape.circle,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Text(
                                 'Live',
                                 style: GoogleFonts.poppins(
                                   fontSize: 12,
                                   color: Colors.green,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           ..._storeActivities.take(5).map((activity) => _buildStoreActivityItem(activity)),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Real-time Store Alerts
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.1),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Text(
                                 'Live Store Alerts',
                                 style: GoogleFonts.poppins(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFF22223B),
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 width: 8,
                                 height: 8,
                                 decoration: const BoxDecoration(
                                   color: Colors.red,
                                   shape: BoxShape.circle,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Text(
                                 'Live',
                                 style: GoogleFonts.poppins(
                                   fontSize: 12,
                                   color: Colors.red,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           _buildStoreAlerts(),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Enhanced Real-time Store Management
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.grey.withOpacity(0.1),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Text(
                                 'Real-time Store Metrics',
                                 style: GoogleFonts.poppins(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFF22223B),
                                 ),
                               ),
                               const Spacer(),
                               Container(
                                 width: 8,
                                 height: 8,
                                 decoration: const BoxDecoration(
                                   color: Colors.green,
                                   shape: BoxShape.circle,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Text(
                                 'Live',
                                 style: GoogleFonts.poppins(
                                   fontSize: 12,
                                   color: Colors.green,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           Consumer<StoreProvider>(
                             builder: (context, storeProvider, child) {
                               return Column(
                                 children: storeProvider.allStores.take(3).map((store) => _buildEnhancedRealTimeStoreItem(store)).toList(),
                               );
                             },
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Action Buttons
                     Column(
                       children: [
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             onPressed: () => _showStoreReportDialog(context),
                             icon: const Icon(Icons.assessment_rounded),
                             label: Text('Generate Report', style: GoogleFonts.poppins()),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFFB5C7F7),
                               foregroundColor: const Color(0xFF22223B),
                             ),
                           ),
                         ),
                         const SizedBox(height: 12),
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             onPressed: () => _showAddStoreDialog(context),
                             icon: const Icon(Icons.add_business_rounded),
                             label: Text('Add Store', style: GoogleFonts.poppins()),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFFF9E79F),
                               foregroundColor: const Color(0xFF22223B),
                             ),
                           ),
                         ),
                       ],
                     ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarbonReports(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Carbon Reports',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Carbon Statistics Cards
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        final stats = carbonProvider.environmentalImpactStats;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCarbonStatCard('Total Carbon Saved', '${stats['totalCarbonSaved'].toStringAsFixed(1)}kg', Icons.eco_rounded, const Color(0xFF4CAF50)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCarbonStatCard('This Month', '${stats['monthlyCarbonSaved'].toStringAsFixed(2)}kg', Icons.calendar_month_rounded, const Color(0xFF2196F3)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCarbonStatCard('Trees Equivalent', '${stats['treesEquivalent'].round()}', Icons.park_rounded, const Color(0xFF8BC34A)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCarbonStatCard('CO₂ Reduction', '${(stats['totalCarbonSaved'] * 1000).round()}kg', Icons.trending_down_rounded, const Color(0xFF00BCD4)),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Carbon Impact Visualization
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carbon Impact by Category',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<CarbonTrackingProvider>(
                            builder: (context, carbonProvider, child) {
                              final categoryData = carbonProvider.currentMonthCarbonByCategory;
                              final totalCarbon = categoryData.values.fold(0.0, (sum, carbon) => sum + carbon);
                              
                              if (categoryData.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      'No carbon data available for this month',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: categoryData.entries.map((entry) {
                                  final percentage = totalCarbon > 0 ? entry.value / totalCarbon : 0.0;
                                  final color = _getCategoryColor(entry.key);
                                  return Column(
                                    children: [
                                      _buildCarbonImpactBar(
                                        entry.key, 
                                        percentage, 
                                        '${entry.value.toStringAsFixed(1)} kg', 
                                        color
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sustainability Goals
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sustainability Goals Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGoalProgress('Carbon Neutral by 2025', 0.68, const Color(0xFF4CAF50)),
                          const SizedBox(height: 12),
                          _buildGoalProgress('100% Eco-friendly Products', 0.85, const Color(0xFF2196F3)),
                          const SizedBox(height: 12),
                          _buildGoalProgress('Zero Waste Initiative', 0.72, const Color(0xFFFF9800)),
                          const SizedBox(height: 12),
                          _buildGoalProgress('Renewable Energy Usage', 0.91, const Color(0xFF9C27B0)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCarbonReportDialog(context),
                            icon: const Icon(Icons.assessment_rounded),
                            label: Text('Generate Report', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCarbonGoalsDialog(context),
                            icon: const Icon(Icons.flag_rounded),
                            label: Text('Set Goals', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening System Settings...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFE8D5C4),
      ),
    );
  }

  // Product Management Methods
  void _showProductManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Manage All Products',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
                              child: _buildAdminProductList(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductAnalytics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Product Analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
                              child: _buildProductAnalytics(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Category Management',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildCategoryManagement(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductAdmin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Add New Product (Admin)',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAddProductForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Security Settings...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD6EAF8),
      ),
    );
  }

  void _showBackupSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Backup Settings...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9E79F),
      ),
    );
  }

  // Helper method to convert UserRole enum to display name
  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.shopkeeper:
        return 'Shopkeeper';
      case UserRole.admin:
        return 'Admin';
    }
  }

  // New helper methods for enhanced functionality
  void _showAllActivities() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'All Activities',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentActivities.length * 3, // Show more activities
                itemBuilder: (context, index) {
                  final activity = _recentActivities[index % _recentActivities.length];
                  return _buildActivityListTile(activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF22223B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity['time'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityListTile(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF22223B),
                  ),
                ),
                Text(
                  activity['time'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementCard(String title, String value, IconData icon, Color color, {bool isLive = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                        ),
                        if (isLive) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // User Management Helper Methods
  List<Map<String, dynamic>> _getFilteredUsers() {
    List<Map<String, dynamic>> filteredUsers = _users;
    
    // Apply role filter
    if (_currentFilter != 'All') {
      filteredUsers = filteredUsers.where((user) => user['role'] == _currentFilter).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final role = user['role'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || 
               email.contains(query) || 
               role.contains(query);
      }).toList();
    }
    
    return filteredUsers;
  }
  
     void _showUserFilterDialog(BuildContext context) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Filter Users', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             ListTile(
               leading: const Icon(Icons.person_rounded),
               title: const Text('All Users'),
               trailing: _currentFilter == 'All' ? const Icon(Icons.check, color: Colors.green) : null,
                               onTap: () {
                  setState(() {
                    _currentFilter = 'All';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Showing all users', style: GoogleFonts.poppins())),
                  );
                },
             ),
                         ListTile(
               leading: const Icon(Icons.admin_panel_settings_rounded),
               title: const Text('Admins Only'),
               trailing: _currentFilter == 'Admin' ? const Icon(Icons.check, color: Colors.green) : null,
                               onTap: () {
                  setState(() {
                    _currentFilter = 'Admin';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Showing admin users', style: GoogleFonts.poppins())),
                  );
                },
             ),
                         ListTile(
               leading: const Icon(Icons.store_rounded),
               title: const Text('Shopkeepers Only'),
               trailing: _currentFilter == 'Shopkeeper' ? const Icon(Icons.check, color: Colors.green) : null,
                               onTap: () {
                  setState(() {
                    _currentFilter = 'Shopkeeper';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Showing shopkeeper users', style: GoogleFonts.poppins())),
                  );
                },
             ),
                         ListTile(
               leading: const Icon(Icons.person_outline_rounded),
               title: const Text('Customers Only'),
               trailing: _currentFilter == 'Customer' ? const Icon(Icons.check, color: Colors.green) : null,
                               onTap: () {
                  setState(() {
                    _currentFilter = 'Customer';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Showing customer users', style: GoogleFonts.poppins())),
                  );
                },
             ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Customer';
    String selectedStatus = 'Active';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              initialValue: selectedRole,
              items: const [
                DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                DropdownMenuItem(value: 'Shopkeeper', child: Text('Shopkeeper')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                selectedRole = value!;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              initialValue: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                // Convert role string to UserRole enum
                UserRole role;
                switch (selectedRole) {
                  case 'Customer':
                    role = UserRole.customer;
                    break;
                  case 'Shopkeeper':
                    role = UserRole.shopkeeper;
                    break;
                  case 'Admin':
                    role = UserRole.admin;
                    break;
                  default:
                    role = UserRole.customer;
                }
                
                // Add user to SpringAuthProvider's static list
                final newUser = {
                  'id': 'user_${SpringAuthProvider.allUsers.length + 1}',
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': role,
                  'status': selectedStatus,
                  'joinDate': DateTime.now().toIso8601String().split('T')[0],
                };
                
                SpringAuthProvider.allUsers.add(newUser);
                
                                                  setState(() {
                  // Refresh the UI
                 });
                 
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('User "${nameController.text}" added successfully!', style: GoogleFonts.poppins()),
                     backgroundColor: Colors.green,
                   ),
                 );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

     void _showAllUsersDialog(BuildContext context) {
     final filteredUsers = _getFilteredUsers();
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('All Users (${filteredUsers.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: SizedBox(
           width: double.maxFinite,
           height: 400,
           child: ListView.builder(
             itemCount: filteredUsers.length,
             itemBuilder: (context, index) {
               final user = filteredUsers[index];
               return Container(
                 margin: const EdgeInsets.only(bottom: 8),
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: const Color(0xFFF7F6F2),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
                 ),
                 child: Row(
                   children: [
                     CircleAvatar(
                       backgroundColor: const Color(0xFFB5C7F7),
                       child: Text(
                         user['name'][0],
                         style: const TextStyle(
                           color: Color(0xFF22223B),
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(user['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                           Text(user['email'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                           Text('${user['role']} • ${user['status']}', 
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700])),
                         ],
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: user['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Text(
                         user['status'],
                         style: GoogleFonts.poppins(
                           color: user['status'] == 'Active' ? Colors.green : Colors.red,
                           fontSize: 11,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ),
                     const SizedBox(width: 8),
                     PopupMenuButton<String>(
                       icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 16),
                       onSelected: (value) {
                         switch (value) {
                           case 'edit':
                             _showEditUserDialog(context, user['name'], user['email'], user['role'], user['status']);
                             break;
                           case 'delete':
                             _showDeleteUserDialog(context, user['name'], user['email']);
                             break;
                           case 'change_role':
                             _showChangeRoleDialog(context, user['name'], user['email'], user['role']);
                             break;
                         }
                       },
                       itemBuilder: (context) => [
                         PopupMenuItem(
                           value: 'edit',
                           child: Row(
                             children: [
                               const Icon(Icons.edit_rounded, size: 14, color: Colors.blue),
                               const SizedBox(width: 6),
                               Text('Edit', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                         PopupMenuItem(
                           value: 'change_role',
                           child: Row(
                             children: [
                               const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.orange),
                               const SizedBox(width: 6),
                               Text('Change Role', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                         PopupMenuItem(
                           value: 'delete',
                           child: Row(
                             children: [
                               const Icon(Icons.delete_rounded, size: 14, color: Colors.red),
                               const SizedBox(width: 6),
                               Text('Delete', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
               );
             },
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Close'),
           ),
         ],
       ),
     );
   }

     Widget _buildUserListItem(String name, String email, String role, String status, Color statusColor) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: const Color(0xFFF7F6F2),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey.withOpacity(0.2)),
       ),
       child: Row(
         children: [
           CircleAvatar(
             backgroundColor: const Color(0xFFB5C7F7),
             child: Text(
               name[0],
               style: const TextStyle(
                 color: Color(0xFF22223B),
                 fontWeight: FontWeight.bold,
               ),
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   name,
                   style: GoogleFonts.poppins(
                     fontWeight: FontWeight.w600,
                     fontSize: 14,
                   ),
                 ),
                 Text(
                   email,
                   style: GoogleFonts.poppins(
                     fontSize: 12,
                     color: Colors.grey[600],
                   ),
                 ),
                 Text(
                   role,
                   style: GoogleFonts.poppins(
                     fontSize: 11,
                     color: Colors.grey[700],
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ],
             ),
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: statusColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Text(
               status,
               style: GoogleFonts.poppins(
                 color: statusColor,
                 fontSize: 11,
                 fontWeight: FontWeight.w500,
               ),
             ),
           ),
           const SizedBox(width: 8),
           PopupMenuButton<String>(
             icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
             onSelected: (value) {
               switch (value) {
                 case 'edit':
                   _showEditUserDialog(context, name, email, role, status);
                   break;
                 case 'delete':
                   _showDeleteUserDialog(context, name, email);
                   break;
                 case 'change_role':
                   _showChangeRoleDialog(context, name, email, role);
                   break;
               }
             },
             itemBuilder: (context) => [
               PopupMenuItem(
                 value: 'edit',
                 child: Row(
                   children: [
                     const Icon(Icons.edit_rounded, size: 16, color: Colors.blue),
                     const SizedBox(width: 8),
                     Text('Edit User', style: GoogleFonts.poppins(fontSize: 12)),
                   ],
                 ),
               ),
               PopupMenuItem(
                 value: 'change_role',
                 child: Row(
                   children: [
                     const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.orange),
                     const SizedBox(width: 8),
                     Text('Change Role', style: GoogleFonts.poppins(fontSize: 12)),
                   ],
                 ),
               ),
               PopupMenuItem(
                 value: 'delete',
                 child: Row(
                   children: [
                     const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                     const SizedBox(width: 8),
                     Text('Delete User', style: GoogleFonts.poppins(fontSize: 12)),
                   ],
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }

     void _showDeleteUserDialog(BuildContext context, String name, String email) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Delete User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Text('Are you sure you want to delete user "$name" ($email)?', style: GoogleFonts.poppins()),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
                                       onPressed: () {
               // Remove user from SpringAuthProvider's static list
               SpringAuthProvider.allUsers.removeWhere((user) => user['email'] == email);
                setState(() {
                 // Refresh the UI
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User "$name" deleted successfully!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              },
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
             child: const Text('Delete', style: TextStyle(color: Colors.white)),
           ),
         ],
       ),
     );
   }

   void _showEditUserDialog(BuildContext context, String name, String email, String role, String status) {
     final nameController = TextEditingController(text: name);
     final emailController = TextEditingController(text: email);
     String selectedRole = role;
     String selectedStatus = status;

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             TextField(
               controller: nameController,
               decoration: const InputDecoration(
                 labelText: 'Full Name',
                 border: OutlineInputBorder(),
               ),
             ),
             const SizedBox(height: 16),
             TextField(
               controller: emailController,
               decoration: const InputDecoration(
                 labelText: 'Email',
                 border: OutlineInputBorder(),
               ),
             ),
             const SizedBox(height: 16),
             DropdownButtonFormField<String>(
               decoration: const InputDecoration(
                 labelText: 'Role',
                 border: OutlineInputBorder(),
               ),
               initialValue: selectedRole,
               items: const [
                 DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                 DropdownMenuItem(value: 'Shopkeeper', child: Text('Shopkeeper')),
                 DropdownMenuItem(value: 'Admin', child: Text('Admin')),
               ],
               onChanged: (value) {
                 selectedRole = value!;
               },
             ),
             const SizedBox(height: 16),
             DropdownButtonFormField<String>(
               decoration: const InputDecoration(
                 labelText: 'Status',
                 border: OutlineInputBorder(),
               ),
               initialValue: selectedStatus,
               items: const [
                 DropdownMenuItem(value: 'Active', child: Text('Active')),
                 DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
               ],
               onChanged: (value) {
                 selectedStatus = value!;
               },
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () {
               if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                 // Convert role string to UserRole enum
                 UserRole role;
                 switch (selectedRole) {
                   case 'Customer':
                     role = UserRole.customer;
                     break;
                   case 'Shopkeeper':
                     role = UserRole.shopkeeper;
                     break;
                   case 'Admin':
                     role = UserRole.admin;
                     break;
                   default:
                     role = UserRole.customer;
                 }
                 
                 // Update user in SpringAuthProvider's static list
                 final userIndex = SpringAuthProvider.allUsers.indexWhere((user) => user['email'] == email);
                   if (userIndex != -1) {
                   SpringAuthProvider.allUsers[userIndex]['name'] = nameController.text;
                   SpringAuthProvider.allUsers[userIndex]['email'] = emailController.text;
                   SpringAuthProvider.allUsers[userIndex]['role'] = role;
                   SpringAuthProvider.allUsers[userIndex]['status'] = selectedStatus;
                 }
                 
                 setState(() {
                   // Refresh the UI
                 });
                 
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('User "${nameController.text}" updated successfully!', style: GoogleFonts.poppins()),
                     backgroundColor: Colors.green,
                   ),
                 );
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('Please fill all fields!', style: GoogleFonts.poppins()),
                     backgroundColor: Colors.red,
                   ),
                 );
               }
             },
             child: const Text('Update User'),
           ),
         ],
       ),
     );
   }

   void _showChangeRoleDialog(BuildContext context, String name, String email, String currentRole) {
     String selectedRole = currentRole;

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Change User Role', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text(
               'Change role for user "$name"',
               style: GoogleFonts.poppins(),
             ),
             const SizedBox(height: 16),
             DropdownButtonFormField<String>(
               decoration: const InputDecoration(
                 labelText: 'New Role',
                 border: OutlineInputBorder(),
               ),
               initialValue: selectedRole,
               items: const [
                 DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                 DropdownMenuItem(value: 'Shopkeeper', child: Text('Shopkeeper')),
                 DropdownMenuItem(value: 'Admin', child: Text('Admin')),
               ],
               onChanged: (value) {
                 selectedRole = value!;
               },
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () {
               // Convert role string to UserRole enum
               UserRole role;
               switch (selectedRole) {
                 case 'Customer':
                   role = UserRole.customer;
                   break;
                 case 'Shopkeeper':
                   role = UserRole.shopkeeper;
                   break;
                 case 'Admin':
                   role = UserRole.admin;
                   break;
                 default:
                   role = UserRole.customer;
               }
               
               // Update user role in SpringAuthProvider's static list
               final userIndex = SpringAuthProvider.allUsers.indexWhere((user) => user['email'] == email);
                 if (userIndex != -1) {
                 SpringAuthProvider.allUsers[userIndex]['role'] = role;
                 }
               
               setState(() {
                 // Refresh the UI
               });
               
               Navigator.pop(context);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('Role changed to $selectedRole for "$name"', style: GoogleFonts.poppins()),
                   backgroundColor: Colors.blue,
                 ),
               );
             },
             child: const Text('Change Role'),
           ),
         ],
       ),
          );
   }

   void _showCustomerUsersDialog(BuildContext context) {
     final customerUsers = _users.where((user) => user['role'] == 'Customer').toList();
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Customer Dashboard Users (${customerUsers.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: SizedBox(
           width: double.maxFinite,
           height: 400,
           child: ListView.builder(
             itemCount: customerUsers.length,
             itemBuilder: (context, index) {
               final user = customerUsers[index];
               return Container(
                 margin: const EdgeInsets.only(bottom: 8),
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: const Color(0xFFF7F6F2),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
                 ),
                 child: Row(
                   children: [
                     CircleAvatar(
                       backgroundColor: const Color(0xFFB5C7F7),
                       child: Text(
                         user['name'][0],
                         style: const TextStyle(
                           color: Color(0xFF22223B),
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(user['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                           Text(user['email'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                           Text('Customer • ${user['status']}', 
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700])),
                         ],
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: user['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Text(
                         user['status'],
                         style: GoogleFonts.poppins(
                           color: user['status'] == 'Active' ? Colors.green : Colors.red,
                           fontSize: 11,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ),
                     const SizedBox(width: 8),
                     PopupMenuButton<String>(
                       icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 16),
                       onSelected: (value) {
                         switch (value) {
                           case 'edit':
                             _showEditUserDialog(context, user['name'], user['email'], user['role'], user['status']);
                             break;
                           case 'change_role':
                             _showChangeRoleDialog(context, user['name'], user['email'], user['role']);
                             break;
                           case 'delete':
                             _showDeleteUserDialog(context, user['name'], user['email']);
                             break;
                         }
                       },
                       itemBuilder: (context) => [
                         PopupMenuItem(
                           value: 'edit',
                           child: Row(
                             children: [
                               const Icon(Icons.edit_rounded, size: 14, color: Colors.blue),
                               const SizedBox(width: 6),
                               Text('Edit', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                         PopupMenuItem(
                           value: 'change_role',
                           child: Row(
                             children: [
                               const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.orange),
                               const SizedBox(width: 6),
                               Text('Change Role', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                         PopupMenuItem(
                           value: 'delete',
                           child: Row(
                             children: [
                               const Icon(Icons.delete_rounded, size: 14, color: Colors.red),
                               const SizedBox(width: 6),
                               Text('Delete', style: GoogleFonts.poppins(fontSize: 11)),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
               );
             },
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Close'),
           ),
         ],
       ),
     );
   }

   void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export User Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download_rounded),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User data exported as CSV', style: GoogleFonts.poppins())),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_rounded),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User data exported as PDF', style: GoogleFonts.poppins())),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserAnalyticsDialog(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticsItem('Total Users', '${filteredUsers.length}'),
            _buildAnalyticsItem('Active Users', '${filteredUsers.where((user) => user['status'] == 'Active').length}'),
            _buildAnalyticsItem('Inactive Users', '${filteredUsers.where((user) => user['status'] == 'Inactive').length}'),
            _buildAnalyticsItem('Customers', '${filteredUsers.where((user) => user['role'] == 'Customer').length}'),
            _buildAnalyticsItem('Shopkeepers', '${filteredUsers.where((user) => user['role'] == 'Shopkeeper').length}'),
            _buildAnalyticsItem('Admins', '${filteredUsers.where((user) => user['role'] == 'Admin').length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins()),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Store Analytics Helper Methods
  Widget _buildStoreStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStorePerformanceBar(Map<String, dynamic> store) {
    // Add null safety for all store fields
    final performance = (store['performance'] as double?) ?? 0.0;
    final category = store['category'] as String? ?? 'Other';
    final color = _getCategoryColor(category);
    final name = store['name'] as String? ?? 'Unknown Store';
    final trend = store['trend'] as String? ?? 'flat';
    final revenue = store['revenue'] as num? ?? 0;
    final products = store['products'] as num? ?? 0;
    final onlineUsers = store['onlineUsers'] as num? ?? 0;
    
    IconData getTrendIcon(String trend) {
      switch (trend) {
        case 'up':
          return Icons.trending_up_rounded;
        case 'down':
          return Icons.trending_down_rounded;
        default:
          return Icons.trending_flat_rounded;
      }
    }
    
    Color getTrendColor(String trend) {
      switch (trend) {
        case 'up':
          return Colors.green;
        case 'down':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    getTrendIcon(trend),
                    color: getTrendColor(trend),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(performance * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Edit Store Button
                  GestureDetector(
                    onTap: () => _showEditStoreDialogAnalytics(store),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5C7F7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFFB5C7F7),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete Store Button
                  GestureDetector(
                    onTap: () => _showDeleteStoreDialogAnalytics(store),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: performance,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue: ₹${revenue.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Products: $products',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Online: $onlineUsers',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

     Widget _buildStorePerformanceBar(Map<String, dynamic> store) {
     // Add null safety for all store fields
     final performance = (store['performance'] as double?) ?? 0.0;
     final category = store['category'] as String? ?? 'Other';
     final color = _getCategoryColor(category);
     final name = store['name'] as String? ?? 'Unknown Store';
     final lastUpdated = store['lastUpdated'] as DateTime? ?? DateTime.now();
     final timeAgo = _getTimeAgo(lastUpdated);
     final products = store['products'] as num? ?? 0;
     final revenue = store['revenue'] as num? ?? 0;
     final rating = store['rating'] as num? ?? 0.0;
     
     return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: color.withOpacity(0.3)),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       name,
                       style: GoogleFonts.poppins(
                         fontWeight: FontWeight.w600,
                         fontSize: 14,
                       ),
                     ),
                     Text(
                       category,
                       style: GoogleFonts.poppins(
                         fontSize: 12,
                         color: Colors.grey[600],
                       ),
                     ),
                   ],
                 ),
               ),
               Row(
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         '${(performance * 100).round()}%',
                         style: GoogleFonts.poppins(
                           fontWeight: FontWeight.bold,
                           color: color,
                           fontSize: 16,
                         ),
                       ),
                       Text(
                         'Updated $timeAgo',
                         style: GoogleFonts.poppins(
                           fontSize: 10,
                           color: Colors.grey[500],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(width: 12),
                   // Edit Store Button
                   GestureDetector(
                     onTap: () => _showEditStoreDialogAnalytics(store),
                     child: Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: const Color(0xFFB5C7F7).withOpacity(0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Icon(
                         Icons.edit_outlined,
                         color: const Color(0xFFB5C7F7),
                         size: 16,
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   // Delete Store Button
                   GestureDetector(
                     onTap: () => _showDeleteStoreDialogAnalytics(store),
                     child: Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: Colors.red.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Icon(
                         Icons.delete_outline_rounded,
                         color: Colors.red,
                         size: 16,
                       ),
                     ),
                   ),
                 ],
               ),
             ],
           ),
           const SizedBox(height: 8),
           LinearProgressIndicator(
             value: performance,
             backgroundColor: color.withOpacity(0.2),
             valueColor: AlwaysStoppedAnimation<Color>(color),
           ),
           const SizedBox(height: 8),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 'Products: $products',
                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
               ),
               Text(
                 'Revenue: ₹${revenue.toStringAsFixed(0)}',
                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
               ),
               Text(
                 'Rating: $rating★',
                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
               ),
             ],
           ),
         ],
       ),
     );
   }
   
   Widget _buildPerformanceBar(String storeName, double performance, Color color) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               storeName,
               style: GoogleFonts.poppins(
                 fontWeight: FontWeight.w600,
                 fontSize: 14,
               ),
             ),
             Text(
               '${(performance * 100).round()}%',
               style: GoogleFonts.poppins(
                 fontWeight: FontWeight.bold,
                 color: color,
               ),
             ),
           ],
         ),
         const SizedBox(height: 8),
         LinearProgressIndicator(
           value: performance,
           backgroundColor: color.withOpacity(0.2),
           valueColor: AlwaysStoppedAnimation<Color>(color),
         ),
       ],
     );
   }
   
   Color _getCategoryColor(String category) {
     switch (category) {
       case 'Food & Beverages':
         return const Color(0xFF4CAF50);
       case 'Clothing & Fashion':
         return const Color(0xFF2196F3);
       case 'Electronics':
         return const Color(0xFFFF9800);
       case 'Home & Garden':
         return const Color(0xFF9C27B0);
       default:
         return const Color(0xFF607D8B);
     }
   }
   
   String _getTimeAgo(DateTime dateTime) {
     final now = DateTime.now();
     final difference = now.difference(dateTime);
     
     if (difference.inMinutes < 1) {
       return 'Just now';
     } else if (difference.inMinutes < 60) {
       return '${difference.inMinutes}m ago';
     } else if (difference.inHours < 24) {
       return '${difference.inHours}h ago';
     } else {
       return '${difference.inDays}d ago';
     }
   }
   
  Widget _buildStoreActivityItem(Map<String, dynamic> activity) {
    IconData getActivityIcon(String type) {
      switch (type) {
        case 'order':
          return Icons.shopping_cart_rounded;
        case 'inventory':
          return Icons.inventory_rounded;
        case 'review':
          return Icons.star_rounded;
        case 'milestone':
          return Icons.emoji_events_rounded;
        case 'product':
          return Icons.add_shopping_cart_rounded;
        case 'performance':
          return Icons.trending_up_rounded;
        case 'carbon':
          return Icons.eco_rounded;
        case 'engagement':
          return Icons.people_rounded;
        default:
          return Icons.notifications_rounded;
      }
    }
    
    Color getActivityColor(String type) {
      switch (type) {
        case 'order':
          return Colors.green;
        case 'inventory':
          return const Color(0xFFB5C7F7);
        case 'review':
          return Colors.amber;
        case 'milestone':
          return const Color(0xFFF9E79F);
        case 'product':
          return const Color(0xFFD6EAF8);
        case 'performance':
          return Colors.blue;
        case 'carbon':
          return Colors.teal;
        case 'engagement':
          return const Color(0xFFE8D5C4);
        default:
          return Colors.grey;
      }
    }
    
    String getTimeAgo(DateTime time) {
      final difference = DateTime.now().difference(time);
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getActivityColor(activity['type']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              getActivityIcon(activity['type']),
              color: getActivityColor(activity['type']),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['store'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  activity['action'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  getTimeAgo(activity['time']),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getActivityColor(activity['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activity['amount'],
              style: TextStyle(
                color: getActivityColor(activity['type']),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRealTimeStoreItem(Map<String, dynamic> store) {
    IconData getTrendIcon(String trend) {
      switch (trend) {
        case 'up':
          return Icons.trending_up_rounded;
        case 'down':
          return Icons.trending_down_rounded;
        default:
          return Icons.trending_flat_rounded;
      }
    }
    
    Color getTrendColor(String trend) {
      switch (trend) {
        case 'up':
          return Colors.green;
        case 'down':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }
    
    String getTimeAgo(DateTime time) {
      final difference = DateTime.now().difference(time);
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB5C7F7),
                child: Text(
                  store['name'][0],
                  style: const TextStyle(
                    color: Color(0xFF22223B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      store['category'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                getTrendIcon(store['trend']),
                color: getTrendColor(store['trend']),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem('Performance', '${(store['performance'] * 100).toStringAsFixed(1)}%', Icons.speed_rounded),
              ),
              Expanded(
                child: _buildMetricItem('Revenue', '₹${store['revenue'].toStringAsFixed(0)}', Icons.attach_money_rounded),
              ),
              Expanded(
                child: _buildMetricItem('Products', '${store['products']}', Icons.inventory_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem('Online', '${store['onlineUsers']}', Icons.people_rounded),
              ),
              Expanded(
                child: _buildMetricItem('Orders', '${store['ordersToday']}', Icons.shopping_cart_rounded),
              ),
              Expanded(
                child: _buildMetricItem('Carbon', '${store['carbonSaved'].toStringAsFixed(1)}kg', Icons.eco_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Last order: ${getTimeAgo(store['lastOrder'])}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  store['status'],
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFB5C7F7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStoreManagementCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreManagementItem(Map<String, dynamic> store, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFB5C7F7),
            child: Text(
              store['name'][0],
              style: const TextStyle(
                color: Color(0xFF22223B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  store['category'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Products: ${store['products']} • Revenue: ₹${store['revenue']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: store['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              store['status'],
              style: TextStyle(
                color: store['status'] == 'Active' ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteStoreDialog(context, store);
                  break;
                case 'toggle_status':
                  _toggleStoreStatus(store);
                  break;
              }
            },
            itemBuilder: (context) => [

              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Toggle Status', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Delete Store', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for enhanced add store dialog
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE8D5C4), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCheckbox(String title, String subtitle, bool value, IconData icon, ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE8D5C4),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFFE8D5C4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22223B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorePreview(String name, String category, String status, String sustainabilityLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, color: const Color(0xFFE8D5C4), size: 20),
              const SizedBox(width: 8),
              Text(
                'Store Preview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE8D5C4),
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF22223B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active' ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.eco_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Sustainability: $sustainabilityLevel',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _showStoreManagementDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer<StoreProvider>(
            builder: (context, storeProvider, child) {
              final allStores = storeProvider.allStores;
              final shopkeeperStores = allStores.where((store) => store['ownerId'] == 'shopkeeper').toList();
              
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F6F2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            'Manage Shopkeeper Stores',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {}); // Force rebuild
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            color: Colors.grey[600],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Store Statistics
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStoreManagementCard(
                              'Total Stores', 
                              '${shopkeeperStores.length}', 
                              Icons.store_rounded, 
                              const Color(0xFFB5C7F7)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStoreManagementCard(
                              'Active Stores', 
                              '${shopkeeperStores.where((s) => s['status'] == 'Active').length}', 
                              Icons.storefront_rounded, 
                              const Color(0xFFD6EAF8)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStoreManagementCard(
                              'Suspended', 
                              '${shopkeeperStores.where((s) => s['status'] == 'Suspended').length}', 
                              Icons.block_rounded, 
                              Colors.orange
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Store List
                    Expanded(
                      child: shopkeeperStores.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_rounded,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Shopkeeper Stores Found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF22223B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Shopkeepers haven\'t created any stores yet.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: shopkeeperStores.length,
                                                             itemBuilder: (context, index) {
                                 final store = shopkeeperStores[index];
                                 return _buildShopkeeperStoreManagementItem(store, setState, context);
                               },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShopkeeperStoreManagementItem(Map<String, dynamic> store, StateSetter setState, BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (store['status']) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Suspended':
        statusColor = Colors.orange;
        statusIcon = Icons.block_rounded;
        break;
      case 'Inactive':
        statusColor = Colors.grey;
        statusIcon = Icons.pause_circle_rounded;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB5C7F7),
                child: Text(
                  store['name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF22223B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      store['category'] ?? 'No Category',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      store['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case 'activate':
                      _activateStore(store);
                      setState(() {});
                      break;
                    case 'suspend':
                      _suspendStore(store);
                      setState(() {});
                      break;
                    case 'deactivate':
                      _deactivateStore(store);
                      setState(() {});
                      break;
                    case 'delete':
                      _showDeleteStoreConfirmation(context, store);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (store['status'] != 'Active')
                    PopupMenuItem(
                      value: 'activate',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Activate Store', style: GoogleFonts.poppins(fontSize: 12)),
                        ],
                      ),
                    ),
                  if (store['status'] != 'Suspended')
                    PopupMenuItem(
                      value: 'suspend',
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('Suspend Store', style: GoogleFonts.poppins(fontSize: 12)),
                        ],
                      ),
                    ),
                  if (store['status'] != 'Inactive')
                    PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          const Icon(Icons.pause_circle_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Deactivate Store', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Delete Store', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ),
            ],
              ),
            ],
          ),
          if (store['description'] != null && store['description'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                store['description'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _activateStore(Map<String, dynamic> store) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.updateStore(store['id'], {'status': 'Active'});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Store "${store['name']}" activated successfully!',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _suspendStore(Map<String, dynamic> store) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.updateStore(store['id'], {'status': 'Suspended'});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Store "${store['name']}" suspended successfully!',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deactivateStore(Map<String, dynamic> store) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.updateStore(store['id'], {'status': 'Inactive'});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.pause_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Store "${store['name']}" deactivated successfully!',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteStoreConfirmation(BuildContext context, Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this store?',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store: ${store['name']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    'Category: ${store['category'] ?? 'No Category'}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Status: ${store['status']}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⚠️ This action cannot be undone. All store data will be permanently deleted.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final storeProvider = Provider.of<StoreProvider>(context, listen: false);
              storeProvider.deleteStore(store['id']);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Store "${store['name']}" deleted successfully!',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.delete_rounded),
            label: Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context) {
    print('Admin Enhanced Add Store Dialog called!');
    
    // Controllers for form fields
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();
    
    // Dropdown selections
    String selectedCategory = 'Food & Beverages';
    String selectedStatus = 'Active';
    String selectedOwnerType = 'Platform';
    String selectedSustainabilityLevel = 'High';
    String selectedVerificationStatus = 'Pending';
    
    // Additional settings
    bool isEcoCertified = false;
    bool hasDelivery = true;
    bool hasPickup = true;
    bool isPremium = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_business_rounded, color: const Color(0xFFE8D5C4), size: 28),
                const SizedBox(width: 12),
                Text('Add New Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
          mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Basic Information Section
                  _buildSectionHeader('Basic Information', Icons.store_rounded),
                  const SizedBox(height: 12),
                  
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                      labelText: 'Store Name *',
                border: OutlineInputBorder(),
                      hintText: 'Enter store name',
                      prefixIcon: Icon(Icons.store_rounded),
              ),
                    textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
                  
                  TextField(
                    controller: descriptionController,
              decoration: const InputDecoration(
                      labelText: 'Store Description',
                border: OutlineInputBorder(),
                      hintText: 'Describe the store and its offerings...',
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category and Status Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_rounded),
              ),
              initialValue: selectedCategory,
              items: const [
                DropdownMenuItem(value: 'Food & Beverages', child: Text('Food & Beverages')),
                DropdownMenuItem(value: 'Clothing & Fashion', child: Text('Clothing & Fashion')),
                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Home & Garden', child: Text('Home & Garden')),
                DropdownMenuItem(value: 'Personal Care', child: Text('Personal Care')),
                            DropdownMenuItem(value: 'Books & Stationery', child: Text('Books & Stationery')),
                            DropdownMenuItem(value: 'Sports & Fitness', child: Text('Sports & Fitness')),
                            DropdownMenuItem(value: 'Automotive', child: Text('Automotive')),
                            DropdownMenuItem(value: 'Health & Wellness', child: Text('Health & Wellness')),
                            DropdownMenuItem(value: 'Education', child: Text('Education')),
              ],
              onChanged: (value) {
                            setState(() {
                selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                             prefixIcon: Icon(Icons.info_rounded),
              ),
              initialValue: selectedStatus,
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
              ],
              onChanged: (value) {
                            setState(() {
                selectedStatus = value!;
                            });
              },
                        ),
            ),
          ],
        ),
                  const SizedBox(height: 24),
                  
                  // Contact Information Section
                  _buildSectionHeader('Contact Information', Icons.contact_phone_rounded),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Store Address',
                      border: OutlineInputBorder(),
                      hintText: 'Enter store address',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            hintText: '+91 98765 43210',
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            hintText: 'store@example.com',
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
          ),
        ],
      ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://www.storewebsite.com',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  
                  // Store Settings Section
                  _buildSectionHeader('Store Settings', Icons.settings_rounded),
                  const SizedBox(height: 12),
                  
                  Row(
          children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                            labelText: 'Owner Type',
                border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          initialValue: selectedOwnerType,
                          items: const [
                            DropdownMenuItem(value: 'Platform', child: Text('Platform Owned')),
                            DropdownMenuItem(value: 'Independent', child: Text('Independent Store')),
                            DropdownMenuItem(value: 'Franchise', child: Text('Franchise')),
                            DropdownMenuItem(value: 'Partner', child: Text('Partner Store')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedOwnerType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                            labelText: 'Sustainability Level',
                border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.eco_rounded),
              ),
                          initialValue: selectedSustainabilityLevel,
              items: const [
                            DropdownMenuItem(value: 'High', child: Text('High')),
                            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'Low', child: Text('Low')),
                            DropdownMenuItem(value: 'Not Rated', child: Text('Not Rated')),
              ],
              onChanged: (value) {
                            setState(() {
                              selectedSustainabilityLevel = value!;
                            });
              },
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 16),
                  
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                      labelText: 'Verification Status',
                border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.verified_rounded),
              ),
                    initialValue: selectedVerificationStatus,
              items: const [
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                      DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                      DropdownMenuItem(value: 'Under Review', child: Text('Under Review')),
              ],
              onChanged: (value) {
                      setState(() {
                        selectedVerificationStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Features Section
                  _buildSectionHeader('Store Features', Icons.featured_play_list_rounded),
                  const SizedBox(height: 12),
                  
                  // Checkboxes for features
                  _buildFeatureCheckbox(
                    'Eco-Certified Store',
                    'Store has eco-friendly certification',
                    isEcoCertified,
                    Icons.eco_rounded,
                    (value) {
                      setState(() {
                        isEcoCertified = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Premium Store',
                    'High-end store with premium features',
                    isPremium,
                    Icons.star_rounded,
                    (value) {
                      setState(() {
                        isPremium = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Home Delivery',
                    'Store offers home delivery service',
                    hasDelivery,
                    Icons.delivery_dining_rounded,
                    (value) {
                      setState(() {
                        hasDelivery = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Pickup Available',
                    'Store offers pickup service',
                    hasPickup,
                    Icons.storefront_rounded,
                    (value) {
                      setState(() {
                        hasPickup = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Store Preview
                  if (nameController.text.isNotEmpty)
                    _buildStorePreview(
                      nameController.text,
                      selectedCategory,
                      selectedStatus,
                      selectedSustainabilityLevel,
                    ),
                ],
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ),
              ElevatedButton.icon(
            onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a store name!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final newStore = {
                    'name': nameController.text.trim(),
                  'category': selectedCategory,
                  'status': selectedStatus,
                    'ownerId': 'admin',
                    'ownerType': selectedOwnerType,
                    'description': descriptionController.text.trim().isNotEmpty 
                        ? descriptionController.text.trim() 
                        : 'A sustainable store offering eco-friendly products.',
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'website': websiteController.text.trim(),
                    'sustainabilityLevel': selectedSustainabilityLevel,
                    'verificationStatus': selectedVerificationStatus,
                    'isEcoCertified': isEcoCertified,
                    'isPremium': isPremium,
                    'hasDelivery': hasDelivery,
                    'hasPickup': hasPickup,
                    'createdAt': DateTime.now().toIso8601String(),
                    'createdBy': 'admin',
                    'rating': 0.0,
                    'totalReviews': 0,
                    'products': 0,
                    'ordersToday': 0,
                    'revenue': 0.0,
                    'carbonSaved': 0.0,
                    'performance': 0.0,
                    'onlineUsers': 0,
                    'lastOrder': DateTime.now(),
                    'lastUpdated': DateTime.now(),
                  };

                  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                  
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Adding store...', style: GoogleFonts.poppins()),
                        ],
                      ),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Add store asynchronously
                  storeProvider.addStore(newStore).then((result) {
                    Navigator.pop(context);
                    
                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['message'] ?? 'Store "${nameController.text.trim()}" added successfully!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['message'] ?? 'Failed to add store!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }).catchError((error) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error adding store: ${error.toString()}',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add_business_rounded),
                label: Text('Add Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8D5C4),
                  foregroundColor: const Color(0xFF22223B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  void _showDeleteStoreDialog(BuildContext context, Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete store "${store['name']}"?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                final result = await storeProvider.deleteStore(store['id']);
                
                Navigator.pop(context);
                
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Store "${store['name']}" deleted successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete store!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting store: ${e.toString()}', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditStoreDialogAnalytics(Map<String, dynamic> store) {
    final TextEditingController nameController = TextEditingController(text: store['name'] ?? '');
    final TextEditingController descriptionController = TextEditingController(text: store['description'] ?? '');
    final TextEditingController categoryController = TextEditingController(text: store['category'] ?? '');
    final TextEditingController locationController = TextEditingController(text: store['location'] ?? '');
    final TextEditingController ownerNameController = TextEditingController(text: store['ownerName'] ?? '');
    final TextEditingController ownerEmailController = TextEditingController(text: store['ownerEmail'] ?? '');
    final TextEditingController ownerPhoneController = TextEditingController(text: store['ownerPhone'] ?? '');
    final TextEditingController addressController = TextEditingController(text: store['address'] ?? '');
    
    String selectedCategory = store['category'] ?? 'Clothing';
    bool isActive = store['isActive'] ?? true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: const Color(0xFFB5C7F7), size: 28),
              const SizedBox(width: 12),
              Text('Edit Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update store information:',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                
                // Store Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Store Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.store_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: [
                    'Clothing',
                    'Accessories',
                    'Electronics',
                    'Personal Care',
                    'Food & Beverages',
                    'Home & Garden',
                    'Books',
                    'Sports',
                    'Beauty',
                    'Other'
                  ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Location
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Name
                TextField(
                  controller: ownerNameController,
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Email
                TextField(
                  controller: ownerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Owner Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Phone
                TextField(
                  controller: ownerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Owner Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Address
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.home_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Active Status
                Row(
                  children: [
                    Icon(Icons.toggle_on_rounded, color: isActive ? Colors.green : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Store Active',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                      activeThumbColor: const Color(0xFFB5C7F7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                  
                  final updateData = {
                    'name': nameController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'category': selectedCategory,
                    'location': locationController.text.trim(),
                    'ownerName': ownerNameController.text.trim(),
                    'ownerEmail': ownerEmailController.text.trim(),
                    'ownerPhone': ownerPhoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'isActive': isActive,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  
                  final result = await storeProvider.updateStore(store['id'], updateData);
                  
                  Navigator.pop(context);
                  
                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Store "${store['name']}" updated successfully!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    // Refresh the analytics data
                    setState(() {
                      _updateStoreAnalytics();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Failed to update store!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating store: ${e.toString()}', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
              ),
              child: Text('Update Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteStoreDialogAnalytics(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete this store?',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store: ${store['name']}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Category: ${store['category']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Revenue: ₹${store['revenue'].toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⚠️ This action cannot be undone. All store data will be permanently removed from the database.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                final result = await storeProvider.deleteStore(store['id']);
                
                Navigator.pop(context);
                
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Store "${store['name']}" deleted successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  // Refresh the analytics data
                  setState(() {
                    _updateStoreAnalytics();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete store!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting store: ${e.toString()}', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete Permanently', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _toggleStoreStatus(Map<String, dynamic> store) async {
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final result = await storeProvider.toggleStoreStatus(store['id']);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Store "${store['name']}" status updated!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update store status!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating store status: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showManageStoresDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.manage_accounts_rounded, color: const Color(0xFFD6EAF8), size: 28),
            const SizedBox(width: 12),
            Text('Manage Stores', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            if (storeProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (storeProvider.allStores.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No stores found',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first store to get started',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                ],
              );
            }
            
            return SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search stores...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (query) {
                      storeProvider.searchStores(query);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Store list
                  Expanded(
                    child: ListView.builder(
                      itemCount: storeProvider.filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = storeProvider.filteredStores[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFD6EAF8),
                              child: Icon(
                                Icons.store_rounded,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            title: Text(
                              store['name'] ?? 'Unknown Store',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store['category'] ?? 'No Category',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                Text(
                                  'Status: ${store['isActive'] == true ? 'Active' : 'Inactive'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: store['isActive'] == true ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    // TODO: Implement edit store functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Edit functionality coming soon!', style: GoogleFonts.poppins()),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                    break;
                                  case 'toggle':
                                    _toggleStoreStatus(store);
                                    break;
                                  case 'delete':
                                    _showDeleteStoreDialog(context, store);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 16),
                                      const SizedBox(width: 8),
                                      Text('Edit', style: GoogleFonts.poppins()),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        store['isActive'] == true ? Icons.block_rounded : Icons.check_circle_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        store['isActive'] == true ? 'Deactivate' : 'Activate',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showStoreFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Stores', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store_rounded),
              title: const Text('All Stores'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Showing all stores', style: GoogleFonts.poppins())),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_rounded),
              title: const Text('Active Stores Only'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Showing active stores only', style: GoogleFonts.poppins())),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_rounded),
              title: const Text('Inactive Stores Only'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Showing inactive stores only', style: GoogleFonts.poppins())),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreAlerts() {
    // Generate real-time alerts based on store performance
    List<Map<String, dynamic>> alerts = [];
    
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    for (var store in storeProvider.allStores) {
      // Performance alerts
      if (store['performance'] < 0.6) {
        alerts.add({
          'store': store['name'],
          'message': 'Low performance detected',
          'type': 'warning',
          'icon': Icons.warning_rounded,
          'color': Colors.orange,
        });
      }
      
      // Revenue alerts
      if (store['revenue'] < 20000) {
        alerts.add({
          'store': store['name'],
          'message': 'Revenue below threshold',
          'type': 'alert',
          'icon': Icons.attach_money_rounded,
          'color': Colors.red,
        });
      }
      
      // High performance alerts
      if (store['performance'] > 0.9) {
        alerts.add({
          'store': store['name'],
          'message': 'Excellent performance!',
          'type': 'success',
          'icon': Icons.emoji_events_rounded,
          'color': Colors.green,
        });
      }
    }
    
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'All stores performing well!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: alerts.take(3).map((alert) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: alert['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: alert['color'].withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              alert['icon'],
              color: alert['color'],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['store'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    alert['message'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: alert['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alert['type'].toString().toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: alert['color'],
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
   }
   
   Widget _buildRealTimeStoreItem(Map<String, dynamic> store) {
     final lastUpdated = store['lastUpdated'] as DateTime;
     final timeAgo = _getTimeAgo(lastUpdated);
     final color = _getCategoryColor(store['category'] as String);
     
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: const Color(0xFFF7F6F2),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: color.withOpacity(0.3)),
       ),
       child: Row(
         children: [
           Container(
             width: 40,
             height: 40,
             decoration: BoxDecoration(
               color: color.withOpacity(0.2),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(
               Icons.store_rounded,
               color: color,
               size: 20,
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   store['name'] as String,
                   style: GoogleFonts.poppins(
                     fontWeight: FontWeight.w600,
                     fontSize: 14,
                   ),
                 ),
                 Text(
                   '${store['category']} • ${store['products']} products',
                   style: GoogleFonts.poppins(
                     fontSize: 11,
                     color: Colors.grey[600],
                   ),
                 ),
               ],
             ),
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 '₹${(store['revenue'] as int).toStringAsFixed(0)}',
                 style: GoogleFonts.poppins(
                   fontWeight: FontWeight.bold,
                   color: color,
                   fontSize: 12,
                 ),
               ),
               Text(
                 timeAgo,
                 style: GoogleFonts.poppins(
                   fontSize: 10,
                   color: Colors.grey[500],
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }

  Widget _buildCategoryItem(String category, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '$count stores',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Store Report', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Store analytics report will be generated and sent to your email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Store report generated successfully!', style: GoogleFonts.poppins())),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

     void _showStoreApprovalDialog(BuildContext context) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Store Management', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             ListTile(
               leading: const Icon(Icons.add_business_rounded),
               title: const Text('Add New Store'),
               subtitle: const Text('Register a new store'),
               onTap: () {
                 Navigator.pop(context);
                 _showAddStoreDialog(context);
               },
             ),
             ListTile(
               leading: const Icon(Icons.store_rounded),
               title: const Text('GreenMart - Pending'),
               subtitle: const Text('Food & Beverages'),
               trailing: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   IconButton(
                     icon: const Icon(Icons.check, color: Colors.green),
                     onPressed: () {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('GreenMart approved!', style: GoogleFonts.poppins())),
                       );
                     },
                   ),
                   IconButton(
                     icon: const Icon(Icons.close, color: Colors.red),
                     onPressed: () {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('GreenMart rejected', style: GoogleFonts.poppins())),
                       );
                     },
                   ),
                 ],
               ),
             ),
           ],
         ),
       ),
     );
   }
   


  // Carbon Reports Helper Methods
  Widget _buildCarbonStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarbonImpactBar(String category, double impact, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: impact,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildGoalProgress(String goal, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  void _showCarbonReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Carbon Report', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Detailed carbon impact report will be generated and sent to your email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Carbon report generated successfully!', style: GoogleFonts.poppins())),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showCarbonGoalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Carbon Goals', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Target Carbon Reduction (T)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Target Date',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Carbon goals updated successfully!', style: GoogleFonts.poppins())),
              );
            },
            child: const Text('Set Goals'),
          ),
        ],
      ),
    );
  }
}

// Product Management Helper Methods

// Helper method to parse color string to Color object
Color _parseColor(String? colorString) {
  if (colorString == null || colorString.isEmpty) {
    return const Color(0xFFB5C7F7); // Default color
  }
  
  try {
    // Remove # if present
    String hex = colorString.startsWith('#') ? colorString.substring(1) : colorString;
    
    // Handle different hex formats
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    } else {
      return const Color(0xFFB5C7F7); // Default color
    }
  } catch (e) {
    print('Error parsing color: $colorString - $e');
    return const Color(0xFFB5C7F7); // Default color
  }
}

  // Helper method to get icon from string
  IconData _getIconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.shopping_bag_rounded; // Default icon
    }
    
    // Map of string to IconData
    final iconMap = {
      'checkroom_rounded': Icons.checkroom_rounded,
      'water_drop_rounded': Icons.water_drop_rounded,
      'solar_power_rounded': Icons.solar_power_rounded,
      'shopping_bag_rounded': Icons.shopping_bag_rounded,
      'brush_rounded': Icons.brush_rounded,
      'spa_rounded': Icons.spa_rounded,
      'book_rounded': Icons.book_rounded,
      'face_rounded': Icons.face_rounded,
      'fitness_center_rounded': Icons.fitness_center_rounded,
      'local_florist_rounded': Icons.local_florist_rounded,
      'local_cafe_rounded': Icons.local_cafe_rounded,
    };
    
    return iconMap[iconString] ?? Icons.shopping_bag_rounded;
  }

  // Helper method to convert IconData to string
  String _getIconString(IconData icon) {
    // Map of IconData to string
    final iconMap = {
      Icons.checkroom_rounded: 'checkroom_rounded',
      Icons.water_drop_rounded: 'water_drop_rounded',
      Icons.solar_power_rounded: 'solar_power_rounded',
      Icons.shopping_bag_rounded: 'shopping_bag_rounded',
      Icons.brush_rounded: 'brush_rounded',
      Icons.spa_rounded: 'spa_rounded',
      Icons.book_rounded: 'book_rounded',
      Icons.face_rounded: 'face_rounded',
      Icons.fitness_center_rounded: 'fitness_center_rounded',
      Icons.local_florist_rounded: 'local_florist_rounded',
      Icons.local_cafe_rounded: 'local_cafe_rounded',
    };
    
    return iconMap[icon] ?? 'shopping_bag_rounded';
  }

Widget _buildAdminProductList(BuildContext context) {
  final allProducts = Provider.of<ProductProvider>(context, listen: true).allProducts;
  
  if (allProducts.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to get started!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    itemCount: allProducts.length,
    itemBuilder: (context, index) {
      final product = allProducts[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _parseColor(product['color']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconFromString(product['icon']),
                    color: _parseColor(product['color']),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Store: ${product['storeName']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product['price'].toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _parseColor(product['color']),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditProductAdmin(context, product);
                        break;
                      case 'delete':
                        _showDeleteProductDialogAdmin(context, product);
                        break;
                                             case 'toggle':
                         Provider.of<ProductProvider>(context, listen: false).toggleProductStatus(product['id']);
                         Navigator.pop(context);
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Product status updated!', style: GoogleFonts.poppins()),
                             backgroundColor: const Color(0xFFF9E79F),
                           ),
                         );
                         break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: const Color(0xFFB5C7F7)),
                          const SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            product['isActive'] == true ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFF9E79F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product['isActive'] == true ? 'Hide' : 'Show',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Delete', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProductStat(
                    'Stock',
                    '${product['quantity']}',
                    Icons.inventory_rounded,
                    const Color(0xFFB5C7F7),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductStat(
                    'Carbon',
                    '${product['carbonFootprint']} kg',
                    Icons.eco_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductStat(
                    'Status',
                    product['isActive'] == true ? 'Active' : 'Hidden',
                    Icons.circle,
                    product['isActive'] == true ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildProductAnalytics(BuildContext context) {
  final allProducts = Provider.of<ProductProvider>(context, listen: true).allProducts;
  final totalProducts = allProducts.length;
  final activeProducts = allProducts.where((p) => p['isActive'] == true).length;
  final totalValue = allProducts.fold<double>(0, (sum, p) => sum + (p['price'] * p['quantity']));
  
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        // Analytics Cards
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Total Products',
                '$totalProducts',
                Icons.inventory_rounded,
                const Color(0xFFB5C7F7),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnalyticsCard(
                'Active Products',
                '$activeProducts',
                Icons.check_circle_rounded,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Total Value',
                '₹${totalValue.toStringAsFixed(0)}',
                Icons.attach_money_rounded,
                const Color(0xFFF9E79F),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnalyticsCard(
                'Categories',
                '${Provider.of<ProductProvider>(context, listen: false).availableCategories.length}',
                Icons.category_rounded,
                const Color(0xFFE8D5C4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Category Distribution
        Text(
          'Products by Category',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 16),
        ...Provider.of<ProductProvider>(context, listen: false).availableCategories.map((category) {
          final categoryProducts = allProducts.where((p) => p['category'] == category).length;
          final percentage = totalProducts > 0 ? (categoryProducts / totalProducts * 100) : 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$categoryProducts products',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

Widget _buildCategoryManagement() {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text(
              'Available Categories',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 16),
            ...productProvider.availableCategories.map((category) {
              final categoryProducts = productProvider.allProducts.where((p) => p['category'] == category).length;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: InkWell(
                  onTap: () => _showCategoryDetails(context, category, categoryProducts),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        color: const Color(0xFFB5C7F7),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$categoryProducts products',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

Widget _buildAddProductForm() {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  
  String selectedStore = 'admin'; // Admin's store
  
  return StatefulBuilder(
    builder: (context, setState) {
      String selectedCategory = Provider.of<ProductProvider>(context, listen: false).availableCategories.first;
      String selectedMaterial = Provider.of<ProductProvider>(context, listen: false).availableMaterials.first;
      Color selectedColor = Provider.of<ProductProvider>(context, listen: false).availableColors.first;
      IconData selectedIcon = Provider.of<ProductProvider>(context, listen: false).availableIcons.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Product Name
          Text(
            'Product Name *',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter product name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category Selection
          Text(
            'Category *',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              items: Provider.of<ProductProvider>(context, listen: false).availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Price and Quantity Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price (₹) *',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity *',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Material Selection
          Text(
            'Material *',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButtonFormField<String>(
              initialValue: selectedMaterial,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              items: Provider.of<ProductProvider>(context, listen: false).availableMaterials.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: Text(material),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMaterial = value!;
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'Description *',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe your eco-friendly product...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Color and Icon Selection
          Text(
            'Product Appearance',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 12),
          
          // Color Selection
          Text(
            'Choose Color:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: Provider.of<ProductProvider>(context, listen: false).availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Icon Selection
          Text(
            'Choose Icon:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: Provider.of<ProductProvider>(context, listen: false).availableIcons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedIcon == icon ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedIcon == icon ? selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: selectedIcon == icon ? selectedColor : Colors.grey,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 30),
          
          // Add Product Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  
                  // Convert Color to hex string and IconData to string
                  String colorHex = '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}';
                  String iconString = _getIconString(selectedIcon);
                  
                  final newProduct = {
                    'name': nameController.text,
                    'category': selectedCategory,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'material': selectedMaterial,
                    'description': descriptionController.text,
                    'color': colorHex,
                    'icon': iconString,
                    'storeId': selectedStore,
                    'storeName': 'Admin Store',
                  };
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
                        ),
                      );
                    },
                  );

                  try {
                    final result = await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
                    
                    // Hide loading indicator
                    Navigator.pop(context);
                    
                    if (result['success']) {
                      Navigator.pop(context); // Close the add product dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Product "${nameController.text}" added successfully!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to add product!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    // Hide loading indicator
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error adding product: ${e.toString()}',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please fill all required fields!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add Product',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductStat(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF22223B),
        ),
      ),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

void _showEditProductAdmin(BuildContext context, Map<String, dynamic> product) {
  // Controllers with pre-filled values
  final nameController = TextEditingController(text: product['name'] ?? '');
  final priceController = TextEditingController(text: (product['price'] ?? 0.0).toString());
  final quantityController = TextEditingController(text: (product['quantity'] ?? 0).toString());
  final descriptionController = TextEditingController(text: product['description'] ?? '');
  
  // Pre-selected values
  String selectedCategory = product['category'] ?? 'Clothing';
  String selectedMaterial = product['material'] ?? 'Organic Cotton';
  Color selectedColor = _parseColor(product['color']);
  IconData selectedIcon = _getIconFromString(product['icon']);
  String selectedStore = product['storeId'] ?? '1';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Edit Product',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildEditProductForm(
                context,
                nameController,
                priceController,
                quantityController,
                descriptionController,
                selectedCategory,
                selectedMaterial,
                selectedColor,
                selectedIcon,
                selectedStore,
                product,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEditProductForm(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController priceController,
  TextEditingController quantityController,
  TextEditingController descriptionController,
  String selectedCategory,
  String selectedMaterial,
  Color selectedColor,
  IconData selectedIcon,
  String selectedStore,
  Map<String, dynamic> product,
) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            'Product Name:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter product name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Category Selection
          Text(
            'Category:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['Clothing', 'Accessories', 'Electronics', 'Personal Care', 'Home & Garden', 'Food & Beverages']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: GoogleFonts.poppins()),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Price and Quantity Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price (₹):',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Material Selection
          Text(
            'Material:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedMaterial,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              'Organic Cotton',
              'Recycled Polyester',
              'Bamboo',
              'Recycled Plastic',
              'Organic Oils',
              'Recycled Paper',
              'Hemp',
              'Cork',
              'Jute',
              'Ceramic',
            ].map((material) => DropdownMenuItem(
                  value: material,
                  child: Text(material, style: GoogleFonts.poppins()),
                )).toList(),
            onChanged: (value) {
              setState(() {
                selectedMaterial = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Description:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter product description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Store Selection
          Text(
            'Store:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<StoreProvider>(
            builder: (context, storeProvider, child) {
              List<String> storeNames = storeProvider.allStores.map((store) => store['name'] as String).toList();
              return DropdownButtonFormField<String>(
                initialValue: selectedStore,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: storeNames.map((storeName) => DropdownMenuItem(
                      value: storeName,
                      child: Text(storeName, style: GoogleFonts.poppins()),
                    )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStore = value!;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // Color Selection
          Text(
            'Choose Color:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: Provider.of<ProductProvider>(context, listen: false).availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Icon Selection
          Text(
            'Choose Icon:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: Provider.of<ProductProvider>(context, listen: false).availableIcons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedIcon == icon ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedIcon == icon ? selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: selectedIcon == icon ? selectedColor : Colors.grey,
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Update Product Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  
                  // Convert Color to hex string and IconData to string
                  String colorHex = '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}';
                  String iconString = _getIconString(selectedIcon);
                  
                  final updatedProduct = {
                    'name': nameController.text,
                    'category': selectedCategory,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'material': selectedMaterial,
                    'description': descriptionController.text,
                    'color': colorHex,
                    'icon': iconString,
                    'storeId': selectedStore,
                    'storeName': 'Admin Store',
                  };
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
                        ),
                      );
                    },
                  );

                  try {
                    final result = await Provider.of<ProductProvider>(context, listen: false).updateProduct(product['id'], updatedProduct);
                    
                    // Hide loading indicator
                    Navigator.pop(context);
                    
                    if (result['success']) {
                      Navigator.pop(context); // Close the edit product dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Product "${nameController.text}" updated successfully!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to update product!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    // Hide loading indicator
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error updating product: ${e.toString()}',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please fill all required fields!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update Product',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

void _showDeleteProductDialogAdmin(BuildContext context, Map<String, dynamic> product) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Delete Product',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to PERMANENTLY delete "${product['name']}"?\n\n⚠️ This action will completely remove the product from the database and cannot be undone!',
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final result = await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product['id']);
              
              Navigator.pop(context); // Close dialog
              
              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Product deleted successfully!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Failed to delete product!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting product: ${e.toString()}', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _PastelStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isLive;

  const _PastelStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
          children: [
            Icon(icon, color: const Color(0xFF22223B), size: 32),
                if (isLive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastelActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PastelActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF22223B), size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  void _showCategoryDetails(BuildContext context, String category, int productCount) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProducts = productProvider.allProducts.where((p) => p['category'] == category).toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    ' Products',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5C7F7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      ' products',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: categoryProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products in this category',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categoryProducts.length,
                      itemBuilder: (context, index) {
                        final product = categoryProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: product['color']?.withOpacity(0.1) ?? Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  product['icon'] ?? Icons.inventory_2_rounded,
                                  color: product['color'] ?? Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Unknown Product',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '?  Qty: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product['isActive'] == true ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product['isActive'] == true ? 'Active' : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: product['isActive'] == true ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

