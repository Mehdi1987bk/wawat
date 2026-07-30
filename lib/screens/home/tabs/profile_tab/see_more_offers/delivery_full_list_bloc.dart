import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/request/create_listing_request.dart';
import '../../../../../data/network/request/delete_listing_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';

class DeliveryFullListBloc extends PaginableBloc<Listing> {
  final userRepository = sl.get<AuthRepository>();
  final BehaviorSubject<bool> _isUpdating = BehaviorSubject.seeded(false);

  PackageTypesResponse? _packageTypes;

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

  @override
  Future<Pagination<Listing>> provideSource(int page) {
    return userRepository.getMyListings(page: page, perPage: 20);
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

  Future<void> repostListing(Listing listing) async {
    await _mutate(
      () => userRepository.repostListing(
        listing.id,
        _requestFromListing(listing),
        'repost-${listing.id}-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
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

  CreateListingRequest _requestFromListing(Listing listing) {
    if (listing.isTrip) {
      return CreateListingRequest(
        type: listing.type,
        cityFromId: listing.cityFromId ?? 0,
        cityToId: listing.cityToId ?? 0,
        packageTypeCodes: listing.packageTypeCodes,
        description: listing.description,
        allowPriceNegotiation: listing.allowPriceNegotiation,
        flightDate: listing.flightDate,
        flightTime: listing.flightTime,
        flightNumber: listing.flightNumber,
        maxWeightKg: listing.maxWeightKg,
        pricePerKg: listing.pricePerKg,
      );
    }
    return CreateListingRequest(
      type: listing.type,
      cityFromId: listing.cityFromId ?? 0,
      cityToId: listing.cityToId ?? 0,
      packageTypeCodes: listing.packageTypeCodes,
      description: listing.description,
      deliveryDateFrom: listing.deliveryDateFrom,
      deliveryDateTo: listing.deliveryDateTo,
      weightKg: listing.weightKg,
    );
  }

  @override
  void dispose() {
    _isUpdating.close();
    super.dispose();
  }
}
