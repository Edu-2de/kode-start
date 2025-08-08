import 'package:flutter/material.dart';
import '../services/game_service.dart';

class GameStatsScreen extends StatefulWidget {
  const GameStatsScreen({super.key});

  @override
  GameStatsScreenState createState() => GameStatsScreenState();
}

class GameStatsScreenState extends State<GameStatsScreen> {
  final GameService _gameService = GameService();
  Map<String, dynamic>? _userStats;
  List<dynamic> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final statsResponse = await _gameService.getUserStats();
      final charactersResponse = await _gameService.getUserCharacters();

      setState(() {
        _userStats = statsResponse;
        _characters = charactersResponse['characters'] ?? [];
      });
    } catch (e) {
      //
      _showErrorDialog('Failed to load statistics');
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCharactersByRarity() {
    if (_characters.isEmpty) return SizedBox.shrink();

    // Group characters by rarity
    final rarityGroups = <String, List<dynamic>>{
      'legendary': [],
      'epic': [],
      'rare': [],
      'common': [],
    };

    for (final character in _characters) {
      final rarity = character['rarity'] ?? 'common';
      if (rarityGroups.containsKey(rarity)) {
        rarityGroups[rarity]!.add(character);
      }
    }

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
            'Characters by Rarity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),

          ...rarityGroups.entries.map((entry) {
            final rarity = entry.key;
            final characters = entry.value;
            if (characters.isEmpty) return SizedBox.shrink();

            return _buildRaritySection(rarity, characters);
          }),
        ],
      ),
    );
  }

  Widget _buildRaritySection(String rarity, List<dynamic> characters) {
    final color = _getRarityColor(rarity);

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${rarity.toUpperCase()} (${characters.length})',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(alpha: 0.5),
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(character['character_image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: 40,
                        child: Text(
                          character['character_name'],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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

  Widget _buildRecentCharacters() {
    if (_characters.isEmpty) return SizedBox.shrink();

    // Sort characters by unlock date (most recent first)
    final sortedCharacters = List<dynamic>.from(_characters);
    sortedCharacters.sort((a, b) {
      final dateA = DateTime.tryParse(a['unlocked_at'] ?? '');
      final dateB = DateTime.tryParse(b['unlocked_at'] ?? '');
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    final recentCharacters = sortedCharacters.take(5).toList();

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
            'Recently Unlocked',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),

          ...recentCharacters.map((character) {
            final rarity = character['rarity'] ?? 'common';
            final color = _getRarityColor(rarity);
            final unlockedAt = DateTime.tryParse(
              character['unlocked_at'] ?? '',
            );

            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(character['character_image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character['character_name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                rarity.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              unlockedAt != null
                                  ? _formatTimeAgo(unlockedAt)
                                  : 'Unknown',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'GAME STATS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    'Loading statistics...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_userStats != null) ...[
                        // Overview Stats
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0, // Better fit for content
                              children: [
                                _buildStatCard(
                                  title: 'Total Characters',
                                  value:
                                      (_userStats!['characters']['total'] ?? 0)
                                          .toString(),
                                  icon: Icons.people,
                                  color: Colors.blue,
                                  subtitle: 'Unlocked characters',
                                ),
                                _buildStatCard(
                                  title: 'Login Streak',
                                  value: (_userStats!['loginDays'] ?? 0)
                                      .toString(),
                                  icon: Icons.calendar_today,
                                  color: Colors.green,
                                  subtitle: 'Days logged in',
                                ),
                                _buildStatCard(
                                  title: 'Total Coins',
                                  value: (_userStats!['user']['coins'] ?? 0)
                                      .toString(),
                                  icon: Icons.monetization_on,
                                  color: Colors.yellow,
                                  subtitle: 'Current balance',
                                ),
                                _buildStatCard(
                                  title: 'Completion',
                                  value:
                                      '${((_characters.length / 826) * 100).toStringAsFixed(1)}%',
                                  icon: Icons.pie_chart,
                                  color: Colors.purple,
                                  subtitle:
                                      '${_characters.length}/826 characters',
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 30),

                        // Characters by Rarity
                        _buildCharactersByRarity(),

                        SizedBox(height: 20),

                        // Recent Characters
                        _buildRecentCharacters(),
                      ] else
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.grey[600],
                                  size: 60,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Failed to Load Stats',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Unable to fetch your game statistics',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 20), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
