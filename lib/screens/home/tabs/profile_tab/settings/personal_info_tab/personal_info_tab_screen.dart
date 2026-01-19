import 'dart:io';

import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/auth/registration/widget/country_code_selector.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/personal_info_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/widget/profile_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../../../../data/network/response/country.dart';
import '../../../../../../data/network/response/user.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../presentation/common/image_selector.dart';
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
  // late TextEditingController _locationController;
  late TextEditingController _aboutController;
  File? _selectedImage;

  late String _initialFullname;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialLocation;
  late String _initialAbout;

  // Countries
  List<Country> _allCountries = [];
  Country? _selectedCountry;
  Country? _initialCountry;
  bool _isLoadingCountries = false;

  @override
  void initState() {
    super.initState();

    _initialFullname = widget.user.fullname ?? '';
    _initialEmail = widget.user.email ?? '';
    _initialPhone = widget.user.phone ?? '';
    _initialLocation = widget.user.profile?.locationText ?? '';
    _initialAbout = widget.user.profile?.about ?? '';
    _initialCountry = widget.user.country;
    _selectedCountry = widget.user.country;

    _fullNameController = TextEditingController(text: _initialFullname);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    // _locationController = TextEditingController(text: _initialLocation);
    _aboutController = TextEditingController(text: _initialAbout);

    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    // _locationController.addListener(_validateForm);
    _aboutController.addListener(_validateForm);

    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      setState(() => _isLoadingCountries = true);
      final response = await bloc.getCountries();
      if (mounted) {
        setState(() {
          _allCountries = response.data;
          // Если у пользователя уже есть код - находим его в списке
          if (widget.user.country != null) {
            _selectedCountry = _allCountries.firstWhere(
              (c) => c.id == widget.user.country!.id,
              orElse: () => widget.user.country!,
            );
            _initialCountry = _selectedCountry;
          }
          _isLoadingCountries = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingCountries = false);
    }
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
                      imageUrl: widget.user.avatar,
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
                      child:   Text(S.of(context).bvfdb4btevsf),
                    ),
                    const SizedBox(height: 24),
                    _buildReadOnlyTextField(
                        S.of(context).vrebveg34g3sd, _fullNameController, isDark),
                    const SizedBox(height: 16),
                    _buildReadOnlyTextField('Email', _emailController, isDark),
                    const SizedBox(height: 16),

                    // 🔥 ТЕЛЕФОН С КОДОМ СТРАНЫ (РЕДАКТИРУЕМЫЙ)
                    _buildPhoneFieldWithCountry(isDark),

                    // const SizedBox(height: 16),
                    // _buildTextField(
                    //     S.of(context).bebfdb34g3vs, _locationController, isDark),
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
                          child:   Text(S.of(context).vrevre43),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _aboutController,
                          maxLines: 4,
                          keyboardAppearance:
                              isDark ? Brightness.dark : Brightness.light,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                            child:   Text(
                              S.of(context).grvge3g5,
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

  // 🔥 Телефон с выбором кода страны
  Widget _buildPhoneFieldWithCountry(bool isDark) {
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
          child:   Text(S.of(context).vsf3grevsf43),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Country code selector (editable)
            CountryCodeSelector(
              enabled: false,
              selectedCountry: _selectedCountry,
              countries: _allCountries,
              isLoading: _isLoadingCountries,
              onChanged: (country) {
                setState(() => _selectedCountry = country);
                _validateForm();
              },
            ),
            const SizedBox(width: 8),

            // Phone number field (read-only)
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _phoneController,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
            ),
          ],
        ),
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
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        try {
          // Читаем оригинальное изображение
          final bytes = await image.readAsBytes();
          final originalImage = img.decodeImage(bytes);

          if (originalImage == null) {
            if (mounted) {
              showIOSStyleMessage(context, "Failed to process image");
            }
            return;
          }

          // 🔥 Применяем EXIF ориентацию (исправляет поворот селфи)
          final fixedImage = img.bakeOrientation(originalImage);

          // Сжимаем если нужно (максимум 1024px по большей стороне)
          final resizedImage = fixedImage.width > 1024 || fixedImage.height > 1024
              ? img.copyResize(
            fixedImage,
            width: fixedImage.width > fixedImage.height ? 1024 : null,
            height: fixedImage.height > fixedImage.width ? 1024 : null,
          )
              : fixedImage;

          // Сохраняем в temp директорию
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${tempDir.path}/profile_$timestamp.jpg');

          // Кодируем в JPG с хорошим качеством
          await file.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

          if (!file.existsSync()) {
            return;
          }

          setState(() {
            _selectedImage = file;
          });

          await bloc.onImageSelected(file);
          if (mounted) {
            showIOSStyleMessage(context, S.of(context).gregre3rg);
            Future.delayed(const Duration(seconds: 2))
                .then((onValue) => bloc.customersMe());
          }
        } catch (e) {
          print('Error processing image: $e');
          if (mounted) {
            showIOSStyleMessage(context, "Failed to process image");
          }
        }
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
                color:
                    isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
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
    // final currentLocation = _locationController.text.trim();
    final currentAbout = _aboutController.text.trim();

    final isRequiredFieldsFilled = currentFullname.isNotEmpty &&
        currentEmail.isNotEmpty &&
        currentPhone.isNotEmpty;

    // Проверяем изменился ли код страны
    final isCountryChanged = _selectedCountry?.id != _initialCountry?.id;

    final isAnythingChanged = currentFullname != _initialFullname ||
        currentEmail != _initialEmail ||
        currentPhone != _initialPhone ||
        // currentLocation != _initialLocation ||
        currentAbout != _initialAbout ||
        isCountryChanged;

    _isFormValid.value = isRequiredFieldsFilled && isAnythingChanged;
  }

  void _addEmployer() {
    final String name = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    // final String location = _locationController.text.trim();
    final String about = _aboutController.text.trim();

    bloc
        .profileEdit(
      name: name,
      email: email,
      phone: phone,
      location: /*location*/ "",
      about: about,
      callingCode: _selectedCountry?.callingCode,
    )
        .then(
      (onValue) {
        // Обновляем initial значение после сохранения
        _initialCountry = _selectedCountry;
        bloc.customersMe();
        showIOSStyleMessage(context, S.of(context).nyh5jj53ge);
        _validateForm(); // Пересчитываем валидацию
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    // _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}
