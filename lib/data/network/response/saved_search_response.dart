class SavedSearchesResponse {
  final List<SavedSearch> data;
  final String? message;

  SavedSearchesResponse({
    required this.data,
    this.message,
  });

  factory SavedSearchesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return SavedSearchesResponse(
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(SavedSearch.fromJson)
              .toList()
          : const [],
      message: json['message']?.toString(),
    );
  }
}

class SavedSearchResponse {
  final SavedSearch data;
  final String? message;

  SavedSearchResponse({
    required this.data,
    this.message,
  });

  factory SavedSearchResponse.fromJson(Map<String, dynamic> json) {
    return SavedSearchResponse(
      data: SavedSearch.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      ),
      message: json['message']?.toString(),
    );
  }
}

class SavedSearch {
  final String id;
  final String? kind;
  final String? name;
  final bool notify;
  final Map<String, dynamic> filters;
  final String? lastRunAt;
  final String? createdAt;

  SavedSearch({
    required this.id,
    this.kind,
    this.name,
    required this.notify,
    required this.filters,
    this.lastRunAt,
    this.createdAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString(),
      name: json['name']?.toString(),
      notify: json['notify'] == true || json['notify']?.toString() == 'true',
      filters: json['filters'] is Map
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : const {},
      lastRunAt: json['last_run_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
