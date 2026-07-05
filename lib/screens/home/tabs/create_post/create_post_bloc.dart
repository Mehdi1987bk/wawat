import 'package:dio/dio.dart';

import '../../../../data/network/request/create_listing_request.dart';
import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_bloc.dart';

class CreatePostBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  PackageTypesResponse? _cachedPackageTypes;

  Future<CitiesResponse> getCities(String search) {
    return authRepository.getListingCities(search, limit: 20);
  }

  Future<PackageTypesResponse> getPackageTypes() async {
    if (_cachedPackageTypes != null) return _cachedPackageTypes!;
    _cachedPackageTypes = await authRepository.getListingPackageTypes();
    return _cachedPackageTypes!;
  }

  Future<ListingResponse> createListing(
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return run(authRepository.createListing(request, idempotencyKey));
  }

  Map<String, String> parseValidationErrors(Object error) {
    if (error is! DioException) return const {};
    final data = error.response?.data;
    if (data is! Map) return const {};
    final errors = data['errors'];
    if (errors is! Map) return const {};

    return errors.map((key, value) {
      if (value is List && value.isNotEmpty) {
        return MapEntry(key.toString(), value.first.toString());
      }
      return MapEntry(key.toString(), value.toString());
    });
  }
}
