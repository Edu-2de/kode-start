import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/login_screen.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isModernTheme = themeProvider.currentStyle == AppStyle.modern;

    if (!authProvider.isLoggedIn || authProvider.user == null) {
      return IconButton(
        icon: ClipOval(
          child: Image.asset(
            'assets/images/icon.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
      );
    }

    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: isModernTheme ? Colors.green : Colors.blue,
        child: Text(
          authProvider.user!.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: _buildUserInfo(authProvider.user!, isModernTheme),
        ),
        _buildMenuItem('profile', Icons.person, 'Profile'),
        _buildMenuItem('stats', Icons.bar_chart, 'Game Stats'),
        _buildMenuItem('characters', Icons.collections, 'My Characters'),
        _buildMenuItem('settings', Icons.settings, 'Settings'),
        _buildMenuItem('logout', Icons.logout, 'Logout', color: Colors.red),
      ],
      onSelected: (String value) => _handleMenuSelection(
        context,
        value,
        authProvider,
        themeProvider,
        isModernTheme,
      ),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String title, {
    Color? color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildUserInfo(user, bool isModernTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isModernTheme ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 12,
            color: isModernTheme ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isModernTheme
                ? const Color(0x33009688)
                : const Color(0x332196F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on,
                size: 16,
                color: isModernTheme ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                '${user.coins} coins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isModernTheme ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _handleMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
    ThemeProvider themeProvider,
    bool isModernTheme,
  ) {
    switch (value) {
      case 'profile':
        _showProfileDialog(context, authProvider.user!, isModernTheme);
        break;
      case 'stats':
        _showStatsDialog(context, isModernTheme);
        break;
      case 'characters':
        _showCharactersDialog(context, isModernTheme);
        break;
      case 'settings':
        _showSettingsDialog(context, themeProvider, isModernTheme);
        break;
      case 'logout':
        _showLogoutConfirmation(context, authProvider, isModernTheme);
        break;
    }
  }

  void _showProfileDialog(BuildContext context, user, bool isModernTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoCard('Name', user.name),
            _buildInfoCard('Email', user.email),
            _buildInfoCard('Coins', '${user.coins}'),
            _buildInfoCard('Total Earned', '${user.totalCoinsEarned}'),
            _buildInfoCard(
              'Member Since',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
          ],
        ),
        actions: [
          _buildDialogButton(
            'Close',
            Colors.green,
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, bool isModernTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Game Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Coming soon! Your game statistics will be displayed here.',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ),
        actions: [
          _buildDialogButton(
            'Close',
            Colors.green,
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showCharactersDialog(BuildContext context, bool isModernTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'My Characters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Your unlocked characters will be displayed here soon!',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ),
        actions: [
          _buildDialogButton(
            'Close',
            Colors.green,
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isModernTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.palette_outlined, color: Colors.white),
              title: const Text('Theme', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                themeProvider.currentStyle == AppStyle.modern
                    ? 'Modern'
                    : 'Classic',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: Switch(
                value: themeProvider.currentStyle == AppStyle.modern,
                onChanged: (value) => themeProvider.toggleStyle(),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.blue,
              ),
            ),
          ),
          actions: [
            _buildDialogButton(
              'Close',
              Colors.green,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
    bool isModernTheme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ),
        actions: [
          _buildDialogButton(
            'Cancel',
            Colors.grey,
            () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          _buildDialogButton('Logout', Colors.red, () async {
            Navigator.pop(context);
            await authProvider.logout();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color == Colors.green
            ? const Color(0x33009688)
            : color == Colors.red
            ? const Color(0x33F44336)
            : const Color(0x33757575),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}
