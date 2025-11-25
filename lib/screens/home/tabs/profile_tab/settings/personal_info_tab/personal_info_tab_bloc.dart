import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';
import '../../../../../../presentation/bloc/base_bloc.dart';

class PersonalInfoTabBloc extends BaseBloc {
  final authRepository = sl.get<AuthRepository>();
  final PublishSubject<File> userAvatar = PublishSubject();

  File? images;
  String? imageUrl;

  onImageSelected(File file) {
    imageUrl = null;
    images = file;
    userAvatar.add(file);
  }

  Future<void> customersMe() => authRepository.customersMe();

  Future<void> profileEdit({
    required String name,
    required String email,
    required String phone,
    required String location,
    required String about,
  }) =>
      run(
        authRepository.profileEdit(
          name,
          email,
          phone,
          location,
          about,
          // images,
        ),
      ) ;
}
