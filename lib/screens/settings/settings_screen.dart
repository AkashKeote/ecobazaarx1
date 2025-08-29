import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Settings & Preferences',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildSectionHeader('Profile', Icons.person_rounded),
                _buildProfileCard(),
                const SizedBox(height: 24),

                // Notifications Section
                _buildSectionHeader('Notifications', Icons.notifications_rounded),
                _buildNotificationSettings(settingsProvider),
                const SizedBox(height: 24),

                // Privacy & Security Section
                _buildSectionHeader('Privacy & Security', Icons.security_rounded),
                _buildPrivacySettings(settingsProvider),
                const SizedBox(height: 24),

                // App Preferences Section
                _buildSectionHeader('App Preferences', Icons.settings_rounded),
                _buildAppPreferences(settingsProvider),
                const SizedBox(height: 24),

                // Support Section
                _buildSectionHeader('Support', Icons.help_rounded),
                _buildSupportOptions(),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About', Icons.info_rounded),
                _buildAboutSection(),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB5C7F7),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFB5C7F7),
            child: Text(
              'AK',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akash Kumar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                Text(
                  'akash@example.com',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Eco Warrior • 1250 Points',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFB5C7F7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Edit profile functionality
            },
            icon: const Icon(Icons.edit_rounded, color: Color(0xFFB5C7F7)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Push Notifications',
            'Receive notifications about orders, offers, and updates',
            Icons.notifications_active_rounded,
            provider.pushNotificationsEnabled,
            (value) => provider.setPushNotifications(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Order Updates',
            'Get notified about order status changes',
            Icons.shopping_bag_rounded,
            provider.orderNotificationsEnabled,
            (value) => provider.setOrderNotifications(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Eco Tips & Challenges',
            'Daily eco-friendly tips and challenge reminders',
            Icons.eco_rounded,
            provider.ecoTipsEnabled,
            (value) => provider.setEcoTips(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Promotional Offers',
            'Receive offers and discounts from eco-friendly stores',
            Icons.local_offer_rounded,
            provider.promotionalNotificationsEnabled,
            (value) => provider.setPromotionalNotifications(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Carbon Tracking Updates',
            'Weekly carbon footprint reports and achievements',
            Icons.trending_up_rounded,
            provider.carbonTrackingEnabled,
            (value) => provider.setCarbonTracking(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Location Services',
            'Allow app to access your location for nearby stores',
            Icons.location_on_rounded,
            provider.locationEnabled,
            (value) => provider.setLocationEnabled(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Data Collection',
            'Help improve app by sharing anonymous usage data',
            Icons.analytics_rounded,
            provider.dataCollectionEnabled,
            (value) => provider.setDataCollection(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Biometric Login',
            'Use fingerprint or face ID for quick login',
            Icons.fingerprint_rounded,
            provider.biometricEnabled,
            (value) => provider.setBiometricEnabled(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Dark Mode',
            'Switch to dark theme for better battery life',
            Icons.dark_mode_rounded,
            provider.darkModeEnabled,
            (value) => provider.setDarkMode(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Auto-Save Progress',
            'Automatically save your eco challenge progress',
            Icons.save_rounded,
            provider.autoSaveEnabled,
            (value) => provider.setAutoSave(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Haptic Feedback',
            'Feel vibrations when interacting with the app',
            Icons.vibration_rounded,
            provider.hapticFeedbackEnabled,
            (value) => provider.setHapticFeedback(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Container(
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
          _buildActionTile(
            'Help Center',
            'Find answers to common questions',
            Icons.help_center_rounded,
            () {
              // Navigate to help center
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Contact Support',
            'Get in touch with our support team',
            Icons.support_agent_rounded,
            () {
              // Contact support
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Report a Bug',
            'Help us improve by reporting issues',
            Icons.bug_report_rounded,
            () {
              // Report bug
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Feature Request',
            'Suggest new features for the app',
            Icons.lightbulb_rounded,
            () {
              // Feature request
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
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
          _buildActionTile(
            'App Version',
            'EcoBazaarX v1.0.0',
            Icons.info_rounded,
            () {
              // Show version info
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description_rounded,
            () {
              // Show terms
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Privacy Policy',
            'Learn how we protect your data',
            Icons.privacy_tip_rounded,
            () {
              // Show privacy policy
            },
          ),
          _buildDivider(),
          _buildActionTile(
            'Open Source Licenses',
            'View third-party libraries used',
            Icons.code_rounded,
            () {
              // Show licenses
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB5C7F7),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF22223B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFB5C7F7),
        activeTrackColor: const Color(0xFFB5C7F7).withOpacity(0.3),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB5C7F7),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF22223B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 72,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutConfirmation();
        },
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
