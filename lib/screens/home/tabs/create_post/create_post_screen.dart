import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';

import '../../../../data/network/response/language.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/type_option.dart';
import '../../../auth/registration/widget/language_selector.dart';
import '../../../auth/registration/widget/package_types_selector.dart';
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

  // ✅ Используем code вместо id для типов упаковки
  Set<String> _selectedLanguageCodes = {};
  Set<String> _selectedPackageTypeCodes = {};

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

      print('API Response packageTypes length: ${packageTypes.data.length}');

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
                        const Center(
                          child: Icon(
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

                  // ✅ Тип посылки - используем PackageTypesSelector
                  _buildLabel('Тип посылки'),
                  const SizedBox(height: 8),
                  PackageTypesSelector(
                    packageTypes: _allPackageTypes,
                    selectedPackageTypeCodes: _selectedPackageTypeCodes,
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedPackageTypeCodes = newSelection;
                      });
                    },
                    isLoading: _isLoadingPackageTypes,
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

                  // ✅ Языки общения - используем LanguageSelector
                  _buildLabel('Языки общения'),
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

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // ✅ Валидация
                          if (_selectedLanguageCodes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Выберите хотя бы один язык'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_selectedPackageTypeCodes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Выберите хотя бы один тип посылки'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          print('========== Публикация объявления ==========');
                          print('Языки (коды): $_selectedLanguageCodes');
                          print('Типы посылки (коды): $_selectedPackageTypeCodes');
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