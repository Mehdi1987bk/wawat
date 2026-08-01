import '../../../domain/entities/pagination.dart';
import 'listing_response.dart';

/// One entry of the data-driven "Мои объявления" filter dropdown. Rendered
/// entirely from the API (`meta.filters`) — key/label/count/order all come from
/// the backend; the client never hardcodes them.
class ListingFilterOption {
  final String key; // e.g. all | active | promoted | booked | ...
  final String label; // already localized for the user's language
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

/// A page of `/listings/my` together with the (page-1-only) filter metadata.
class MyListingsResult {
  final Pagination<Listing> page;
  final List<ListingFilterOption> filters; // empty on pages > 1
  final String? activeFilter; // server's currently-selected filter (page 1)

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
