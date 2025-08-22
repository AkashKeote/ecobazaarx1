import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      value: '1,247',
                      color: const Color(0xFFB5C7F7),
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Active Stores',
                      value: '89',
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
                      value: '2.4T',
                      color: const Color(0xFFD6EAF8),
                      icon: Icons.eco_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Revenue',
                      value: '₹89.2L',
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
                      Text(
                        'System Status: Operational',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uptime: 99.8%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB5C7F7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active Sessions: 347',
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

  // Admin action methods
  void _showUserManagement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening User Management...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFB5C7F7),
      ),
    );
  }

  void _showStoreAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Store Analytics...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9E79F),
      ),
    );
  }

  void _showCarbonReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Carbon Reports...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD6EAF8),
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
