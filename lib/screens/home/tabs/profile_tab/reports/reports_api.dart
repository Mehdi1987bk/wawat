import 'package:dio/dio.dart';

import 'package:buking/services/localization_service.dart';

import '../../../../../main.dart';

class ReportsApi {
  ReportsApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

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
  final String targetType;
  final String reasonCode;
  final String note;
  final String status;
  final String resolutionNote;
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

  String get reasonLabel {
    if (reasonCode.isEmpty) return '';
    const legacy = {
      'wrong_info': 'fake',
      'misleading': 'fake',
      'offensive': 'abuse',
      'insult': 'abuse',
      'scam': 'fraud',
      'prohibited': 'other',
      'prohibited_item': 'other',
    };
    final code = legacy[reasonCode] ?? reasonCode;
    return t('enum.report_reason_code.$code');
  }
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
