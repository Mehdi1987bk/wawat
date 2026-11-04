import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'isDarkMode';

  bool? _userChoice;
  bool _isInitialized = false;

  bool get isDarkMode => _userChoice ?? _systemIsDark();

  bool get followsSystem => _userChoice == null;

  bool get isInitialized => _isInitialized;

  ThemeManager();

  static Future<ThemeManager> create() async {
    final manager = ThemeManager();
    await manager._loadTheme();
    WidgetsBinding.instance.addObserver(manager);
    manager._isInitialized = true;
    return manager;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _userChoice =
        prefs.containsKey(_themeKey) ? prefs.getBool(_themeKey) : null;
  }

  bool _systemIsDark() =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void didChangePlatformBrightness() {
    if (_userChoice == null) notifyListeners();
    super.didChangePlatformBrightness();
  }

  Future<void> toggleTheme() async {
    _userChoice = !isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _userChoice!);
  }

  Future<void> setTheme(bool isDark) async {
    if (_userChoice == isDark) return;
    _userChoice = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _userChoice!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
