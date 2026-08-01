import 'dart:async';
import 'dart:math';

import '../../../../../data/network/request/delete_listing_request.dart';
import '../../../../../data/network/request/listing_proposal_request.dart';
import '../../../../../data/network/request/report_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../data/network/response/user.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/wawat_content.dart';

class ListingDetailsBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  PackageTypesResponse? _packageTypes;
  Map<String, String>? _content;

  Future<ListingResponse> getDetails(String id) {
    return run(authRepository.getListingDetails(id));
  }

  Future<Map<String, String>> loadContent() async {
    if (_content != null) return _content!;
    _content = await WawatContent.loadDefault();
    return _content!;
  }

  Future<PackageTypesResponse> loadPackageTypes() async {
    if (_packageTypes != null) return _packageTypes!;
    _packageTypes = await authRepository.getListingPackageTypes();
    return _packageTypes!;
  }

  Map<String, String> get packageNamesByCode {
    final data = _packageTypes?.data ?? const [];
    return {for (final item in data) item.code: item.name};
  }

  Future<bool> isLogged() => authRepository.isLogged();

  Future<User?> currentUser() async {
    if (!await authRepository.isLogged()) return null;
    try {
      await authRepository.customersMe();
    } catch (_) {
      // The cache may still contain the last user; keep the detail page usable.
    }
    try {
      return await authRepository.userDetails
          .map<User?>((user) => user)
          .first
          .timeout(
            const Duration(milliseconds: 900),
            onTimeout: () => null,
          );
    } catch (_) {
      return null;
    }
  }

  Future<void> setFavorite(Listing listing, bool nextValue) async {
    if (nextValue) {
      await authRepository.addListingFavorite(listing.id);
    } else {
      await authRepository.removeListingFavorite(listing.id);
    }
  }

  Future<ListingResponse> pauseListing(String id) {
    return run(authRepository.pauseListing(id));
  }

  Future<ListingResponse> resumeListing(String id) {
    return run(authRepository.resumeListing(id));
  }

  Future<void> deleteListing({
    required String id,
    required String reasonCode,
    String? reasonNote,
  }) {
    return run(
      authRepository.deleteListing(
        id,
        DeleteListingRequest(reasonCode: reasonCode, reasonNote: reasonNote),
      ),
    );
  }

  Future<void> createProposal({
    required String listingId,
    required String packageTypeCode,
    double? weightKg,
    double? priceTotal,
    String? note,
  }) {
    return run(
      authRepository.createListingProposal(
        listingId,
        ListingProposalRequest(
          packageTypeCode: packageTypeCode,
          weightKg: weightKg,
          priceTotal: priceTotal,
          note: note,
        ),
        _idempotencyKey('proposal'),
      ),
    );
  }

  Future<void> reportListing({
    required String listingId,
    String? reasonCode,
    String? note,
  }) {
    return run(
      authRepository.reportListing(
        ReportRequest(
          targetType: 'listing',
          targetId: listingId,
          reasonCode: reasonCode,
          note: note,
        ),
        _idempotencyKey('report'),
      ),
    );
  }

  String _idempotencyKey(String scope) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return 'listing-$scope-$now-$random';
  }

}
