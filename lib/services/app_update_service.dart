import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';
import 'localization_service.dart';

/// Result of the public startup version check.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.forceUpdate,
    this.latestVersion,
    this.title,
    this.message,
    this.storeUrl,
  });

  final bool forceUpdate;
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

    final rawForceUpdate = data['force_update'];
    final forceUpdate = rawForceUpdate == true ||
        rawForceUpdate == 1 ||
        rawForceUpdate?.toString().toLowerCase() == 'true';

    return AppUpdateInfo(
      forceUpdate: forceUpdate,
      latestVersion: stringValue('latest_version'),
      title: stringValue('title'),
      message: stringValue('message'),
      storeUrl: stringValue('store_url'),
    );
  }
}

/// Checks the minimum supported app version before onboarding/home is opened.
///
/// The endpoint is deliberately public: signed-out and first-launch users must
/// be blocked as well. Network/server errors are fail-open so an outage cannot
/// permanently lock every user out of the application.
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();
  static const _endpoint = '$baseUrl/app/version-check';
  static const _iosStoreUrl = 'https://apps.apple.com/app/id6755226789';

  Future<AppUpdateInfo?> check() async {
    if (!Platform.isIOS && !Platform.isAndroid) return null;

    try {
      final package = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await sl.get<Dio>().get<Map<String, dynamic>>(
            _endpoint,
            queryParameters: {
              'platform': platform,
              // `version` keeps compatibility with the Namazov API contract.
              'version': package.version,
              'version_name': package.version,
              'build_number': package.buildNumber,
              'package_name': package.packageName,
              'lang': LocalizationService.instance.locale,
            },
            options: Options(
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
            ),
          );
      final raw = response.data;
      if (raw == null) return null;

      final parsed = AppUpdateInfo.fromJson(raw);
      if (!parsed.forceUpdate || parsed.storeUrl != null) return parsed;

      // A missing URL must not leave a forced-update user on a dead screen.
      final fallbackUrl = Platform.isIOS
          ? _iosStoreUrl
          : 'https://play.google.com/store/apps/details?id=${package.packageName}';
      return AppUpdateInfo(
        forceUpdate: true,
        latestVersion: parsed.latestVersion,
        title: parsed.title,
        message: parsed.message,
        storeUrl: fallbackUrl,
      );
    } catch (_) {
      return null;
    }
  }
}
