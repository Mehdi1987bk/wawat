import 'package:buking/screens/home/tabs/create_post/widget/city_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/offer_type_model.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../home_tab_bloc.dart';
import '../search/search_offer_list_screen.dart';

class SearchFormWidget extends StatefulWidget {
  final HomeTabBloc bloc;

  const SearchFormWidget({Key? key, required this.bloc}) : super(key: key);

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  String? _selectedOfferType;
  String? _selectedPackageType;
  City? _selectedFromCity;
  City? _selectedToCity;

  List<City> _allCities = [];
  bool _isLoadingCities = true;

  List<OfferTypeModel> _allOfferTypes = [];
  bool _isLoadingOfferTypes = true;

  List<PackageType> _allPackageTypes = [];
  bool _isLoadingPackageTypes = true;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();

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
      _isLoadingPackageTypes = true;
    });

    await Future.wait([
      _loadCities(),
      _loadOfferTypes(),
     ]);
  }

  Future<void> _loadOfferTypes() async {
    try {
      final offerTypes = await widget.bloc.getOfferTypes();

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
    // Конвертируем даты в формат YYYY-MM-DD для API
    String? dateFrom;
    String? dateTo;

    if (_dateFromController.text.isNotEmpty) {
      dateFrom = _convertDateToApiFormat(_dateFromController.text);
    }

    if (_dateToController.text.isNotEmpty) {
      dateTo = _convertDateToApiFormat(_dateToController.text);
    }

    // Открываем экран с результатами поиска
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SearchOfferListScreen(
          offerType: _selectedOfferType,
          packageType: _selectedPackageType,
          cityFromId: _selectedFromCity?.id != null ? _selectedFromCity!.id : null,
          cityToId: _selectedToCity?.id != null ? _selectedToCity!.id : null,
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      ),
    );
  }

  String? _convertDateToApiFormat(String dateString) {
    try {
      // Входной формат: дд.мм.гггг
      // Выходной формат: гггг-мм-дд
      final parts = dateString.split('.');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      print('Ошибка конвертации даты: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
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
          // Тип предложения
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

          // Дата С
          _buildFieldLabel('Дата с'),
          SizedBox(height: 10),
          _buildDateField(_dateFromController, 'дд.мм.гггг'),
          SizedBox(height: 20),

          // Дата До
          _buildFieldLabel('Дата до'),
          SizedBox(height: 10),
          _buildDateField(_dateToController, 'дд.мм.гггг'),
          SizedBox(height: 28),

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
