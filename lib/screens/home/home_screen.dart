import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../shopping/shopping_cart_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../shopkeeper/shopkeeper_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  // Real-time data variables
  Timer? _realTimeTimer;
  double _carbonSaved = 2.4;
  int _productsViewed = 12;
  int _onlineUsers = 1247;
  double _todaysSavings = 156.80;
  int _nearbyStores = 8;
  String _currentWeather = "Sunny 28°C";
  List<String> _liveActivities = [
    "Sarah just bought organic cotton shirts",
    "GreenMart added 12 new eco products",
    "Mumbai saved 45kg CO₂ today",
    "New sustainable store opened nearby",
  ];
  int _activityIndex = 0;
  
  // Live notifications
  List<Map<String, dynamic>> _notifications = [
    {
      'title': '🎉 Flash Sale!',
      'message': '30% off on eco-friendly products',
      'color': const Color(0xFFF9E79F),
      'time': 'Now',
    },
    {
      'title': '🌱 Daily Goal',
      'message': 'You\'re 80% closer to your carbon goal!',
      'color': const Color(0xFFB5C7F7),
      'time': '5 min ago',
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);

    // Start real-time updates
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Update real-time data with realistic increments
          _carbonSaved += (Random().nextDouble() * 0.1);
          _productsViewed += Random().nextInt(3);
          _onlineUsers += Random().nextInt(20) - 10;
          _todaysSavings += (Random().nextDouble() * 5);
          _nearbyStores = 8 + Random().nextInt(5);
          
          // Cycle through activities
          _activityIndex = (_activityIndex + 1) % _liveActivities.length;
          
          // Occasionally add new notifications
          if (Random().nextDouble() < 0.3) {
            _addRandomNotification();
          }
        });
      }
    });
  }

  void _addRandomNotification() {
    List<Map<String, dynamic>> newNotifications = [
      {
        'title': '💚 Eco Achievement',
        'message': 'You saved 500g CO₂ this week!',
        'color': const Color(0xFFE8D5C4),
        'time': 'Just now',
      },
      {
        'title': '🚚 Order Update',
        'message': 'Your bamboo products are out for delivery',
        'color': const Color(0xFFD6EAF8),
        'time': 'Just now',
      },
      {
        'title': '🏪 New Store',
        'message': 'EcoMart opened 2km from your location',
        'color': const Color(0xFFF9E79F),
        'time': 'Just now',
      },
    ];
    
    if (_notifications.length < 5) {
      _notifications.insert(0, newNotifications[Random().nextInt(newNotifications.length)]);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _realTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFFB5C7F7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with Live Status
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB5C7F7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  size: 30,
                                  color: Colors.white,
                                ),
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
                                        'Hello, ${authProvider.userName ?? 'User'}!\nWelcome to EcoBazaarX.',
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
                            // Live Notification Bell
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () => _showNotifications(),
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9E79F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_rounded,
                                      color: Color(0xFF22223B),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (_notifications.isNotEmpty)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
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
                                  color: const Color(0xFFB5C7F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFF22223B),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Live Activity Feed
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5C4).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE8D5C4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Live: ${_liveActivities[_activityIndex]}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF22223B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                _currentWeather,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search eco-friendly products...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFFB5C7F7),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _showSearchFilters();
                            },
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: const Color(0xFFB5C7F7),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onTap: () {
                          _navigateToShopping();
                        },
                        readOnly: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Real-time Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _AnimatedStatCard(
                          title: 'Carbon Saved',
                          value: '${_carbonSaved.toStringAsFixed(1)} kg',
                          color: const Color(0xFFF9E79F),
                          icon: Icons.eco_rounded,
                          onTap: _showImpactTracker,
                        ),
                        const SizedBox(width: 16),
                        _AnimatedStatCard(
                          title: 'Products Viewed',
                          value: _productsViewed.toString(),
                          color: const Color(0xFFD6EAF8),
                          icon: Icons.visibility_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _AnimatedStatCard(
                          title: 'Today\'s Savings',
                          value: '₹${_todaysSavings.toStringAsFixed(0)}',
                          color: const Color(0xFFB5C7F7),
                          icon: Icons.savings_rounded,
                        ),
                        const SizedBox(width: 16),
                        _AnimatedStatCard(
                          title: 'Nearby Stores',
                          value: _nearbyStores.toString(),
                          color: const Color(0xFFE8D5C4),
                          icon: Icons.store_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Live Community Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Text(
                          'Live Community',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_onlineUsers} online',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Real-time Impact Tracker
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mumbai\'s Impact Today',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Carbon Saved: ${(_carbonSaved * 50).toStringAsFixed(1)} kg',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB5C7F7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Community Goal: ${((_carbonSaved * 50) / 1000 * 100).toStringAsFixed(1)}% complete',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: (_carbonSaved * 50) / 1000,
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

                  // Enhanced Shopping Call-to-Action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB5C7F7),
                            const Color(0xFFF9E79F),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB5C7F7).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _navigateToShopping(),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🛍️ Start Shopping',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Discover eco-friendly products',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Enhanced Quick Actions with Real-time Features
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Quick Actions',
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
                          child: _EnhancedShoppingCard(
                            onTap: () => _navigateToShopping(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.track_changes_rounded,
                            label: 'Track Impact',
                            color: const Color(0xFFD6EAF8),
                            onTap: () => _showImpactTracker(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.eco_rounded,
                            label: 'Daily Tips',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _showEcoTips(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Second row of action cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.people_rounded,
                            label: 'Community',
                            color: const Color(0xFFE8D5C4),
                            onTap: () => _showCommunityUpdates(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.notifications_active_rounded,
                            label: 'Notifications',
                            color: const Color(0xFFF9E79F),
                            onTap: () => _showNotifications(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.refresh_rounded,
                            label: 'Refresh Data',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _refreshData(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Trending Products Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Trending Now',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 220, // Increased height to prevent overflow
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildTrendingProductCard(index);
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Role-based Dashboard Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.userRole == null)
                          return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                _handleRoleSpecificAction(
                                  authProvider.userRole!,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getRoleSpecificColor(
                                  authProvider.userRole!,
                                ),
                                foregroundColor: const Color(0xFF22223B),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getRoleSpecificIcon(authProvider.userRole!),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getRoleSpecificButtonText(
                                      authProvider.userRole!,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      // Enhanced Floating Action Button for Shopping
      floatingActionButton: Stack(
        children: [
          FloatingActionButton.extended(
            onPressed: () => _navigateToShopping(),
            backgroundColor: const Color(0xFFB5C7F7),
            icon: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
            ),
            label: Text(
              'Shop Now',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 8,
          ),
          if (_productsViewed > 5)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${Random().nextInt(9) + 1}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Real-time refresh function
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _carbonSaved += Random().nextDouble() * 0.5;
      _productsViewed += Random().nextInt(5);
      _todaysSavings += Random().nextDouble() * 20;
      _onlineUsers += Random().nextInt(100) - 50;
    });
  }

  // Enhanced navigation methods
  void _navigateToShopping() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildShoppingOptionsModal(),
    );
  }

  Widget _buildShoppingOptionsModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Start Shopping 🛍️',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
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
          
          // Shopping Categories
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Shopping Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickShoppingCard(
                          'Browse All\nProducts',
                          Icons.grid_view_rounded,
                          const Color(0xFFB5C7F7),
                          () => _navigateToAllProducts(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickShoppingCard(
                          'View Cart\n& Checkout',
                          Icons.shopping_cart_rounded,
                          const Color(0xFFF9E79F),
                          () => _navigateToCart(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories Section
                  Text(
                    'Shop by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildCategoryCard(
                        'Organic Food',
                        Icons.restaurant_rounded,
                        const Color(0xFFE8D5C4),
                        '250+ items',
                      ),
                      _buildCategoryCard(
                        'Eco Clothing',
                        Icons.checkroom_rounded,
                        const Color(0xFFD6EAF8),
                        '180+ items',
                      ),
                      _buildCategoryCard(
                        'Home & Garden',
                        Icons.home_rounded,
                        const Color(0xFFF9E79F),
                        '320+ items',
                      ),
                      _buildCategoryCard(
                        'Personal Care',
                        Icons.spa_rounded,
                        const Color(0xFFB5C7F7),
                        '150+ items',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Special Offers
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB5C7F7).withOpacity(0.8),
                          const Color(0xFFF9E79F).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer_rounded,
                              color: const Color(0xFF22223B),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Special Eco Deals',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Get up to 40% off on eco-friendly products today! Limited time offer.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToOffers();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22223B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'View All Offers',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  Text(
                    'Recently Viewed',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildRecentProductCard(index);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShoppingCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF22223B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, String itemCount) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateToCategory(title);
      },
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              itemCount,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProductCard(int index) {
    List<Map<String, dynamic>> recentProducts = [
      {
        'name': 'Bamboo Toothbrush',
        'price': '₹120',
        'color': const Color(0xFFE8D5C4),
        'icon': Icons.brush_rounded,
      },
      {
        'name': 'Organic Honey',
        'price': '₹350',
        'color': const Color(0xFFF9E79F),
        'icon': Icons.water_drop_outlined,
      },
      {
        'name': 'Cotton Tote Bag',
        'price': '₹299',
        'color': const Color(0xFFB5C7F7),
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'name': 'Plant-based Soap',
        'price': '₹150',
        'color': const Color(0xFFD6EAF8),
        'icon': Icons.soap_outlined,
      },
      {
        'name': 'Reusable Bottle',
        'price': '₹450',
        'color': const Color(0xFFE8D5C4),
        'icon': Icons.local_drink_rounded,
      },
    ];

    final product = recentProducts[index % recentProducts.length];

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: product['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              product['icon'],
              color: product['color'],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['name'],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product['price'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: product['color'],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced shopping navigation methods
  void _navigateToAllProducts() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingCartScreen(),
      ),
    );
  }

  void _navigateToOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingCartScreen(),
      ),
    );
  }

  void _navigateToCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          category,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: const Color(0xFFB5C7F7),
            ),
            const SizedBox(height: 16),
            Text(
              'This category is coming soon! We\'re adding more eco-friendly products.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCart();
            },
            child: Text(
              'Browse Cart Instead',
              style: GoogleFonts.poppins(
                color: const Color(0xFFB5C7F7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingCartScreen(),
      ),
    );
  }

  // Show notifications bottom sheet
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                    'Live Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _notifications.clear();
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
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
                            color: notification['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: notification['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              Text(
                                notification['message'],
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          notification['time'],
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 12,
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

  // Show impact tracker
  void _showImpactTracker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Real-time Impact Tracker',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImpactMetric('Carbon Saved', '${_carbonSaved.toStringAsFixed(1)} kg', Icons.eco_rounded, Colors.green),
            _buildImpactMetric('Money Saved', '₹${_todaysSavings.toStringAsFixed(0)}', Icons.savings_rounded, const Color(0xFFB5C7F7)),
            _buildImpactMetric('Products Viewed', _productsViewed.toString(), Icons.visibility_rounded, const Color(0xFFF9E79F)),
            _buildImpactMetric('Community Rank', '#${Random().nextInt(100) + 1}', Icons.leaderboard_rounded, const Color(0xFFE8D5C4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: const Color(0xFFB5C7F7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF22223B),
              ),
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
    );
  }

  // Show eco tips
  void _showEcoTips() {
    List<String> tips = [
      "💡 Use reusable bags for shopping",
      "🌱 Choose organic products when possible",
      "♻️ Recycle packaging materials",
      "🚗 Walk or cycle for short distances",
      "💧 Conserve water at home",
      "🌟 Buy from local eco-friendly stores",
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Daily Eco Tips',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tips.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.poppins(color: const Color(0xFFB5C7F7)),
            ),
          ),
        ],
      ),
    );
  }

  // Role-specific helper methods
  Color _getRoleSpecificColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFFB5C7F7);
      case UserRole.shopkeeper:
        return const Color(0xFFF9E79F);
      case UserRole.admin:
        return const Color(0xFFE8D5C4);
    }
  }

  IconData _getRoleSpecificIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_cart_rounded;
      case UserRole.shopkeeper:
        return Icons.store_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  // Show community updates
  void _showCommunityUpdates() {
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
              child: Text(
                'Community Activity',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  List<Map<String, dynamic>> activities = [
                    {
                      'user': 'Sarah K.',
                      'action': 'saved 2.3 kg CO2 by buying organic cotton',
                      'time': '${index + 1}m ago',
                      'icon': Icons.eco_rounded,
                      'color': Colors.green,
                    },
                    {
                      'user': 'Mike R.',
                      'action': 'purchased a bamboo water bottle',
                      'time': '${index + 3}m ago',
                      'icon': Icons.water_drop_rounded,
                      'color': const Color(0xFFB5C7F7),
                    },
                    {
                      'user': 'Emma W.',
                      'action': 'achieved 100 eco-points milestone!',
                      'time': '${index + 5}m ago',
                      'icon': Icons.stars_rounded,
                      'color': const Color(0xFFF9E79F),
                    },
                    {
                      'user': 'Alex T.',
                      'action': 'shared an eco-tip with the community',
                      'time': '${index + 7}m ago',
                      'icon': Icons.lightbulb_rounded,
                      'color': const Color(0xFFE8D5C4),
                    },
                  ];
                  
                  final activity = activities[index % activities.length];
                  
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
                            borderRadius: BorderRadius.circular(20),
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
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF22223B),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: activity['user'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ' ${activity['action']}'),
                                  ],
                                ),
                              ),
                              Text(
                                activity['time'],
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.red[300],
                          size: 16,
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

  // Show search filters
  void _showSearchFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
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
              child: Text(
                'Search Filters',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFilterChip('🌱 Organic', const Color(0xFFB5C7F7)),
                    const SizedBox(height: 12),
                    _buildFilterChip('♻️ Recycled', const Color(0xFFF9E79F)),
                    const SizedBox(height: 12),
                    _buildFilterChip('🌿 Biodegradable', const Color(0xFFD6EAF8)),
                    const SizedBox(height: 12),
                    _buildFilterChip('💚 Sustainable', const Color(0xFFE8D5C4)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToShopping();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5C7F7),
                            ),
                            child: Text(
                              'Apply',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.check_circle_outline_rounded,
            color: color,
          ),
        ],
      ),
    );
  }

  // Product interaction method
  void _onProductTap(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<CartProvider>(
        builder: (context, cartProvider, child) => Container(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Section
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: product['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          product['icon'],
                          color: product['color'],
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Product Details
                      Text(
                        product['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            product['rating'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product['discount'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        product['price'],
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: product['color'],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Eco-friendly product made with sustainable materials. Perfect for environmentally conscious customers.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      
                      // Quantity Selection
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Quantity:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: product['color']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final productId = product['id'] ?? product['name'];
                                    if (cartProvider.isInCart(productId)) {
                                      cartProvider.removeSingleItem(productId);
                                    }
                                  },
                                  icon: Icon(Icons.remove, color: product['color']),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '${cartProvider.getQuantity(product['id'] ?? product['name'])}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF22223B),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _addToCart(product, cartProvider);
                                  },
                                  icon: Icon(Icons.add, color: product['color']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _addToCart(product, cartProvider);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product['name']} added to cart!',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: product['color'],
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart_rounded),
                              label: Text(
                                'Add to Cart',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: product['color'],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToCart();
                              },
                              icon: const Icon(Icons.shopping_cart_rounded),
                              label: Text(
                                'View Cart',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: product['color'],
                                side: BorderSide(color: product['color'], width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product, CartProvider cartProvider) {
    // Extract price from string (remove ₹ symbol)
    String priceString = product['price'].toString().replaceAll('₹', '').replaceAll(',', '');
    double price = double.tryParse(priceString) ?? 0.0;
    
    cartProvider.addItem(
      productId: product['id'] ?? product['name'],
      name: product['name'],
      description: 'Eco-friendly ${product['name'].toLowerCase()}',
      price: price,
      icon: product['icon'],
      color: product['color'],
    );
  }

  // Build trending product cards
  Widget _buildTrendingProductCard(int index) {
    List<Map<String, dynamic>> products = [
      {
        'id': 'organic-cotton-tshirt',
        'name': 'Organic Cotton T-Shirt',
        'price': '₹899',
        'discount': '20% OFF',
        'rating': '4.8',
        'color': const Color(0xFFB5C7F7),
        'icon': Icons.checkroom_rounded,
      },
      {
        'id': 'bamboo-water-bottle',
        'name': 'Bamboo Water Bottle',
        'price': '₹599',
        'discount': '15% OFF',
        'rating': '4.9',
        'color': const Color(0xFFD6EAF8),
        'icon': Icons.water_drop_rounded,
      },
      {
        'id': 'reusable-shopping-bag',
        'name': 'Reusable Shopping Bag',
        'price': '₹299',
        'discount': 'NEW',
        'rating': '4.7',
        'color': const Color(0xFFE8D5C4),
        'icon': Icons.shopping_bag_rounded,
      },
      {
        'id': 'eco-friendly-soap',
        'name': 'Eco-Friendly Soap',
        'price': '₹199',
        'discount': '25% OFF',
        'rating': '4.6',
        'color': const Color(0xFFF9E79F),
        'icon': Icons.soap_rounded,
      },
      {
        'id': 'solar-phone-charger',
        'name': 'Solar Phone Charger',
        'price': '₹1299',
        'discount': 'HOT',
        'rating': '4.9',
        'color': const Color(0xFFB5C7F7),
        'icon': Icons.solar_power_rounded,
      },
    ];

    final product = products[index % products.length];

    return GestureDetector(
      onTap: () => _onProductTap(product),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image/Icon Section
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: product['color'].withOpacity(0.2),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        product['icon'],
                        color: product['color'],
                        size: 40,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['discount'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product Details Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF22223B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product['rating'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product['price'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: product['color'],
                            ),
                          ),
                          Icon(
                            Icons.add_shopping_cart_rounded,
                            color: product['color'],
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    String _getRoleSpecificButtonText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Start Shopping';
      case UserRole.shopkeeper:
        return 'Manage Inventory';
      case UserRole.admin:
        return 'Admin Panel';
    }
  }

  void _handleRoleSpecificAction(UserRole role) {
    switch (role) {
      case UserRole.customer:
        _navigateToShopping();
        break;
      case UserRole.shopkeeper:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShopkeeperDashboardScreen(),
          ),
        );
        break;
      case UserRole.admin:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
        break;
    }
  }
}

// Animated Stat Card Widget
class _AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  _AnimatedStatCardState createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    
    // Start pulsing animation
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _controller.forward().then((_) {
          _controller.reverse();
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 28,
                        ),
                      ),
                      if (widget.onTap != null)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: widget.color.withOpacity(0.7),
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Shopping Card Widget
class _EnhancedShoppingCard extends StatefulWidget {
  final VoidCallback onTap;

  const _EnhancedShoppingCard({
    required this.onTap,
  });

  @override
  _EnhancedShoppingCardState createState() => _EnhancedShoppingCardState();
}

class _EnhancedShoppingCardState extends State<_EnhancedShoppingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _dealCount = 25;
  Timer? _dealTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Update deal count every few seconds
    _dealTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _dealCount = 20 + Random().nextInt(30);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF9E79F),
                    const Color(0xFFF9E79F).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF9E79F).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        color: const Color(0xFF22223B),
                        size: 32,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_dealCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start Shopping',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_dealCount deals',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF22223B).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
