import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../../data/network/request/courier_profile.dart';
import '../../../../../../data/network/request/privacy_settings.dart';
import '../../../../../../data/network/response/language_response.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';

class ExperienceTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  LanguageResponse? _cachedLanguages;
  PackageTypesResponse? _cachedPackageTypes;
  Future<void> customersMe() => authRepository.customersMe();

  Future<LanguageResponse> getLanguages() async {
    try {
      if (_cachedLanguages != null) {
        return _cachedLanguages!;
      }

      final result = await authRepository.getLanguages();

      for (var lang in result.data) {
        print('  ✓   ${lang.code} - ${lang.name}');
      }

      _cachedLanguages = result;

      return result;
    } catch (e, stackTrace) {
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
      if (e.toString().contains('404')) {
        _cachedPackageTypes = PackageTypesResponse(data: []);
        return _cachedPackageTypes!;
      }

      rethrow;
    }
  }

  Future<void> createProfessional(CourierProfile request) {
    return run(authRepository.createProfessional(request));
  }


  CourierProfile createProfessionalRequest({
    required int workExperienceYears,
    required int maxWeightKg,
    required int insuranceAmount,
    required double pricePerKgMin,
    required double pricePerKgMax,
    required String workTimeFrom,
    required String workTimeTo,
    required List<String> communicationLanguageIds,
    required List<String> packageTypeIds,
  }) {
    return CourierProfile(
      experienceYears: workExperienceYears,
      maxWeightKg: maxWeightKg,
      workTimeFrom: workTimeFrom,
      workTimeTo: workTimeTo,
      priceFrom: pricePerKgMin,
      priceTo: pricePerKgMax,
      insuranceUsd: insuranceAmount,
      packageTypes: packageTypeIds,
      languages: communicationLanguageIds,
    );
  }

  void clearCache() {
    _cachedLanguages = null;
    _cachedPackageTypes = null;
  }
}
