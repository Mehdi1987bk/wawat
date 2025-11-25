import 'package:buking/presentation/bloc/base_bloc.dart';

import '../../../../data/network/response/language_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';

class CreatePostBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();

  // ✅ Кэширование загруженных данных
  LanguageResponse? _cachedLanguages;
  PackageTypesResponse? _cachedPackageTypes;

  /// Получить список языков с кэшированием
  Future<LanguageResponse> getLanguages() async {
    try {
      print('========== CreatePostBloc: Начало загрузки языков ==========');

      // ✅ Возвращаем кэшированные данные если они есть
      if (_cachedLanguages != null) {
        print('CreatePostBloc: Возвращаю кэшированные языки - ${_cachedLanguages!.data.length} штук');
        return _cachedLanguages!;
      }

      final result = await authRepository.getLanguages();

      print('CreatePostBloc: API Response type: ${result.runtimeType}');
      print('CreatePostBloc: Языки загружены - ${result.data.length} штук');

      // ✅ Логируем каждый язык
      for (var lang in result.data) {
        print('  ✓  ${lang.code} - ${lang.name}');
      }

      // ✅ Кэшируем результат
      _cachedLanguages = result;

      print('========== CreatePostBloc: Загрузка языков завершена ==========');
      return result;

    } catch (e, stackTrace) {
      print('========== CreatePostBloc ERROR: Ошибка при загрузке языков ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');
      rethrow;
    }
  }

  /// Получить список типов упаковки с кэшированием
  Future<PackageTypesResponse> getPackageTypes() async {
    try {
      print('========== CreatePostBloc: Начало загрузки типов упаковки ==========');

      // ✅ Возвращаем кэшированные данные если они есть
      if (_cachedPackageTypes != null) {
        print('CreatePostBloc: Возвращаю кэшированные типы - ${_cachedPackageTypes!.data.length} штук');
        return _cachedPackageTypes!;
      }

      final result = await authRepository.getPackageType();

      print('CreatePostBloc: API Response type: ${result.runtimeType}');
      print('CreatePostBloc: Типы упаковки загружены - ${result.data.length} штук');

      // ✅ Логируем каждый тип упаковки
      for (var pkg in result.data) {
        print('  ✓ ${pkg.code}: ${pkg.name} (icon: ${pkg.icon})');
      }

      // ✅ Кэшируем результат
      _cachedPackageTypes = result;

      print('========== CreatePostBloc: Загрузка типов завершена ==========');
      return result;

    } catch (e, stackTrace) {
      print('========== CreatePostBloc ERROR: Ошибка при загрузке типов ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');

      // ✅ Если это 404 ошибка, возвращаем пустой response вместо rethrow
      if (e.toString().contains('404')) {
        print('CreatePostBloc: 404 ошибка - endpoint не найден на сервере, возвращаю пустой список');
        _cachedPackageTypes = PackageTypesResponse(data: []);
        return _cachedPackageTypes!;
      }

      rethrow;
    }
  }

  /// Очистить кэш (вызвать при обновлении данных)
  void clearCache() {
    print('CreatePostBloc: Кэш очищен');
    _cachedLanguages = null;
    _cachedPackageTypes = null;
  }
}