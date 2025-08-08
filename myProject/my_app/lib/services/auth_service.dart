import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../models/user.dart';

class AuthService {
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

  // Método para testar conectividade
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      // Connection test failed: $e
      return false;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      // Attempting to login user: $email
      // Using API URL: $baseUrl/auth/login

      // Test connection first
      final canConnect = await testConnection();
      if (!canConnect) {
        // Cannot connect to server
        return AuthResponse(
          success: false,
          error:
              'Cannot connect to server. Make sure the backend is running on port 3001.',
        );
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      //
      //

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
      //
      String errorMessage = 'Network error: ';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage +=
            'Cannot connect to server. Check if backend is running.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage += 'Request timeout. Server might be slow.';
      } else {
        errorMessage += e.toString();
      }

      return AuthResponse(success: false, error: errorMessage);
    }
  }

  Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      //
      //

      // Test connection first
      final canConnect = await testConnection();
      if (!canConnect) {
        //
        return AuthResponse(
          success: false,
          error:
              'Cannot connect to server. Make sure the backend is running on port 3001.',
        );
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      //
      //

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Salvar token se fornecido (pode ser null no registro)
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
        }

        return AuthResponse(
          success: true,
          token: responseData['token'], // Pode ser null
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
      //
      String errorMessage = 'Network error: ';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage +=
            'Cannot connect to server. Check if backend is running.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage += 'Request timeout. Server might be slow.';
      } else {
        errorMessage += e.toString();
      }

      return AuthResponse(success: false, error: errorMessage);
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
