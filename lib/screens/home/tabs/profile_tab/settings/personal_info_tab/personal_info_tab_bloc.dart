import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../../../../../data/network/api/auth_api.dart';
import '../../../../../../data/network/response/countries_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';
import '../../../../../../presentation/bloc/base_bloc.dart';

class PersonalInfoTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  final AuthApi _authApi = sl.get<AuthApi>();
  final PublishSubject<File> userAvatar = PublishSubject();

  File? images;
  String? imageUrl;

  onImageSelected(File file) {
    imageUrl = null;
    images = file;
    userAvatar.add(file);
    authRepository.addAvatar(images!);
  }

  /// Получить список стран
  Future<CountriesResponse> getCountries() {
    return _authApi.getCountries();
  }

  Future<void> customersMe() => authRepository.customersMe();

  Future<void> profileEdit({
    required String name,
    required String email,
    required String phone,
    required String location,
    required String about,
    String? callingCode,
  }) =>
      run(
        authRepository.profileEdit(
          name,
          email,
          phone,
          location,
          about,
          callingCode,
        ),
      );
}
