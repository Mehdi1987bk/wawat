import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'guarded_request.dart';

class HomeConfig {
  HomeConfig({GuardedRequest? request})
      : _request = request ?? GuardedRequest(dio: () => sl.get<Dio>());

  static final HomeConfig instance = HomeConfig();

  static const String _baseUrl = 'https://api.wawatair.com/api/v1';
  static const String _endpoint = '$_baseUrl/app/config';
  static const String _prefsKey = 'home_default_tab';

  final GuardedRequest _request;

  Future<int>? _refresh;

  static const int _homeTab = 0;
  static const int _searchTab = 1;

  int? _memory;

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

  Future<int> refreshDefaultTab() => _refresh ??= _fetchDefaultTab();

  Future<int> _fetchDefaultTab() async {
    final fallback = await cachedDefaultTab();
    try {
      final result = await _request.get(_endpoint);
      final resolved = _parse(result.data);
      if (resolved == null) return fallback;
      _memory = resolved;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefsKey, resolved);
      } catch (_) {
      }
      return resolved;
    } catch (_) {
      return fallback;
    }
  }

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

  int _clamp(int? value) =>
      value == _searchTab ? _searchTab : _homeTab;
}
