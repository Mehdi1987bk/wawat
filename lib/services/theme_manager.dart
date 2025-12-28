import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeManager();

   static Future<ThemeManager> create() async {
    final manager = ThemeManager();
    await manager._loadTheme();
    manager._isInitialized = true;
    return manager;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;

    _isDarkMode = isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
