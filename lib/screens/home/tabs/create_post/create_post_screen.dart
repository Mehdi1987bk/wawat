import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';

import '../../../../data/network/response/language.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../home_tab/home_tab_screen.dart';
import 'create_post_bloc.dart';

class CreatePostScreen extends BaseScreen {
  CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState
    extends BaseState<CreatePostScreen, CreatePostBloc> {
  String? selectedCategory;

  // ✅ Изменили на мультиселект
  Set<int> _selectedLanguageIds = {};
  Set<int> _selectedPackageTypeIds = {};

  List<Language> _allLanguages = [];
  List<PackageType> _allPackageTypes = [];
  bool _isLoadingLanguages = true;
  bool _isLoadingPackageTypes = true;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ Загружаем данные сразу после инициализации
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

      print('API Response languages length: ${languages.data.length}');

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

      print('API Response packageTypes length: ${packageTypes.packageTypes.length}');

      setState(() {
        _allPackageTypes = List<PackageType>.from(packageTypes.packageTypes);
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

  // ✅ Получить названия выбранных языков
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

  // ✅ Получить названия выбранных типов упаковки
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

  // ✅ Показать Bottom Sheet для выбора языков
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
                    final isSelected =
                    _selectedLanguageIds.contains(language.id);

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
                        color: Color(0xFF5B51FF),
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
                    backgroundColor: const Color(0xFF5B51FF),
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

  // ✅ Показать Bottom Sheet для выбора типов посылки
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
                      'Выберите типы посылки',
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
                        color: Color(0xFF5B51FF),
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
                    backgroundColor: const Color(0xFF5B51FF),
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

  @override
  Widget body() {
    return SafeArea(
      child: Column(
        children: [
          BuildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Icon
                  Container(
                    width: 81,
                    height: 81,
                    child: Stack(
                      children: [
                        Image.asset("asset/add_back.png"),
                        Center(
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    'Подать',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Создайте объявление для поиска курьера или\nклиента',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Тип предложения
                  _buildLabel('Тип предложения'),
                  const SizedBox(height: 8),
                  _buildDropdownField(
                    hint: 'Все категории',
                    value: selectedCategory,
                    icon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: ['Все категории', 'Курьер', 'Клиент'],
                  ),
                  const SizedBox(height: 20),

                  // Откуда
                  _buildLabel('Откуда'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: fromController,
                    hint: 'Город отправления',
                  ),
                  const SizedBox(height: 20),

                  // Куда
                  _buildLabel('Куда'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: toController,
                    hint: 'Город назначения',
                  ),
                  const SizedBox(height: 20),

                  // Дата вылета
                  _buildLabel('Дата вылета'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: dateController,
                    hint: 'дд.мм.гггг',
                    suffixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );
                      if (date != null) {
                        dateController.text =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Время вылета
                  _buildLabel('Время вылета'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: timeController,
                    hint: '',
                    suffixIcon: Icons.access_time,
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        timeController.text =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // ✅ Тип посылки - теперь мультиселект
                  _buildLabel('Тип посылки'),
                  const SizedBox(height: 8),
                  _buildMultiSelectDropdown(
                    _getPackageTypeNames(),
                    _showPackageTypesBottomSheet,
                    _isLoadingPackageTypes,
                  ),
                  const SizedBox(height: 20),

                  // Максимальный вес
                  _buildLabel('Максимальный вес (кг)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: maxWeightController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Цена за кг
                  _buildLabel('Цена за кг (\$)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: priceController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Описание
                  _buildLabel('Описание'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: descriptionController,
                    hint: 'Расскажите о своих услугах доставки...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Языки общения - теперь мультиселект
                  _buildLabel('Языки общения'),
                  const SizedBox(height: 8),
                  _buildMultiSelectDropdown(
                    _getLanguageNames(),
                    _showLanguagesBottomSheet,
                    _isLoadingLanguages,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // ✅ Валидация
                          if (_selectedLanguageIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Выберите хотя бы один язык'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_selectedPackageTypeIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Выберите хотя бы один тип посылки'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          print('========== Публикация объявления ==========');
                          print('Языки: $_selectedLanguageIds');
                          print('Типы посылки: $_selectedPackageTypeIds');
                          print('От: ${fromController.text}');
                          print('До: ${toController.text}');
                          print('Дата: ${dateController.text}');
                          print('Время: ${timeController.text}');
                          print('Вес: ${maxWeightController.text}');
                          print('Цена: ${priceController.text}');
                          print('Описание: ${descriptionController.text}');
                          print('===========================================');

                          // TODO: Отправить данные на сервер
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B51FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.file_upload_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Опубликовать объявление',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFFC7C7CC),
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
            suffixIcon,
            color: const Color(0xFFC7C7CC),
            size: 20,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF5B51FF),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required IconData icon,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF5B51FF),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF5B51FF),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        hint: Text(
          hint,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFFC7C7CC),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFFC7C7CC),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ✅ Новый виджет для мультиселекта
  Widget _buildMultiSelectDropdown(
      String value,
      VoidCallback onTap,
      bool isLoading,
      ) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isLoading ? 'Загрузка...' : value,
                style: TextStyle(
                  fontSize: 15,
                  color: isLoading ? const Color(0xFFC7C7CC) : Colors.black,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: const Color(0xFFC7C7CC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    dateController.dispose();
    timeController.dispose();
    maxWeightController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  CreatePostBloc provideBloc() {
    return CreatePostBloc();
  }
}