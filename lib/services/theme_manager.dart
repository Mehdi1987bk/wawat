import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme controller.
///
/// The stored preference is **nullable**: when the user has never picked a
/// theme in-app (`_userChoice == null`) the app follows the OS setting — read
/// live, so a fresh install on a light phone opens light, and toggling the
/// system theme repaints the app while it is still following the system. Once
/// the user explicitly toggles, that choice is persisted and wins until changed.
class ThemeManager extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'isDarkMode';

  /// null → follow the system; true/false → explicit user choice.
  bool? _userChoice;
  bool _isInitialized = false;

  /// Effective mode used by the whole app. Computed live so it always reflects
  /// either the user's explicit choice or the current OS brightness.
  bool get isDarkMode => _userChoice ?? _systemIsDark();

  /// Whether the app is currently deferring to the OS theme.
  bool get followsSystem => _userChoice == null;

  bool get isInitialized => _isInitialized;

  ThemeManager();

  static Future<ThemeManager> create() async {
    final manager = ThemeManager();
    await manager._loadTheme();
    // Observe OS brightness changes so we can repaint while following system.
    WidgetsBinding.instance.addObserver(manager);
    manager._isInitialized = true;
    return manager;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Absent key → follow system (null). A stored bool → explicit user choice.
    _userChoice =
        prefs.containsKey(_themeKey) ? prefs.getBool(_themeKey) : null;
  }

  bool _systemIsDark() =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void didChangePlatformBrightness() {
    // Only repaint for OS changes while we're actually following the system.
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
