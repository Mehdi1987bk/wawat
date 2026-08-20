import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Одна запись телеметрии в том виде, в каком её принимает бэкенд.
///
/// Формат намеренно плоский и одинаковый для событий, ошибок и HTTP-сбоев:
/// панели нужен один поток, который можно фильтровать по `type`/`severity`,
/// а не три разных таблицы.
class TelemetryRecord {
  TelemetryRecord({
    required this.type,
    required this.name,
    required this.severity,
    required this.occurredAt,
    this.params = const {},
    this.stack,
    this.fingerprint,
    this.screen,
    this.breadcrumbs = const [],
  });

  /// `event` | `error` | `screen` | `http`
  final String type;
  final String name;

  /// `info` | `warning` | `error` | `fatal`
  final String severity;
  final DateTime occurredAt;
  final Map<String, Object?> params;
  final String? stack;

  /// Стабильный ключ группировки: одинаковые падения схлопываются в одну
  /// строку панели, как это делает Crashlytics.
  final String? fingerprint;
  final String? screen;
  final List<String> breadcrumbs;

  Map<String, Object?> toJson() => {
        'type': type,
        'name': name,
        'severity': severity,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        if (screen != null) 'screen': screen,
        if (params.isNotEmpty) 'params': params,
        if (stack != null) 'stack': stack,
        if (fingerprint != null) 'fingerprint': fingerprint,
        if (breadcrumbs.isNotEmpty) 'breadcrumbs': breadcrumbs,
      };

  static TelemetryRecord? fromJson(Map<String, Object?> json) {
    try {
      return TelemetryRecord(
        type: json['type'] as String? ?? 'event',
        name: json['name'] as String? ?? 'unknown',
        severity: json['severity'] as String? ?? 'info',
        occurredAt:
            DateTime.tryParse(json['occurred_at'] as String? ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
        params: (json['params'] as Map?)?.cast<String, Object?>() ?? const {},
        stack: json['stack'] as String?,
        fingerprint: json['fingerprint'] as String?,
        screen: json['screen'] as String?,
        breadcrumbs:
            (json['breadcrumbs'] as List?)?.cast<String>() ?? const <String>[],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Зеркалирует телеметрию на собственный бэкенд, чтобы **одна** панель
/// показывала и падения, и продуктовые события, и сетевые сбои.
///
/// Почему не хватает одного Firebase: Crashlytics и Analytics живут в разных
/// консолях, отдают данные с задержкой (Analytics — часы) и не знают ничего о
/// серверных ошибках. Панель бэкенда сшивает клиентский поток с серверным по
/// `user_id`/`request_id` и показывает всё в одном месте — это и просил заказчик.
///
/// Устройство работы:
///  • очередь в памяти, сброс пачкой по 20 записей / раз в 30 с / при уходе
///    приложения в фон / принудительно при фатальной ошибке;
///  • не отправленное переживает перезапуск (SharedPreferences, до 300 записей,
///    вытесняются самые старые);
///  • **отдельный [Dio]**, не тот, что у приложения: иначе телеметрия попала бы
///    в собственный интерцептор (бесконечная рекурсия) и в обработчик 402,
///    который выкидывает пользователя на логин;
///  • если бэкенд ещё не выкатил эндпоинт (404/405/501), сток тихо выключается
///    до перезапуска — приложение не должно долбиться в несуществующий URL.
class BackendTelemetrySink {
  BackendTelemetrySink._();

  static final BackendTelemetrySink instance = BackendTelemetrySink._();

  static const _outboxKey = 'telemetry_outbox_v1';
  static const int _batchSize = 20;
  static const int _outboxCap = 300;
  static const Duration _flushInterval = Duration(seconds: 30);

  final List<TelemetryRecord> _queue = [];
  final _random = Random();

  Dio? _dio;
  String? _path;
  Future<String?> Function()? _tokenProvider;
  Map<String, Object?> Function()? _contextProvider;
  bool Function()? _isOffline;

  Timer? _timer;
  bool _enabled = false;
  bool _flushing = false;
  int _consecutiveFailures = 0;
  late final String _sessionId = _newId();

  String get sessionId => _sessionId;

  bool get isEnabled => _enabled;

  /// [baseUrl] — тот же, что у API приложения (`…/api/v1`).
  /// [contextProvider] отдаёт снимок устройства/версии на момент отправки.
  Future<void> init({
    required String baseUrl,
    required Future<String?> Function() tokenProvider,
    required Map<String, Object?> Function() contextProvider,
    bool Function()? isOffline,
  }) async {
    _path = '$baseUrl/telemetry/batch';
    _tokenProvider = tokenProvider;
    _contextProvider = contextProvider;
    _isOffline = isOffline;
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        // Разбираем статус сами — нам важно отличить «эндпоинта нет»
        // от «сеть отвалилась».
        validateStatus: (_) => true,
      ),
    );
    _enabled = true;
    await _restoreOutbox();
    _timer?.cancel();
    _timer = Timer.periodic(_flushInterval, (_) => unawaited(flush()));
  }

  void add(TelemetryRecord record) {
    if (!_enabled) return;
    _queue.add(record);
    if (_queue.length > _outboxCap) {
      _queue.removeRange(0, _queue.length - _outboxCap);
    }
    if (_queue.length >= _batchSize) unawaited(flush());
  }

  /// Отправляет накопленное. Никогда не бросает: телеметрия не имеет права
  /// ронять приложение или всплывать пользователю.
  Future<void> flush({bool force = false}) async {
    if (!_enabled || _flushing || _queue.isEmpty) return;
    if (_dio == null || _path == null) return;
    if (!force && (_isOffline?.call() ?? false)) return;
    // Мягкий backoff: после серии неудач не пытаемся каждые 30 секунд.
    if (!force && _consecutiveFailures > 0 && _consecutiveFailures < 5) {
      if (_random.nextInt(_consecutiveFailures + 1) != 0) return;
    }

    _flushing = true;
    final batch = List<TelemetryRecord>.from(_queue);
    try {
      final token = await _tokenProvider?.call();
      final response = await _dio!.post<dynamic>(
        _path!,
        data: {
          'session_id': _sessionId,
          'sent_at': DateTime.now().toUtc().toIso8601String(),
          'context': _contextProvider?.call() ?? const {},
          'records': batch.map((r) => r.toJson()).toList(),
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        _queue.removeRange(0, min(batch.length, _queue.length));
        _consecutiveFailures = 0;
        await _persistOutbox();
      } else if (status == 404 || status == 405 || status == 501) {
        // Эндпоинт ещё не задеплоен — выключаемся до следующего запуска,
        // чтобы не жечь трафик и не шуметь в логах.
        _enabled = false;
        _queue.clear();
        _timer?.cancel();
        await _clearOutbox();
      } else if (status == 401 || status == 403) {
        // Гость или протухший токен: записи не наши — просто отбрасываем.
        _queue.removeRange(0, min(batch.length, _queue.length));
        await _persistOutbox();
      } else {
        _consecutiveFailures++;
        await _persistOutbox();
      }
    } catch (_) {
      _consecutiveFailures++;
      await _persistOutbox();
    } finally {
      _flushing = false;
    }
  }

  /// Вызывается при уходе в фон — иначе последняя пачка (в т.ч. запись о
  /// падении) может не пережить закрытие приложения.
  Future<void> flushOnPause() => flush(force: true);

  Future<void> _persistOutbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_queue.isEmpty) {
        await prefs.remove(_outboxKey);
        return;
      }
      final tail = _queue.length <= _outboxCap
          ? _queue
          : _queue.sublist(_queue.length - _outboxCap);
      await prefs.setString(
        _outboxKey,
        jsonEncode(tail.map((r) => r.toJson()).toList()),
      );
    } catch (_) {
      // Переполнение диска и т.п. — теряем буфер, но не приложение.
    }
  }

  Future<void> _restoreOutbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_outboxKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final restored = decoded
          .whereType<Map>()
          .map((m) => TelemetryRecord.fromJson(m.cast<String, Object?>()))
          .whereType<TelemetryRecord>()
          .toList();
      // Прошлая сессия — вперёд очереди, чтобы отчёт о вчерашнем падении
      // не вытеснился сегодняшними событиями.
      _queue.insertAll(0, restored);
    } catch (_) {
      await _clearOutbox();
    }
  }

  Future<void> _clearOutbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_outboxKey);
    } catch (_) {}
  }

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = _random.nextInt(1 << 32).toRadixString(36);
    return '$now-$rand';
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
