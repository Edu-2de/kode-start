import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppStyle { modern, classic }

class ThemeProvider with ChangeNotifier {
  AppStyle _currentStyle = AppStyle.modern;

  // Cache dos temas para evitar recriação
  late ThemeData _modernTheme;
  late ThemeData _classicTheme;

  ThemeProvider() {
    _initializeThemes();
  }

  void _initializeThemes() {
    _modernTheme = _createModernTheme();
    _classicTheme = _createClassicTheme();
  }

  AppStyle get currentStyle => _currentStyle;

  // Métodos privados para criar os temas
  ThemeData _createModernTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF18181B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF18181B),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      surface: const Color(0xFF18181B),
    ),
  );

  ThemeData _createClassicTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
      surface: const Color(0xFF1A1A1A),
    ),
  );

  // Getters que retornam os temas em cache
  ThemeData get modernTheme => _modernTheme;
  ThemeData get classicTheme => _classicTheme;

  // Retorna o tema atual baseado no estilo
  ThemeData get currentTheme {
    return _currentStyle == AppStyle.modern ? _modernTheme : _classicTheme;
  }

  void toggleStyle() {
    _currentStyle = _currentStyle == AppStyle.modern
        ? AppStyle.classic
        : AppStyle.modern;

    notifyListeners();
  }

  void setStyle(AppStyle style) {
    if (_currentStyle != style) {
      _currentStyle = style;
      notifyListeners();
    }
  }
}
