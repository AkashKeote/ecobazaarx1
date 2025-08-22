import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoBazaarX'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(
                Icons.shopping_bag,
                color: Color(0xFF2196F3),
                size: 100,
              ),
              const SizedBox(height: 32),

              // Welcome Message
              Text(
                'Welcome to EcoBazaarX!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Carbon Footprint Aware Shopping Assistant',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF757575),
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // User Info Card
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            'Hello, ${authProvider.userName ?? 'User'}!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                authProvider.getRoleIcon(
                                  authProvider.userRole!,
                                ),
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                authProvider.getRoleDisplayName(
                                  authProvider.userRole!,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Role-specific content
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            _getRoleSpecificIcon(authProvider.userRole!),
                            size: 48,
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getRoleSpecificTitle(authProvider.userRole!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getRoleSpecificDescription(authProvider.userRole!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleSpecificIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_cart;
      case UserRole.shopkeeper:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleSpecificTitle(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Start Shopping!';
      case UserRole.shopkeeper:
        return 'Manage Your Store';
      case UserRole.admin:
        return 'Admin Dashboard';
    }
  }

  String _getRoleSpecificDescription(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Browse eco-friendly products and track your carbon footprint while shopping.';
      case UserRole.shopkeeper:
        return 'Add products, manage inventory, and help customers make sustainable choices.';
      case UserRole.admin:
        return 'Monitor the platform, manage users, and ensure eco-friendly practices.';
    }
  }
}
