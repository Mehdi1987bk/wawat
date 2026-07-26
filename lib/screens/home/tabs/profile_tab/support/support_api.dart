import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../main.dart';

/// Feature flag for the support-form screen. The `POST /support` endpoint is not
/// live yet — while enabled, the form is shown and submit falls back to a
/// mailto draft (never silently drops the user's message). Flip off to hide.
const bool kSupportFormEnabled = true;

const _supportEmail = 'destek@wawatair.com';

class SupportApi {
  SupportApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// POST /support → { ticket_no }. Returns the ticket number on success, or
  /// `null` when the endpoint isn't live yet (caller opens a mailto draft).
  Future<String?> submit({
    required String category,
    required String subject,
    required String body,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/support',
        data: {'category': category, 'subject': subject, 'body': body},
      );
      final data = res.data?['data'] is Map
          ? Map<String, dynamic>.from(res.data!['data'] as Map)
          : (res.data ?? const {});
      return data['ticket_no']?.toString();
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      // Endpoint not implemented yet → signal the mailto fallback.
      if (code == 404 || code == 405 || code == 501) return null;
      rethrow;
    }
  }

  /// Opens the user's mail app with the message pre-filled — used until the
  /// backend endpoint ships, so a submitted request is never lost.
  Future<void> mailtoDraft({
    required String subject,
    required String body,
  }) async {
    final uri = Uri.parse(
      'mailto:$_supportEmail?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
