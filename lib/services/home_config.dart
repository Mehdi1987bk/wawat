import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

/// Backend-controlled startup configuration for the home shell.
///
/// Today it decides **which bottom-nav tab is active on cold start** — the
/// first tab (Главная, index 0) or the second (Поиск, index 1). The value comes
/// from a single endpoint (`GET /app/config`) so the choice can be flipped
/// server-side with no app release.
///
/// Zero-lag contract: the resolved index is produced **before** `HomeScreen`
/// builds (the splash screen already waits, so the fetch hides inside that
/// window). If the network is slow or offline we fall back to the value cached
/// from the previous launch, so Home always opens on the correct tab from the
/// very first frame — it never opens on one tab and then jumps to another.
class HomeConfig {
  HomeConfig._();

  static final HomeConfig instance = HomeConfig._();

  static const String _baseUrl = 'https://api.wawatair.com/api/v1';
  static const String _endpoint = '$_baseUrl/app/config';
  static const String _prefsKey = 'home_default_tab';

  /// Bottom-nav indexes the backend is allowed to pick as the landing tab.
  static const int _homeTab = 0;
  static const int _searchTab = 1;

  /// The last value we successfully cached, kept in memory so a second reader
  /// in the same launch doesn't touch disk again.
  int? _memory;

  /// Reads the cached landing tab (previous launch's value, or 0 on a fresh
  /// install). Cheap — used as the instant fallback.
  Future<int> cachedDefaultTab() async {
    if (_memory != null) return _memory!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memory = _clamp(prefs.getInt(_prefsKey));
    } catch (_) {
      _memory = _homeTab;
    }
    return _memory!;
  }

  /// Asks the backend for the current landing tab and caches it for this and the
  /// next launch. On any failure returns the cached value — never throws, so it
  /// is safe to `await` on the startup path. Callers should still bound it with
  /// a timeout so a hung request cannot delay the splash beyond its window.
  Future<int> refreshDefaultTab() async {
    final fallback = await cachedDefaultTab();
    try {
      final response = await sl
          .get<Dio>()
          .get<Map<String, dynamic>>(_endpoint);
      final resolved = _parse(response.data);
      if (resolved == null) return fallback;
      _memory = resolved;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefsKey, resolved);
      } catch (_) {
        // Cache write is best-effort; the in-memory value still applies now.
      }
      return resolved;
    } catch (_) {
      return fallback;
    }
  }

  /// Accepts `{"data": {"default_tab": 0}}`, a top-level `default_tab`, an int,
  /// or the strings "home"/"search" — whichever the backend ends up sending.
  int? _parse(Map<String, dynamic>? json) {
    if (json == null) return null;
    final data = json['data'];
    final raw = (data is Map ? data['default_tab'] : null) ??
        json['default_tab'];
    if (raw == null) return null;
    if (raw is num) return _clamp(raw.toInt());
    final text = raw.toString().trim().toLowerCase();
    switch (text) {
      case 'home':
      case 'main':
      case '0':
        return _homeTab;
      case 'search':
      case 'poisk':
      case '1':
        return _searchTab;
    }
    return null;
  }

  /// Only the first two tabs are valid landing tabs; anything else → Главная.
  int _clamp(int? value) =>
      value == _searchTab ? _searchTab : _homeTab;
}
