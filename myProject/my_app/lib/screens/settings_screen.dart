import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _soundEffects = true;
  bool _animations = true;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );

                // Perform logout
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Close loading and navigate to login
                Navigator.of(context).pop(); // Close loading
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('About', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rick & Morty Character Collector',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('Version 1.0.0', style: TextStyle(color: Colors.grey[400])),
              SizedBox(height: 15),
              Text(
                'Collect your favorite Rick & Morty characters through exciting mini-games! Earn coins, unlock rare characters, and build your ultimate collection.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 15),
              Text(
                'Data provided by the Rick and Morty API',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 10, top: 20),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              )
            : null,
        trailing:
            trailing ??
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: iconColor,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[800],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  if (user == null) return SizedBox.shrink();

                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.purple.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: Colors.yellow,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${user.coins} coins',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Game Settings
              _buildSectionTitle('Game Settings'),
              _buildSwitchTile(
                title: 'Notifications',
                subtitle: 'Get notified about daily bonuses',
                icon: Icons.notifications,
                iconColor: Colors.orange,
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Sound Effects',
                subtitle: 'Play sounds during games',
                icon: Icons.volume_up,
                iconColor: Colors.green,
                value: _soundEffects,
                onChanged: (value) {
                  setState(() {
                    _soundEffects = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Animations',
                subtitle: 'Enable smooth animations',
                icon: Icons.animation,
                iconColor: Colors.purple,
                value: _animations,
                onChanged: (value) {
                  setState(() {
                    _animations = value;
                  });
                },
              ),

              // Account Settings
              _buildSectionTitle('Account'),
              _buildSettingsTile(
                title: 'Profile',
                subtitle: 'View and edit your profile',
                icon: Icons.person,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _buildSettingsTile(
                title: 'My Characters',
                subtitle: 'View your character collection',
                icon: Icons.collections,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/my-characters');
                },
              ),
              _buildSettingsTile(
                title: 'Game Statistics',
                subtitle: 'View detailed game stats',
                icon: Icons.bar_chart,
                iconColor: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/game-stats');
                },
              ),

              // Support & Info
              _buildSectionTitle('Support & Information'),
              _buildSettingsTile(
                title: 'About',
                subtitle: 'App version and information',
                icon: Icons.info,
                iconColor: Colors.blue,
                onTap: _showAboutDialog,
              ),
              _buildSettingsTile(
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                icon: Icons.help,
                iconColor: Colors.green,
                onTap: () {
                  // TODO: Implement help screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Help feature coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // Logout Button
              _buildSettingsTile(
                title: 'Logout',
                subtitle: 'Sign out of your account',
                icon: Icons.logout,
                iconColor: Colors.red,
                trailing: null,
                onTap: _showLogoutDialog,
              ),

              SizedBox(height: 30),

              // App Version Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Rick & Morty Character Collector',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.grey[700], fontSize: 10),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20), // Bottom padding to prevent overflow
            ],
          ),
        ),
      ),
    );
  }
}
