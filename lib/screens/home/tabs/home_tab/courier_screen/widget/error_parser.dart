// lib/core/utils/error_parser.dart
import 'package:dio/dio.dart';

import 'package:buking/services/localization_service.dart';

class ErrorParser {
  static String parseDioError(dynamic e) {
    if (e is! DioException) {
      return e.toString();
    }

    // 🌐 Нет интернета
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return tr('error.timeout', 'Превышено время ожидания');
    }

    if (e.type == DioExceptionType.connectionError) {
      return tr('error.no_connection', 'Нет подключения к интернету');
    }

    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    // 🔐 Обработка по статус-коду
    if (statusCode == 401) {
      return tr('error.unauthorized', 'Требуется авторизация');
    }

    if (statusCode == 403) {
      return tr('error.forbidden', 'Доступ запрещен');
    }

    if (statusCode == 500) {
      return tr('error.server', 'Ошибка сервера. Попробуйте позже');
    }

    // 📝 Парсинг тела ответа
    if (data is Map<String, dynamic>) {
      // 1️⃣ Проверяем message
      if (data['message'] != null) {
        return data['message'].toString();
      }

      // 2️⃣ Проверяем errors (валидация Laravel)
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
    }

    return tr('error.request_failed', 'Ошибка запроса');
  }
}
