import 'package:dio/dio.dart';

import '../../../../../main.dart';

class LegalApi {
  LegalApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  Future<PageDoc> getPage(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('$baseUrl/pages/$slug');
    final data = res.data?['data'] is Map
        ? Map<String, dynamic>.from(res.data!['data'] as Map)
        : (res.data ?? const {});
    return PageDoc.fromJson(Map<String, dynamic>.from(data));
  }
}

class PageDoc {
  final String slug;
  final String title;
  final String body;
  final DateTime? updatedAt;

  const PageDoc({
    required this.slug,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  factory PageDoc.fromJson(Map<String, dynamic> json) {
    return PageDoc(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      updatedAt: _dateTime(json['updated_at']),
    );
  }
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
