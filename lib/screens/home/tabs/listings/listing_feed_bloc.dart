import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/request/saved_search_request.dart';
import '../../../../data/network/response/saved_search_response.dart';
import '../../../../data/network/response/trending_routes_response.dart';
import '../../../../domain/entities/pagination.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/paginable_bloc.dart';
import '../../../../services/wawat_content.dart';

class ListingFilterState {
  final String? type;
  final City? cityFrom;
  final City? cityTo;
  final List<String> packageTypes;
  final bool verifiedOnly;
  final bool following;
  final String? dateFrom;
  final String? dateTo;
  final double? weightMin;
  final double? weightMax;
  final double? priceMin;
  final double? priceMax;
  final double? ratingMin;
  final String? tierMin;
  final String sort;

  const ListingFilterState({
    this.type,
    this.cityFrom,
    this.cityTo,
    this.packageTypes = const [],
    this.verifiedOnly = false,
    this.following = false,
    this.dateFrom,
    this.dateTo,
    this.weightMin,
    this.weightMax,
    this.priceMin,
    this.priceMax,
    this.ratingMin,
    this.tierMin,
    this.sort = 'relevance',
  });

  ListingFilterState copyWith({
    String? type,
    City? cityFrom,
    City? cityTo,
    List<String>? packageTypes,
    bool? verifiedOnly,
    bool? following,
    String? dateFrom,
    String? dateTo,
    double? weightMin,
    double? weightMax,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    String? tierMin,
    String? sort,
    bool clearType = false,
    bool clearCityFrom = false,
    bool clearCityTo = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearWeightMin = false,
    bool clearWeightMax = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    bool clearRatingMin = false,
    bool clearTierMin = false,
  }) {
    return ListingFilterState(
      type: clearType ? null : type ?? this.type,
      cityFrom: clearCityFrom ? null : cityFrom ?? this.cityFrom,
      cityTo: clearCityTo ? null : cityTo ?? this.cityTo,
      packageTypes: packageTypes ?? this.packageTypes,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      following: following ?? this.following,
      dateFrom: clearDateFrom ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDateTo ? null : dateTo ?? this.dateTo,
      weightMin: clearWeightMin ? null : weightMin ?? this.weightMin,
      weightMax: clearWeightMax ? null : weightMax ?? this.weightMax,
      priceMin: clearPriceMin ? null : priceMin ?? this.priceMin,
      priceMax: clearPriceMax ? null : priceMax ?? this.priceMax,
      ratingMin: clearRatingMin ? null : ratingMin ?? this.ratingMin,
      tierMin: clearTierMin ? null : tierMin ?? this.tierMin,
      sort: sort ?? this.sort,
    );
  }

  bool get hasFilters {
    return type != null ||
        cityFrom != null ||
        cityTo != null ||
        packageTypes.isNotEmpty ||
        verifiedOnly ||
        following ||
        dateFrom != null ||
        dateTo != null ||
        weightMin != null ||
        weightMax != null ||
        priceMin != null ||
        priceMax != null ||
        ratingMin != null ||
        tierMin != null ||
        sort != 'relevance';
  }

  int get activeFilterCount {
    var count = 0;
    if (type != null) count++;
    if (packageTypes.isNotEmpty) count += packageTypes.length;
    if (verifiedOnly) count++;
    if (following) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (weightMin != null || weightMax != null) count++;
    if (priceMin != null || priceMax != null) count++;
    if (ratingMin != null) count++;
    if (tierMin != null) count++;
    return count;
  }

  bool get hasRoute => cityFrom != null || cityTo != null;

  ListingFilterState routeOnly() {
    return ListingFilterState(cityFrom: cityFrom, cityTo: cityTo);
  }

  Map<String, dynamic> toApiFilters({bool includeFollowing = true}) {
    final data = <String, dynamic>{};
    if (type != null) data['type'] = type;
    if (cityFrom != null) data['city_from_id'] = cityFrom!.id;
    if (cityTo != null) data['city_to_id'] = cityTo!.id;
    if (verifiedOnly) data['verified_only'] = true;
    if (includeFollowing && following) data['following'] = true;
    if (packageTypes.isNotEmpty) data['package_types'] = packageTypes;
    if (dateFrom != null) data['date_from'] = dateFrom;
    if (dateTo != null) data['date_to'] = dateTo;
    if (weightMin != null) data['weight_min'] = weightMin;
    if (weightMax != null) data['weight_max'] = weightMax;
    if (priceMin != null) data['price_min'] = priceMin;
    if (priceMax != null) data['price_max'] = priceMax;
    if (ratingMin != null) data['rating_min'] = ratingMin;
    if (tierMin != null) data['tier_min'] = tierMin;
    return data;
  }

  Map<String, dynamic> toHistoryJson() {
    return {
      'filters': toApiFilters(),
      'from_name': cityFrom?.name,
      'from_country': cityFrom?.countryName,
      'to_name': cityTo?.name,
      'to_country': cityTo?.countryName,
    };
  }

  static ListingFilterState fromHistoryJson(Map<String, dynamic> json) {
    final filters = json['filters'] is Map
        ? Map<String, dynamic>.from(json['filters'] as Map)
        : json;
    return fromFilterMap(
      filters,
      cityFromName: json['from_name']?.toString(),
      cityFromCountry: json['from_country']?.toString(),
      cityToName: json['to_name']?.toString(),
      cityToCountry: json['to_country']?.toString(),
    );
  }

  static ListingFilterState fromFilterMap(
    Map<String, dynamic> filters, {
    String? cityFromName,
    String? cityFromCountry,
    String? cityToName,
    String? cityToCountry,
  }) {
    final fromId = _intValue(filters['city_from_id']);
    final toId = _intValue(filters['city_to_id']);
    return ListingFilterState(
      type: filters['type']?.toString(),
      cityFrom: fromId == null
          ? null
          : City(
              id: fromId,
              name: cityFromName ?? '#$fromId',
              countryId: 0,
              countryCode: '',
              countryName: cityFromCountry ?? '',
            ),
      cityTo: toId == null
          ? null
          : City(
              id: toId,
              name: cityToName ?? '#$toId',
              countryId: 0,
              countryCode: '',
              countryName: cityToCountry ?? '',
            ),
      packageTypes: _stringList(filters['package_types']),
      verifiedOnly: filters['verified_only'] == true ||
          filters['verified_only']?.toString() == 'true',
      following: filters['following'] == true ||
          filters['following']?.toString() == 'true',
      dateFrom: filters['date_from']?.toString(),
      dateTo: filters['date_to']?.toString(),
      weightMin: _doubleValue(filters['weight_min']),
      weightMax: _doubleValue(filters['weight_max']),
      priceMin: _doubleValue(filters['price_min']),
      priceMax: _doubleValue(filters['price_max']),
      ratingMin: _doubleValue(filters['rating_min']),
      tierMin: filters['tier_min']?.toString(),
    );
  }
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

List<String> _stringList(Object? value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

class ListingFeedBloc extends PaginableBloc<Listing> {
  final authRepository = sl.get<AuthRepository>();

  ListingFilterState filters;
  int? _seed;
  Pagination<Listing>? lastPagination;
  PackageTypesResponse? _packageTypes;
  Map<String, String>? _listingContent;

  final BehaviorSubject<Map<String, String>> packageNamesByCode =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<Map<String, String>> listingContent =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<List<PaginationSuggestion>> suggestions =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<ListingFilterState>> recentSearches =
      BehaviorSubject.seeded(const []);

  ListingFeedBloc({this.filters = const ListingFilterState()});

  @override
  void init() {
    super.init();
    loadPackageTypes();
    loadListingContent();
  }

  @override
  void dispose() {
    packageNamesByCode.close();
    listingContent.close();
    suggestions.close();
    recentSearches.close();
    super.dispose();
  }

  Future<void> refreshList() async {
    _seed = null;
    suggestions.add(const []);
    return load(refresh: true, cancelable: true);
  }

  void setFilters(ListingFilterState nextFilters) {
    filters = nextFilters;
    _seed = null;
    suggestions.add(const []);
  }

  void swapCities() {
    filters = filters.copyWith(
      cityFrom: filters.cityTo,
      cityTo: filters.cityFrom,
      clearCityFrom: filters.cityTo == null,
      clearCityTo: filters.cityFrom == null,
    );
    _seed = null;
  }

  Future<PackageTypesResponse> loadPackageTypes() async {
    if (_packageTypes != null) return _packageTypes!;
    final result = await authRepository.getListingPackageTypes();
    _packageTypes = result;
    packageNamesByCode.add({
      for (final item in result.data) item.code: item.name,
    });
    return result;
  }

  Future<Map<String, String>> loadListingContent() async {
    if (_listingContent != null) return _listingContent!;
    final result = await WawatContent.loadDefault();
    _listingContent = result;
    listingContent.add(result);
    return result;
  }

  Future<CitiesResponse> getCities(String search) {
    return authRepository.getListingCities(search, limit: 20);
  }

  Future<CitiesResponse> getPopularCities() {
    return authRepository.getPopularCities();
  }

  Future<TrendingRoutesResponse> getTrendingRoutes() {
    return authRepository.getTrendingRoutes();
  }

  Future<bool> isLogged() => authRepository.isLogged();

  Future<void> setFavorite(Listing listing, bool nextValue) async {
    if (nextValue) {
      await authRepository.addListingFavorite(listing.id);
    } else {
      await authRepository.removeListingFavorite(listing.id);
    }
  }

  @override
  Future<Pagination<Listing>> provideSource(int page) async {
    final response = await authRepository.getListings(
      type: filters.type,
      cityFromId: filters.cityFrom?.id,
      cityToId: filters.cityTo?.id,
      verifiedOnly: filters.verifiedOnly ? true : null,
      following: filters.following ? true : null,
      packageTypes: filters.packageTypes.isEmpty ? null : filters.packageTypes,
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      weightMin: filters.weightMin,
      weightMax: filters.weightMax,
      priceMin: filters.priceMin,
      priceMax: filters.priceMax,
      ratingMin: filters.ratingMin,
      tierMin: filters.tierMin,
      sort: filters.sort,
      seed: filters.sort == 'relevance' ? _seed : null,
      page: page,
      perPage: 20,
    );
    lastPagination = response;
    if (filters.sort == 'relevance') {
      _seed = response.seed ?? _seed;
    }
    suggestions.add(response.suggestions);
    return response;
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('wawatair_recent_searches') ?? const [];
    recentSearches.add(
      raw
          .map((item) {
            try {
              return ListingFilterState.fromHistoryJson(
                Map<String, dynamic>.from(jsonDecode(item) as Map),
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<ListingFilterState>()
          .where((item) => !_hasTechnicalCityName(item))
          .toList(),
    );
  }

  Future<void> saveRecentSearch(ListingFilterState filters) async {
    if (!filters.hasFilters) return;
    final prefs = await SharedPreferences.getInstance();
    final current =
        prefs.getStringList('wawatair_recent_searches') ?? const <String>[];
    final next = [
      jsonEncode(filters.toHistoryJson()),
      ...current.where((item) {
        try {
          final saved = ListingFilterState.fromHistoryJson(
            Map<String, dynamic>.from(jsonDecode(item) as Map),
          );
          return saved.cityFrom?.id != filters.cityFrom?.id ||
              saved.cityTo?.id != filters.cityTo?.id ||
              saved.type != filters.type;
        } catch (_) {
          return false;
        }
      }),
    ].take(8).toList();
    await prefs.setStringList('wawatair_recent_searches', next);
    await loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wawatair_recent_searches');
    recentSearches.add(const []);
  }

  Future<SavedSearchesResponse> getSavedSearches() {
    return authRepository.getSavedSearches();
  }

  Future<SavedSearchResponse> createSavedSearch({
    String? name,
    bool notify = true,
    required ListingFilterState filters,
  }) {
    return authRepository.createSavedSearch(
      SavedSearchRequest(
        name: name,
        notify: notify,
        filters: filters.toApiFilters(includeFollowing: false),
      ),
    );
  }

  Future<void> deleteSavedSearch(String id) {
    return authRepository.deleteSavedSearch(id);
  }
}

bool _hasTechnicalCityName(ListingFilterState filters) {
  return (filters.cityFrom?.name.startsWith('#') ?? false) ||
      (filters.cityTo?.name.startsWith('#') ?? false);
}
