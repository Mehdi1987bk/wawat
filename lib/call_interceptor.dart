import 'dart:io';

 import 'package:buking/screens/home/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/cache/cache_manager.dart';
 import 'kango_app.dart';
import 'main.dart';

class CallInterceptor extends Interceptor {
  late final CacheManager _storage = sl.get<CacheManager>();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.uri.toString().contains("api/ebook/review")) {
      return handler.next(options);
    }
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    // options.headers['X-localization'] = await _storage.getCurrentLocale().then((value) => value.languageCode);
    return handler.next(options);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 401:
        {
          await _navigateToSignInPage(err, handler);
          break;
        }
      default:
        handler.next(err);
    }
  }

  Future<void> _navigateToSignInPage(DioError err, ErrorInterceptorHandler handler) async {
    handler.next(err);
    await _storage.clear();
    await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
  }
}
