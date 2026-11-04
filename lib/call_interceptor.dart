import 'dart:io';

import 'package:buking/screens/home/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/cache/cache_manager.dart';
import 'screens/auth/email_otp/email_otp_screen.dart';
import 'services/app_update_service.dart';
import 'services/network_status_service.dart';
import 'services/notification_socket_service.dart';
import 'wawat_app.dart';
import 'main.dart';

class CallInterceptor extends Interceptor {
  late final CacheManager _storage = sl.get<CacheManager>();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.uri.toString().contains("api/ebook/review")) {
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    } else if (_needsAuth(options.uri.path)) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'skipped: not signed in',
        ),
        false,
      );
    }
    options.headers[HttpHeaders.acceptHeader] = 'application/json';

    final locale = await _storage.getLocaleAsync();
    final storedLanguageCode = locale?.languageCode ?? 'az';
    final languageCode = storedLanguageCode == 'uk' ? 'ua' : storedLanguageCode;
    const supportedLanguages = {'az', 'en', 'ru', 'tr', 'ua', 'es'};
    options.headers['Accept-Language'] =
        supportedLanguages.contains(languageCode) ? languageCode : 'az';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    NetworkStatusService.instance.markOnline();
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    NetworkStatusService.instance.handleDioError(err);
    switch (err.response?.statusCode) {
      case 401:
        {
          await _handleUnauthorized(err, handler);
          break;
        }
      case 402:
        {
          await _navigateToSignInPage(err, handler);
          break;
        }
      case 403:
        {
          await _handleEmailNotVerified(err, handler);
          break;
        }
      default:
        handler.next(err);
    }
  }

  Future<void> _handleEmailNotVerified(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    final code = data is Map ? data['code']?.toString() : null;
    final path = err.requestOptions.uri.path;
    handler.next(err);
    if (code == 'EMAIL_NOT_VERIFIED' && !path.contains('/auth/email/')) {
      await presentEmailOtpIfRequired(autoSend: true);
    }
  }

  static const _authOnlyPaths = [
    '/auth/me',
    '/auth/logout',
    '/fcm-tokens',
    '/profile',
    '/conversations',
    '/chats',
    '/notifications',
    '/users/search',
    '/search/trending-routes',
    '/saved-searches',
    '/shipments',
    '/deals',
    '/verification',
    '/promotions',
    '/listing-quota',
    '/favorites',
    '/blocks',
    '/reviews/mine',
    '/referrals',
    // Слежение за рейсами: гостю эти пути отправлять нельзя — 401 на них
    // уводит сессию в выход, а подписка по замыслу предлагает экран входа.
    '/me/flight-watches',
    '/watch',
  ];

  bool _needsAuth(String path) {
    for (final p in _authOnlyPaths) {
      if (path.contains(p)) return true;
    }
    return false;
  }

  static bool _signingOut = false;

  Future<void> _handleUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.uri.path;
    handler.next(err);

    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password')) {
      return;
    }

    if (_signingOut) return;
    _signingOut = true;
    try {
      await _storage.clear();
      await NotificationSocketService.instance.onLogout();
      if (AppUpdateService.instance.isBlocking) return;
      await navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
    } finally {
      _signingOut = false;
    }
  }

  Future<void> _navigateToSignInPage(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
    await _storage.clear();
    await NotificationSocketService.instance.onLogout();
    if (AppUpdateService.instance.isBlocking) return;
    await navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }
}
