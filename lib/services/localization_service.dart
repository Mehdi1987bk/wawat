import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'wawat_content.dart';

/// Единый источник UI-текстов из CMS: GET /content?lang={locale}.
///
/// - Грузит ВСЮ карту key→value для текущего языка (источник истины по ключам —
///   ответ бэка, список ключей не хардкодим).
/// - Кэширует карту на диск (SharedPreferences) + ETag; при рефетче шлёт
///   If-None-Match, на 304 оставляет кэш.
/// - Рефетч ТОЛЬКО при смене языка ([changeLocale]) или явном force.
/// - Глобальный доступ без context — функция [t] в конце файла.
class LocalizationService extends ChangeNotifier {
  LocalizationService._();
  static final LocalizationService instance = LocalizationService._();

  static const _mapPrefix = 'l10n.map.'; // + locale
  static const _etagPrefix = 'l10n.etag.'; // + locale

  Map<String, String> _map = const {};
  String _locale = 'az';
  bool _loaded = false;

  String get locale => _locale;
  bool get isLoaded => _loaded;

  /// Нормализация кода языка. Псевдоним uk = ua. Поддерживаемые: az,en,ru,tr,ua,es.
  static String normalize(String code) {
    final c = code.trim().toLowerCase();
    if (c == 'uk') return 'ua';
    return c.isEmpty ? 'az' : c;
  }

  /// Загрузка контента для [locale]: сначала мгновенно из диск-кэша, затем
  /// сверка с сервером по ETag (в фоне; 304 → кэш актуален).
  Future<void> load(String locale, {bool force = false}) async {
    _locale = normalize(locale);
    final prefs = await SharedPreferences.getInstance();

    // 1) мгновенно из диска — чтобы UI не ждал сеть.
    final cached = prefs.getString('$_mapPrefix$_locale');
    if (cached != null && cached.isNotEmpty) {
      _map = _decode(cached);
      _loaded = true;
      notifyListeners();
    }

    // 2) сверка с сервером (короткий таймаут — не вешаем старт офлайн).
    final etag = force ? null : prefs.getString('$_etagPrefix$_locale');
    try {
      final res = await sl
          .get<Dio>()
          .get<Map<String, dynamic>>(
            '$baseUrl/content',
            queryParameters: {'lang': _locale},
            options: Options(
              headers: {if (etag != null) 'If-None-Match': etag},
              // 304 — валидный ответ (контент не изменился), не ошибка.
              validateStatus: (s) => s != null && s < 500,
              receiveTimeout: const Duration(seconds: 12),
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 304) {
        _loaded = true;
        return; // диск-кэш актуален
      }
      final raw = res.data?['data'];
      if (raw is Map) {
        _map = raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        _loaded = true;
        await prefs.setString('$_mapPrefix$_locale', jsonEncode(_map));
        final newEtag = res.headers.value('etag');
        if (newEtag != null && newEtag.isNotEmpty) {
          await prefs.setString('$_etagPrefix$_locale', newEtag);
        }
        notifyListeners();
      }
    } catch (_) {
      // офлайн/таймаут/ошибка — остаёмся на диск-кэше или AZ-фолбэках.
      _loaded = true;
    }
  }

  /// Смена языка в рантайме: сбросить кэш контента (иначе экраны на
  /// WawatContent.load/loadAll останутся на старом языке), рефетчить, перестроить UI.
  Future<void> changeLocale(String locale) {
    WawatContent.clearCache();
    return load(locale, force: true);
  }

  /// Перевод ключа `group.key`. Подстановка {placeholder} из [params].
  /// Fallback: AZ-строка из [WawatContent.fallbacks], иначе сам ключ.
  String t(String key, [Map<String, String>? params]) {
    final raw = _map[key];
    var value = (raw == null || raw.trim().isEmpty || raw == key)
        ? (WawatContent.fallbacks[key] ?? key)
        : raw;
    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
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

/// Глобальный перевод без BuildContext: `t('common.continue')`,
/// `t('create.step_template', {'step': '2', 'total': '3'})`.
String t(String key, [Map<String, String>? params]) =>
    LocalizationService.instance.t(key, params);
