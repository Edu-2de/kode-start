import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Para dispositivo físico, use:
  // static const String baseUrl = 'http://SEU_IP:3000/api';

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Salvar token
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
        }

        return AuthResponse(
          success: true,
          token: responseData['token'],
          user: responseData['user'] != null
              ? User.fromJson(responseData['user'])
              : null,
          message: responseData['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          error: responseData['error'] ?? 'Login failed',
          message: responseData['message'],
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: 'Network error: $e');
    }
  }

  Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Salvar token se fornecido
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
        }

        return AuthResponse(
          success: true,
          token: responseData['token'],
          user: responseData['user'] != null
              ? User.fromJson(responseData['user'])
              : null,
          message: responseData['message'] ?? 'Registration successful',
        );
      } else {
        return AuthResponse(
          success: false,
          error: responseData['error'] ?? 'Registration failed',
          message: responseData['message'],
        );
      }
    } catch (e) {
      return AuthResponse(success: false, error: 'Network error: $e');
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      await _removeToken();
      return true;
    } catch (e) {
      // Mesmo se der erro na API, remove o token localmente
      await _removeToken();
      return true;
    }
  }

  Future<User?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return User.fromJson(responseData['user']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Verificar se o token ainda é válido
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
