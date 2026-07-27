import 'package:dio/dio.dart';

import '../../../../data/network/request/create_listing_request.dart';
import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/trending_routes_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_bloc.dart';
import '../../../../services/wawat_content.dart';

class CreatePostBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  PackageTypesResponse? _cachedPackageTypes;
  Map<String, String>? _cachedListingContent;

  Stream<User> get userDetails => authRepository.userDetails;

  Future<void> refreshCurrentUser() => authRepository.customersMe();

  Future<CitiesResponse> getCities(String search) {
    return authRepository.getListingCities(search, limit: 20);
  }

  Future<CitiesResponse> getPopularCities() {
    return authRepository.getPopularCities();
  }

  Future<TrendingRoutesResponse> getTrendingRoutes() {
    return authRepository.getTrendingRoutes();
  }

  Future<PackageTypesResponse> getPackageTypes() async {
    if (_cachedPackageTypes != null) return _cachedPackageTypes!;
    _cachedPackageTypes = await authRepository.getListingPackageTypes();
    return _cachedPackageTypes!;
  }

  Future<Map<String, String>> getListingContent() async {
    if (_cachedListingContent != null) return _cachedListingContent!;
    _cachedListingContent = await WawatContent.loadGroups(
      const ['listing', 'create', 'search', 'common', 'validation', 'picker'],
    );
    return _cachedListingContent!;
  }

  Future<ListingResponse> createListing(
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return run(authRepository.createListing(request, idempotencyKey));
  }

  /// Full update of an existing listing (PATCH /listings/{id}). The backend
  /// re-runs moderation, so the returned listing comes back in `moderation`.
  Future<ListingResponse> updateListing(
    String id,
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return run(authRepository.updateListing(id, request, idempotencyKey));
  }

  /// Top-level server `message` (403 permission/status, or a domain error such
  /// as the verification-tier weight limit) — shown when there are no
  /// field-level validation errors to attach.
  String? extractErrorMessage(Object error) {
    if (error is! DioException) return null;
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
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
