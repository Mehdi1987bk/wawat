import 'dart:async';

import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/network/response/language.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../data/network/response/user.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
import '../../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/localization_service.dart';
import '../../../../../../services/theme_aware_screen.dart';
import '../../../../../../services/theme_manager.dart';
import '../../../../../auth/registration/widget/language_selector.dart';
import '../../../../../auth/registration/widget/package_types_selector.dart';
import 'experience_tab_bloc.dart';

class ExperienceTab extends BaseScreen {
  final User user;

  ExperienceTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ExperienceTab> createState() => _ExperienceTabState();
}

class _ExperienceTabState extends BaseState<ExperienceTab, ExperienceTabBloc>
    with ErrorDispatcher {
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  late TextEditingController _maxWeightController;
  late TextEditingController _insuranceController;
  late TextEditingController _priceFromController;
  late TextEditingController _priceToController;

  double _selectedExperience = 0.5; // Изменено с int на double
  String _selectedWorkTimeFrom = '00:00';
  String _selectedWorkTimeTo = '00:00';
  Set<String> _selectedLanguageCodes = {};
  Set<String> _selectedPackageTypeCodes = {};

  List<Language> _allLanguages = [];
  List<PackageType> _allPackageTypes = [];
  bool _isLoadingLanguages = true;
  bool _isLoadingPackageTypes = true;

  @override
  void initState() {
    super.initState();

    final professional = widget.user.professional;

    _maxWeightController = TextEditingController(
      text: professional?.maxWeightKg?.toString() ?? '',
    );
    _insuranceController = TextEditingController(
      text: professional?.insuranceAmount?.toString() ?? '',
    );
    _priceFromController = TextEditingController(
      text: professional?.pricePerKgMin ?? '',
    );
    _priceToController = TextEditingController(
      text: professional?.pricePerKgMax ?? '',
    );

    _maxWeightController.addListener(_validateForm);
    _insuranceController.addListener(_validateForm);
    _priceFromController.addListener(_validateForm);
    _priceToController.addListener(_validateForm);

    // Инициализация опыта с поддержкой половинных значений
    if (professional?.workExperienceYears != null) {
      _selectedExperience =
          double.tryParse(professional!.workExperienceYears ?? "")!;
      if (_selectedExperience < 0.5) _selectedExperience = 0.5;
      if (_selectedExperience > 15) _selectedExperience = 15;
    } else {
      _selectedExperience = 0.5;
    }

    if (professional?.workTimeFrom != null &&
        professional!.workTimeFrom!.isNotEmpty) {
      final parts = professional.workTimeFrom!.split(':');
      _selectedWorkTimeFrom =
          parts.length >= 2 ? '${parts[0]}:${parts[1]}' : '00:00';
    }

    if (professional?.workTimeTo != null &&
        professional!.workTimeTo!.isNotEmpty) {
      final parts = professional.workTimeTo!.split(':');
      _selectedWorkTimeTo =
          parts.length >= 2 ? '${parts[0]}:${parts[1]}' : '00:00';
    }

    if (professional != null && professional.languages.isNotEmpty) {
      _selectedLanguageCodes = professional.languages
          .map((l) => l.code ?? '')
          .where((code) => code.isNotEmpty)
          .toSet();
    }

    if (professional != null && professional.packageTypes.isNotEmpty) {
      _selectedPackageTypeCodes = professional.packageTypes
          .map((p) => p.code ?? '')
          .where((code) => code.isNotEmpty)
          .toSet();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLanguagesAndPackageTypes();
      _validateForm();
    });
  }

  void _validateForm() {
    final isMaxWeightFilled = _maxWeightController.text.trim().isNotEmpty;
    final isInsuranceFilled = _insuranceController.text.trim().isNotEmpty;
    final isPriceFromFilled = _priceFromController.text.trim().isNotEmpty;
    final isPriceToFilled = _priceToController.text.trim().isNotEmpty;
    final hasLanguages = _selectedLanguageCodes.isNotEmpty;
    final hasPackageTypes =
        _selectedPackageTypeCodes.isNotEmpty || _allPackageTypes.isEmpty;

    _isFormValid.value = isMaxWeightFilled &&
        isInsuranceFilled &&
        isPriceFromFilled &&
        isPriceToFilled &&
        hasLanguages &&
        hasPackageTypes;
  }

  Future<void> _loadLanguagesAndPackageTypes() async {
    if (!_isLoadingLanguages &&
        !_isLoadingPackageTypes &&
        _allLanguages.isNotEmpty &&
        _allPackageTypes.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingLanguages = true;
      _isLoadingPackageTypes = true;
    });

    _loadLanguages();
    _loadPackageTypes();
  }

  Future<void> _loadLanguages() async {
    try {
      final languages = await bloc.getLanguages();

      if (mounted) {
        setState(() {
          _allLanguages = List<Language>.from(languages.data);
          _isLoadingLanguages = false;
        });

        _validateForm();
      }
    } catch (e, stackTrace) {
      // 🔥 Проверяем mounted перед setState
      if (mounted) {
        setState(() {
          _isLoadingLanguages = false;
          _allLanguages = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('picker.language_load_error') + '$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadPackageTypes() async {
    try {
      final packageTypes = await bloc.getPackageTypes();

      if (mounted) {
        setState(() {
          _allPackageTypes = List<PackageType>.from(packageTypes.data);
          _isLoadingPackageTypes = false;
        });

        _validateForm();
      }
    } catch (e, stackTrace) {
      // 🔥 Проверяем mounted перед setState
      if (mounted) {
        setState(() {
          _isLoadingPackageTypes = false;
          _allPackageTypes = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('picker.package_type_load_error') + ' $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showTimePickerFrom() async {
    try {
      final timeString =
          _selectedWorkTimeFrom.isNotEmpty ? _selectedWorkTimeFrom : '09:00';
      final timeParts = timeString.split(':');

      if (timeParts.length != 2) {
        throw Exception(t('courier.invalid_time_format') + ' $timeString');
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Container(
          height: 250,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: DateTime(2024, 1, 1, hour, minute),
              onDateTimeChanged: (DateTime newTime) {
                setState(() {
                  _selectedWorkTimeFrom =
                      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                });
              },
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(t('error.generic_with_detail') + ' $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showTimePickerTo() async {
    try {
      final timeString =
          _selectedWorkTimeTo.isNotEmpty ? _selectedWorkTimeTo : '18:00';
      final timeParts = timeString.split(':');

      if (timeParts.length != 2) {
        throw Exception(t('courier.invalid_time_format') + ' $timeString');
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Container(
          height: 250,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: DateTime(2024, 1, 1, hour, minute),
              onDateTimeChanged: (DateTime newTime) {
                setState(() {
                  _selectedWorkTimeTo =
                      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                });
              },
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(t('error.generic_with_detail') + ' $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _saveChanges() {
    // 🔥 Закрываем клавиатуру ПЕРЕД любыми операциями
    FocusScope.of(context).unfocus();

    if (_selectedLanguageCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('courier.language_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPackageTypeCodes.isEmpty && _allPackageTypes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('courier.specialization_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final courierProfile = bloc.createProfessionalRequest(
      workExperienceYears: _selectedExperience.toInt(),
      maxWeightKg: int.tryParse(_maxWeightController.text) ?? 0,
      insuranceAmount: int.tryParse(_insuranceController.text) ?? 0,
      pricePerKgMin: double.tryParse(_priceFromController.text) ?? 0,
      pricePerKgMax: double.tryParse(_priceToController.text) ?? 0,
      workTimeFrom: _selectedWorkTimeFrom,
      workTimeTo: _selectedWorkTimeTo,
      communicationLanguageIds: _selectedLanguageCodes.toList(),
      packageTypeIds: _selectedPackageTypeCodes.toList(),
    );

    bloc.createProfessional(courierProfile).then((_) {
      // 🔥 Проверяем что виджет еще существует
      if (!mounted) return;

      showIOSStyleMessage(context, t('courier.experience_saved'));
      bloc.customersMe();
    }).catchError((error) {
      // 🔥 Обрабатываем ошибки
      if (mounted) {
        showIOSStyleMessage(
          context,
          tr('error.generic_with_detail', 'Error: {detail}',
              {'detail': '$error'}),
          isSuccess: false,
        );
      }
    });
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
                  color: cCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: cCardBorder(isDark),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.work_experience')),
                    ),
                    const SizedBox(height: 8),
                    _buildExperienceSlider(isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.max_weight_kg')),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(_maxWeightController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.insurance') + "\$)"),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(_insuranceController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.price_range')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? WawatDark.textPrimary : Colors.black,
                        ),
                        child: Text(t('common.range_from')),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(_priceFromController, isDark),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('common.range_to')),
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(_priceToController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.work_hours')),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? WawatDark.textPrimary
                                      : Colors.black,
                                ),
                                child: Text(t('common.range_from')),
                              ),
                              const SizedBox(height: 4),
                              _buildTimePickerField(
                                _selectedWorkTimeFrom.isNotEmpty
                                    ? _selectedWorkTimeFrom
                                    : '09:00',
                                _showTimePickerFrom,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? WawatDark.textPrimary
                                      : Colors.black,
                                ),
                                child: Text(t('common.range_to')),
                              ),
                              const SizedBox(height: 4),
                              _buildTimePickerField(
                                _selectedWorkTimeTo.isNotEmpty
                                    ? _selectedWorkTimeTo
                                    : '18:00',
                                _showTimePickerTo,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.spoken_languages')),
                    ),
                    const SizedBox(height: 8),
                    LanguageSelector(
                      languages: _allLanguages,
                      selectedLanguageCodes: _selectedLanguageCodes,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedLanguageCodes = newSelection;
                        });
                        _validateForm();
                      },
                      isLoading: _isLoadingLanguages,
                    ),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(t('courier.specialization')),
                    ),
                    const SizedBox(height: 8),
                    _allPackageTypes.isEmpty && !_isLoadingPackageTypes
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? WawatDark.border
                                    : const Color(0xFFE5E5EA),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? WawatDark.surfaceAlt
                                  : const Color(0xFFF5F5F5),
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? WawatDark.textSecondary
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              child: Text(t('picker.package_type_unavailable')),
                            ),
                          )
                        : PackageTypesSelector(
                            packageTypes: _allPackageTypes,
                            selectedPackageTypeCodes: _selectedPackageTypeCodes,
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _selectedPackageTypeCodes = newSelection;
                              });
                              _validateForm();
                            },
                            isLoading: _isLoadingPackageTypes,
                          ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
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
                            onPressed: isValid ? _saveChanges : null,
                            child: Text(
                              t('common.save_changes'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
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

  Widget _buildInputField(TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: 14,
        color: isDark ? WawatDark.textPrimary : Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? WawatDark.surfaceAlt : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? WawatDark.border : const Color(0xFFE5E5EA),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? WawatDark.border : const Color(0xFFE5E5EA),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? WawatDark.focusRing : const Color(0xFF5B4FFF),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    String value,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surfaceAlt : Colors.white,
          border: Border.all(
            color: isDark ? WawatDark.border : const Color(0xFFE5E5EA),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? WawatDark.textPrimary : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              child: Text(value),
            ),
            Icon(
              Icons.access_time,
              color: isDark ? WawatDark.iconMuted : const Color(0xFF8E8E93),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSlider(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-12, 0),
          child: Transform.scale(
            scaleX: 1.05,
            alignment: Alignment.centerLeft,
            child: Slider(
              value: _selectedExperience,
              min: 1,
              max: 10,
              divisions: 9,
              label:
                  '${_selectedExperience.toInt()} ${_getYearLabel(_selectedExperience.toInt())}',
              activeColor: const Color(0xFF5B4FFF),
              inactiveColor:
                  isDark ? WawatDark.border : const Color(0xFFE5E5EA),
              onChanged: (value) {
                setState(() {
                  _selectedExperience =
                      value.roundToDouble(); // Округляем до целого
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            t('courier.selected_experience') +
                ' ${_selectedExperience.toInt()} ${_getYearLabel(_selectedExperience.toInt())}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B4FFF),
            ),
          ),
        ),
      ],
    );
  }

  String _getYearLabel(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return t('common.year_short');
    } else if ([2, 3, 4].contains(years % 10) &&
        ![12, 13, 14].contains(years % 100)) {
      return t('common.year_short');
    } else {
      return t('common.year_short');
    }
  }

  @override
  ExperienceTabBloc provideBloc() {
    return ExperienceTabBloc();
  }

  @override
  void dispose() {
    _maxWeightController.removeListener(_validateForm);
    _insuranceController.removeListener(_validateForm);
    _priceFromController.removeListener(_validateForm);
    _priceToController.removeListener(_validateForm);

    _maxWeightController.dispose();
    _insuranceController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _isFormValid.dispose();

    super.dispose();
  }
}

void showIOSStyleAlert(BuildContext context, String message,
    {bool isError = true}) {
  final themeManager = Provider.of<ThemeManager>(context, listen: false);
  final isDark = themeManager.isDarkMode;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surface : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? WawatDark.textPrimary : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  t('common.ok'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: isError ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showIOSStyleMessage(
  BuildContext context,
  String message, {
  bool isSuccess = true,
  Duration duration = const Duration(seconds: 2),
}) {
  final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

  // barrierDismissible + tap-to-close are a hard safety net: even if the
  // auto-dismiss timer somehow never fires, a tap always removes the barrier so
  // the toast can NEVER trap the user on an unresponsive screen.
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.1),
    builder: (_) => _IOSStyleMessage(
      message: message,
      isDark: isDark,
      duration: duration,
    ),
  );
}

/// Self-dismissing toast. The auto-close timer lives in its own [State] so it is
/// created exactly once (not re-armed on every dialog rebuild) and pops via the
/// dialog's OWN context — which stays valid while the dialog is up and whose
/// [State] is disposed (cancelling the timer) the moment the dialog closes, so a
/// stray pop can never swallow the screen underneath. This replaces the old
/// builder-scheduled `Future.delayed` guarded by `context.mounted`, which left
/// the barrier up forever when the caller rebuilt the tree right after showing
/// it (e.g. verification refreshing its status on success).
class _IOSStyleMessage extends StatefulWidget {
  const _IOSStyleMessage({
    required this.message,
    required this.isDark,
    required this.duration,
  });

  final String message;
  final bool isDark;
  final Duration duration;

  @override
  State<_IOSStyleMessage> createState() => _IOSStyleMessageState();
}

class _IOSStyleMessageState extends State<_IOSStyleMessage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: widget.isDark ? WawatDark.surface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.isDark ? WawatDark.textPrimary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
