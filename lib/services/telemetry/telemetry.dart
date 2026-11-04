import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' show DioException;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../network_failure.dart';
import 'backend_telemetry_sink.dart';
import 'telemetry_consent.dart';
import 'telemetry_events.dart';
import 'telemetry_redactor.dart';

class Telemetry with WidgetsBindingObserver {
  Telemetry._();

  static final Telemetry instance = Telemetry._();

  static const int _breadcrumbLimit = 25;

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  FirebasePerformance? _performance;

  final Queue<String> _breadcrumbs = Queue<String>();
  final Map<String, Object?> _context = <String, Object?>{};

  bool _initialised = false;
  bool _firebaseReady = false;
  String? _currentScreen;
  String? _userId;

  bool get isFirebaseReady => _firebaseReady;

  String? get currentScreen => _currentScreen;

  FirebaseAnalytics? get analytics => _analytics;

  Map<String, Object?> get context => Map.unmodifiable(_context);

  Future<void> init({
    required bool firebaseReady,
    required String baseUrl,
    required Future<String?> Function() tokenProvider,
    bool Function()? isOffline,
  }) async {
    if (_initialised) return;
    _initialised = true;
    _firebaseReady = firebaseReady;

    await TelemetryConsent.instance.load();
    TelemetryConsent.instance.addListener(_applyConsent);

    await _collectContext();

    if (firebaseReady) {
      try {
        _analytics = FirebaseAnalytics.instance;
        _crashlytics = FirebaseCrashlytics.instance;
        _performance = FirebasePerformance.instance;
        await _applyConsent();
        await _pushContextToCrashlytics();
      } catch (e) {
        debugPrint('Telemetry: Firebase modules partially unavailable: $e');
      }
    }

    try {
      await BackendTelemetrySink.instance.init(
        baseUrl: baseUrl,
        tokenProvider: tokenProvider,
        contextProvider: () => _context,
        isOffline: isOffline,
      );
    } catch (e) {
      debugPrint('Telemetry: backend sink init failed: $e');
    }

    _installErrorHandlers();
    WidgetsBinding.instance.addObserver(this);

    event(TelemetryEvents.appStarted, params: {
      TelemetryParams.source: firebaseReady ? 'firebase' : 'degraded',
    });
    if (!firebaseReady) {
      event(TelemetryEvents.featureUnavailable,
          params: {TelemetryParams.reason: 'firebase_init_failed'});
    }
  }

  static void runGuarded(void Function() body) {
    runZonedGuarded(body, (error, stack) {
      Telemetry.instance._reportUncaught(error, stack, 'uncaught_zone_error');
    });
  }

  void _reportUncaught(Object error, StackTrace? stack, String reason) {
    error0(error, stack, reason: reason, urgent: true);
  }

  void _installErrorHandlers() {
    final previousOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      previousOnError?.call(details);
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      unawaited(_recordFlutterError(details));
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _reportUncaught(error, stack, 'platform_dispatcher');
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
      final list = pair as List<dynamic>;
      final err = list.first;
      final stack = list.length > 1 && list[1] != null
          ? StackTrace.fromString(list[1].toString())
          : null;
      _reportUncaught(err ?? 'isolate error', stack, 'isolate_error');
    }).sendPort);
  }

  Future<void> _recordFlutterError(FlutterErrorDetails details) async {
    if (_reportedAsConnectivity(details.exception, details.library)) return;
    if (!TelemetryConsent.instance.crashReportsEnabled) return;
    final library = details.library ?? 'flutter';
    try {
      await _crashlytics?.recordFlutterError(details, fatal: false);
    } catch (_) {}
    _sendToBackend(
      type: 'error',
      name: TelemetryEvents.renderError,
      severity: 'error',
      params: {
        TelemetryParams.errorType: details.exception.runtimeType.toString(),
        TelemetryParams.errorMessage:
            TelemetryRedactor.redact(details.exceptionAsString()),
        'library': library,
      },
      stack: _trimStack(details.stack),
      fingerprint:
          _fingerprint(details.exception.runtimeType.toString(), details.stack),
    );
    _logAnalytics(TelemetryEvents.renderError, {
      TelemetryParams.errorType: details.exception.runtimeType.toString(),
      TelemetryParams.screen: _currentScreen,
    });
  }

  Future<void> _applyConsent() async {
    final consent = TelemetryConsent.instance;
    try {
      await _analytics?.setAnalyticsCollectionEnabled(consent.analyticsEnabled);
    } catch (_) {}
    try {
      await _crashlytics
          ?.setCrashlyticsCollectionEnabled(consent.crashReportsEnabled);
    } catch (_) {}
    try {
      await _performance?.setPerformanceCollectionEnabled(
          consent.analyticsEnabled);
    } catch (_) {}
  }

  Future<void> _collectContext() async {
    _context['platform'] = Platform.operatingSystem;
    _context['is_debug'] = kDebugMode;
    try {
      final info = await PackageInfo.fromPlatform();
      _context['app_version'] = info.version;
      _context['build_number'] = info.buildNumber;
      _context['package_name'] = info.packageName;
    } catch (_) {}
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await plugin.androidInfo;
        _context['device_model'] = '${a.manufacturer} ${a.model}';
        _context['os_version'] = 'Android ${a.version.release}';
        _context['sdk_int'] = a.version.sdkInt;
        _context['is_physical'] = a.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final i = await plugin.iosInfo;
        _context['device_model'] = i.utsname.machine;
        _context['os_version'] = 'iOS ${i.systemVersion}';
        _context['is_physical'] = i.isPhysicalDevice;
      }
    } catch (_) {}
  }

  Future<void> _pushContextToCrashlytics() async {
    final c = _crashlytics;
    if (c == null) return;
    for (final entry in _context.entries) {
      final v = entry.value;
      if (v == null) continue;
      try {
        await c.setCustomKey(entry.key, v is bool || v is num ? v : v.toString());
      } catch (_) {}
    }
  }

  Future<void> identify(
    String? userId, {
    Map<String, String?> properties = const {},
  }) async {
    if (_userId == userId && properties.isEmpty) return;
    _userId = userId;
    _context['user_id'] = userId;

    try {
      await _analytics?.setUserId(id: userId);
    } catch (_) {}
    try {
      await _crashlytics?.setUserIdentifier(userId ?? '');
    } catch (_) {}

    await setUserProperties(properties);
  }

  Future<void> setUserProperties(Map<String, String?> properties) async {
    for (final entry in properties.entries) {
      final value = entry.value;
      try {
        await _analytics?.setUserProperty(
          name: TelemetrySchema.userPropName(entry.key),
          value: value == null
              ? null
              : TelemetrySchema.userPropValue(value),
        );
      } catch (_) {}
      try {
        await _crashlytics?.setCustomKey(entry.key, value ?? '');
      } catch (_) {}
      _context[entry.key] = value;
    }
  }

  Future<void> clearIdentity() async {
    _userId = null;
    _context.remove('user_id');
    try {
      await _analytics?.setUserId(id: null);
    } catch (_) {}
    try {
      await _crashlytics?.setUserIdentifier('');
    } catch (_) {}
  }

  void event(
    String name, {
    Map<String, Object?>? params,
    String severity = 'info',
  }) {
    final safeName = TelemetrySchema.name(name);
    final enriched = <String, Object?>{
      if (_currentScreen != null) TelemetryParams.screen: _currentScreen,
      ...?params,
    };
    _logAnalytics(safeName, enriched);
    breadcrumb('event: $safeName');
    _sendToBackend(
      type: 'event',
      name: safeName,
      severity: severity,
      params: enriched,
    );
  }

  Future<void> screen(String name, {String? screenClass}) async {
    final safe = TelemetrySchema.name(name);
    if (_currentScreen == safe) return;
    _currentScreen = safe;
    breadcrumb('screen: $safe');
    try {
      await _crashlytics?.setCustomKey('current_screen', safe);
    } catch (_) {}
    if (!TelemetryConsent.instance.analyticsEnabled) return;
    try {
      await _analytics?.logScreenView(
        screenName: safe,
        screenClass: screenClass ?? name,
      );
    } catch (_) {}
    _sendToBackend(
      type: 'screen',
      name: safe,
      severity: 'info',
      params: {TelemetryParams.screenClass: screenClass ?? name},
    );
  }

  void breadcrumb(String message) {
    final line =
        '${DateTime.now().toIso8601String()} ${TelemetryRedactor.redact(message, maxLength: 160)}';
    _breadcrumbs.addLast(line);
    while (_breadcrumbs.length > _breadcrumbLimit) {
      _breadcrumbs.removeFirst();
    }
    if (!TelemetryConsent.instance.crashReportsEnabled) return;
    try {
      _crashlytics?.log(line);
    } catch (_) {}
  }

  Future<void> error(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Map<String, Object?>? context,
  }) async {
    error0(error, stack, reason: reason, fatal: fatal, context: context);
  }

  void error0(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    bool urgent = false,
    Map<String, Object?>? context,
  }) {
    if (!fatal && _reportedAsConnectivity(error, reason)) return;

    final type = error.runtimeType.toString();
    final message = TelemetryRedactor.redact(error.toString());

    final crashlytics = _crashlytics;
    if (crashlytics != null && TelemetryConsent.instance.crashReportsEnabled) {
      try {
        unawaited(crashlytics.recordError(
          error,
          stack,
          reason: reason,
          fatal: fatal,
          information: [
            if (_currentScreen != null) 'screen: $_currentScreen',
            ..._breadcrumbs,
          ],
        ));
      } catch (_) {
      }
    }

    _logAnalytics(
      fatal ? TelemetryEvents.renderError : TelemetryEvents.appError,
      {
        TelemetryParams.errorType: type,
        TelemetryParams.reason: reason,
        TelemetryParams.screen: _currentScreen,
      },
    );

    _sendToBackend(
      type: 'error',
      name: fatal
          ? 'fatal_error'
          : (urgent ? 'uncaught_error' : TelemetryEvents.appError),
      severity: fatal ? 'fatal' : 'error',
      params: {
        TelemetryParams.errorType: type,
        TelemetryParams.errorMessage: message,
        TelemetryParams.reason: reason,
        ...?context,
      },
      stack: _trimStack(stack),
      fingerprint: _fingerprint(type, stack),
      withBreadcrumbs: true,
    );

    if (fatal || urgent) {
      unawaited(BackendTelemetrySink.instance.flush(force: true));
    }
  }

  bool _reportedAsConnectivity(Object error, String? reason) {
    if (error is DioException &&
        NetworkFailure.of(error).kind == NetworkFailureKind.rateLimited) {
      return true;
    }
    if (!NetworkFailure.isConnectivity(error)) return false;
    if (error is! DioException) {
      event(
        TelemetryEvents.networkError,
        params: {
          TelemetryParams.errorType: error.runtimeType.toString(),
          TelemetryParams.reason: reason,
          TelemetryParams.isOffline: NetworkFailure.isNoLink(error),
        },
        severity: 'warning',
      );
    }
    return true;
  }

  Future<T> trace<T>(
    String name,
    Future<T> Function() body, {
    Map<String, String> attributes = const {},
  }) async {
    Trace? t;
    try {
      if (TelemetryConsent.instance.analyticsEnabled) {
        t = _performance?.newTrace(TelemetrySchema.name(name));
        await t?.start();
        for (final a in attributes.entries) {
          t?.putAttribute(a.key, TelemetrySchema.userPropValue(a.value));
        }
      }
    } catch (_) {
      t = null;
    }
    try {
      return await body();
    } finally {
      try {
        await t?.stop();
      } catch (_) {}
    }
  }

  HttpMetric? newHttpMetric(String url, HttpMethod method) {
    if (!TelemetryConsent.instance.analyticsEnabled) return null;
    try {
      return _performance?.newHttpMetric(url, method);
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        event(TelemetryEvents.appForeground);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        event(TelemetryEvents.appBackground);
        unawaited(BackendTelemetrySink.instance.flushOnPause());
        break;
      default:
        break;
    }
  }

  void _logAnalytics(String name, Map<String, Object?> params) {
    if (!TelemetryConsent.instance.analyticsEnabled) return;
    final a = _analytics;
    if (a == null) return;
    final safeName = TelemetrySchema.name(name);
    try {
      final safe = TelemetrySchema.params(params);
      unawaited(
        a
            .logEvent(name: safeName, parameters: safe.isEmpty ? null : safe)
            .catchError((Object e) {
          debugPrint('Analytics отклонил событие "$safeName": $e');
        }),
      );
    } catch (e) {
      debugPrint('Analytics отклонил событие "$safeName": $e');
    }
  }

  void _sendToBackend({
    required String type,
    required String name,
    required String severity,
    Map<String, Object?>? params,
    String? stack,
    String? fingerprint,
    bool withBreadcrumbs = false,
  }) {
    final isDiagnostic = severity != 'info';
    final allowed = isDiagnostic
        ? TelemetryConsent.instance.crashReportsEnabled
        : TelemetryConsent.instance.analyticsEnabled;
    if (!allowed) return;

    final cleaned = <String, Object?>{};
    params?.forEach((key, value) {
      if (value == null) return;
      cleaned[key] = TelemetryRedactor.value(value);
    });

    BackendTelemetrySink.instance.add(TelemetryRecord(
      type: type,
      name: name,
      severity: severity,
      occurredAt: DateTime.now(),
      params: cleaned,
      stack: stack,
      fingerprint: fingerprint,
      screen: _currentScreen,
      breadcrumbs:
          withBreadcrumbs ? List<String>.from(_breadcrumbs) : const <String>[],
    ));
  }

  String _fingerprint(String type, StackTrace? stack) {
    final frames = (stack?.toString() ?? '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .where((l) => !l.contains('package:flutter/'))
        .take(3)
        .map((l) => l.replaceAll(RegExp(r':\d+:\d+'), '').trim())
        .join('|');
    return _hash('$type|$frames');
  }

  static String _hash(String input) {
    var hash = 0x811c9dc5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String? _trimStack(StackTrace? stack, {int maxLines = 40}) {
    if (stack == null) return null;
    final lines = stack.toString().split('\n');
    final trimmed =
        lines.length <= maxLines ? lines : lines.sublist(0, maxLines);
    return TelemetryRedactor.redact(
      trimmed.join('\n'),
      maxLength: 4000,
      collapseWhitespace: false,
    );
  }

  void forceCrashForTesting() => _crashlytics?.crash();
}
