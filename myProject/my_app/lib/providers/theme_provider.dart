import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppStyle { modern, classic }

class ThemeProvider with ChangeNotifier {
  AppStyle _currentStyle = AppStyle.modern;

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

  ThemeData _createModernTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F0F0F),
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

  ThemeData get modernTheme => _modernTheme;
  ThemeData get classicTheme => _classicTheme;

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
