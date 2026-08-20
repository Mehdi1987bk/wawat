import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Согласие пользователя на диагностику и аналитику.
///
/// Зачем отдельный слой, а не «всегда включено»:
///  • **App Store** — App Privacy требует, чтобы сбор «Product Interaction» и
///    «Crash Data» был отключаемым, если он не критичен для работы приложения;
///  • **Google Play Data safety** — раздел «Data collection is optional»
///    можно заявить только при наличии реального переключателя;
///  • **GDPR/GDPR-подобные законы** (пользователи из ЕС/UK) — сбор аналитики
///    должен отключаться без потери функциональности.
///
/// По умолчанию оба флага включены: это legitimate-interest диагностика без
/// рекламных идентификаторов и без передачи данных третьим лицам для рекламы
/// (AD_ID из манифеста удалён — см. `AndroidManifest.xml`). Пользователь может
/// выключить в «Параметrlər → Məxfilik».
class TelemetryConsent extends ChangeNotifier {
  TelemetryConsent._();

  static final TelemetryConsent instance = TelemetryConsent._();

  static const _kAnalytics = 'telemetry_analytics_enabled';
  static const _kCrash = 'telemetry_crash_enabled';

  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _loaded = false;

  /// Разрешена ли продуктовая аналитика (события, экраны, воронки).
  bool get analyticsEnabled => _analyticsEnabled;

  /// Разрешены ли отчёты о падениях и не-фатальных ошибках.
  bool get crashReportsEnabled => _crashReportsEnabled;

  bool get isLoaded => _loaded;

  /// Читает сохранённый выбор. Ошибка чтения не должна ломать старт — тогда
  /// остаются значения по умолчанию.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool(_kAnalytics) ?? true;
      _crashReportsEnabled = prefs.getBool(_kCrash) ?? true;
    } catch (_) {
      // оставляем дефолты
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
      // Не критично: флаг уже применён в памяти на текущую сессию.
    }
  }
}
