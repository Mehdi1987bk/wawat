import 'package:buking/data/network/response/type_option.dart';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../../data/network/response/language.dart';
import '../../../../../../data/network/response/language_response.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../data/network/response/user.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
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

class _ExperienceTabState extends BaseState<ExperienceTab, ExperienceTabBloc> with ErrorDispatcher{
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  late TextEditingController _maxWeightController;
  late TextEditingController _insuranceController;
  late TextEditingController _priceFromController;
  late TextEditingController _priceToController;

  int _selectedExperience = 3;
  String _selectedWorkTimeFrom = '09:00';
  String _selectedWorkTimeTo = '18:00';
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
      text: professional?.maxWeightKg?.toStringAsFixed(0) ?? '',
    );
    _insuranceController = TextEditingController(
      text: professional?.insuranceAmount?.toStringAsFixed(0) ?? '',
    );
    _priceFromController = TextEditingController(
      text: professional?.pricePerKgMin?.toStringAsFixed(2) ?? '',
    );
    _priceToController = TextEditingController(
      text: professional?.pricePerKgMax?.toStringAsFixed(2) ?? '',
    );

    _selectedExperience = professional?.workExperienceYears ?? 3;

    _selectedWorkTimeFrom = (professional?.workTimeFrom?.isNotEmpty ?? false)
        ? professional!.workTimeFrom!
        : '09:00';
    _selectedWorkTimeTo = (professional?.workTimeTo?.isNotEmpty ?? false)
        ? professional!.workTimeTo!
        : '18:00';

    // ✅ Исправленная инициализация языков
    if (professional != null && professional.languages.isNotEmpty) {
      _selectedLanguageCodes = professional.languages
          .map((l) {
        try {
          return (l.code as String?) ?? '';
        } catch (e) {
          print('ERROR parsing language code: $e');
          return '';
        }
      })
          .where((code) => code.isNotEmpty)
          .toSet();
      print(
          'DEBUG initState: Инициализировано языков из professional: $_selectedLanguageCodes');
    }

    // ✅ Исправленная инициализация типов упаковки - используем code
    if (professional != null && professional.packageTypes.isNotEmpty) {
      _selectedPackageTypeCodes = professional.packageTypes
          .map((p) {
        try {
          return (p.code as String?) ?? '';
        } catch (e) {
          print('ERROR parsing package type code: $e');
          return '';
        }
      })
          .where((code) => code.isNotEmpty)
          .toSet();
      print(
          'DEBUG initState: Инициализировано типов упаковки: $_selectedPackageTypeCodes');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLanguagesAndPackageTypes();
    });
  }

  Future<void> _loadLanguagesAndPackageTypes() async {
    if (!_isLoadingLanguages &&
        !_isLoadingPackageTypes &&
        _allLanguages.isNotEmpty &&
        _allPackageTypes.isNotEmpty) {
      print('DEBUG: Данные уже загружены, пропускаем повторную загрузку');
      return;
    }

    print('========== DEBUG: Начало загрузки языков и типов ==========');

    setState(() {
      _isLoadingLanguages = true;
      _isLoadingPackageTypes = true;
    });

    _loadLanguages();
    _loadPackageTypes();
  }

  /// Загрузить языки
  Future<void> _loadLanguages() async {
    try {
      print('========== DEBUG: Начало загрузки языков ==========');

      final languages = await bloc.getLanguages();

      print('API Response languages type: ${languages.runtimeType}');
      print('API Response languages.data length: ${languages.data.length}');

      if (languages.data.isNotEmpty) {
        print(
            'First language: ${languages.data[0].name} (code: ${languages.data[0].code})');
        for (var lang in languages.data) {
          print('  ✓ ${lang.code}: ${lang.name}');
        }
      }

      setState(() {
        _allLanguages = List<Language>.from(languages.data);
        _isLoadingLanguages = false;
      });

      print('After setState: _allLanguages.length: ${_allLanguages.length}');
      print('========== DEBUG: Загрузка языков завершена ==========');
    } catch (e, stackTrace) {
      print('========== ERROR: Ошибка загрузки языков ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');

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

  /// Загрузить типы упаковки
  Future<void> _loadPackageTypes() async {
    try {
      print('========== DEBUG: Начало загрузки типов упаковки ==========');

      final packageTypes = await bloc.getPackageTypes();

      print('API Response packageTypes length: ${packageTypes.data.length}');
      if (packageTypes.data.isNotEmpty) {
        for (var pkg in packageTypes.data) {
          print('  ✓ ${pkg.code}: ${pkg.name} (icon: ${pkg.icon})');
        }
      }

      setState(() {
        _allPackageTypes = List<PackageType>.from(packageTypes.data);
        _isLoadingPackageTypes = false;
      });

      print('After setState: _allPackageTypes.length: ${_allPackageTypes.length}');
      print('========== DEBUG: Загрузка типов завершена ==========');
    } catch (e, stackTrace) {
      print('========== ERROR: Ошибка загрузки типов упаковки ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');

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
      print('ERROR in _showTimePickerFrom: $e');
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
      print('ERROR in _showTimePickerTo: $e');
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

    print('DEBUG _saveChanges:');
    print('  Languages: $_selectedLanguageCodes');
    print('  Package Types: $_selectedPackageTypeCodes');

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные об опыте сохранены'),
            backgroundColor: Color(0xFF5B4FFF),
          ),
        );
      }
    }).then((value) {
      bloc.customersMe();
      showTopSnackbar("Сохранено", "Сохранено", true, context);
    });
  }

  void _resetForm() {
    final professional = widget.user.professional;

    setState(() {
      _selectedExperience = professional?.workExperienceYears ?? 3;
      _maxWeightController.text =
          professional?.maxWeightKg?.toStringAsFixed(0) ?? '15';
      _insuranceController.text =
          professional?.insuranceAmount?.toStringAsFixed(0) ?? '5000';
      _priceFromController.text =
          professional?.pricePerKgMin?.toStringAsFixed(2) ?? '1.50';
      _priceToController.text =
          professional?.pricePerKgMax?.toStringAsFixed(2) ?? '3.00';
      _selectedWorkTimeFrom = (professional?.workTimeFrom?.isNotEmpty ?? false)
          ? professional!.workTimeFrom!
          : '09:00';
      _selectedWorkTimeTo = (professional?.workTimeTo?.isNotEmpty ?? false)
          ? professional!.workTimeTo!
          : '18:00';

      _selectedLanguageCodes.clear();
      if (professional != null && professional.languages.isNotEmpty) {
        _selectedLanguageCodes = professional.languages
            .map((l) {
          try {
            return (l.code as String?) ?? '';
          } catch (e) {
            print('ERROR parsing language code in reset: $e');
            return '';
          }
        })
            .where((code) => code.isNotEmpty)
            .toSet();
      }

      _selectedPackageTypeCodes.clear();
      if (professional != null && professional.packageTypes.isNotEmpty) {
        _selectedPackageTypeCodes = professional.packageTypes
            .map((p) {
          try {
            return (p.code as String?) ?? '';
          } catch (e) {
            print('ERROR parsing package type code in reset: $e');
            return '';
          }
        })
            .where((code) => code.isNotEmpty)
            .toSet();
      }
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Опыт работы',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildExperienceSlider(),
              const SizedBox(height: 16),
              const Text(
                'Максимальный вес (кг)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(_maxWeightController),
              const SizedBox(height: 16),
              const Text(
                'Страхование (\$)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(_insuranceController),
              const SizedBox(height: 16),
              const Text(
                'Диапазон цен (\$/кг)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'От',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildInputField(_priceFromController),
              const SizedBox(height: 12),
              const Text(
                'До',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              _buildInputField(_priceToController),
              const SizedBox(height: 16),
              const Text(
                'Рабочие часы',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'С',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTimePickerField(
                          _selectedWorkTimeFrom.isNotEmpty
                              ? _selectedWorkTimeFrom
                              : '09:00',
                          _showTimePickerFrom,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'До',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTimePickerField(
                          _selectedWorkTimeTo.isNotEmpty
                              ? _selectedWorkTimeTo
                              : '18:00',
                          _showTimePickerTo,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Языки общения',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              LanguageSelector(
                languages: _allLanguages,
                selectedLanguageCodes: _selectedLanguageCodes,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedLanguageCodes = newSelection;
                  });
                },
                isLoading: _isLoadingLanguages,
              ),
              const SizedBox(height: 16),
              const Text(
                'Специализация',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _allPackageTypes.isEmpty && !_isLoadingPackageTypes
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE5E5EA),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5F5),
                ),
                child: const Text(
                  'Типы упаковки недоступны на сервере',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : PackageTypesSelector(
                packageTypes: _allPackageTypes,
                selectedPackageTypeCodes: _selectedPackageTypeCodes,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPackageTypeCodes = newSelection;
                  });
                },
                isLoading: _isLoadingPackageTypes,
              ),
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.only(
                  top: 20,
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
                      onPressed: isValid ? _saveChanges : null,
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

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTimePickerField(
      String value,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE5E5EA),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.access_time,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSlider() {
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
          inactiveColor: const Color(0xFFE5E5EA),
          onChanged: (value) {
            setState(() {
              _selectedExperience = value.toInt();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Выбранный опыт: $_selectedExperience лет',
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

  @override
  ExperienceTabBloc provideBloc() {
    return ExperienceTabBloc();
  }

  @override
  void dispose() {
    _maxWeightController.dispose();
    _insuranceController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    super.dispose();
  }
}