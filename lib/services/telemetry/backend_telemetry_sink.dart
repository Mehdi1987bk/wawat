import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network_failure.dart';

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

  final String type;
  final String name;

  final String severity;
  final DateTime occurredAt;
  final Map<String, Object?> params;
  final String? stack;

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

class BackendTelemetrySink {
  BackendTelemetrySink._();

  @visibleForTesting
  BackendTelemetrySink.forTest();

  static final BackendTelemetrySink instance = BackendTelemetrySink._();

  static const _outboxKey = 'telemetry_outbox_v1';
  static const int _batchSize = 20;
  static const int _outboxCap = 300;

  static const int _maxPerSend = 50;
  static const Duration _flushInterval = Duration(seconds: 30);

  static const Duration _minSendGap = Duration(seconds: 5);

  static const List<Duration> _retryPauses = [
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 9),
  ];

  static const Duration _exhaustedPause = Duration(minutes: 15);

  static const Duration _rateLimitPause = Duration(minutes: 1);

  final List<TelemetryRecord> _queue = [];
  final _random = Random();
  DateTime Function() _now = DateTime.now;

  Dio? _dio;
  String? _path;
  Future<String?> Function()? _tokenProvider;
  Map<String, Object?> Function()? _contextProvider;
  bool Function()? _isOffline;

  Timer? _timer;
  Timer? _deferred;
  bool _enabled = false;
  bool _flushing = false;

  bool _dirty = false;
  int _consecutiveFailures = 0;

  DateTime? _lastSendAt;

  DateTime? _retryAt;

  DateTime? _blockedUntil;
  late final String _sessionId = _newId();

  String get sessionId => _sessionId;

  @visibleForTesting
  bool get hasDeferredSend => _deferred != null;

  bool get isEnabled => _enabled;

  Future<void> init({
    required String baseUrl,
    required Future<String?> Function() tokenProvider,
    required Map<String, Object?> Function() contextProvider,
    bool Function()? isOffline,
    Dio? dio,
    DateTime Function()? clock,
  }) async {
    _path = '$baseUrl/telemetry/batch';
    _tokenProvider = tokenProvider;
    _contextProvider = contextProvider;
    _isOffline = isOffline;
    if (clock != null) _now = clock;
    _dio = dio ?? Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );
    _enabled = true;
    await _restoreOutbox();
    _timer?.cancel();
    _timer = Timer.periodic(_flushInterval, (_) => unawaited(tick()));
  }

  @visibleForTesting
  Future<void> tick() async {
    await flush();
    if (_dirty) await _persistOutbox();
  }

  void add(TelemetryRecord record) {
    if (!_enabled) return;
    _queue.add(record);
    _dirty = true;
    if (_queue.length > _outboxCap) {
      _queue.removeRange(0, _queue.length - _outboxCap);
    }
    if (_queue.length >= _batchSize) unawaited(flush());
  }

  Future<void> flush({bool force = false}) async {
    if (!_enabled || _queue.isEmpty) return;
    if (_flushing) {
      if (force) _deferUrgent(_minSendGap);
      return;
    }
    if (_dio == null || _path == null) return;
    if (!force && (_isOffline?.call() ?? false)) return;

    final now = _now();
    final wait = _waitBeforeSend(now);
    if (wait > Duration.zero) {
      if (force) {
        await _persistOutbox();
        _deferUrgent(wait);
      }
      return;
    }

    _flushing = true;
    _lastSendAt = now;
    final batch = _queue.take(_maxPerSend).toList();
    final hadMore = _queue.length > batch.length;
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
        _retryAt = null;
        await _persistOutbox();
        if (hadMore && _queue.isNotEmpty) _deferUrgent(_minSendGap);
      } else if (status == 404 || status == 405 || status == 501) {
        _enabled = false;
        _queue.clear();
        _timer?.cancel();
        await _clearOutbox();
      } else if (status == 401 || status == 403) {
        _queue.removeRange(0, min(batch.length, _queue.length));
        await _persistOutbox();
      } else if (status == 400 || status == 413 || status == 422) {
        _queue.removeRange(0, min(batch.length, _queue.length));
        await _persistOutbox();
      } else {
        if (status == 429) {
          final now = _now();
          final asked = NetworkFailure.retryAfterOf(response, now);
          _blockedUntil = now.add(asked ?? _rateLimitPause);
        }
        _registerFailure();
        await _persistOutbox();
      }
    } catch (_) {
      _registerFailure();
      await _persistOutbox();
    } finally {
      _flushing = false;
    }
  }

  Future<void> flushOnPause() => flush(force: true);

  Duration _waitBeforeSend(DateTime now) {
    var until = now;
    for (final moment in [
      _retryAt,
      _blockedUntil,
      _lastSendAt?.add(_minSendGap),
    ]) {
      if (moment != null && moment.isAfter(until)) until = moment;
    }
    return until.difference(now);
  }

  void _registerFailure() {
    _consecutiveFailures++;
    final Duration pause;
    if (_consecutiveFailures <= _retryPauses.length) {
      pause = _retryPauses[_consecutiveFailures - 1];
    } else {
      pause = _exhaustedPause;
      _consecutiveFailures = 0;
    }
    final factor = 0.8 + _random.nextDouble() * 0.4;
    _retryAt = _now().add(
      Duration(milliseconds: (pause.inMilliseconds * factor).round()),
    );
  }

  void _deferUrgent(Duration wait) {
    if (_deferred != null) return;
    _deferred = Timer(wait, () {
      _deferred = null;
      unawaited(flush(force: true));
    });
  }

  Future<void> _persistOutbox() async {
    _dirty = false;
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
    _deferred?.cancel();
    _deferred = null;
  }
}
