import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/game_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final GameService _gameService = GameService();
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoading = true);

    try {
      final response = await _gameService.getUserStats();
      setState(() {
        _userStats = response;
      });
    } catch (e) {
      //
      _showErrorDialog('Failed to load profile data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimDailyBonus() async {
    try {
      final response = await _gameService.getDailyBonus();

      // Update user coins in provider
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshProfile();
      }

      if (mounted) {
        _showSuccessDialog(
          'Daily bonus claimed!',
          'You received ${response['coinsReceived']} coins!',
        );
      }

      // Reload stats to reflect changes
      _loadUserStats();
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Great!', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Info', style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          SizedBox(height: 15),

          // Username
          Text(
            user.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),

          // Email
          Text(
            user.email,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          SizedBox(height: 15),

          // Coins Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.yellow.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                SizedBox(width: 8),
                Text(
                  '${user.coins} Coins',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
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

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityStats() {
    if (_userStats == null) return SizedBox.shrink();

    final characters = _userStats!['characters'] ?? {};

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Character Collection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildRarityItem(
                  'Common',
                  characters['common'] ?? 0,
                  Colors.grey,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildRarityItem(
                  'Rare',
                  characters['rare'] ?? 0,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildRarityItem(
                  'Epic',
                  characters['epic'] ?? 0,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildRarityItem(
                  'Legendary',
                  characters['legendary'] ?? 0,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRarityItem(String rarity, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            rarity,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  String _formatMemberSince(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      return '${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadUserStats),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (_userStats == null) {
                      return Center(
                        child: Text(
                          'Failed to load profile data',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final user = _userStats!['user'] ?? {};
                    final characters = _userStats!['characters'] ?? {};
                    final loginDays = _userStats!['loginDays'] ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        _buildProfileHeader(authProvider),
                        SizedBox(height: 25),

                        // Stats Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.1, // Adjusted for better fit
                              children: [
                                _buildStatItem(
                                  'Characters\nUnlocked',
                                  (characters['total'] ?? 0).toString(),
                                  Icons.people,
                                  Colors.blue,
                                ),
                                _buildStatItem(
                                  'Login Days',
                                  loginDays.toString(),
                                  Icons.calendar_today,
                                  Colors.green,
                                ),
                                _buildStatItem(
                                  'Member Since',
                                  _formatMemberSince(user['memberSince']),
                                  Icons.access_time,
                                  Colors.purple,
                                ),
                                _buildStatItem(
                                  'Total Coins',
                                  (user['coins'] ?? 0).toString(),
                                  Icons.monetization_on,
                                  Colors.yellow,
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 25),

                        // Rarity Stats
                        _buildRarityStats(),

                        SizedBox(height: 25),

                        // Action Buttons
                        _buildActionButton(
                          title: 'Daily Bonus',
                          subtitle: 'Claim your daily coins',
                          icon: Icons.card_giftcard,
                          color: Colors.orange,
                          onTap: _claimDailyBonus,
                        ),

                        SizedBox(height: 15),

                        _buildActionButton(
                          title: 'My Characters',
                          subtitle: 'View your collection',
                          icon: Icons.collections,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, '/my-characters');
                          },
                        ),

                        SizedBox(height: 15),

                        _buildActionButton(
                          title: 'Game Stats',
                          subtitle: 'View detailed statistics',
                          icon: Icons.bar_chart,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, '/game-stats');
                          },
                        ),

                        SizedBox(height: 20), // Bottom padding
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
