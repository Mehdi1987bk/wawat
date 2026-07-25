import 'package:dio/dio.dart';

import '../../../../../main.dart';

/// Feature flag. `true` → calls the endpoints but degrades gracefully on 404
/// (empty list / null detail). Never fabricates reports.
const bool kReportsEnabled = true;

/// Data-layer for "Şikayətlərim" (my reports). Mirrors [BlockedUsersApi]:
/// `sl.get<Dio>()`, global [baseUrl], manual `fromJson`, defensive on 404.
/// Creating a report happens from listing/user/chat screens — this only reads.
class ReportsApi {
  ReportsApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  /// GET /me/reports → the reports this user has filed.
  Future<List<Report>> getReports() async {
    if (!kReportsEnabled) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>('$baseUrl/me/reports');
      final raw = res.data?['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
          .where((r) => r.id.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      if (_missing(error)) return const [];
      rethrow;
    }
  }

  /// GET /me/reports/{id} → detail with description, timeline, admin response.
  Future<ReportDetail?> getReport(String id) async {
    if (!kReportsEnabled) return null;
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('$baseUrl/me/reports/$id');
      final data = res.data?['data'] is Map
          ? Map<String, dynamic>.from(res.data!['data'] as Map)
          : (res.data ?? const {});
      return ReportDetail.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (_missing(error)) return null;
      rethrow;
    }
  }

  bool _missing(DioException error) {
    final code = error.response?.statusCode;
    return code == 404 || code == 204 || code == 501;
  }
}

class Report {
  final String id;
  final String targetType; // listing | user | message
  final String targetLabel;
  final String? targetSubtitle;
  final String reason;
  final String reasonLabel;
  final String status; // reviewing | pending | resolved | rejected
  final String statusLabel;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.targetType,
    required this.targetLabel,
    required this.targetSubtitle,
    required this.reason,
    required this.reasonLabel,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? 'listing',
      targetLabel: json['target_label']?.toString() ?? '',
      targetSubtitle: json['target_subtitle']?.toString(),
      reason: json['reason']?.toString() ?? '',
      reasonLabel:
          json['reason_label']?.toString() ?? json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'reviewing',
      statusLabel: json['status_label']?.toString() ?? '',
      createdAt: _dateTime(json['created_at']),
    );
  }
}

class ReportDetail extends Report {
  final String? description;
  final String? targetOwner;
  final List<ReportTimelineStep> timeline;
  final String? adminResponse;

  const ReportDetail({
    required super.id,
    required super.targetType,
    required super.targetLabel,
    required super.targetSubtitle,
    required super.reason,
    required super.reasonLabel,
    required super.status,
    required super.statusLabel,
    required super.createdAt,
    required this.description,
    required this.targetOwner,
    required this.timeline,
    required this.adminResponse,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    final base = Report.fromJson(json);
    final rawTimeline = json['timeline'];
    final timeline = rawTimeline is List
        ? rawTimeline
            .whereType<Map>()
            .map((e) =>
                ReportTimelineStep.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ReportTimelineStep>[];
    return ReportDetail(
      id: base.id,
      targetType: base.targetType,
      targetLabel: base.targetLabel,
      targetSubtitle: base.targetSubtitle,
      reason: base.reason,
      reasonLabel: base.reasonLabel,
      status: base.status,
      statusLabel: base.statusLabel,
      createdAt: base.createdAt,
      description: json['description']?.toString(),
      targetOwner: json['target_owner']?.toString(),
      timeline: timeline,
      adminResponse: json['admin_response']?.toString(),
    );
  }
}

class ReportTimelineStep {
  final String title;
  final String? subtitle;
  final String state; // done | active | future

  const ReportTimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  factory ReportTimelineStep.fromJson(Map<String, dynamic> json) {
    return ReportTimelineStep(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      state: json['state']?.toString() ?? 'future',
    );
  }
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
