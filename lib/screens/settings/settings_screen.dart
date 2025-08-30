import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditingProfile = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.userName ?? '';
    // You can add phone and address loading here when implemented
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
    final authProvider = Provider.of<AuthProvider>(context);
    
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFB5C7F7),
                child: Text(
                  _getInitials(authProvider.userName ?? 'User'),
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
                      authProvider.userName ?? 'User',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      authProvider.userEmail ?? 'user@example.com',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${authProvider.getRoleDisplayName(authProvider.userRole ?? UserRole.customer)} • 1250 Points',
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
                  setState(() {
                    _isEditingProfile = !_isEditingProfile;
                  });
                },
                icon: Icon(
                  _isEditingProfile ? Icons.close_rounded : Icons.edit_rounded,
                  color: const Color(0xFFB5C7F7),
                ),
              ),
            ],
          ),
          if (_isEditingProfile) ...[
            const SizedBox(height: 20),
            _buildProfileEditForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileEditForm() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Address',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5C7F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditingProfile = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    _loadUserData();
    setState(() {
      _isEditingProfile = false;
    });
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
          _buildDivider(),
          _buildActionTile(
            provider.anyNotificationsEnabled ? 'Disable All' : 'Enable All',
            provider.anyNotificationsEnabled 
                ? 'Turn off all notifications'
                : 'Turn on all notifications',
            provider.anyNotificationsEnabled 
                ? Icons.notifications_off_rounded
                : Icons.notifications_active_rounded,
            () {
              if (provider.anyNotificationsEnabled) {
                provider.disableAllNotifications();
              } else {
                provider.enableAllNotifications();
              }
            },
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
          _buildDivider(),
          _buildActionTile(
            'Reset to Defaults',
            'Restore all settings to their default values',
            Icons.restore_rounded,
            () => _showResetConfirmation(provider),
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
            () => _launchUrl('https://ecobazaarx.com/help'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Contact Support',
            'Get in touch with our support team',
            Icons.support_agent_rounded,
            () => _launchUrl('mailto:support@ecobazaarx.com'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Report a Bug',
            'Help us improve by reporting issues',
            Icons.bug_report_rounded,
            () => _launchUrl('mailto:bugs@ecobazaarx.com?subject=Bug Report'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Feature Request',
            'Suggest new features for the app',
            Icons.lightbulb_rounded,
            () => _launchUrl('mailto:features@ecobazaarx.com?subject=Feature Request'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Rate the App',
            'Share your experience on the app store',
            Icons.star_rounded,
            () => _launchUrl('https://play.google.com/store/apps/details?id=com.ecobazaarx.app'),
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
            () => _showVersionInfo(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description_rounded,
            () => _launchUrl('https://ecobazaarx.com/terms'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Privacy Policy',
            'Learn how we protect your data',
            Icons.privacy_tip_rounded,
            () => _launchUrl('https://ecobazaarx.com/privacy'),
          ),
          _buildDivider(),
          _buildActionTile(
            'Open Source Licenses',
            'View third-party libraries used',
            Icons.code_rounded,
            () => _showLicenses(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Follow Us',
            'Stay updated on social media',
            Icons.share_rounded,
            () => _showSocialMediaOptions(),
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
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
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

  void _showResetConfirmation(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values?',
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
              provider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5C7F7),
              foregroundColor: Colors.white,
            ),
            child: Text('Reset', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'App Version',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EcoBazaarX v1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build: 1.0.0+1',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Released: December 2024',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFFB5C7F7)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'EcoBazaarX',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 EcoBazaarX. All rights reserved.',
    );
  }

  void _showSocialMediaOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Follow Us',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSocialMediaTile('Facebook', Icons.facebook, () => _launchUrl('https://facebook.com/ecobazaarx')),
            _buildSocialMediaTile('Twitter', Icons.flutter_dash, () => _launchUrl('https://twitter.com/ecobazaarx')),
            _buildSocialMediaTile('Instagram', Icons.camera_alt, () => _launchUrl('https://instagram.com/ecobazaarx')),
            _buildSocialMediaTile('LinkedIn', Icons.business, () => _launchUrl('https://linkedin.com/company/ecobazaarx')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB5C7F7)),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
