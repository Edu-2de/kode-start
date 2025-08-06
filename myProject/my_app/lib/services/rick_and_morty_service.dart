import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class RickAndMortyService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static Future<ApiResponse> getCharacters({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/character?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Character> getCharacterById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/character/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Character.fromJson(data);
      } else {
        throw Exception('Failed to load character');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<ApiResponse> searchCharacters(
    String name, {
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/character?page=$page&name=$name'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        throw Exception('Failed to search characters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
