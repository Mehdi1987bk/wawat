import 'dart:io';

import 'package:dio/dio.dart';

import 'data/cache/cache_manager.dart';
import 'main.dart';


class CallInterceptor extends Interceptor {
 late final CacheManager _storage = sl.get<CacheManager>();


  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.uri.toString().contains("api/ebook/review")){
      return handler.next(options);
    }
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    // options.headers['X-localization'] = await _storage.getCurrentLocale().then((value) => value.languageCode);

    return handler.next(options);
  }
}
