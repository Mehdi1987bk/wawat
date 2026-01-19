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
    // Загружаем данные в фоне без блокировки UI
    _loadAllDataSilently();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 20,right: 20,bottom: 20),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _buildSearchForm(isDark),
            ),
          ),
        );
      },
    );
  }


  Future<void> _loadAllDataSilently() async {
    _loadOfferTypesSilently();
    _loadCitiesSilently();
  }

  Future<void> _loadOfferTypesSilently() async {
    try {
      final offerTypes = await widget.bloc.getOfferTypes();
      if (mounted) {
        setState(() {
          _allOfferTypes = List<OfferTypeModel>.from(offerTypes.data);
          _isLoadingOfferTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOfferTypes = false;
        });
      }
      // Тихо повторяем через 3 секунды
      _retryLoadOfferTypes();
    }
  }

  Future<void> _retryLoadOfferTypes() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _allOfferTypes.isEmpty) {
      _loadOfferTypesSilently();
    }
  }

  Future<void> _loadCitiesSilently() async {
    try {
      final cities = await widget.bloc.getCities('');
      if (mounted) {
        setState(() {
          _allCities = List<City>.from(cities.data);
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
        });
      }
      // Тихо повторяем через 3 секунды
      _retryLoadCities();
    }
  }

  Future<void> _retryLoadCities() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _allCities.isEmpty) {
      _loadCitiesSilently();
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
    // Если города ещё не загружены, пробуем загрузить
    if (_allCities.isEmpty && !_isLoadingCities) {
      setState(() => _isLoadingCities = true);
      await _loadCitiesSilently();
    }

    // Если всё ещё загружается, показываем диалог с индикатором
    if (_isLoadingCities) {
      _showLoadingCityDialog(isFromCity);
      return;
    }

    if (!mounted) return;

    final selectedCity = await showCitySelector(
      context: context,
      initialCities: _allCities,
      selectedCity: isFromCity ? _selectedFromCity : _selectedToCity,
      onSearch: _searchCities,
      isLoading: _isLoadingCities,
    );

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

  void _showLoadingCityDialog(bool isFromCity) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        // Автоматически закрываем когда загрузится
        _waitForCitiesAndOpen(dialogContext, isFromCity);

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF7C6FFF)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).vfegrbfdthgbr5j45ehrw,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _waitForCitiesAndOpen(
      BuildContext dialogContext, bool isFromCity) async {
    // Ждём максимум 10 секунд
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (!_isLoadingCities && _allCities.isNotEmpty) {
        // Закрываем диалог загрузки
        if (Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }

        // Небольшая задержка для плавности
        await Future.delayed(const Duration(milliseconds: 100));

        // Открываем селектор городов
        if (mounted) {
          final selectedCity = await showCitySelector(
            context: context,
            initialCities: _allCities,
            selectedCity: isFromCity ? _selectedFromCity : _selectedToCity,
            onSearch: _searchCities,
            isLoading: false,
          );

          if (mounted) {
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
        }
        return;
      }
    }

    // Таймаут - закрываем диалог
    if (Navigator.of(dialogContext).canPop()) {
      Navigator.of(dialogContext).pop();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).nkmlregt4lk),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
            onClear: () {
              setState(() {
                _selectedFromCity = null;
                _fromController.clear();
              });
            },
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
            onClear: () {
              setState(() {
                _selectedToCity = null;
                _toController.clear();
              });
            },
            isDark: isDark,
          ),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).br45gre24, isDark),
          SizedBox(height: 10),
          _buildDateField(
              _dateFromController, S.of(context).grereg3gr3g3r3gr, isDark),
          SizedBox(height: 20),
          _buildFieldLabel(S.of(context).vfedrgev3r2g4, isDark),
          SizedBox(height: 10),
          _buildDateField(
              _dateToController, S.of(context).grereg3gr3g3r3gr, isDark),
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
                // Показываем маленький индикатор пока загружается
                if (_isLoadingOfferTypes && _allOfferTypes.isEmpty)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF7C6FFF)),
                    ),
                  )
                else
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
                          name: S.of(context).bgfbgfb3,
                        ),
                      )
                          .name)
                          : S.of(context).bgfbgfb3,
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
                S.of(context).bgfbgfb3,
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
    required VoidCallback onClear, // Добавляем параметр для очистки
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
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
            if (selectedCity != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: const Color(0xFF7C6FFF),
                    size: 20,
                  ),
                ),
              )
            else
              Icon(
                Icons.location_on_outlined,
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
                color:
                isDark ? const Color(0xFF6B7280) : const Color(0xFFB0B0B0),
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