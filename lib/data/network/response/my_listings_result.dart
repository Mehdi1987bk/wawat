import '../../../domain/entities/pagination.dart';
import 'listing_response.dart';

class ListingFilterOption {
  final String key;
  final String label;
  final int count;

  const ListingFilterOption({
    required this.key,
    required this.label,
    this.count = 0,
  });

  factory ListingFilterOption.fromJson(Map<String, dynamic> json) =>
      ListingFilterOption(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        count: _int(json['count']),
      );
}

class MyListingsResult {
  final Pagination<Listing> page;
  final List<ListingFilterOption> filters;
  final String? activeFilter;

  const MyListingsResult({
    required this.page,
    this.filters = const [],
    this.activeFilter,
  });

  factory MyListingsResult.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final rawFilters = (meta is Map) ? meta['filters'] : null;
    return MyListingsResult(
      page: Pagination<Listing>.fromJson(json),
      filters: rawFilters is List
          ? rawFilters
              .whereType<Map>()
              .map((e) =>
                  ListingFilterOption.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
      activeFilter: (meta is Map) ? meta['active_filter']?.toString() : null,
    );
  }
}

int _int(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
