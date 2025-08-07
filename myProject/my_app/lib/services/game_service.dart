import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  // Detecta automaticamente a URL correta baseada na plataforma
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api'; // Emulador Android
    } else if (Platform.isIOS) {
      return 'http://localhost:3001/api'; // iOS Simulator
    } else {
      return 'http://localhost:3001/api'; // Web/Desktop
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Check if user can play random character game today
  Future<Map<String, dynamic>> canPlayRandomGame(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/can-play-random'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, ...json.decode(response.body)};
    } else {
      return {'success': false, 'message': 'Failed to check game availability'};
    }
  }

  // Play random character game (once per day)
  Future<Map<String, dynamic>> playRandomCharacterGame(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/random-character'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, ...json.decode(response.body)};
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      return {'success': false, 'message': error['message'] ?? error['error']};
    } else {
      return {'success': false, 'message': 'Failed to play game'};
    }
  }

  // Start memory game
  Future<Map<String, dynamic>> startMemoryGame(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/memory-game/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, ...json.decode(response.body)};
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      return {'success': false, 'message': error['message'] ?? error['error']};
    } else {
      return {'success': false, 'message': 'Failed to start memory game'};
    }
  }

  // Submit memory game guess
  Future<Map<String, dynamic>> submitMemoryGameGuess(
    String token,
    String gameId,
    int selectedPosition,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/memory-game/guess'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'gameId': gameId,
        'selectedPosition': selectedPosition,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, ...json.decode(response.body)};
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to submit guess',
      };
    }
  }

  // Unlock a random character (legacy method)
  Future<Map<String, dynamic>> unlockCharacter() async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/game/unlock-character'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Not enough coins');
    } else {
      throw Exception('Failed to unlock character');
    }
  }

  // Get user's unlocked characters
  Future<Map<String, dynamic>> getUserCharacters() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/game/characters'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch characters');
    }
  }

  // Claim daily bonus
  Future<Map<String, dynamic>> getDailyBonus() async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/game/daily-bonus'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Daily bonus already claimed');
    } else {
      throw Exception('Failed to claim daily bonus');
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/game/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user stats');
    }
  }
}
