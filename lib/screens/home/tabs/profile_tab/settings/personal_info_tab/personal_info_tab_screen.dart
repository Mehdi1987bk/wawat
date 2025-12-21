import 'dart:io';

import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/personal_info_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/widget/profile_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/network/response/user.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
import '../../../../../../presentation/common/image_selector.dart';
import '../../../../../../presentation/resourses/app_colors.dart';
import '../../../../../../services/theme_aware_screen.dart';
import '../../../../../../services/theme_manager.dart';
import '../experience_tab/experience_tab_screen.dart';

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

  late String _initialFullname;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialLocation;
  late String _initialAbout;

  @override
  void initState() {
    super.initState();

    _initialFullname = widget.user.fullname ?? '';
    _initialEmail = widget.user.email ?? '';
    _initialPhone = widget.user.phone ?? '';
    _initialLocation = widget.user.profile?.locationText ?? '';
    _initialAbout = widget.user.profile?.about ?? '';

    _fullNameController = TextEditingController(text: _initialFullname);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    _locationController = TextEditingController(text: _initialLocation);
    _aboutController = TextEditingController(text: _initialAbout);

    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _aboutController.addListener(_validateForm);
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileImageWidget(
                      imageUrl: 'url',
                      localFile: _selectedImage,
                      onCameraPressed: _selectImage,
                      size: 120,
                      borderRadius: 100,
                      cameraIconSize: 14,
                      showShadow: true,
                    ),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF8E8E93),
                      ),
                      child: const Text('Нажмите для изменения фото'),
                    ),
                    const SizedBox(height: 24),
                    // ❌ Только для чтения с "пленкой"
                    _buildReadOnlyTextField('Полное имя', _fullNameController, isDark),
                    const SizedBox(height: 16),
                    _buildReadOnlyTextField('Email', _emailController, isDark),
                    const SizedBox(height: 16),
                    _buildReadOnlyTextField('Телефон', _phoneController, isDark),
                    const SizedBox(height: 16),
                    _buildTextField('Местоположение', _locationController, isDark),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          child: const Text('О себе'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _aboutController,
                          maxLines: 4,
                          keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF4A4A4A)
                                    : const Color(0xFFE5E5EA),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF4A4A4A)
                                    : const Color(0xFFE5E5EA),
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
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isFormValid,
                        builder: (_, isValid, __) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor:
                              const Color(0xFF5B4FFF).withOpacity(0.3),
                              backgroundColor: const Color(0xFF5B4FFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: isValid ? _addEmployer : null,
                            child: const Text(
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
          ),
        );
      },
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
          _selectedImage = file;
        });

        await bloc.onImageSelected(file);
        showIOSStyleMessage(context, 'Сохранено');
      }
    }
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF4A4A4A)
                    : const Color(0xFFE5E5EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF4A4A4A)
                    : const Color(0xFFE5E5EA),
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
        ),
      ],
    );
  }

  // ❌ Новая функция для ReadOnly полей с "пленкой"
  Widget _buildReadOnlyTextField(
      String label, TextEditingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF4A4A4A)
                        : const Color(0xFFE5E5EA),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF4A4A4A)
                        : const Color(0xFFE5E5EA),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validateForm() {
    final currentFullname = _fullNameController.text.trim();
    final currentEmail = _emailController.text.trim();
    final currentPhone = _phoneController.text.trim();
    final currentLocation = _locationController.text.trim();
    final currentAbout = _aboutController.text.trim();

    final isRequiredFieldsFilled = currentFullname.isNotEmpty &&
        currentEmail.isNotEmpty &&
        currentPhone.isNotEmpty;

    final isAnythingChanged = currentFullname != _initialFullname ||
        currentEmail != _initialEmail ||
        currentPhone != _initialPhone ||
        currentLocation != _initialLocation ||
        currentAbout != _initialAbout;

    _isFormValid.value = isRequiredFieldsFilled && isAnythingChanged;
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
        showIOSStyleMessage(context, 'Сохранено');
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
