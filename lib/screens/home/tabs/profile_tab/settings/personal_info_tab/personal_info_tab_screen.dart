import 'dart:io';

import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/personal_info_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/widget/profile_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../data/network/response/user.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
import '../../../../../../presentation/common/image_selector.dart';
import '../../../../../../presentation/resourses/app_colors.dart';

class PersonalInfoTab extends BaseScreen {
  final User user;

  PersonalInfoTab({Key? key, required this.user}) : super(key: key);

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState
    extends BaseState<PersonalInfoTab, PersonalInfoTabBloc> {
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  File? _selectedImage;

  // ✅ Сохраняем исходные значения для сравнения
  late String _initialFullname;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialLocation;
  late String _initialAbout;

  @override
  void initState() {
    super.initState();

    // Инициализируем текущие значения
    _initialFullname = widget.user.fullname ?? '';
    _initialEmail = widget.user.email ?? '';
    _initialPhone = widget.user.phone ?? '';
    _initialLocation = widget.user.location ?? '';
    _initialAbout = widget.user.about ?? '';

    _fullNameController = TextEditingController(text: _initialFullname);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    _locationController = TextEditingController(text: _initialLocation);
    _aboutController = TextEditingController(text: _initialAbout);

    // Добавляем слушатели для валидации при любом изменении
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _aboutController.addListener(_validateForm);
  }

  @override
  Widget body() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ProfileImageWidget(
                imageUrl: 'url',
                // Ссылка на фото (опционально)
                localFile: _selectedImage,
                // Локальный файл (опционально)
                onCameraPressed: _selectImage,
                // Обязательный callback
                size: 120,
                // Размер (по умолчанию 120)
                borderRadius: 100,
                // Скругление (по умолчанию 24)
                cameraIconSize: 14,
                // Размер иконки (по умолчанию 20)
                showShadow: true, // Тень (по умолчанию true)
              ),
              const SizedBox(height: 12),
              const Text(
                'Нажмите для изменения фото',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Полное имя', _fullNameController),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController),
              const SizedBox(height: 16),
              _buildTextField('Телефон', _phoneController),
              const SizedBox(height: 16),
              _buildTextField('Местоположение', _locationController),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О себе',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aboutController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5EA),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5EA),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF5B4FFF),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.only(
                  top: 20,
                  bottom: 50,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isFormValid,
                  builder: (_, isValid, __) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                        Color(0xFF5B4FFF).withOpacity(0.3),
                        backgroundColor: const Color(0xFF5B4FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isValid ? _addEmployer : null,
                      child: Text(
                        "Сохранить изменения",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  provideBloc() {
    return PersonalInfoTabBloc();
  }

  Future<void> _selectImage() async {
    final source = await showSelectImageSourceAlert(context);
    if (source != null) {
      final image =
      await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (image != null) {
        final file = File(image.path);

        if (!file.existsSync()) {
          print("Файл не найден: ${file.path}");
          return;
        }

        setState(() {
          _selectedImage = file; // 🔹 обновляем состояние для перерисовки
        });

        await bloc.onImageSelected(file);
        // Фотка не влияет на валидацию кнопки
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5EA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5B4FFF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  /// ✅ УЛУЧШЕННАЯ ВАЛИДАЦИЯ
  /// Кнопка активна если:
  /// 1. Хотя бы одно поле изменилось от исходного значения
  /// 2. Все обязательные поля (fullname, email, phone) не пусты
  void _validateForm() {
    final currentFullname = _fullNameController.text.trim();
    final currentEmail = _emailController.text.trim();
    final currentPhone = _phoneController.text.trim();
    final currentLocation = _locationController.text.trim();
    final currentAbout = _aboutController.text.trim();

    // Проверка что обязательные поля заполнены
    final isRequiredFieldsFilled =
        currentFullname.isNotEmpty &&
            currentEmail.isNotEmpty &&
            currentPhone.isNotEmpty;

    // Проверка что хотя бы одно поле изменилось
    final isAnythingChanged =
        currentFullname != _initialFullname ||
            currentEmail != _initialEmail ||
            currentPhone != _initialPhone ||
            currentLocation != _initialLocation ||
            currentAbout != _initialAbout;

    // Кнопка активна если заполнены все обязательные поля И что-то изменилось
    _isFormValid.value = isRequiredFieldsFilled && isAnythingChanged;

    print('=== ВАЛИДАЦИЯ ===');
    print('Fullname: "$currentFullname" != "$_initialFullname" = ${currentFullname != _initialFullname}');
    print('Email: "$currentEmail" != "$_initialEmail" = ${currentEmail != _initialEmail}');
    print('Phone: "$currentPhone" != "$_initialPhone" = ${currentPhone != _initialPhone}');
    print('Location: "$currentLocation" != "$_initialLocation" = ${currentLocation != _initialLocation}');
    print('About: "$currentAbout" != "$_initialAbout" = ${currentAbout != _initialAbout}');
    print('isAnythingChanged: $isAnythingChanged');
    print('isRequiredFieldsFilled: $isRequiredFieldsFilled');
    print('isFormValid: ${_isFormValid.value}');
    print('================');
  }

  void _addEmployer() {
    final String name = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String location = _locationController.text.trim();
    final String about = _aboutController.text.trim();

    bloc
        .profileEdit(
        name: name,
        email: email,
        phone: phone,
        location: location,
        about: about)
        .then(
          (onValue) {
        bloc.customersMe();
        showTopSnackbar("Сохранено", "Сохранено", true, context);
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}