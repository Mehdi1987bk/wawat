import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/request/delete_listing_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/my_listings_result.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';
import '../new_profile/profile_api.dart';

class DeliveryFullListBloc extends PaginableBloc<Listing> {
  final userRepository = sl.get<AuthRepository>();
  final WawatProfileApi _listingsApi = WawatProfileApi();
  final BehaviorSubject<bool> _isUpdating = BehaviorSubject.seeded(false);

  PackageTypesResponse? _packageTypes;

  // Data-driven filter state. `meta.filters` arrives only on page 1 and is kept
  // for the lifetime of the screen; the active key drives the requery.
  final BehaviorSubject<String> _activeFilter = BehaviorSubject.seeded('all');
  final BehaviorSubject<List<ListingFilterOption>> _filters =
      BehaviorSubject.seeded(const []);

  Stream<List<ListingFilterOption>> get filters => _filters.stream;
  List<ListingFilterOption> get currentFilters => _filters.value;
  Stream<String> get activeFilter => _activeFilter.stream;
  String get activeFilterKey => _activeFilter.value;

  Stream<bool> get isUpdating => _isUpdating.stream;

  Future<void> loadList() {
    return load(refresh: true, cancelable: true);
  }

  Future<PackageTypesResponse> loadPackageTypes() async {
    if (_packageTypes != null) return _packageTypes!;
    _packageTypes = await userRepository.getListingPackageTypes();
    return _packageTypes!;
  }

  Map<String, String> get packageNamesByCode {
    final data = _packageTypes?.data ?? const [];
    return {for (final item in data) item.code: item.name};
  }

  // Tracks whether the most recent page-1 load failed, so a filter switch can
  // revert its optimistic label change (PaginableBloc swallows load errors).
  bool _lastFirstPageFailed = false;

  @override
  Future<Pagination<Listing>> provideSource(int page) async {
    try {
      final result = await _listingsApi.myListingsFiltered(
        page: page,
        filter: _activeFilter.value,
      );
      if (page == 1) {
        _lastFirstPageFailed = false;
        // Filter metadata is sent only on page 1 — capture it per requery.
        if (result.filters.isNotEmpty) _filters.add(result.filters);
      }
      return result.page;
    } catch (_) {
      if (page == 1) _lastFirstPageFailed = true;
      rethrow;
    }
  }

  /// Switch the active filter and requery from page 1. No-op if unchanged.
  /// Returns false if the reload failed — the active key is then reverted so
  /// the dropdown label matches the still-shown data and a retry is possible.
  Future<bool> setFilter(String key) async {
    final previous = _activeFilter.value;
    if (key == previous) return true;
    _activeFilter.add(key);
    await loadList();
    if (_lastFirstPageFailed && _activeFilter.value == key) {
      _activeFilter.add(previous);
      return false;
    }
    return true;
  }

  /// Returns the backend's (localized) message so the UI can surface it —
  /// resume in particular may report a return to moderation, not `active`.
  Future<String?> pauseListing(Listing listing) async {
    final response =
        await _mutate(() => userRepository.pauseListing(listing.id));
    return response.message;
  }

  Future<String?> resumeListing(Listing listing) async {
    final response =
        await _mutate(() => userRepository.resumeListing(listing.id));
    return response.message;
  }

  Future<void> deleteListing(
    Listing listing, {
    required String reasonCode,
    String? reasonNote,
  }) async {
    await _mutate(
      () => userRepository.deleteListing(
        listing.id,
        DeleteListingRequest(
          reasonCode: reasonCode,
          reasonNote: reasonNote,
        ),
      ),
    );
  }

  Future<T> _mutate<T>(Future<T> Function() action) async {
    _isUpdating.add(true);
    try {
      final result = await action();
      await loadList();
      return result;
    } finally {
      _isUpdating.add(false);
    }
  }

  @override
  void dispose() {
    _isUpdating.close();
    _filters.close();
    _activeFilter.close();
    super.dispose();
  }
}
