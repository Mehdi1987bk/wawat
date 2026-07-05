import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';

class FovoriteOfferBloc extends PaginableBloc<Listing> {
  final authRepository = sl.get<AuthRepository>();
  PackageTypesResponse? _packageTypes;

  Future<void> loadList() async {
    return load(refresh: true, cancelable: true);
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

  @override
  Future<Pagination<Listing>> provideSource(int page) {
    return run(authRepository.getListingFavorites(page: page, perPage: 20));
  }

  Future<void> setFavorite(Listing listing, bool nextValue) async {
    if (nextValue) {
      await authRepository.addListingFavorite(listing.id);
    } else {
      await authRepository.removeListingFavorite(listing.id);
      deletedItem(listing);
    }
  }
}
