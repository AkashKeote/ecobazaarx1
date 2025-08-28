import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';

class ShopkeeperDashboardScreen extends StatefulWidget {
  const ShopkeeperDashboardScreen({super.key});

  @override
  State<ShopkeeperDashboardScreen> createState() =>
      _ShopkeeperDashboardScreenState();
}

class _ShopkeeperDashboardScreenState extends State<ShopkeeperDashboardScreen>
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
                        Icons.store_rounded,
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
                                'My Store Dashboard\nHello, ${authProvider.userName ?? 'Shopkeeper'}!',
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
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E79F),
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
                      title: 'Total Products',
                      value: '247',
                      color: const Color(0xFFB5C7F7),
                      icon: Icons.inventory_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Orders Today',
                      value: '18',
                      color: const Color(0xFFF9E79F),
                      icon: Icons.shopping_cart_rounded,
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
                      title: 'Revenue',
                      value: '₹12.5K',
                      color: const Color(0xFFD6EAF8),
                      icon: Icons.currency_rupee_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Eco Rating',
                      value: '4.8★',
                      color: const Color(0xFFE8D5C4),
                      icon: Icons.eco_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Store Management
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Store Management',
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
                        icon: Icons.add_box_rounded,
                        label: 'Add Product',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showAddProduct(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.inventory_rounded,
                        label: 'Manage Stock',
                        color: const Color(0xFFB5C7F7),
                        onTap: () => _showManageStock(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.list_alt_rounded,
                        label: 'View Orders',
                        color: const Color(0xFFD6EAF8),
                        onTap: () => _showOrders(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.storefront_rounded,
                        label: 'My Store',
                        color: const Color(0xFFE8D5C4),
                        onTap: () => _showMyStore(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.edit_rounded,
                        label: 'Edit Store',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showEditStore(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.add_business_rounded,
                        label: 'Add Store',
                        color: const Color(0xFFB5C7F7),
                        onTap: () => _showAddStore(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Store Performance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Store Performance',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Performance Overview Card
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
                        'This Month\'s Performance',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sales Growth: +24%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB5C7F7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customer Rating: 4.8/5',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.75,
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

              // Sustainability Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Sustainability Impact',
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
                        icon: Icons.eco_rounded,
                        label: 'Eco Products',
                        color: const Color(0xFFE8D5C4),
                        onTap: () => _showEcoProducts(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.analytics_rounded,
                        label: 'Impact Report',
                        color: const Color(0xFFD6EAF8),
                        onTap: () => _showImpactReport(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Improve Score',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showImprovementTips(context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProduct(context),
        backgroundColor: const Color(0xFFB5C7F7),
        child: const Icon(
          Icons.add,
          color: Color(0xFF22223B),
        ),
      ),
    );
  }

  Widget _buildStoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
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
                    const Icon(Icons.store, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GreenMart Store',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Eco-friendly products for conscious consumers',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStoreStat('Products', '156', Colors.white),
                    const SizedBox(width: 24),
                    _buildStoreStat('Orders', '89', Colors.white),
                    const SizedBox(width: 24),
                    _buildStoreStat('Rating', '4.8★', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Add Product',
                  Icons.add_shopping_cart,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'View Orders',
                  Icons.shopping_bag,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Update Profile',
                  Icons.edit,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'Sustainability Report',
                  Icons.eco,
                  Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders
          _buildSectionTitle('Recent Orders'),
          const SizedBox(height: 16),
          _buildOrderCard(
            'Order #1234',
            'Organic Cotton T-Shirt',
            '₹899',
            'Pending',
            Colors.orange,
          ),
          _buildOrderCard(
            'Order #1233',
            'Bamboo Water Bottle',
            '₹599',
            'Delivered',
            Colors.green,
          ),
          _buildOrderCard(
            'Order #1232',
            'Reusable Shopping Bag',
            '₹299',
            'Shipped',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
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
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Product Categories
          _buildSectionTitle('Product Categories'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCategoryChip('All', true),
              _buildCategoryChip('Food', false),
              _buildCategoryChip('Clothing', false),
              _buildCategoryChip('Home', false),
              _buildCategoryChip('Beauty', false),
            ],
          ),
          const SizedBox(height: 24),

          // Product List
          _buildSectionTitle('My Products'),
          const SizedBox(height: 16),
          _buildProductCard(
            'Organic Cotton T-Shirt',
            '₹899',
            'Made from 100% organic cotton',
            '156 in stock',
            Icons.check_circle,
            Colors.green,
          ),
          _buildProductCard(
            'Bamboo Water Bottle',
            '₹599',
            'Sustainable bamboo material',
            '89 in stock',
            Icons.check_circle,
            Colors.green,
          ),
          _buildProductCard(
            'Reusable Shopping Bag',
            '₹299',
            'Eco-friendly shopping solution',
            '234 in stock',
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sustainability Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                      'Store Sustainability Score',
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
                  '92/100',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Excellent! Your store is highly sustainable',
                  style: TextStyle(color: Colors.green.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sustainability Metrics
          _buildSectionTitle('Sustainability Metrics'),
          const SizedBox(height: 16),
          _buildMetricCard(
            'Carbon Footprint',
            'Reduced by 45%',
            Icons.trending_down,
            Colors.green,
          ),
          _buildMetricCard(
            'Water Usage',
            'Reduced by 32%',
            Icons.water_drop,
            Colors.blue,
          ),
          _buildMetricCard(
            'Waste Reduction',
            'Reduced by 67%',
            Icons.delete_sweep,
            Colors.orange,
          ),
          _buildMetricCard(
            'Renewable Energy',
            '85% usage',
            Icons.solar_power,
            Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales Overview
          _buildSectionTitle('Sales Overview'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Sales',
                  '₹45,678',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Orders',
                  '156',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Customers',
                  '89',
                  Icons.people,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Growth',
                  '+23%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Products
          _buildSectionTitle('Top Performing Products'),
          const SizedBox(height: 16),
          _buildTopProductCard(
            'Organic Cotton T-Shirt',
            '₹8,990',
            '10 sold',
            1,
          ),
          _buildTopProductCard('Bamboo Water Bottle', '₹5,390', '9 sold', 2),
          _buildTopProductCard('Reusable Shopping Bag', '₹2,690', '9 sold', 3),
        ],
      ),
    );
  }

  Widget _buildStoreStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    String orderId,
    String product,
    String price,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  product,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

  Widget _buildCategoryChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          // Handle category selection
        });
      },
      selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1976D2),
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    String description,
    String stock,
    IconData icon,
    Color color,
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 30),
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
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      stock,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
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

  Widget _buildTopProductCard(
    String name,
    String revenue,
    String sales,
    int rank,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
                  sales,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
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
        color: const Color(0xFF1976D2),
      ),
    );
  }

  // Shopkeeper action methods
  void _showAddProduct(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Add Product...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9E79F),
      ),
    );
  }

  void _showManageStock(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Stock Management...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFB5C7F7),
      ),
    );
  }

  void _showOrders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Orders...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD6EAF8),
      ),
    );
  }

  void _showEcoProducts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Eco Products...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFE8D5C4),
      ),
    );
  }

  void _showImpactReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Impact Report...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD6EAF8),
      ),
    );
  }

  void _showImprovementTips(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Improvement Tips...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9E79F),
      ),
    );
  }

  // Store Management Methods
  void _showMyStore(BuildContext context) {
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
                    'My Store Details',
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
                    _buildStoreInfoCard(),
                    const SizedBox(height: 20),
                    _buildStoreStatsCard(),
                    const SizedBox(height: 20),
                    _buildStoreActionsCard(context),
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

  void _showEditStore(BuildContext context) {
    final nameController = TextEditingController(text: 'My Eco Store');
    final descriptionController = TextEditingController(text: 'A sustainable store offering eco-friendly products');
    String selectedCategory = 'Food & Beverages';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Store Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
              items: const [
                DropdownMenuItem(value: 'Food & Beverages', child: Text('Food & Beverages')),
                DropdownMenuItem(value: 'Clothing & Fashion', child: Text('Clothing & Fashion')),
                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Home & Garden', child: Text('Home & Garden')),
                DropdownMenuItem(value: 'Personal Care', child: Text('Personal Care')),
              ],
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Store Description',
                border: OutlineInputBorder(),
                hintText: 'Tell customers about your store...',
              ),
              maxLines: 3,
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
              // Find the shopkeeper's store to update
              final shopkeeperStores = StoreProvider.getStoresByOwner('shopkeeper');
              if (shopkeeperStores.isNotEmpty) {
                final storeToUpdate = shopkeeperStores.first;
                StoreProvider.updateStore(storeToUpdate['id'], {
                  'name': nameController.text,
                  'category': selectedCategory,
                  'description': descriptionController.text,
                });
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Store details updated successfully!', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddStore(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
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
              items: const [
                DropdownMenuItem(value: 'Food & Beverages', child: Text('Food & Beverages')),
                DropdownMenuItem(value: 'Clothing & Fashion', child: Text('Clothing & Fashion')),
                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Home & Garden', child: Text('Home & Garden')),
                DropdownMenuItem(value: 'Personal Care', child: Text('Personal Care')),
              ],
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Store Description',
                border: OutlineInputBorder(),
                hintText: 'Tell customers about your store...',
              ),
              maxLines: 3,
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
                  'name': nameController.text,
                  'category': selectedCategory,
                  'status': 'Active',
                  'ownerId': 'shopkeeper', // Shopkeeper created store
                  'description': descriptionController.text.isNotEmpty ? descriptionController.text : 'A new store added by shopkeeper.',
                };
                
                StoreProvider.addStore(newStore);
                
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

  Widget _buildStoreInfoCard() {
    // Get shopkeeper's stores
    final shopkeeperStores = StoreProvider.getStoresByOwner('shopkeeper');
    final store = shopkeeperStores.isNotEmpty ? shopkeeperStores.first : null;
    
    if (store == null) {
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
            Icon(
              Icons.store_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Store Found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t created any stores yet. Use "Add Store" to create your first store!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      store['category'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
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
            ],
          ),
          const SizedBox(height: 16),
          Text(
            store['description'] ?? 'A sustainable store offering eco-friendly products.',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatsCard() {
    // Get shopkeeper's stores
    final shopkeeperStores = StoreProvider.getStoresByOwner('shopkeeper');
    final store = shopkeeperStores.isNotEmpty ? shopkeeperStores.first : null;
    
    if (store == null) {
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
            Text(
              'Store Statistics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No store data available',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
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
          Text(
            'Store Statistics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Products', '${store['products']}', Icons.inventory_rounded, const Color(0xFFB5C7F7)),
              ),
              Expanded(
                child: _buildStatItem('Orders', '${store['ordersToday']}', Icons.shopping_cart_rounded, const Color(0xFFF9E79F)),
              ),
              Expanded(
                child: _buildStatItem('Revenue', '₹${(store['revenue'] / 1000).toStringAsFixed(1)}K', Icons.currency_rupee_rounded, const Color(0xFFD6EAF8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreActionsCard(BuildContext context) {
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
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Edit Store',
                  Icons.edit_rounded,
                  const Color(0xFFB5C7F7),
                  () => _showEditStore(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Add Product',
                  Icons.add_box_rounded,
                  const Color(0xFFF9E79F),
                  () => _showAddProduct(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
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
