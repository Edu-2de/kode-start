import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import 'dart:async';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  MemoryGameScreenState createState() => MemoryGameScreenState();
}

class MemoryGameScreenState extends State<MemoryGameScreen> {
  final GameService _gameService = GameService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _gameStarted = false;
  bool _cardsRevealed = true;
  bool _gameEnded = false;

  String? _gameId;
  Map<String, dynamic>? _character;
  List<Map<String, dynamic>> _cards = [];
  int? _selectedCard;
  Timer? _memoryTimer;
  int _memoryTimeLeft = 3;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        _showErrorDialog('Please login again');
        return;
      }

      final response = await _gameService.startMemoryGame(token);

      if (response['success'] == true) {
        setState(() {
          _gameId = response['gameId'];
          _character = response['character'];
          _cards = List<Map<String, dynamic>>.from(response['cards']);
          _gameStarted = true;
          _cardsRevealed = true;
          _memoryTimeLeft = 3;
        });

        _startMemoryTimer();
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to start game');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startMemoryTimer() {
    _memoryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _memoryTimeLeft--;
      });

      if (_memoryTimeLeft <= 0) {
        timer.cancel();
        setState(() {
          _cardsRevealed = false;
        });
      }
    });
  }

  Future<void> _selectCard(int position) async {
    if (_cardsRevealed || _gameEnded || _selectedCard != null) return;

    setState(() {
      _selectedCard = position;
      _isLoading = true;
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        if (mounted) _showErrorDialog('Please login again');
        return;
      }

      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _gameService.submitMemoryGameGuess(
        token,
        _gameId!,
        position,
      );

      if (response['success'] == true) {
        if (mounted) setState(() => _gameEnded = true);

        // Update user coins
        await authProvider.refreshProfile();

        // Show result dialog
        if (mounted) _showResultDialog(response);
      } else {
        if (mounted)
          _showErrorDialog(response['message'] ?? 'Failed to submit guess');
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> response) {
    final isCorrect = response['correct'] ?? false;
    final coinsEarned = response['coinsEarned'] ?? 0;
    final correctPosition = response['correctPosition'];
    final character = response['character'];

    showDialog(
      context: context,
      barrierDismissible: false,
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
                // Result icon
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 60,
                ),
                SizedBox(height: 15),

                // Result title
                Text(
                  isCorrect ? 'CORRECT!' : 'WRONG!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Character image
                if (character != null) ...[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.grey[600]!, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Image.network(
                        character['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    character['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                ],

                // Message
                Text(
                  isCorrect
                      ? 'You found the character!\n+$coinsEarned coins'
                      : 'The character was in position ${correctPosition + 1}.\nBetter luck next time!',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Back to Games',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Play Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _gameStarted = false;
      _cardsRevealed = true;
      _gameEnded = false;
      _gameId = null;
      _character = null;
      _cards = [];
      _selectedCard = null;
      _memoryTimeLeft = 3;
    });

    _memoryTimer?.cancel();
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'MEMORY GAME',
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
      body: _isLoading && !_gameStarted
          ? Center(child: CircularProgressIndicator(color: Colors.purple))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Instructions
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Find the character!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Memorize which card has the character, then find it after the cards flip!',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Character info (during memorization)
                          if (_character != null && _cardsRevealed) ...[
                            Text(
                              'Remember this character:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(38),
                                child: Image.network(
                                  _character!['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _character!['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],

                          // Timer (during memorization)
                          if (_cardsRevealed && _memoryTimeLeft > 0) ...[
                            Text(
                              'Cards will flip in: $_memoryTimeLeft',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],

                          // Game area
                          if (_gameStarted) ...[
                            SizedBox(
                              height: 200, // Fixed height for game area
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: _cards.asMap().entries.map((
                                        entry,
                                      ) {
                                        int index = entry.key;
                                        Map<String, dynamic> card = entry.value;
                                        bool isSelected =
                                            _selectedCard == index;
                                        bool hasCharacter =
                                            card['hasCharacter'] ?? false;

                                        return GestureDetector(
                                          onTap: () => _selectCard(index),
                                          child: Container(
                                            width: 100,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: _cardsRevealed
                                                  ? (hasCharacter
                                                        ? Colors.purple
                                                              .withValues(
                                                                alpha: 0.3,
                                                              )
                                                        : Colors.grey[800])
                                                  : (isSelected
                                                        ? Colors.purple
                                                              .withValues(
                                                                alpha: 0.5,
                                                              )
                                                        : Colors.grey[800]),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: _cardsRevealed
                                                    ? (hasCharacter
                                                          ? Colors.purple
                                                          : Colors.grey[600]!)
                                                    : (isSelected
                                                          ? Colors.purple
                                                          : Colors.grey[600]!),
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (_cardsRevealed &&
                                                    hasCharacter &&
                                                    _character != null) ...[
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      child: Image.network(
                                                        _character!['image'],
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                color: Colors
                                                                    .grey[700],
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Icon(
                                                    Icons.help_outline,
                                                    color: Colors.grey[600],
                                                    size: 40,
                                                  ),
                                                ],
                                                SizedBox(height: 8),
                                                Text(
                                                  'Card ${index + 1}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    if (!_cardsRevealed && !_gameEnded) ...[
                                      SizedBox(height: 30),
                                      Text(
                                        'Which card has the character?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],

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
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${authProvider.user?.coins ?? 0} COINS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
}
