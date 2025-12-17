import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class to manage the application's theme.
///
/// It allows toggling between light and dark themes and persists the
/// user's choice across app sessions.
class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'theme_preference';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  /// Toggles the theme between light and dark mode.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(_themeMode);
    notifyListeners();
  }

  // Loads the saved theme preference from SharedPreferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Saves the current theme preference to SharedPreferences.
  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themePrefKey, themeMode == ThemeMode.dark);
  }
}