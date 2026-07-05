class TrendingRoutesResponse {
  final Object? data;
  final Map<String, dynamic>? meta;
  final String? message;
  final Map<String, dynamic> raw;

  TrendingRoutesResponse({
    required this.raw,
    this.data,
    this.meta,
    this.message,
  });

  factory TrendingRoutesResponse.fromJson(Map<String, dynamic> json) {
    return TrendingRoutesResponse(
      raw: json,
      data: json['data'],
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => raw;
}
