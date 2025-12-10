import 'package:buking/data/network/response/type_option.dart';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/network/response/language.dart';
import '../../../../../../data/network/response/language_response.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../data/network/response/user.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
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

  int _selectedExperience = 3;
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
      text: professional?.maxWeightKg ?? '',
    );
    _insuranceController = TextEditingController(
      text: professional?.insuranceAmount ?? '',
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

    _selectedExperience =
        int.tryParse(professional?.workExperienceYears ?? '') ?? 3;

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

      setState(() {
        _allLanguages = List<Language>.from(languages.data);
        _isLoadingLanguages = false;
      });

      _validateForm();
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingLanguages = false;
        _allLanguages = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки языков: $e'),
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

      setState(() {
        _allPackageTypes = List<PackageType>.from(packageTypes.data);
        _isLoadingPackageTypes = false;
      });

      _validateForm();
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingPackageTypes = false;
        _allPackageTypes = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки типов упаковки: $e'),
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
        throw Exception('Неверный формат времени: $timeString');
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
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
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
        throw Exception('Неверный формат времени: $timeString');
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
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _saveChanges() {
    if (_selectedLanguageCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один язык'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPackageTypeCodes.isEmpty && _allPackageTypes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы одну специализацию'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final courierProfile = bloc.createProfessionalRequest(
      workExperienceYears: _selectedExperience,
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
      if (mounted) {
        showIOSStyleMessage(context, 'Данные об опыте сохранены');
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Опыт работы'),
                    ),
                    const SizedBox(height: 8),
                    _buildExperienceSlider(isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Максимальный вес (кг)'),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(_maxWeightController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Страхование (\$)'),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(_insuranceController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Диапазон цен (\$/кг)'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        child: const Text('От'),
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
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('До'),
                    ),
                    const SizedBox(height: 4),
                    _buildInputField(_priceToController, isDark),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Рабочие часы'),
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
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                child: const Text('С'),
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
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                child: const Text('До'),
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Языки общения'),
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Специализация'),
                    ),
                    const SizedBox(height: 8),
                    _allPackageTypes.isEmpty && !_isLoadingPackageTypes
                        ? AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF4A4A4A)
                              : const Color(0xFFE5E5EA),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF5F5F5),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        child: const Text('Типы упаковки недоступны на сервере'),
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

  Widget _buildInputField(TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
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
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
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
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              child: Text(value),
            ),
            Icon(
              Icons.access_time,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93),
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
        Slider(
          value: _selectedExperience.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_selectedExperience лет',
          activeColor: const Color(0xFF5B4FFF),
          inactiveColor: isDark
              ? const Color(0xFF4A4A4A)
              : const Color(0xFFE5E5EA),
          onChanged: (value) {
            setState(() {
              _selectedExperience = value.toInt();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Выбранный опыт:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B4FFF),
            ),
          ).toString().contains('_selectedExperience')
              ? Text(
            'Выбранный опыт: $_selectedExperience лет',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B4FFF),
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
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
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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
  final themeManager = Provider.of<ThemeManager>(context);

  final isDark = themeManager.isDarkMode;

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.1),
    builder: (BuildContext context) {
      Future.delayed(duration, () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
