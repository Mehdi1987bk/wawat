import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/create_post/widget/city_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/network/request/courier_offer_model.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/language.dart';
import '../../../../data/network/response/offer_type_model.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/type_option.dart';
import '../../../../presentation/bloc/error_dispatcher.dart';
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
  String? selectedOfferType;

  Set<String> _selectedPackageTypeCodes = {};

  City? _selectedFromCity;
  City? _selectedToCity;
  List<City> _allCities = [];
  bool _isLoadingCities = true;

  List<OfferTypeModel> _allOfferTypes = [];
  bool _isLoadingOfferTypes = true;

  List<PackageType> _allPackageTypes = [];
  bool _isLoadingPackageTypes = true;

  bool _isSubmitting = false;

  final ScrollController _scrollController = ScrollController();

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final TextEditingController flightDateController = TextEditingController();
  final TextEditingController flightTimeController = TextEditingController();
  final TextEditingController deliveryDateFromController =
  TextEditingController();
  final TextEditingController deliveryDateToController =
  TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchaseTimeController = TextEditingController();

  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fromController.addListener(_updateButtonState);
    toController.addListener(_updateButtonState);
    flightDateController.addListener(_updateButtonState);
    flightTimeController.addListener(_updateButtonState);
    deliveryDateFromController.addListener(_updateButtonState);
    deliveryDateToController.addListener(_updateButtonState);
    purchaseDateController.addListener(_updateButtonState);
    purchaseTimeController.addListener(_updateButtonState);
    maxWeightController.addListener(_updateButtonState);
    priceController.addListener(_updateButtonState);
    descriptionController.addListener(_updateButtonState);

    // ✅ ДОБАВЛЕНО: Загрузка данных
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormValid {
    final baseValid = selectedOfferType != null &&
        selectedOfferType!.isNotEmpty &&
        _selectedPackageTypeCodes.isNotEmpty &&
        _selectedFromCity != null &&
        _selectedToCity != null &&
        maxWeightController.text.isNotEmpty &&
        int.tryParse(maxWeightController.text) != null &&
        int.parse(maxWeightController.text) > 0 &&
        priceController.text.isNotEmpty &&
        double.tryParse(priceController.text) != null &&
        double.parse(priceController.text) > 0 &&
        descriptionController.text.trim().isNotEmpty;

    if (!baseValid) return false;

    switch (selectedOfferType) {
      case 'courier':
        return flightDateController.text.isNotEmpty &&
            flightTimeController.text.isNotEmpty;
      case 'sender':
        return deliveryDateFromController.text.isNotEmpty &&
            deliveryDateToController.text.isNotEmpty;
      case 'buyer':
        return purchaseDateController.text.isNotEmpty &&
            purchaseTimeController.text.isNotEmpty;
      default:
        return false;
    }
  }

  // ✅ ДОБАВЛЕНО: Метод для загрузки всех данных
  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingPackageTypes = true;
      _isLoadingCities = true;
      _isLoadingOfferTypes = true;
    });

    await Future.wait([
      _loadPackageTypes(),
      _loadCities(),
      _loadOfferTypes(),
    ]);
  }

  // ✅ ДОБАВЛЕНО: Метод для загрузки типов предложений
  Future<void> _loadOfferTypes() async {
    try {
      final offerTypes = await bloc.getOfferTypes();

      setState(() {
        _allOfferTypes = List<OfferTypeModel>.from(offerTypes.data);
        _isLoadingOfferTypes = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingOfferTypes = false;
        _allOfferTypes = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки типов предложений: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ✅ ДОБАВЛЕНО: Метод для загрузки городов
  Future<void> _loadCities() async {
    try {
      final cities = await bloc.getCities();

      setState(() {
        _allCities = List<City>.from(cities.data);
        _isLoadingCities = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingCities = false;
        _allCities = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки городов: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ✅ ДОБАВЛЕНО: Метод для загрузки типов посылок
  Future<void> _loadPackageTypes() async {
    try {
      final packageTypes = await bloc.getPackageTypes();

      setState(() {
        _allPackageTypes = List<PackageType>.from(packageTypes.data);
        _isLoadingPackageTypes = false;
      });
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

  Future<void> _showCitySelector({required bool isFromCity}) async {
    final selectedCity = await showCitySelector(
      context: context,
      cities: _allCities,
      selectedCity: isFromCity ? _selectedFromCity : _selectedToCity,
      isLoading: _isLoadingCities,
    );

    if (selectedCity != null) {
      setState(() {
        if (isFromCity) {
          _selectedFromCity = selectedCity;
          fromController.text = selectedCity.name;
        } else {
          _selectedToCity = selectedCity;
          toController.text = selectedCity.name;
        }
      });
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
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Container(
                margin: EdgeInsets.only(bottom: 100),
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                    const Text(
                      'Подать',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    _buildLabel('Тип предложения', isRequired: true),
                    const SizedBox(height: 8),
                    _buildOfferTypeDropdown(),
                    const SizedBox(height: 20),
                    _buildLabel('Тип посылки', isRequired: true),
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
                    _buildLabel('Откуда', isRequired: true),
                    const SizedBox(height: 8),
                    _buildCityField(
                      controller: fromController,
                      hint: 'Город отправления',
                      selectedCity: _selectedFromCity,
                      onTap: () => _showCitySelector(isFromCity: true),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Куда', isRequired: true),
                    const SizedBox(height: 8),
                    _buildCityField(
                      controller: toController,
                      hint: 'Город назначения',
                      selectedCity: _selectedToCity,
                      onTap: () => _showCitySelector(isFromCity: false),
                    ),
                    const SizedBox(height: 20),
                    ..._buildDateTimeFields(),
                    _buildLabel('Максимальный вес (кг)', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: maxWeightController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Цена за кг (\$)', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: priceController,
                      hint: '0',
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Описание', isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: descriptionController,
                      hint: 'Расскажите о своих услугах доставки...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isFormValid && !_isSubmitting)
                              ? _submitOffer
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? const Color(0xFF5B51FF)
                                : const Color(0xFFE5E5EA),
                            foregroundColor: _isFormValid
                                ? Colors.white
                                : const Color(0xFF8E8E93),
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFFE5E5EA),
                            disabledForegroundColor: const Color(0xFF8E8E93),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "asset/micro.png",
                                color: _isFormValid
                                    ? Colors.white
                                    : Colors.grey,
                                width: 20,
                              ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTypeDropdown() {


    return _buildDropdownField(
      hint: 'Выберите тип',
      value: selectedOfferType,
      icon: "asset/search.png",
      onChanged: (value) {
        setState(() {
          selectedOfferType = value;
          flightDateController.clear();
          flightTimeController.clear();
          deliveryDateFromController.clear();
          deliveryDateToController.clear();
          purchaseDateController.clear();
          purchaseTimeController.clear();
        });
      },
      items: _allOfferTypes.map((type) => type.code).toList(),
      displayNames: Map.fromEntries(
        _allOfferTypes.map((type) => MapEntry(type.code, type.name)),
      ),
    );
  }

  List<Widget> _buildDateTimeFields() {
    if (selectedOfferType == null) return [];

    switch (selectedOfferType) {
      case 'courier':
        return [
          _buildLabel('Дата вылета', isRequired: true),
          const SizedBox(height: 8),
          _buildDateField(flightDateController, 'дд.мм.гггг'),
          const SizedBox(height: 20),
          _buildLabel('Время вылета', isRequired: true),
          const SizedBox(height: 8),
          _buildTimeField(flightTimeController),
          const SizedBox(height: 20),
        ];

      case 'sender':
        return [
          _buildLabel('Дата доставки с', isRequired: true),
          const SizedBox(height: 8),
          _buildDateField(deliveryDateFromController, 'дд.мм.гггг'),
          const SizedBox(height: 20),
          _buildLabel('Дата доставки до', isRequired: true),
          const SizedBox(height: 8),
          _buildDateField(deliveryDateToController, 'дд.мм.гггг'),
          const SizedBox(height: 20),
        ];

      case 'buyer':
        return [
          _buildLabel('Дата покупки', isRequired: true),
          const SizedBox(height: 8),
          _buildDateField(purchaseDateController, 'дд.мм.гггг'),
          const SizedBox(height: 20),
          _buildLabel('Время покупки', isRequired: true),
          const SizedBox(height: 8),
          _buildTimeField(purchaseTimeController),
          const SizedBox(height: 20),
        ];

      default:
        return [];
    }
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return _buildTextField(
      controller: controller,
      hint: hint,
      suffixIcon: Icons.calendar_today_outlined,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
        );
        if (date != null) {
          controller.text =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        }
      },
    );
  }

  Widget _buildTimeField(TextEditingController controller) {
    return _buildTextField(
      controller: controller,
      hint: 'чч:мм (24-часовой формат)',
      suffixIcon: Icons.access_time,
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          controller.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  Future<void> _submitOffer() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final packageType = _selectedPackageTypeCodes.first;

      final request = CourierOfferModel(
        offerType: selectedOfferType!,
        cityFromId: _selectedFromCity!.id,
        cityToId: _selectedToCity!.id,
        flightDate:
        selectedOfferType == 'courier' ? flightDateController.text : '',
        flightTime:
        selectedOfferType == 'courier' ? flightTimeController.text : '',
        deliveryDateFrom: selectedOfferType == 'sender'
            ? deliveryDateFromController.text
            : '',
        deliveryDateTo:
        selectedOfferType == 'sender' ? deliveryDateToController.text : '',
        purchaseDate:
        selectedOfferType == 'buyer' ? purchaseDateController.text : '',
        purchaseTime:
        selectedOfferType == 'buyer' ? purchaseTimeController.text : '',
        packageType: packageType,
        maxWeightKg: int.parse(maxWeightController.text),
        pricePerKg: double.parse(priceController.text),
        description: descriptionController.text.trim(),
      );

      await bloc.createOffers(request);

      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        showTopSnackbar("Сохранено", "Объявление опубликовано!", true, context);

        _clearAllFields();
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ошибка при отправке: ${e.toString()}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearAllFields() {
    setState(() {
      fromController.clear();
      toController.clear();
      flightDateController.clear();
      flightTimeController.clear();
      deliveryDateFromController.clear();
      deliveryDateToController.clear();
      purchaseDateController.clear();
      purchaseTimeController.clear();
      maxWeightController.clear();
      priceController.clear();
      descriptionController.clear();
      _selectedFromCity = null;
      _selectedToCity = null;
      _selectedPackageTypeCodes.clear();
      selectedOfferType = null;
    });
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField({
    required TextEditingController controller,
    required String hint,
    required City? selectedCity,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: selectedCity != null
              ? Border.all(color: const Color(0xFF5B51FF), width: 1.5)
              : null,
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
          children: [
            Expanded(
              child: selectedCity != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCity.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedCity.countryName} (${selectedCity.countryCode})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              )
                  : Text(
                hint,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFC7C7CC),
                ),
              ),
            ),
            Icon(
              selectedCity != null
                  ? Icons.check_circle
                  : Icons.location_on_outlined,
              color: selectedCity != null
                  ? const Color(0xFF5B51FF)
                  : const Color(0xFFC7C7CC),
              size: 20,
            ),
          ],
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
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
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
    required String icon,
    required Function(String?) onChanged,
    required List<String> items,
    Map<String, String>? displayNames,
  }) {
    return Container(
      height: 60,
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          customButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Image.asset(
                  icon,
                  color: const Color(0xFF5B51FF),
                  width: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null ? (displayNames?[value] ?? value) : hint,
                    style: TextStyle(
                      fontSize: 15,
                      color: value != null
                          ? Colors.black
                          : const Color(0xFFC7C7CC),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                displayNames?[item] ?? item,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            offset: const Offset(0, -6),
            maxHeight: 300,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fromController.removeListener(_updateButtonState);
    toController.removeListener(_updateButtonState);
    flightDateController.removeListener(_updateButtonState);
    flightTimeController.removeListener(_updateButtonState);
    deliveryDateFromController.removeListener(_updateButtonState);
    deliveryDateToController.removeListener(_updateButtonState);
    purchaseDateController.removeListener(_updateButtonState);
    purchaseTimeController.removeListener(_updateButtonState);
    maxWeightController.removeListener(_updateButtonState);
    priceController.removeListener(_updateButtonState);
    descriptionController.removeListener(_updateButtonState);

    fromController.dispose();
    toController.dispose();
    flightDateController.dispose();
    flightTimeController.dispose();
    deliveryDateFromController.dispose();
    deliveryDateToController.dispose();
    purchaseDateController.dispose();
    purchaseTimeController.dispose();
    maxWeightController.dispose();
    priceController.dispose();
    descriptionController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  @override
  CreatePostBloc provideBloc() {
    return CreatePostBloc();
  }
}
