import 'package:dio/dio.dart';

import '../../../../../main.dart';

/// Data-layer for "Şikayətlərim" (my reports), wired to the live API.
/// GET /reports returns full objects, so the detail screen reuses the list item
/// (no extra fetch). Mirrors [BlockedUsersApi]: `sl.get<Dio>()`, global
/// [baseUrl], manual `fromJson`, defensive on 404 (empty list). Creating a
/// report happens from listing/user/chat screens (POST /reports).
class ReportsApi {
  ReportsApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// GET /reports → the reports the current user has filed.
  Future<List<Report>> getReports({int page = 1}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/reports',
        queryParameters: {'page': page},
      );
      final raw = res.data?['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
          .where((r) => r.id.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 404 || code == 204) return const [];
      rethrow;
    }
  }
}

class Report {
  final String id;
  final String targetType; // listing | user | message
  final String reasonCode;
  final String note; // the user's explanation ("İzah")
  final String status; // pending | reviewing | resolved | rejected
  final String resolutionNote; // moderation response
  final bool hasEvidence;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.targetType,
    required this.reasonCode,
    required this.note,
    required this.status,
    required this.resolutionNote,
    required this.hasEvidence,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? 'listing',
      reasonCode: json['reason_code']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      resolutionNote: json['resolution_note']?.toString() ?? '',
      hasEvidence: json['has_evidence'] == true,
      createdAt: _dateTime(json['created_at']),
    );
  }

  /// reason_code → Azerbaijani label (codes aren't localized by the backend).
  String get reasonLabel {
    switch (reasonCode) {
      case 'wrong_info':
      case 'misleading':
        return 'Yanlış / aldadıcı məlumat';
      case 'spam':
        return 'Spam';
      case 'offensive':
      case 'insult':
      case 'abuse':
        return 'Təhqir';
      case 'fraud':
      case 'scam':
        return 'Fırıldaqçılıq';
      case 'prohibited':
      case 'prohibited_item':
        return 'Qadağan olunmuş əşya';
      case 'inappropriate':
        return 'Uyğunsuz məzmun';
      case 'other':
        return 'Digər';
      default:
        if (reasonCode.isEmpty) return '';
        final s = reasonCode.replaceAll('_', ' ');
        return s[0].toUpperCase() + s.substring(1);
    }
  }
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
