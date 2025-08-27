import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/auth_provider.dart';

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
  int _totalUsers = 1247;
  int _activeStores = 89;
  double _carbonSaved = 2.4;
  double _revenue = 89.2;
  int _activeSessions = 347;
  double _systemUptime = 99.8;
  
  // Store Analytics real-time data
  List<Map<String, dynamic>> _stores = [
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
    },
    {
      'id': '3',
      'name': 'Sustainable Store',
      'category': 'Electronics',
      'performance': 0.68,
      'rating': 3.9,
      'status': 'Active',
      'products': 67,
      'revenue': 28000,
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 8)),
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
    },
    {
      'id': '5',
      'name': 'EcoTech Solutions',
      'category': 'Electronics',
      'performance': 0.78,
      'rating': 4.0,
      'status': 'Active',
      'products': 123,
      'revenue': 38000,
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 12)),
    },
  ];
  
  // Store categories with real-time counts
  Map<String, int> _storeCategories = {
    'Food & Beverages': 35,
    'Clothing & Fashion': 28,
    'Electronics': 18,
    'Home & Garden': 19,
  };
  
     // User management data
   List<Map<String, dynamic>> _users = [
     {
       'id': '1',
       'name': 'John Doe',
       'email': 'john@example.com',
       'role': 'Customer',
       'status': 'Active',
       'joinDate': '2024-01-15',
     },
     {
       'id': '2',
       'name': 'Jane Smith',
       'email': 'jane@example.com',
       'role': 'Shopkeeper',
       'status': 'Active',
       'joinDate': '2024-01-10',
     },
     {
       'id': '3',
       'name': 'Bob Wilson',
       'email': 'bob@example.com',
       'role': 'Customer',
       'status': 'Inactive',
       'joinDate': '2024-01-05',
     },
     {
       'id': '4',
       'name': 'Alice Brown',
       'email': 'alice@example.com',
       'role': 'Admin',
       'status': 'Active',
       'joinDate': '2024-01-01',
     },
     // Additional users that would be shown from customer home screen dashboard
     {
       'id': '5',
       'name': 'Sarah Johnson',
       'email': 'sarah@example.com',
       'role': 'Customer',
       'status': 'Active',
       'joinDate': '2024-01-20',
     },
     {
       'id': '6',
       'name': 'Mike Davis',
       'email': 'mike@example.com',
       'role': 'Customer',
       'status': 'Active',
       'joinDate': '2024-01-18',
     },
     {
       'id': '7',
       'name': 'Emily Wilson',
       'email': 'emily@example.com',
       'role': 'Shopkeeper',
       'status': 'Active',
       'joinDate': '2024-01-12',
     },
     {
       'id': '8',
       'name': 'David Miller',
       'email': 'david@example.com',
       'role': 'Customer',
       'status': 'Active',
       'joinDate': '2024-01-16',
     },
     {
       'id': '9',
       'name': 'Lisa Anderson',
       'email': 'lisa@example.com',
       'role': 'Customer',
       'status': 'Inactive',
       'joinDate': '2024-01-08',
     },
     {
       'id': '10',
       'name': 'Tom Garcia',
       'email': 'tom@example.com',
       'role': 'Shopkeeper',
       'status': 'Active',
       'joinDate': '2024-01-14',
     },
   ];
  
  // Filter variables
  String _currentFilter = 'All';
  String _searchQuery = '';
  
  // Recent activities
  List<Map<String, dynamic>> _recentActivities = [
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
    
    // Debug: Print user count
    print('AdminDashboard: Initialized with ${_users.length} users');
  }
  
  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Update real-time data with realistic increments
          _totalUsers += Random().nextInt(3);
          _activeStores += Random().nextInt(2) - 1;
          _carbonSaved += (Random().nextDouble() * 0.1);
          _revenue += (Random().nextDouble() * 0.5);
          _activeSessions += Random().nextInt(10) - 5;
          _systemUptime = 99.8 + (Random().nextDouble() * 0.2);
          
          // Update store analytics in real-time
          _updateStoreAnalytics();
        });
      }
    });
  }
  
  void _updateStoreAnalytics() {
    // Update store performance randomly
    for (var store in _stores) {
      // Randomly update performance
      if (Random().nextBool()) {
        store['performance'] = (store['performance'] + (Random().nextDouble() * 0.1 - 0.05)).clamp(0.0, 1.0);
      }
      
      // Randomly update revenue
      if (Random().nextBool()) {
        store['revenue'] += Random().nextInt(1000) - 500;
        store['revenue'] = store['revenue'].clamp(0, 100000);
      }
      
      // Randomly update products count
      if (Random().nextBool()) {
        store['products'] += Random().nextInt(5) - 2;
        store['products'] = store['products'].clamp(0, 500);
      }
      
      // Update last updated time
      store['lastUpdated'] = DateTime.now();
    }
    
    // Update store categories randomly
    for (var category in _storeCategories.keys) {
      if (Random().nextBool()) {
        _storeCategories[category] = (_storeCategories[category]! + Random().nextInt(3) - 1).clamp(0, 100);
      }
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
                          Consumer<AuthProvider>(
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
                        final authProvider = Provider.of<AuthProvider>(
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
                      value: '${_totalUsers.toStringAsFixed(0)}',
                      color: const Color(0xFFB5C7F7),
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Active Stores',
                      value: '${_activeStores.toStringAsFixed(0)}',
                      color: const Color(0xFFF9E79F),
                      icon: Icons.store_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _PastelStatCard(
                      title: 'Carbon Saved',
                      value: '${_carbonSaved.toStringAsFixed(1)}T',
                      color: const Color(0xFFD6EAF8),
                      icon: Icons.eco_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Revenue',
                      value: '₹${_revenue.toStringAsFixed(1)}L',
                      color: const Color(0xFFE8D5C4),
                      icon: Icons.currency_rupee_rounded,
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
                child: Row(
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
                     Row(
                       children: [
                         Expanded(
                           child: _buildUserManagementCard('Total Users', '${_getFilteredUsers().length}', Icons.people_rounded, const Color(0xFFB5C7F7)),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: _buildUserManagementCard('Active Users', '${_getFilteredUsers().where((user) => user['status'] == 'Active').length}', Icons.person_rounded, const Color(0xFFD6EAF8)),
                         ),
                       ],
                     ),
                     
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUserManagementCard('New Users (Today)', '${Random().nextInt(5) + 1}', Icons.person_add_rounded, const Color(0xFFF9E79F)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUserManagementCard('Premium Users', '${(_users.length * 0.15).round()}', Icons.star_rounded, const Color(0xFFE8D5C4)),
                        ),
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
                               if (_currentFilter != 'All' || _searchQuery.isNotEmpty)
                                 Expanded(
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
                                     label: Text('Clear', style: GoogleFonts.poppins()),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.red[400],
                                       foregroundColor: Colors.white,
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
                    Row(
                      children: [
                        Expanded(
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
                        const SizedBox(width: 16),
                        Expanded(
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
                     Row(
                       children: [
                         Expanded(
                           child: _buildStoreStatCard('Total Stores', '${_stores.length}', Icons.store_rounded, const Color(0xFFB5C7F7)),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: _buildStoreStatCard('Active Stores', '${_stores.where((store) => store['status'] == 'Active').length}', Icons.storefront_rounded, const Color(0xFFD6EAF8)),
                         ),
                       ],
                     ),
                     const SizedBox(height: 16),
                     Row(
                       children: [
                         Expanded(
                           child: _buildStoreStatCard('Total Products', '${_stores.fold<int>(0, (sum, store) => sum + (store['products'] as int))}', Icons.inventory_rounded, const Color(0xFFF9E79F)),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: _buildStoreStatCard('Avg. Rating', '${(_stores.fold<double>(0.0, (sum, store) => sum + (store['rating'] as double)) / _stores.length).toStringAsFixed(1)}★', Icons.star_rounded, const Color(0xFFE8D5C4)),
                         ),
                       ],
                     ),
                    const SizedBox(height: 24),
                    
                    // Store Performance Chart
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
                            'Store Performance',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                                                     ..._stores.map((store) => Column(
                             children: [
                               _buildStorePerformanceBar(store),
                               const SizedBox(height: 12),
                             ],
                           )).toList(),
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
                     
                     // Real-time Store Management
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
                                 'Real-time Store Activity',
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
                           ..._stores.take(3).map((store) => _buildRealTimeStoreItem(store)),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Action Buttons
                     Row(
                       children: [
                         Expanded(
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
                         const SizedBox(width: 16),
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: () => _showStoreApprovalDialog(context),
                             icon: const Icon(Icons.approval_rounded),
                             label: Text('Manage Stores', style: GoogleFonts.poppins()),
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildCarbonStatCard('Total Carbon Saved', '${_carbonSaved.toStringAsFixed(1)}T', Icons.eco_rounded, const Color(0xFF4CAF50)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCarbonStatCard('This Month', '${(_carbonSaved * 0.12).toStringAsFixed(2)}T', Icons.calendar_month_rounded, const Color(0xFF2196F3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCarbonStatCard('Trees Equivalent', '${(_carbonSaved * 50).round()}', Icons.park_rounded, const Color(0xFF8BC34A)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCarbonStatCard('CO₂ Reduction', '${(_carbonSaved * 1000).round()}kg', Icons.trending_down_rounded, const Color(0xFF00BCD4)),
                        ),
                      ],
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
                          _buildCarbonImpactBar('Food & Beverages', 0.45, '1,281 kg', const Color(0xFF4CAF50)),
                          const SizedBox(height: 12),
                          _buildCarbonImpactBar('Clothing & Fashion', 0.28, '797 kg', const Color(0xFF2196F3)),
                          const SizedBox(height: 12),
                          _buildCarbonImpactBar('Electronics', 0.15, '427 kg', const Color(0xFFFF9800)),
                          const SizedBox(height: 12),
                          _buildCarbonImpactBar('Home & Garden', 0.12, '342 kg', const Color(0xFF9C27B0)),
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

  Widget _buildUserManagementCard(String title, String value, IconData icon, Color color) {
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
              value: selectedRole,
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
              value: selectedStatus,
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
                final newUser = {
                  'id': '${_users.length + 1}',
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': selectedRole,
                  'status': selectedStatus,
                  'joinDate': DateTime.now().toString().split(' ')[0],
                };
                
                                                  setState(() {
                   _users.add(newUser);
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
                setState(() {
                  _users.removeWhere((user) => user['email'] == email);
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
               value: selectedRole,
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
               value: selectedStatus,
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
                 setState(() {
                   final userIndex = _users.indexWhere((user) => user['email'] == email);
                   if (userIndex != -1) {
                     _users[userIndex]['name'] = nameController.text;
                     _users[userIndex]['email'] = emailController.text;
                     _users[userIndex]['role'] = selectedRole;
                     _users[userIndex]['status'] = selectedStatus;
                   }
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
               value: selectedRole,
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
               setState(() {
                 final userIndex = _users.indexWhere((user) => user['email'] == email);
                 if (userIndex != -1) {
                   _users[userIndex]['role'] = selectedRole;
                 }
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

     Widget _buildStorePerformanceBar(Map<String, dynamic> store) {
     final performance = store['performance'] as double;
     final color = _getCategoryColor(store['category'] as String);
     final lastUpdated = store['lastUpdated'] as DateTime;
     final timeAgo = _getTimeAgo(lastUpdated);
     
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
                       store['name'] as String,
                       style: GoogleFonts.poppins(
                         fontWeight: FontWeight.w600,
                         fontSize: 14,
                       ),
                     ),
                     Text(
                       store['category'] as String,
                       style: GoogleFonts.poppins(
                         fontSize: 12,
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
                 'Products: ${store['products']}',
                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
               ),
               Text(
                 'Revenue: ₹${(store['revenue'] as int).toStringAsFixed(0)}',
                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
               ),
               Text(
                 'Rating: ${store['rating']}★',
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
   
   void _showAddStoreDialog(BuildContext context) {
     final nameController = TextEditingController();
     String selectedCategory = 'Food & Beverages';
     
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Add New Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             TextField(
               controller: nameController,
               decoration: const InputDecoration(
                 labelText: 'Store Name',
                 border: OutlineInputBorder(),
               ),
             ),
             const SizedBox(height: 16),
             DropdownButtonFormField<String>(
               decoration: const InputDecoration(
                 labelText: 'Category',
                 border: OutlineInputBorder(),
               ),
               value: selectedCategory,
               items: _storeCategories.keys.map((category) => 
                 DropdownMenuItem(value: category, child: Text(category))
               ).toList(),
               onChanged: (value) {
                 selectedCategory = value!;
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
               if (nameController.text.isNotEmpty) {
                 final newStore = {
                   'id': '${_stores.length + 1}',
                   'name': nameController.text,
                   'category': selectedCategory,
                   'performance': Random().nextDouble() * 0.3 + 0.6, // Random performance between 0.6-0.9
                   'rating': (Random().nextDouble() * 1.5 + 3.5).clamp(3.0, 5.0), // Random rating between 3.0-5.0
                   'status': 'Active',
                   'products': Random().nextInt(200) + 50, // Random products between 50-250
                   'revenue': Random().nextInt(50000) + 10000, // Random revenue between 10k-60k
                   'lastUpdated': DateTime.now(),
                 };
                 
                 setState(() {
                   _stores.add(newStore);
                   _storeCategories[selectedCategory] = (_storeCategories[selectedCategory] ?? 0) + 1;
                 });
                 
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('Store "${nameController.text}" added successfully!', style: GoogleFonts.poppins()),
                     backgroundColor: Colors.green,
                   ),
                 );
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('Please enter store name!', style: GoogleFonts.poppins()),
                     backgroundColor: Colors.red,
                   ),
                 );
               }
             },
             child: const Text('Add Store'),
           ),
         ],
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

class _PastelStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _PastelStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
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
            Icon(icon, color: const Color(0xFF22223B), size: 32),
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
