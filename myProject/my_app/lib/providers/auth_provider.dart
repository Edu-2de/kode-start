import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getProfile();
      if (user != null) {
        _user = user;
        _isLoggedIn = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await _authService.login(email, password);

    if (response.success && response.user != null) {
      _user = response.user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } else {
      _isLoading = false;
      notifyListeners();
      return response.error ?? response.message ?? 'Login failed';
    }
  }

  Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final response = await _authService.register(username, email, password);

    if (response.success) {
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } else {
      _isLoading = false;
      notifyListeners();
      return response.error ?? response.message ?? 'Registration failed';
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (!_isLoggedIn) return;

    final user = await _authService.getProfile();
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }
}
