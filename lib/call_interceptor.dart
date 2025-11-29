import 'dart:io';

import 'package:buking/screens/home/home_screen.dart';
import 'package:buking/screens/splesh/splesh_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/cache/cache_manager.dart';
import 'domain/repositories/auth_repository.dart';
import 'kango_app.dart';
 import 'main.dart';

class CallInterceptor extends Interceptor {
  late final CacheManager _storage = sl.get<CacheManager>();
  final authRepository = sl.get<AuthRepository>();

  late final Future<void> logout = authRepository.logout();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.uri.toString().contains("api/ebook/review")) {
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }



    return handler.next(options);
  }
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {

    // Если получили 401 (Unauthorized) - токен невалидный
    if (err.response?.statusCode == 401) {
      print('🔒 Token invalid (401), clearing auth data');

      // Удаляем токен и данные пользователя
      await _storage.clear();

      // НЕ показываем ошибку пользователю каждый раз
      // Просто тихо очищаем токен
      return handler.reject(err);
    }

    return handler.next(err);
  }


  Future<void> _navigateToSignInPage(DioError err, ErrorInterceptorHandler handler) async {
    handler.next(err);
    await _storage.clear();
    await navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SpleshScreen()), (route) => false);
  }
}
