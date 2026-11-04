import 'package:dio/dio.dart';

import 'localization_service.dart';
import 'network_failure.dart';

class ApiError {
  final int? statusCode;
  final String? code;
  final String? message;
  final Map<String, String> fieldErrors;
  final Duration? retryAfter;
  final bool noConnection;
  final bool timeout;
  final bool notSignedIn;

  const ApiError({
    this.statusCode,
    this.code,
    this.message,
    this.fieldErrors = const {},
    this.retryAfter,
    this.noConnection = false,
    this.timeout = false,
    this.notSignedIn = false,
  });

  bool get hasMessage => message != null && message!.trim().isNotEmpty;

  bool get isValidation =>
      code == 'VALIDATION_ERROR' || statusCode == 422 || fieldErrors.isNotEmpty;

  bool get isRateLimited => code == 'RATE_LIMITED' || statusCode == 429;

  bool get isUnauthenticated =>
      notSignedIn || code == 'UNAUTHENTICATED' || statusCode == 401;

  bool get isEmailNotVerified => code == 'EMAIL_NOT_VERIFIED';

  bool get isSuspended => code == 'ACCOUNT_SUSPENDED';

  factory ApiError.from(Object error) {
    if (error is! DioException) return const ApiError();

    switch (error.type) {
      case DioExceptionType.cancel:
        final skipped =
            error.error?.toString().contains('not signed in') ?? false;
        return ApiError(notSignedIn: skipped);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(timeout: true);
      default:
        break;
    }

    final response = error.response;
    if (response == null) {
      return const ApiError(noConnection: true);
    }

    final data = response.data;
    String? message;
    String? code;
    final fields = <String, String>{};

    if (data is Map) {
      final rawMessage = data['message'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        message = rawMessage.trim();
      }
      final rawCode = data['code'];
      if (rawCode is String && rawCode.trim().isNotEmpty) {
        code = rawCode.trim();
      }
      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fields[key.toString()] = value.first.toString();
          } else if (value != null) {
            fields[key.toString()] = value.toString();
          }
        });
      }
    } else if (data is String && data.trim().isNotEmpty) {
      message = data.trim();
    }

    return ApiError(
      statusCode: response.statusCode,
      code: code,
      message: message,
      fieldErrors: fields,
      retryAfter: NetworkFailure.retryAfterOf(response, DateTime.now()),
    );
  }

  String display([String? fallback]) {
    if (hasMessage) return message!.trim();
    if (fieldErrors.isNotEmpty) return fieldErrors.values.first;
    if (notSignedIn) {
      return tr('error.unauthorized', 'Davam etmək üçün hesabına daxil ol.');
    }
    if (timeout) {
      return tr('error.timeout', 'Cavab gecikdi. Yenidən cəhd et.');
    }
    if (noConnection) {
      return tr('error.no_connection', 'İnternet bağlantısı yoxdur.');
    }
    return fallback ??
        tr('error.request_failed', 'Əməliyyat alınmadı. Yenidən cəhd et.');
  }
}

String errorMessage(Object error, [String? fallback]) =>
    ApiError.from(error).display(fallback);
