import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import 'memory_game_screen.dart';
import 'dart:async';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  GamesScreenState createState() => GamesScreenState();
}

class GamesScreenState extends State<GamesScreen> {
  final GameService _gameService = GameService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _canPlayRandomGame = true;
  Map<String, dynamic>? _timeRemaining;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkRandomGameAvailability();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_canPlayRandomGame && _timeRemaining != null) {
        final total = _timeRemaining!['total'] ?? 0;
        if (total > 1000) {
          // Se ainda há mais de 1 segundo
          setState(() {
            final newTotal = total - 1000; // Subtrai 1 segundo
            final hours = (newTotal / (1000 * 60 * 60)).floor();
            final minutes = ((newTotal % (1000 * 60 * 60)) / (1000 * 60))
                .floor();
            final seconds = ((newTotal % (1000 * 60)) / 1000).floor();

            _timeRemaining = {
              'hours': hours,
              'minutes': minutes,
              'seconds': seconds,
              'total': newTotal,
            };
          });
        } else {
          // Timer acabou, verificar novamente a disponibilidade
          _checkRandomGameAvailability();
        }
      }
    });
  }

  Future<void> _checkRandomGameAvailability() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final response = await _gameService.canPlayRandomGame(token);

      if (response['success'] == true) {
        setState(() {
          _canPlayRandomGame = response['canPlay'] ?? true;
          _timeRemaining = response['timeRemaining'];
        });
      }
    } catch (e) {
      // Error checking game availability: $e
    }
  }

  Future<void> _playRandomCharacterGame() async {
    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        if (mounted) _showErrorDialog('Please login again');
        return;
      }

      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _gameService.playRandomCharacterGame(token);

      if (response['success'] == true) {
        // Update user coins
        await authProvider.refreshProfile();

        // Show success dialog
        if (mounted) _showCharacterDialog(response);

        // Update availability
        await _checkRandomGameAvailability();
      } else {
        if (mounted) {
          _showErrorDialog(response['message'] ?? 'Failed to play game');
        }
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCharacterDialog(Map<String, dynamic> response) {
    final character = response['character'];
    final alreadyUnlocked = response['alreadyUnlocked'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Character image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: _getRarityColor(character['rarity'] ?? 'common'),
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(57),
                    child: Image.network(
                      character['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.error, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Character name
                Text(
                  character['name'].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // Rarity
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRarityColor(character['rarity'] ?? 'common'),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    (character['rarity'] ?? 'common').toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Message
                Text(
                  alreadyUnlocked
                      ? '⭐ Already unlocked! You received ${response['bonusCoins']} bonus coins!'
                      : '🎉 New character unlocked!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Close button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Cool!', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
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
          title: Text('Error', style: TextStyle(color: Colors.white)),
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

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  String _formatTimeRemaining() {
    if (_timeRemaining == null) return '';

    final hours = _timeRemaining!['hours'] ?? 0;
    final minutes = _timeRemaining!['minutes'] ?? 0;
    final seconds = _timeRemaining!['seconds'] ?? 0;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'GAMES',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Choose Your Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Play games to unlock new characters and earn coins!',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    SizedBox(height: 30),

                    // Random Character Game Card
                    _buildGameCard(
                      title: 'RANDOM CHARACTER',
                      subtitle: 'Get a random character',
                      description:
                          'Unlock a random Rick & Morty character. Only once per day!',
                      cost: '10 COINS',
                      icon: Icons.shuffle,
                      color: Colors.green,
                      canPlay: _canPlayRandomGame,
                      timeRemaining: _canPlayRandomGame
                          ? null
                          : _formatTimeRemaining(),
                      onTap: _canPlayRandomGame && !_isLoading
                          ? _playRandomCharacterGame
                          : null,
                    ),

                    SizedBox(height: 20),

                    // Memory Game Card
                    _buildGameCard(
                      title: 'MEMORY GAME',
                      subtitle: 'Find the character card',
                      description:
                          '3 cards, 1 character. Memorize and find it after shuffle!',
                      cost: '5 COINS',
                      icon: Icons.psychology,
                      color: Colors.purple,
                      canPlay: true,
                      onTap: !_isLoading
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoryGameScreen(),
                                ),
                              );
                            }
                          : null,
                    ),

                    SizedBox(height: 30), // Extra space before coins
                  ],
                ),
              ),
            ),

            // Fixed coins display at bottom
            Container(
              padding: EdgeInsets.all(20),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.yellow,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${authProvider.user?.coins ?? 0} COINS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String description,
    required String cost,
    required IconData icon,
    required Color color,
    required bool canPlay,
    String? timeRemaining,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: canPlay && onTap != null
              ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
              : Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canPlay
                        ? color.withValues(alpha: 0.2)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: canPlay ? color : Colors.grey[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: canPlay ? Colors.white : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (canPlay)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cost,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              description,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            if (!canPlay && timeRemaining != null) ...[
              SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: 20),
                    SizedBox(height: 8),
                    Text(
                      'Next available in:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      timeRemaining,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
