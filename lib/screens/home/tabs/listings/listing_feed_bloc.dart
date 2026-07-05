import 'package:rxdart/rxdart.dart';

import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/trending_routes_response.dart';
import '../../../../domain/entities/pagination.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/paginable_bloc.dart';

class ListingFilterState {
  final String? type;
  final City? cityFrom;
  final City? cityTo;
  final List<String> packageTypes;
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
}

class ListingFeedBloc extends PaginableBloc<Listing> {
  final authRepository = sl.get<AuthRepository>();

  ListingFilterState filters;
  int? _seed;
  Pagination<Listing>? lastPagination;
  PackageTypesResponse? _packageTypes;

  final BehaviorSubject<Map<String, String>> packageNamesByCode =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<List<PaginationSuggestion>> suggestions =
      BehaviorSubject.seeded(const []);

  ListingFeedBloc({this.filters = const ListingFilterState()});

  @override
  void init() {
    super.init();
    loadPackageTypes();
  }

  @override
  void dispose() {
    packageNamesByCode.close();
    suggestions.close();
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
}
