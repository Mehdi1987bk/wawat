import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';
import 'guarded_request.dart';
import 'localization_service.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.forceUpdate,
    this.updateAvailable = false,
    this.latestVersion,
    this.title,
    this.message,
    this.storeUrl,
  });

  final bool forceUpdate;

  final bool updateAvailable;
  final String? latestVersion;
  final String? title;
  final String? message;
  final String? storeUrl;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final data = nested is Map
        ? nested.map((key, value) => MapEntry(key.toString(), value))
        : json;

    String? stringValue(String key) {
      final value = data[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    bool boolValue(String key) {
      final raw = data[key];
      return raw == true || raw == 1 || raw?.toString().toLowerCase() == 'true';
    }

    return AppUpdateInfo(
      forceUpdate: boolValue('force_update'),
      updateAvailable: boolValue('update_available'),
      latestVersion: stringValue('latest_version'),
      title: stringValue('title'),
      message: stringValue('message'),
      storeUrl: stringValue('store_url'),
    );
  }
}

class AppBuild {
  const AppBuild({
    required this.platform,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  final String platform;
  final String version;
  final String buildNumber;
  final String packageName;
}

class AppUpdateService with WidgetsBindingObserver {
  AppUpdateService({
    GuardedRequest? request,
    Future<AppBuild?> Function()? build,
    String Function()? lang,
    DateTime Function()? clock,
  })  : _request = request ?? GuardedRequest(dio: () => sl.get<Dio>()),
        _build = build ?? _platformBuild,
        _lang = lang ?? (() => LocalizationService.instance.locale),
        _now = clock ?? DateTime.now;

  static final AppUpdateService instance = AppUpdateService();

  static const _endpoint = '$baseUrl/app/version-check';
  static const _iosStoreUrl = 'https://apps.apple.com/app/id6755226789';
  static const _platforms = {'ios', 'android'};

  static const recheckInterval = Duration(minutes: 15);

  final GuardedRequest _request;
  final Future<AppBuild?> Function() _build;
  final String Function() _lang;
  final DateTime Function() _now;

  AppUpdateInfo? _lastAnswer;

  DateTime? _lastCheckAt;
  Future<AppUpdateInfo?>? _inFlight;

  bool Function(AppUpdateInfo info)? _onForcedUpdate;
  bool _forcedShown = false;

  bool get isBlocking => _forcedShown;
  bool _observing = false;

  void attach({required bool Function(AppUpdateInfo info) onForcedUpdate}) {
    _onForcedUpdate = onForcedUpdate;
    if (_observing) return;
    _observing = true;
    WidgetsBinding.instance.addObserver(this);
  }

  Future<AppUpdateInfo?> startupCheck({
    Duration window = const Duration(seconds: 4),
  }) async {
    final pending = check();
    var late = false;
    final info = await pending.timeout(window, onTimeout: () {
      late = true;
      return null;
    });
    if (late) {
      unawaited(pending.then(_presentIfForced));
      return null;
    }
    if (info?.forceUpdate == true) _forcedShown = true;
    return info;
  }

  Future<AppUpdateInfo?> check() {
    final running = _inFlight;
    if (running != null) return running;

    final now = _now();
    final last = _lastCheckAt;
    if (last != null && now.difference(last) < recheckInterval) {
      return Future.value(_lastAnswer);
    }

    _lastCheckAt = now;
    final future = _fetch().whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  Future<AppUpdateInfo?> _fetch() async {
    try {
      final build = await _build();
      if (build == null || !_platforms.contains(build.platform)) return null;

      final buildNumber = int.tryParse(build.buildNumber.trim());
      if (buildNumber == null || buildNumber <= 0) return null;

      final result = await _request.get(
        _endpoint,
        query: {
          'platform': build.platform,
          'version': build.version,
          'version_name': build.version,
          'build_number': buildNumber,
          'package_name': build.packageName,
          'lang': _lang(),
        },
      );
      final data = result.data;
      if (data == null) return null;

      final info = _withStoreUrl(AppUpdateInfo.fromJson(data), build);
      _lastAnswer = info;
      return info;
    } catch (_) {
      return null;
    }
  }

  AppUpdateInfo _withStoreUrl(AppUpdateInfo parsed, AppBuild build) {
    if (!parsed.forceUpdate || parsed.storeUrl != null) return parsed;
    return AppUpdateInfo(
      forceUpdate: true,
      updateAvailable: parsed.updateAvailable,
      latestVersion: parsed.latestVersion,
      title: parsed.title,
      message: parsed.message,
      storeUrl: build.platform == 'ios'
          ? _iosStoreUrl
          : 'https://play.google.com/store/apps/details?id=${build.packageName}',
    );
  }

  void _presentIfForced(AppUpdateInfo? info) {
    if (info == null || !info.forceUpdate || _forcedShown) return;
    _forcedShown = _onForcedUpdate?.call(info) ?? false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_lastCheckAt == null) return;
    unawaited(check().then(_presentIfForced));
  }

  static Future<AppBuild?> _platformBuild() async {
    if (!Platform.isIOS && !Platform.isAndroid) return null;
    final package = await PackageInfo.fromPlatform();
    return AppBuild(
      platform: Platform.isIOS ? 'ios' : 'android',
      version: package.version,
      buildNumber: package.buildNumber,
      packageName: package.packageName,
    );
  }
}
