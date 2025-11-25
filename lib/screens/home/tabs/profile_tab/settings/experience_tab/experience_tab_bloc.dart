import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../../../data/network/request/courier_profile.dart';
import '../../../../../../data/network/request/privacy_settings.dart';
import '../../../../../../data/network/response/language_response.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';

class ExperienceTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  // ✅ Кэширование загруженных данных
  LanguageResponse? _cachedLanguages;
  PackageTypesResponse? _cachedPackageTypes;

  /// Получить список языков с кэшированием
  Future<LanguageResponse> getLanguages() async {
    try {
      print('========== ExperienceTabBloc: Начало загрузки языков ==========');

      // ✅ Возвращаем кэшированные данные если они есть
      if (_cachedLanguages != null) {
        print('ExperienceTabBloc: Возвращаю кэшированные языки - ${_cachedLanguages!.data.length} штук');
        return _cachedLanguages!;
      }

      final result = await authRepository.getLanguages();

      print('ExperienceTabBloc: API Response type: ${result.runtimeType}');
      print('ExperienceTabBloc: Языки загружены - ${result.data.length} штук');

      // ✅ Логируем каждый язык
      for (var lang in result.data) {
        print('  ✓   ${lang.code} - ${lang.name}');
      }

      // ✅ Кэшируем результат
      _cachedLanguages = result;

      print('========== ExperienceTabBloc: Загрузка языков завершена ==========');
      return result;

    } catch (e, stackTrace) {
      print('========== ExperienceTabBloc ERROR: Ошибка при загрузке языков ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');
      rethrow;
    }
  }

  /// Получить список типов упаковки с кэшированием
  Future<PackageTypesResponse> getPackageTypes() async {
    try {
      print('========== ExperienceTabBloc: Начало загрузки типов упаковки ==========');

      // ✅ Возвращаем кэшированные данные если они есть
      if (_cachedPackageTypes != null) {
        print('ExperienceTabBloc: Возвращаю кэшированные типы - ${_cachedPackageTypes!.data.length} штук');
        return _cachedPackageTypes!;
      }

      final result = await authRepository.getPackageType();

      print('ExperienceTabBloc: API Response type: ${result.runtimeType}');
      print('ExperienceTabBloc: Типы упаковки загружены - ${result.data.length} штук');

      // ✅ Логируем каждый тип упаковки
      for (var pkg in result.data) {
        print('  ✓ ${pkg.code}: ${pkg.name} (icon: ${pkg.icon})');
      }

      // ✅ Кэшируем результат
      _cachedPackageTypes = result;

      print('========== ExperienceTabBloc: Загрузка типов завершена ==========');
      return result;

    } catch (e, stackTrace) {
      print('========== ExperienceTabBloc ERROR: Ошибка при загрузке типов ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');

      // ✅ Если это 404 ошибка, возвращаем пустой response вместо rethrow
      if (e.toString().contains('404')) {
        print('ExperienceTabBloc: 404 ошибка - endpoint не найден на сервере, возвращаю пустой список');
        _cachedPackageTypes = PackageTypesResponse(data: []);
        return _cachedPackageTypes!;
      }

      rethrow;
    }
  }

  /// Создать профиль курьера
  Future<void> createProfessional(CourierProfile request) {
    return authRepository.createProfessional(request);
  }

  /// Вспомогательный метод для создания CourierProfile из отдельных параметров
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
    print('========== ExperienceTabBloc: Создание профиля ==========');
    print('workExperienceYears: $workExperienceYears');
    print('maxWeightKg: $maxWeightKg');
    print('insuranceAmount: $insuranceAmount');
    print('pricePerKgMin: $pricePerKgMin');
    print('pricePerKgMax: $pricePerKgMax');
    print('workTimeFrom: $workTimeFrom');
    print('workTimeTo: $workTimeTo');
    print('communicationLanguageIds: $communicationLanguageIds');
    print('packageTypeIds: $packageTypeIds');
    print('==========================================================');

    return CourierProfile(
      workExperienceYears: workExperienceYears,
      maxWeightKg: maxWeightKg,
      insuranceAmount: insuranceAmount,
      pricePerKgMin: pricePerKgMin,
      pricePerKgMax: pricePerKgMax,
      workTimeFrom: workTimeFrom,
      workTimeTo: workTimeTo,
      communicationLanguageIds: communicationLanguageIds,
      packageTypeIds: packageTypeIds,
    );
  }

  /// Очистить кэш (вызвать при обновлении данных)
  void clearCache() {
    print('ExperienceTabBloc: Кэш очищен');
    _cachedLanguages = null;
    _cachedPackageTypes = null;
  }
}