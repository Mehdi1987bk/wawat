import 'package:buking/screens/home/tabs/create_post/widget/city_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/offer_type_model.dart';
import '../home_tab_bloc.dart';

class SearchFormWidget extends StatefulWidget {
  final HomeTabBloc bloc;

  const SearchFormWidget({Key? key, required this.bloc}) : super(key: key);

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  String? _selectedOfferType;
  City? _selectedFromCity;
  City? _selectedToCity;

  List<City> _allCities = [];
  bool _isLoadingCities = true;

  List<OfferTypeModel> _allOfferTypes = [];
  bool _isLoadingOfferTypes = true;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Контроллеры для разных типов предложений
  final TextEditingController _flightDateController = TextEditingController();
  final TextEditingController _flightTimeController = TextEditingController();
  final TextEditingController _deliveryDateFromController = TextEditingController();
  final TextEditingController _deliveryDateToController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _purchaseTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingCities = true;
      _isLoadingOfferTypes = true;
    });

    await Future.wait([
      _loadCities(),
      _loadOfferTypes(),
    ]);
  }

  Future<void> _loadOfferTypes() async {
    try {
      print('🔍 Загрузка типов предложений...');
      final offerTypes = await widget.bloc.getOfferTypes();

      print('✅ Получено типов: ${offerTypes.data.length}');
      for (var i = 0; i < (offerTypes.data.length > 5 ? 5 : offerTypes.data.length); i++) {
        final type = offerTypes.data[i];
       }

      setState(() {
        _allOfferTypes = List<OfferTypeModel>.from(offerTypes.data);
        _isLoadingOfferTypes = false;
      });

      print('✅ Типы предложений загружены: ${_allOfferTypes.length}');
    } catch (e, stackTrace) {
      print('❌ Ошибка загрузки типов предложений: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoadingOfferTypes = false;
        _allOfferTypes = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки типов предложений: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadCities() async {
    try {
      final cities = await widget.bloc.getCities();

      setState(() {
        _allCities = List<City>.from(cities.data);
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
        _allCities = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки городов: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
          _fromController.text = selectedCity.name;
        } else {
          _selectedToCity = selectedCity;
          _toController.text = selectedCity.name;
        }
      });
    }
  }

  void _performSearch() {
    // TODO: Implement search logic
    print('Search params:');
    print('Offer Type: $_selectedOfferType');
    print('From: ${_selectedFromCity?.name}');
    print('To: ${_selectedToCity?.name}');

    switch (_selectedOfferType) {
      case 'courier':
        print('Flight Date: ${_flightDateController.text}');
        print('Flight Time: ${_flightTimeController.text}');
        break;
      case 'sender':
        print('Delivery Date From: ${_deliveryDateFromController.text}');
        print('Delivery Date To: ${_deliveryDateToController.text}');
        break;
      case 'buyer':
        print('Purchase Date: ${_purchaseDateController.text}');
        print('Purchase Time: ${_purchaseTimeController.text}');
        break;
    }

    // Navigate to results screen
    // Navigator.push(
    //   context,
    //   CupertinoPageRoute(
    //     builder: (context) => SearchResultsScreen(
    //       offerType: _selectedOfferType,
    //       fromCity: _selectedFromCity,
    //       toCity: _selectedToCity,
    //       ...
    //     ),
    //   ),
    // );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _flightDateController.dispose();
    _flightTimeController.dispose();
    _deliveryDateFromController.dispose();
    _deliveryDateToController.dispose();
    _purchaseDateController.dispose();
    _purchaseTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: _buildSearchForm(),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
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
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Тип предложения (первым)
          _buildFieldLabel('Тип предложения'),
          SizedBox(height: 10),
          _buildOfferTypeDropdown(),
          SizedBox(height: 20),

          // Откуда
          _buildFieldLabel('Откуда'),
          SizedBox(height: 10),
          _buildCityField(
            controller: _fromController,
            hint: 'Город отправления',
            selectedCity: _selectedFromCity,
            onTap: () => _showCitySelector(isFromCity: true),
          ),
          SizedBox(height: 20),

          // Куда
          _buildFieldLabel('Куда'),
          SizedBox(height: 10),
          _buildCityField(
            controller: _toController,
            hint: 'Город назначения',
            selectedCity: _selectedToCity,
            onTap: () => _showCitySelector(isFromCity: false),
          ),
          SizedBox(height: 20),

          // Динамические поля в зависимости от типа
          ..._buildDateTimeFields(),

          // Кнопка поиск
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        height: 1.2,
      ),
    );
  }

  Widget _buildOfferTypeDropdown() {
    if (_isLoadingOfferTypes) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE8E8E8)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7C6FFF),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          customButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Color(0xFF7C6FFF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedOfferType != null
                        ? (_allOfferTypes
                        .firstWhere(
                          (type) => type.code == _selectedOfferType,
                      orElse: () => OfferTypeModel(
                        code: '',
                       name: 'Все категории',
                      ),
                    )
                        .name)
                        : 'Все категории',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedOfferType != null
                          ? Color(0xFF1A1A1A)
                          : Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFB0B0B0),
                ),
              ],
            ),
          ),
          value: _selectedOfferType,
          items: [
            // "Все категории" option
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Все категории',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // Actual offer types
            ..._allOfferTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type.code,
                child: Text(
                  type.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOfferType = value;
              // Очищаем все поля дат при смене типа
              _flightDateController.clear();
              _flightTimeController.clear();
              _deliveryDateFromController.clear();
              _deliveryDateToController.clear();
              _purchaseDateController.clear();
              _purchaseTimeController.clear();
            });
          },
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

  List<Widget> _buildDateTimeFields() {
    if (_selectedOfferType == null) return [];

    switch (_selectedOfferType) {
      case 'courier':
        return [
          _buildFieldLabel('Дата вылета'),
          SizedBox(height: 10),
          _buildDateField(_flightDateController, 'дд.мм.гггг'),
          SizedBox(height: 20),
          _buildFieldLabel('Время вылета'),
          SizedBox(height: 10),
          _buildTimeField(_flightTimeController),
          SizedBox(height: 28),
        ];

      case 'sender':
        return [
          _buildFieldLabel('Дата доставки с'),
          SizedBox(height: 10),
          _buildDateField(_deliveryDateFromController, 'дд.мм.гггг'),
          SizedBox(height: 20),
          _buildFieldLabel('Дата доставки до'),
          SizedBox(height: 10),
          _buildDateField(_deliveryDateToController, 'дд.мм.гггг'),
          SizedBox(height: 28),
        ];

      case 'buyer':
        return [
          _buildFieldLabel('Дата покупки'),
          SizedBox(height: 10),
          _buildDateField(_purchaseDateController, 'дд.мм.гггг'),
          SizedBox(height: 20),
          _buildFieldLabel('Время покупки'),
          SizedBox(height: 10),
          _buildTimeField(_purchaseTimeController),
          SizedBox(height: 28),
        ];

      default:
        return [];
    }
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
          border: Border.all(
            color: selectedCity != null
                ? const Color(0xFF7C6FFF)
                : Color(0xFFE8E8E8),
            width: selectedCity != null ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${selectedCity.countryName} (${selectedCity.countryCode})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              )
                  : Text(
                hint,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              selectedCity != null
                  ? Icons.check_circle
                  : Icons.location_on_outlined,
              color: selectedCity != null
                  ? const Color(0xFF7C6FFF)
                  : const Color(0xFFB0B0B0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF7C6FFF),
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF1A1A1A),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            controller.text =
                '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.text.isEmpty
                      ? Color(0xFFB0B0B0)
                      : Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFB0B0B0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFF7C6FFF),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF1A1A1A),
                  ),
                ),
                child: child!,
              ),
            );
          },
        );
        if (time != null) {
          setState(() {
            controller.text =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? 'чч:мм (24-часовой формат)' : controller.text,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.text.isEmpty
                      ? Color(0xFFB0B0B0)
                      : Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.access_time,
              color: Color(0xFFB0B0B0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A5FFF), Color(0xFFB74CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x334A5FFF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _performSearch,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Поиск',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}