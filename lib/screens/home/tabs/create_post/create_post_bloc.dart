import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../data/network/request/courier_offer_model.dart';
import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/language_response.dart';
import '../../../../data/network/response/offer_type_model.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';

class CreatePostBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  LanguageResponse? _cachedLanguages;
  PackageTypesResponse? _cachedPackageTypes;

  Future<CitiesResponse> getCities(String search) async {
    try {
      final result = await authRepository.getCities(search);

      for (var i = 0;
      i < (result.data.length > 5 ? 5 : result.data.length);
      i++) {
        final city = result.data[i];
        print('  ✓ ${city.name} (${city.countryName})');
      }

      return result;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<LanguageResponse> getLanguages() async {
    try {
      if (_cachedLanguages != null) {
        return _cachedLanguages!;
      }

      final result = await authRepository.getLanguages();

      for (var lang in result.data) {
        print('  ✓  ${lang.code} - ${lang.name}');
      }

      _cachedLanguages = result;

      return result;
    } catch (e, stackTrace) {
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<PackageTypesResponse> getPackageTypes() async {
    try {
      if (_cachedPackageTypes != null) {
        return _cachedPackageTypes!;
      }

      final result = await authRepository.getPackageType();

      for (var pkg in result.data) {
        print('  ✓ ${pkg.code}: ${pkg.name} (icon: ${pkg.icon})');
      }

      _cachedPackageTypes = result;

      return result;
    } catch (e, stackTrace) {
      // if (e.toString().contains('404')) {
      //   _cachedPackageTypes = PackageTypesResponse(data: []);
      //   return _cachedPackageTypes!;
      // }

      rethrow;
    }
  }

  Future<void> createOffers(CourierOfferModel request) =>
      run(authRepository.createOffers(request));

  Future<OfferTypeResponse> getOfferTypes() => authRepository.getOfferTypes();

  void clearCache() {
    _cachedLanguages = null;
    _cachedPackageTypes = null;
  }
}
