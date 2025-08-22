import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F6F2), Color(0xFFB5C7F7), Color(0xFFF9E79F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB5C7F7),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFB5C7F7,
                                    ).withOpacity(0.3),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return Text(
                                        'Hello, ${authProvider.userName ?? 'User'}!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF22223B),
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    'Welcome to EcoBazaarX',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(
                                        0xFF22223B,
                                      ).withOpacity(0.7),
                                    ),
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
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Stats
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Impact',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPastelStatCard(
                                'Carbon Saved',
                                '2.4 kg',
                                Icons.eco_rounded,
                                const Color(0xFFF9E79F),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPastelStatCard(
                                'Products',
                                '12',
                                Icons.shopping_bag_rounded,
                                const Color(0xFFB5C7F7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPastelStatCard(
                                'Trees Planted',
                                '0.12',
                                Icons.park_rounded,
                                const Color(0xFFE8D5C4),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPastelStatCard(
                                'Rating',
                                '4.8★',
                                Icons.star_rounded,
                                const Color(0xFFD6EAF8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Role-based Dashboard Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.userRole == null)
                          return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Access',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: () {
                                  _navigateToRoleSpecificDashboard(
                                    context,
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
                                      _getRoleSpecificIcon(
                                        authProvider.userRole!,
                                      ),
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
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Features',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          'Carbon Footprint Calculator',
                          'Calculate your shopping impact',
                          Icons.calculate_rounded,
                          const Color(0xFFF9E79F),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          'Eco-Friendly Products',
                          'Browse sustainable alternatives',
                          Icons.eco_rounded,
                          const Color(0xFFB5C7F7),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          'Sustainability Tips',
                          'Learn eco-friendly practices',
                          Icons.lightbulb_rounded,
                          const Color(0xFFE8D5C4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
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
                            children: [
                              _buildActivityItem(
                                'Bought organic cotton t-shirt',
                                '2 hours ago',
                                Icons.shopping_bag_rounded,
                                const Color(0xFFF9E79F),
                              ),
                              const SizedBox(height: 16),
                              _buildActivityItem(
                                'Calculated carbon footprint',
                                '1 day ago',
                                Icons.calculate_rounded,
                                const Color(0xFFB5C7F7),
                              ),
                              const SizedBox(height: 16),
                              _buildActivityItem(
                                'Read sustainability tips',
                                '2 days ago',
                                Icons.lightbulb_rounded,
                                const Color(0xFFE8D5C4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastelStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
          Icon(icon, color: const Color(0xFF22223B), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF22223B).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF22223B), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22223B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF22223B).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: const Color(0xFF22223B).withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF22223B), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF22223B),
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF22223B).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRoleSpecificButtonText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Start Shopping';
      case UserRole.shopkeeper:
        return 'Go to Store Dashboard';
      case UserRole.admin:
        return 'Go to Admin Dashboard';
    }
  }

  Color _getRoleSpecificColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFFF9E79F);
      case UserRole.shopkeeper:
        return const Color(0xFFB5C7F7);
      case UserRole.admin:
        return const Color(0xFFE8D5C4);
    }
  }

  IconData _getRoleSpecificIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_bag_rounded;
      case UserRole.shopkeeper:
        return Icons.store_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  void _navigateToRoleSpecificDashboard(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.customer:
        // For customers, stay on home screen or navigate to shopping
        break;
      case UserRole.shopkeeper:
        Navigator.pushReplacementNamed(context, '/shopkeeper');
        break;
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
    }
  }
}
