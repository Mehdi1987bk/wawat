import 'dart:io';

import 'package:buking/screens/home/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/cache/cache_manager.dart';
import 'screens/auth/email_otp/email_otp_screen.dart';
import 'services/network_status_service.dart';
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
    }
    options.headers[HttpHeaders.acceptHeader] = 'application/json';

    // Добавляем язык в header
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

  /// A blocked action (create listing / send proposal / send chat message) comes
  /// back as 403 `EMAIL_NOT_VERIFIED`. Let the original call see its error, then
  /// open the code screen once, globally. Ignore the e-mail endpoints themselves
  /// so this can never recurse.
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

  Future<void> _navigateToSignInPage(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
    await _storage.clear();
    await navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }
}
