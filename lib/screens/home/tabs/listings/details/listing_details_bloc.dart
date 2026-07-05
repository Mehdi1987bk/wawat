import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class ListingDetailsBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  PackageTypesResponse? _packageTypes;

  Future<ListingResponse> getDetails(String id) {
    return run(authRepository.getListingDetails(id));
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

  Future<void> setFavorite(Listing listing, bool nextValue) async {
    if (nextValue) {
      await authRepository.addListingFavorite(listing.id);
    } else {
      await authRepository.removeListingFavorite(listing.id);
    }
  }
}
