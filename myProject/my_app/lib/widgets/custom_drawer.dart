import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/search_screen.dart';
import '../screens/filter_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const CustomDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final style = themeProvider.currentStyle;
        final drawerColor = style == AppStyle.modern
            ? const Color(0xFF1F1F1F) // Cor do header no modern
            : const Color(0xFF1A1A1A);

        return Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: drawerColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Drawer header...
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 60,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'RICK AND MORTY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'API',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 32),

                // Menu items...
                Expanded(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.home,
                        title: 'Home',
                        subtitle: 'All characters',
                        onTap: () {
                          // Close drawer using callback if available
                          if (onClose != null) {
                            onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.search,
                        title: 'Search',
                        subtitle: 'Find characters',
                        onTap: () {
                          // Close drawer using callback if available
                          if (onClose != null) {
                            onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.filter_alt,
                        title: 'Filters',
                        subtitle: 'Filter by category',
                        onTap: () {
                          // Close drawer using callback if available
                          if (onClose != null) {
                            onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FilterScreen(),
                            ),
                          );
                        },
                      ),
                      // Style/theme selector - Super simplified version
                      _buildMenuItem(
                        context,
                        icon: Icons.palette,
                        title: 'Change Theme',
                        subtitle: themeProvider.currentStyle == AppStyle.modern
                            ? 'Switch to Classic'
                            : 'Switch to Modern',
                        onTap: () {
                          // Make theme change
                          themeProvider.toggleStyle();

                          // Close drawer using HomeScreen callback
                          if (onClose != null) {
                            onClose!();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Footer...
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(height: 1, color: Colors.grey[800]),
                      const SizedBox(height: 16),
                      Text(
                        'Made with ❤️ using Rick and Morty API',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // Special color for palette icon
    final iconColor = icon == Icons.palette ? Colors.purple : Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const DrawerOverlay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }
}
