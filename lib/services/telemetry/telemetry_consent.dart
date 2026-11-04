import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelemetryConsent extends ChangeNotifier {
  TelemetryConsent._();

  static final TelemetryConsent instance = TelemetryConsent._();

  static const _kAnalytics = 'telemetry_analytics_enabled';
  static const _kCrash = 'telemetry_crash_enabled';

  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _loaded = false;

  bool get analyticsEnabled => _analyticsEnabled;

  bool get crashReportsEnabled => _crashReportsEnabled;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool(_kAnalytics) ?? true;
      _crashReportsEnabled = prefs.getBool(_kCrash) ?? true;
    } catch (_) {
    } finally {
      _loaded = true;
    }
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    if (_analyticsEnabled == value) return;
    _analyticsEnabled = value;
    notifyListeners();
    await _persist(_kAnalytics, value);
  }

  Future<void> setCrashReportsEnabled(bool value) async {
    if (_crashReportsEnabled == value) return;
    _crashReportsEnabled = value;
    notifyListeners();
    await _persist(_kCrash, value);
  }

  Future<void> _persist(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
    }
  }
}
