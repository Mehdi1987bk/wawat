import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'wawat_content.dart';

class LocalizationService extends ChangeNotifier {
  LocalizationService._();
  static final LocalizationService instance = LocalizationService._();

  static const _mapPrefix = 'l10n.map.';
  static const _etagPrefix = 'l10n.etag.';

  Map<String, String> _map = const {};
  String _locale = 'az';
  bool _loaded = false;

  String get locale => _locale;
  bool get isLoaded => _loaded;

  static String normalize(String code) {
    final c = code.trim().toLowerCase();
    if (c == 'uk') return 'ua';
    return c.isEmpty ? 'az' : c;
  }

  Future<void> load(String locale, {bool force = false}) async {
    _locale = normalize(locale);
    WawatContent.locale = _locale;
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString('$_mapPrefix$_locale');
    if (cached != null && cached.isNotEmpty) {
      _map = _decode(cached);
      WawatContent.setRuntimeTranslations(_map);
      _loaded = true;
      notifyListeners();
    }

    final etag = force ? null : prefs.getString('$_etagPrefix$_locale');
    try {
      final res = await sl
          .get<Dio>()
          .get<Map<String, dynamic>>(
            '$baseUrl/content',
            queryParameters: {'lang': _locale},
            options: Options(
              headers: {if (etag != null) 'If-None-Match': etag},
              validateStatus: (s) => s != null && s < 500,
              receiveTimeout: const Duration(seconds: 12),
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 304) {
        _loaded = true;
        return;
      }
      final raw = res.data?['data'];
      if (raw is Map) {
        _map = raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        WawatContent.setRuntimeTranslations(_map);
        _loaded = true;
        await prefs.setString('$_mapPrefix$_locale', jsonEncode(_map));
        final newEtag = res.headers.value('etag');
        if (newEtag != null && newEtag.isNotEmpty) {
          await prefs.setString('$_etagPrefix$_locale', newEtag);
        }
        notifyListeners();
      }
    } catch (_) {
      _loaded = true;
    }
  }

  Future<void> changeLocale(String locale) {
    WawatContent.clearCache();
    return load(locale, force: true);
  }

  String t(String key, [Map<String, String>? params]) {
    final raw = _map[key];
    var value = (raw == null || raw.trim().isEmpty || raw == key)
        ? (WawatContent.fallbacks[key] ?? '')
        : raw;
    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }

  String? rawValue(String key) {
    final v = _map[key];
    if (v == null || v.trim().isEmpty || v == key) return null;
    return v;
  }

  Map<String, String> _decode(String json) {
    try {
      final m = jsonDecode(json);
      if (m is Map) {
        return m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
    } catch (_) {}
    return const {};
  }
}

String t(String key, [Map<String, String>? params]) =>
    LocalizationService.instance.t(key, params);

String tr(String key, String fallback, [Map<String, String>? params]) {
  final raw = LocalizationService.instance.rawValue(key);
  var value = raw ?? fallback;
  if (params != null && params.isNotEmpty) {
    params.forEach((k, v) => value = value.replaceAll('{$k}', v));
  }
  return value;
}
