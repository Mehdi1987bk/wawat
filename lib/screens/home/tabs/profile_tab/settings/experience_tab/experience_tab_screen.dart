import 'package:buking/data/network/response/type_option.dart';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../../data/network/response/language.dart';
import '../../../../../../data/network/response/language_response.dart';
import '../../../../../../data/network/response/package_types_response.dart';
import '../../../../../../data/network/response/user.dart';
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

class _ExperienceTabState extends BaseState<ExperienceTab, ExperienceTabBloc> {
  late TextEditingController _maxWeightController;
  late TextEditingController _insuranceController;
  late TextEditingController _priceFromController;
  late TextEditingController _priceToController;

  int _selectedExperience = 3;
  String _selectedWorkTimeFrom = '09:00';
  String _selectedWorkTimeTo = '18:00';
  Set<int> _selectedLanguageIds = {};
  Set<int> _selectedPackageTypeIds = {};

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
      _selectedLanguageIds = professional.languages.map((l) {
        try {
          return (l.id as int?) ?? 0;
        } catch (e) {
          print('ERROR parsing language id: $e');
          return 0;
        }
      }).where((id) => id != 0).toSet();
      print('DEBUG initState: Инициализировано языков из professional: $_selectedLanguageIds');
    }

    // ✅ Исправленная инициализация типов упаковки
    if (professional != null && professional.packageTypes.isNotEmpty) {
      _selectedPackageTypeIds = professional.packageTypes
          .map((p) {
        try {
          return (p.id as int?) ?? 0;
        } catch (e) {
          print('ERROR parsing package type id: $e');
          return 0;
        }
      })
          .where((id) => id != 0)
          .toSet();
      print('DEBUG initState: Инициализировано типов упаковки: $_selectedPackageTypeIds');
    }

    // ВАЖНО: Загружаем данные сразу после инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLanguagesAndPackageTypes();
    });
  }

  Future<void> _loadLanguagesAndPackageTypes() async {
    // ✅ Не загружаем повторно, если уже загружены
    if (!_isLoadingLanguages && !_isLoadingPackageTypes &&
        _allLanguages.isNotEmpty && _allPackageTypes.isNotEmpty) {
      print('DEBUG: Данные уже загружены, пропускаем повторную загрузку');
      return;
    }

    print('========== DEBUG: Начало загрузки языков и типов ==========');

    setState(() {
      _isLoadingLanguages = true;
      _isLoadingPackageTypes = true;
    });

    // ✅ Загружаем языки независимо
    _loadLanguages();

    // ✅ Загружаем типы независимо
    _loadPackageTypes();
  }

  /// Загрузить языки
  Future<void> _loadLanguages() async {
    try {
      print('========== DEBUG: Начало загрузки языков ==========');

      final languages = await bloc.getLanguages();

      print('API Response languages type: ${languages.runtimeType}');
      print('API Response languages.data type: ${languages.data.runtimeType}');
      print('API Response languages.data length: ${languages.data.length}');

      if (languages.data.isNotEmpty) {
        print('First language: ${languages.data[0].name} (id: ${languages.data[0].id})');
        for (var lang in languages.data) {
          print('  ✓ ${lang.id}: ${lang.code} - ${lang.name}');
        }
      }

      setState(() {
        _allLanguages = List<Language>.from(languages.data);
        _isLoadingLanguages = false;
      });

      print('After setState:');
      print('  _allLanguages.length: ${_allLanguages.length}');
      print('========== DEBUG: Загрузка языков завершена ==========');

    } catch (e, stackTrace) {
      print('========== ERROR: Ошибка загрузки языков ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');

      setState(() {
        _isLoadingLanguages = false;
        _allLanguages = []; // ✅ Устанавливаем пустой список при ошибке
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

      print('API Response packageTypes length: ${packageTypes.packageTypes.length}');
      if (packageTypes.packageTypes.isNotEmpty) {
        for (var pkg in packageTypes.packageTypes) {
          final translation = pkg.translations.isNotEmpty
              ? pkg.translations.first.title
              : pkg.key;
          print('  ✓ ${pkg.id}: $translation (icon: ${pkg.icon})');
        }
      }

      setState(() {
        _allPackageTypes = List<PackageType>.from(packageTypes.packageTypes);
        _isLoadingPackageTypes = false;
      });

      print('After setState:');
      print('  _allPackageTypes.length: ${_allPackageTypes.length}');
      print('========== DEBUG: Загрузка типов завершена ==========');

    } catch (e, stackTrace) {
      print('========== ERROR: Ошибка загрузки типов упаковки ==========');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('==========================================================');

      setState(() {
        _isLoadingPackageTypes = false;
        _allPackageTypes = []; // ✅ Устанавливаем пустой список при ошибке
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

  String _getLanguageNames() {
    print('_getLanguageNames called: selectedIds=$_selectedLanguageIds, allLanguages=${_allLanguages.length}');

    if (_selectedLanguageIds.isEmpty) {
      print('  -> Нет выбранных языков, возвращаю "Выбор"');
      return 'Выбор';
    }

    final selectedNames = <String>[];
    for (var id in _selectedLanguageIds) {
      final lang = _allLanguages.firstWhere(
            (l) => l.id == id,
        orElse: () => Language(id: 0, code: '', name: 'Unknown'),
      );
      if (lang.id != 0) {
        selectedNames.add(lang.name ?? '');
        print('  -> Добавлен язык: ${lang.name} (id: ${lang.id})');
      }
    }

    final result = selectedNames.join(', ');
    print('  -> Результат: $result');
    return result.isNotEmpty ? result : 'Выбор';
  }

  String _getPackageTypeNames() {
    if (_selectedPackageTypeIds.isEmpty) return 'Выбор';

    final selectedNames = <String>[];
    for (var id in _selectedPackageTypeIds) {
      final pkg = _allPackageTypes.firstWhere(
            (p) => p.id == id,
        orElse: () => PackageType(
          id: 0,
          key: '',
          icon: '',
          isActive: false,
          translations: [],
        ),
      );
      if (pkg.id != 0) {
        final translation = pkg.translations.isNotEmpty
            ? pkg.translations.first.title
            : pkg.key;
        selectedNames.add(translation);
      }
    }

    return selectedNames.isNotEmpty ? selectedNames.join(', ') : 'Выбор';
  }

  void _showLanguagesBottomSheet() {
    print('========== _showLanguagesBottomSheet ==========');
    print('_allLanguages.length: ${_allLanguages.length}');
    print('_isLoadingLanguages: $_isLoadingLanguages');
    print('_selectedLanguageIds: $_selectedLanguageIds');

    // ✅ Если данные загружаются, показываем сообщение
    if (_allLanguages.isEmpty && _isLoadingLanguages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Языки загружаются. Попробуйте позже.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Если данные не загружены и не загружаются - загружаем их
    if (_allLanguages.isEmpty) {
      print('DEBUG: Языки не загружены, начинаем загрузку...');
      _loadLanguagesAndPackageTypes().then((_) {
        print('DEBUG: Загрузка завершена, открываем BottomSheet');
        _showLanguagesBottomSheetContent();
      }).catchError((error) {
        print('DEBUG: Ошибка при загрузке: $error');
      });
      return;
    }

    _showLanguagesBottomSheetContent();
  }

  void _showLanguagesBottomSheetContent() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Выберите языки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _allLanguages.isEmpty
                    ? const Center(
                  child: Text('Языки не найдены'),
                )
                    : ListView.builder(
                  itemCount: _allLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _allLanguages[index];
                    final isSelected = _selectedLanguageIds.contains(language.id);

                    print('ListTile $index: ${language.name} (id=${language.id}, selected=$isSelected)');

                    return ListTile(
                      title: Text(
                        language.name ?? 'Неизвестный язык',
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        'Код: ${language.code}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF5B4FFF),
                        size: 28,
                      )
                          : const Icon(
                        Icons.circle_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedLanguageIds.remove(language.id);
                            print('Удален язык: ${language.name} (id: ${language.id})');
                          } else {
                            _selectedLanguageIds.add(language.id);
                            print('Добавлен язык: ${language.name} (id: ${language.id})');
                          }
                        });
                        // ✅ Обновляем и BottomSheet
                        setStateBottomSheet(() {});
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    print('Bottom sheet закрыта, выбранные языки: $_selectedLanguageIds');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Применить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showPackageTypesBottomSheet() {
    print('========== _showPackageTypesBottomSheet ==========');
    print('_allPackageTypes.length: ${_allPackageTypes.length}');
    print('_isLoadingPackageTypes: $_isLoadingPackageTypes');

    // ✅ Если данные загружаются, показываем сообщение
    if (_allPackageTypes.isEmpty && _isLoadingPackageTypes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Типы упаковки загружаются. Попробуйте позже.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Если данные не загружены и не загружаются - загружаем их
    if (_allPackageTypes.isEmpty) {
      print('DEBUG: Типы упаковки не загружены, начинаем загрузку...');
      _loadPackageTypes().then((_) {
        print('DEBUG: Загрузка завершена, открываем BottomSheet');

        // ✅ Если всё ещё пусто, показываем сообщение об ошибке
        if (_allPackageTypes.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Типы упаковки не доступны на сервере'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        _showPackageTypesBottomSheetContent();
      }).catchError((error) {
        print('DEBUG: Ошибка при загрузке: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка загрузки: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
      return;
    }

    _showPackageTypesBottomSheetContent();
  }

  void _showPackageTypesBottomSheetContent() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Выберите специализацию',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _allPackageTypes.isEmpty
                    ? const Center(
                  child: Text('Типы упаковки не найдены'),
                )
                    : ListView.builder(
                  itemCount: _allPackageTypes.length,
                  itemBuilder: (context, index) {
                    final packageType = _allPackageTypes[index];
                    final isSelected =
                    _selectedPackageTypeIds.contains(packageType.id);
                    final translation = packageType.translations.isNotEmpty
                        ? packageType.translations.first.title
                        : packageType.key;

                    print('PackageType $index: $translation (id=${packageType.id}, selected=$isSelected)');

                    return ListTile(
                      leading: Text(
                        packageType.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(translation),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF5B4FFF),
                        size: 28,
                      )
                          : const Icon(
                        Icons.circle_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedPackageTypeIds.remove(packageType.id);
                            print('Удален тип: $translation (id: ${packageType.id})');
                          } else {
                            _selectedPackageTypeIds.add(packageType.id);
                            print('Добавлен тип: $translation (id: ${packageType.id})');
                          }
                        });
                        // ✅ Обновляем и BottomSheet
                        setStateBottomSheet(() {});
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    print('Bottom sheet закрыта, выбранные типы: $_selectedPackageTypeIds');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Применить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showTimePickerFrom() async {
    try {
      final timeString = _selectedWorkTimeFrom.isNotEmpty
          ? _selectedWorkTimeFrom
          : '09:00';

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
      final timeString = _selectedWorkTimeTo.isNotEmpty
          ? _selectedWorkTimeTo
          : '18:00';

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
    if (_selectedLanguageIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один язык'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Типы упаковки теперь опциональны если их нет на сервере
    if (_selectedPackageTypeIds.isEmpty && _allPackageTypes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы одну специализацию'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('DEBUG _saveChanges:');
    print('  Languages: $_selectedLanguageIds');
    print('  Package Types: $_selectedPackageTypeIds');

    final courierProfile = bloc.createProfessionalRequest(
      workExperienceYears: _selectedExperience,
      maxWeightKg: int.tryParse(_maxWeightController.text) ?? 0,
      insuranceAmount: int.tryParse(_insuranceController.text) ?? 0,
      pricePerKgMin: double.tryParse(_priceFromController.text) ?? 0,
      pricePerKgMax: double.tryParse(_priceToController.text) ?? 0,
      workTimeFrom: _selectedWorkTimeFrom,
      workTimeTo: _selectedWorkTimeTo,
      communicationLanguageIds: _selectedLanguageIds.toList(),
      packageTypeIds: _selectedPackageTypeIds.toList(),
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
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

      _selectedLanguageIds.clear();
      if (professional != null && professional.languages.isNotEmpty) {
        _selectedLanguageIds = professional.languages.map((l) {
          try {
            return (l.id as int?) ?? 0;
          } catch (e) {
            print('ERROR parsing language id in reset: $e');
            return 0;
          }
        }).where((id) => id != 0).toSet();
      }

      _selectedPackageTypeIds.clear();
      if (professional != null && professional.packageTypes.isNotEmpty) {
        _selectedPackageTypeIds = professional.packageTypes
            .map((p) {
          try {
            return (p.id as int?) ?? 0;
          } catch (e) {
            print('ERROR parsing package type id in reset: $e');
            return 0;
          }
        })
            .where((id) => id != 0)
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
              _buildMultiSelectDropdown(
                _getLanguageNames(),
                _showLanguagesBottomSheet,
                _isLoadingLanguages,
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
                  : _buildMultiSelectDropdown(
                _getPackageTypeNames(),
                _showPackageTypesBottomSheet,
                _isLoadingPackageTypes,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Color(0xFF5B4FFF),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Отмена',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B4FFF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Сохранить изменения',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildMultiSelectDropdown(
      String value,
      VoidCallback onTap,
      bool isLoading,
      ) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
            Expanded(
              child: Text(
                isLoading ? 'Загрузка...' : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
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