import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tour_leader/core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppTheme.darkTheme;
  static const String _themeKey = 'theme_mode';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppTheme.darkTheme;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode =
        prefs.getBool(_themeKey) ?? true; // Default to dark theme
    _currentTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = _currentTheme == AppTheme.darkTheme;
    _currentTheme = isDarkMode ? AppTheme.lightTheme : AppTheme.darkTheme;
    await prefs.setBool(_themeKey, !isDarkMode);
    notifyListeners();
  }
}
