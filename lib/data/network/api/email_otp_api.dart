import 'package:dio/dio.dart';

import '../../../main.dart';

/// Data-layer for e-mail verification by one-time code (OTP).
///
/// Three authed endpoints (the Bearer token is added by [CallInterceptor]):
///   GET  /auth/email/otp         → status {required, verified, email, attempts_left}
///   POST /auth/email/otp         → send / resend a code
///   POST /auth/email/otp/verify  → verify a code {otp}
///
/// Kept on the raw [Dio] (not Retrofit) because the generator is blocked by a
/// pub conflict — this way no `*.g.dart` has to be hand-edited for it.
class EmailOtpApi {
  EmailOtpApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// Current status. The source of truth for whether the feature flag is on
  /// (`required`) and whether this account is already verified.
  Future<EmailOtpStatus> getStatus() async {
    final res = await _dio.get<dynamic>('$baseUrl/auth/email/otp');
    return EmailOtpStatus.fromJson(_data(res.data));
  }

  /// Send (or resend) a code. Throws [EmailOtpException] on 429/409/etc.
  Future<EmailOtpSendResult> sendCode() async {
    try {
      final res = await _dio.post<dynamic>('$baseUrl/auth/email/otp');
      return EmailOtpSendResult.fromJson(_data(res.data));
    } on DioException catch (e) {
      throw EmailOtpException.fromDio(e);
    }
  }

  /// Verify a 6-digit code. Returns true on success; throws
  /// [EmailOtpException] (422 VALIDATION_ERROR with a server message) otherwise.
  Future<bool> verify(String otp) async {
    try {
      final res = await _dio.post<dynamic>(
        '$baseUrl/auth/email/otp/verify',
        data: <String, dynamic>{'otp': otp},
      );
      return _data(res.data)['verified'] == true;
    } on DioException catch (e) {
      throw EmailOtpException.fromDio(e);
    }
  }

  /// Unwrap the Laravel `{data: {...}}` envelope, tolerating a flat body.
  Map<String, dynamic> _data(dynamic body) {
    if (body is Map) {
      final d = body['data'];
      if (d is Map) return Map<String, dynamic>.from(d);
      return Map<String, dynamic>.from(body);
    }
    return const <String, dynamic>{};
  }
}

class EmailOtpStatus {
  final bool required;
  final bool verified;
  final String email;
  final int attemptsLeft;

  const EmailOtpStatus({
    required this.required,
    required this.verified,
    required this.email,
    required this.attemptsLeft,
  });

  factory EmailOtpStatus.fromJson(Map<String, dynamic> j) => EmailOtpStatus(
        required: j['required'] == true,
        verified: j['verified'] == true,
        email: j['email']?.toString() ?? '',
        attemptsLeft: _asInt(j['attempts_left']) ?? 0,
      );
}

class EmailOtpSendResult {
  final int expiresInSeconds;
  final int resendAvailableInSeconds;
  final int attemptsLeft;

  const EmailOtpSendResult({
    required this.expiresInSeconds,
    required this.resendAvailableInSeconds,
    required this.attemptsLeft,
  });

  factory EmailOtpSendResult.fromJson(Map<String, dynamic> j) =>
      EmailOtpSendResult(
        expiresInSeconds: _asInt(j['expires_in_seconds']) ?? 900,
        resendAvailableInSeconds: _asInt(j['resend_available_in_seconds']) ?? 60,
        attemptsLeft: _asInt(j['attempts_left']) ?? 0,
      );
}

/// A typed error for the send/verify endpoints: carries the machine [code]
/// (RATE_LIMITED / CONFLICT / VALIDATION_ERROR) and the server [message] so the
/// screen can show the backend text verbatim (never invent its own).
class EmailOtpException implements Exception {
  final int? statusCode;
  final String? code;
  final String? message;
  final int? resendAvailableInSeconds;

  const EmailOtpException({
    this.statusCode,
    this.code,
    this.message,
    this.resendAvailableInSeconds,
  });

  bool get isConflict => statusCode == 409 || code == 'CONFLICT';
  bool get isRateLimited => statusCode == 429 || code == 'RATE_LIMITED';

  factory EmailOtpException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? code;
    String? message;
    int? resend;
    if (data is Map) {
      code = data['code']?.toString();
      message = data['message']?.toString();
      final errors = data['errors'];
      if ((message == null || message.isEmpty) && errors is Map) {
        final otp = errors['otp'];
        if (otp is List && otp.isNotEmpty) message = otp.first.toString();
      }
      resend = _asInt(data['resend_available_in_seconds']);
      if (resend == null && data['data'] is Map) {
        resend = _asInt((data['data'] as Map)['resend_available_in_seconds']);
      }
    }
    return EmailOtpException(
      statusCode: status,
      code: code,
      message: (message != null && message.isNotEmpty) ? message : null,
      resendAvailableInSeconds: resend,
    );
  }
}

int? _asInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
