import 'package:buking/screens/home/tabs/create_post/widget/city_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/offer_type_model.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../services/theme_manager.dart';
import '../home_tab_bloc.dart';
import '../search/search_offer_list_screen.dart';
import 'city_selector.dart';

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
            content: Text(S.of(context).egreergreger + ' $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadCities() async {
    try {
      final cities = await widget.bloc.getCities('');

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
            content: Text(S.of(context).vfevevreveve + ' $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<List<City>> _searchCities(String search) async {
    try {
      final result = await widget.bloc.getCities(search);
      return result.data;
    } catch (e) {
      return [];
    }
  }

  Future<void> _showCitySelector({required bool isFromCity}) async {
    final selectedCity = await showCitySelector(
      context: context,
      initialCities: _allCities,
      selectedCity: isFromCity ? _selectedFromCity : _selectedToCity,
      onSearch: _searchCities,
      isLoading: _isLoadingCities,
    );

    // Обрабатываем как выбор, так и отмену выбора
    setState(() {
      if (isFromCity) {
        _selectedFromCity = selectedCity;
        _fromController.text = selectedCity?.name ?? '';
      } else {
        _selectedToCity = selectedCity;
        _toController.text = selectedCity?.name ?? '';
      }
    });
  }

  void _performSearch() {
    String? dateFrom;
    String? dateTo;

    if (_dateFromController.text.isNotEmpty) {
      dateFrom = _convertDateToApiFormat(_dateFromController.text);
    }

    if (_dateToController.text.isNotEmpty) {
      dateTo = _convertDateToApiFormat(_dateToController.text);
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SearchOfferListScreen(
          offerType: _selectedOfferType,
          packageType: _selectedPackageType,
          cityFromId:
              _selectedFromCity?.id != null ? _selectedFromCity!.id : null,
          cityToId: _selectedToCity?.id != null ? _selectedToCity!.id : null,
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      ),
    );
  }

  String? _convertDateToApiFormat(String dateString) {
    try {
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildSearchForm(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchForm(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
          _buildFieldLabel(S.of(context).hth453gwsf, isDark),
          SizedBox(height: 10),
          _buildOfferTypeDropdown(isDark),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).gtrh53ygr43g, isDark),
          SizedBox(height: 10),
          _buildCityField(
            controller: _fromController,
            hint: S.of(context).htrh5hetsgft42,
            selectedCity: _selectedFromCity,
            onTap: () => _showCitySelector(isFromCity: true),
            isDark: isDark,
          ),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).htrhey34tgesft, isDark),
          SizedBox(height: 10),
          _buildCityField(
            controller: _toController,
            hint: S.of(context).ryh53gr45h3,
            selectedCity: _selectedToCity,
            onTap: () => _showCitySelector(isFromCity: false),
            isDark: isDark,
          ),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).br45gre24, isDark),
          SizedBox(height: 10),
          _buildDateField(_dateFromController, S.of(context).grereg3gr3g3r3gr, isDark),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).vfedrgev3r2g4, isDark),
          SizedBox(height: 10),
          _buildDateField(_dateToController, S.of(context).grereg3gr3g3r3gr, isDark),
          SizedBox(height: 28),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isDark) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        height: 1.2,
      ),
      child: Text(text),
    );
  }

  Widget _buildOfferTypeDropdown(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
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
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w400,
                    ),
                    child: Text(
                      _selectedOfferType != null
                          ? (_allOfferTypes
                              .firstWhere(
                                (type) => type.code == _selectedOfferType,
                                orElse: () => OfferTypeModel(
                                  code: '',
                                  name: S.of(context).vfdefrwgerg,
                                ),
                              )
                              .name)
                          : S.of(context).vfdefrwgerg,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFB0B0B0),
                ),
              ],
            ),
          ),
          value: _selectedOfferType,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                S.of(context).vfdefrwgerg,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            ..._allOfferTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type.code,
                child: Text(
                  type.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCity != null
                ? const Color(0xFF7C6FFF)
                : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8)),
            width: selectedCity != null ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
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
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          child: Text(selectedCity.name),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFFB0B0B0),
                          ),
                          child: Text(
                              '${selectedCity.countryName} (${selectedCity.countryCode})'),
                        ),
                      ],
                    )
                  : AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w400,
                      ),
                      child: Text(hint),
                    ),
            ),
            Icon(
              selectedCity != null
                  ? Icons.check_circle
                  : Icons.location_on_outlined,
              color: selectedCity != null
                  ? const Color(0xFF7C6FFF)
                  : (isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFB0B0B0)),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String hint, bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365 * 10)),
          locale: Localizations.localeOf(context),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF7C6FFF),
                  onPrimary: Colors.white,
                  surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  onSurface: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                dialogBackgroundColor:
                isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.text.isNotEmpty
                ? const Color(0xFF7C6FFF)
                : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8)),
            width: controller.text.isNotEmpty ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  color: controller.text.isEmpty
                      ? (isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFB0B0B0))
                      : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  fontWeight: controller.text.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w600,
                ),
                child: Text(controller.text.isEmpty ? hint : controller.text),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    controller.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.clear,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
              )
            else
              Icon(
                Icons.calendar_today_outlined,
                color: isDark
                    ? const Color(0xFF6B7280)
                    : const Color(0xFFB0B0B0),
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
                S.of(context).reg23rdwerf32w,
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
