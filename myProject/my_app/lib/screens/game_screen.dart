import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/game_service.dart';
import 'login_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  bool _isUnlocking = false;
  bool _isClaimingBonus = false;
  Map<String, dynamic>? _userStats;
  List<dynamic> _unlockedCharacters = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    _loadUserData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return;

    try {
      final stats = await _gameService.getUserStats();
      final characters = await _gameService.getUserCharacters();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _unlockedCharacters = characters['characters'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _unlockCharacter() async {
    setState(() {
      _isUnlocking = true;
    });

    try {
      final result = await _gameService.unlockCharacter();

      if (mounted) {
        _showUnlockResult(result);
        await _loadUserData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<void> _claimDailyBonus() async {
    setState(() {
      _isClaimingBonus = true;
    });

    try {
      final result = await _gameService.getDailyBonus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Daily bonus claimed!'),
            backgroundColor: Colors.green[800],
          ),
        );
        await _loadUserData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClaimingBonus = false;
        });
      }
    }
  }

  void _showUnlockResult(Map<String, dynamic> result) {
    final character = result['character'];
    final rarity = character['rarity'] ?? 'common';
    final isAlreadyUnlocked = result['alreadyUnlocked'] ?? false;

    Color rarityColor = Colors.grey;
    switch (rarity) {
      case 'rare':
        rarityColor = Colors.blue;
        break;
      case 'epic':
        rarityColor = Colors.purple;
        break;
      case 'legendary':
        rarityColor = Colors.orange;
        break;
      default:
        rarityColor = Colors.grey;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isAlreadyUnlocked ? 'Already Unlocked!' : 'Character Unlocked!',
          style: TextStyle(color: Colors.grey[300]),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rarityColor, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(character['image'], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              character['name'],
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rarity.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isAlreadyUnlocked) ...[
              const SizedBox(height: 12),
              Text(
                '+${result['bonusCoins']} Bonus Coins!',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cool!', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return Scaffold(
            backgroundColor: const Color(0xFF000000),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.games, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 24),
                    Text(
                      'You need to be logged in to play!',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login to unlock characters, collect coins, and build your collection!',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login to Play',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Character Game',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.yellow[700],
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_userStats?['user']?['coins'] ?? 0}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadUserData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily bonus section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: Colors.green[400],
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Daily Login Bonus',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get 5 coins every day!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isClaimingBonus
                                ? null
                                : _claimDailyBonus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isClaimingBonus
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Claim Daily Bonus'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unlock character section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0x4D4A148C),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shuffle,
                                  color: Colors.purple[300],
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unlock Random Character',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cost: 10 coins',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isUnlocking ? null : _unlockCharacter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isUnlocking
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Unlocking...'),
                                    ],
                                  )
                                : const Text(
                                    'Unlock Character',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats section
                  if (_userStats != null) ...[
                    Text(
                      'Your Collection',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatsCard(
                          'Characters',
                          '${_userStats!['characters']['total']}',
                          Icons.people,
                        ),
                        _buildStatsCard(
                          'Login Days',
                          '${_userStats!['loginDays']}',
                          Icons.calendar_today,
                        ),
                        _buildStatsCard(
                          'Legendary',
                          '${_userStats!['characters']['legendary']}',
                          Icons.star,
                        ),
                        _buildStatsCard(
                          'Epic',
                          '${_userStats!['characters']['epic']}',
                          Icons.diamond,
                        ),
                      ],
                    ),
                  ],

                  // Recent characters
                  if (_unlockedCharacters.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Recent Unlocks',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _unlockedCharacters.take(10).length,
                        itemBuilder: (context, index) {
                          final character = _unlockedCharacters[index];
                          Color rarityColor = Colors.grey;
                          switch (character['rarity']) {
                            case 'rare':
                              rarityColor = Colors.blue;
                              break;
                            case 'epic':
                              rarityColor = Colors.purple;
                              break;
                            case 'legendary':
                              rarityColor = Colors.orange;
                              break;
                          }

                          return Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: rarityColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      character['character_image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  character['character_name'],
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
