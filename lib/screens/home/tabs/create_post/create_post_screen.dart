import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/bloc/error_dispatcher.dart';
import 'package:buking/screens/home/tabs/create_post/widget/city_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/request/courier_offer_model.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/offer_type_model.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../generated/l10n.dart';
import '../../../../services/theme_aware_screen.dart';
import '../../../../services/theme_manager.dart';
import '../../../auth/registration/widget/package_types_selector.dart';
import '../home_tab/home_tab_screen.dart';
import '../home_tab/notification/unread_notif_bloc.dart';
import '../home_tab/widget/build_header.dart';
import '../home_tab/widget/city_selector.dart';
import '../profile_tab/settings/experience_tab/experience_tab_screen.dart';
import 'create_post_bloc.dart';

class CreatePostScreen extends BaseScreen {
  CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState
    extends BaseState<CreatePostScreen, CreatePostBloc> with ErrorDispatcher {
  @override
  bool get useSystemOverlay => false;

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
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController deliveryDateFromController =
  TextEditingController();
  final TextEditingController deliveryDateToController =
  TextEditingController();
  final TextEditingController purchaseDateFromController =
  TextEditingController();
  final TextEditingController purchaseDateToController =
  TextEditingController();

  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late final UnreadNotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();

    fromController.addListener(_updateButtonState);
    toController.addListener(_updateButtonState);
    flightDateController.addListener(_updateButtonState);
    flightTimeController.addListener(_updateButtonState);
    flightNumberController.addListener(_updateButtonState);
    deliveryDateFromController.addListener(_updateButtonState);
    deliveryDateToController.addListener(_updateButtonState);
    purchaseDateFromController.addListener(_updateButtonState);
    purchaseDateToController.addListener(_updateButtonState);
    maxWeightController.addListener(_updateButtonState);
    priceController.addListener(_updateButtonState);
    // descriptionController.addListener(_updateButtonState); // <-- УБРАТЬ ЭТУ СТРОКУ
    _notificationBloc = UnreadNotificationBloc();
    _notificationBloc.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllDataSilently();
    });
  }

  bool get _isFormValid {
    final baseValid = selectedOfferType != null &&
        selectedOfferType!.isNotEmpty &&
        _selectedPackageTypeCodes.isNotEmpty &&
        _selectedFromCity != null &&
        _selectedToCity != null &&
        maxWeightController.text.isNotEmpty &&
        double.tryParse(maxWeightController.text.replaceAll(',', '.')) != null &&
        double.parse(maxWeightController.text.replaceAll(',', '.')) > 0 &&
        priceController.text.isNotEmpty &&
        double.tryParse(priceController.text.replaceAll(',', '.')) != null &&
        double.parse(priceController.text.replaceAll(',', '.')) > 0;
    // descriptionController.text.trim().isNotEmpty; // <-- УБРАТЬ ЭТУ СТРОКУ

    if (!baseValid) return false;

    switch (selectedOfferType) {
      case 'courier':
        return flightDateController.text.isNotEmpty &&
            flightTimeController.text.isNotEmpty &&
            flightNumberController.text.trim().isNotEmpty;
      case 'sender':
        return deliveryDateFromController.text.isNotEmpty &&
            deliveryDateToController.text.isNotEmpty;
      case 'buyer':
        return purchaseDateFromController.text.isNotEmpty &&
            purchaseDateToController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _updateButtonState() {
    setState(() {});
  }


  Future<void> _loadAllDataSilently() async {
    // Запускаем параллельно, не блокируя UI
    _loadPackageTypesSilently();
    _loadCitiesSilently();
    _loadOfferTypesSilently();
  }

  Future<void> _loadOfferTypesSilently() async {
    try {
      final offerTypes = await bloc.getOfferTypes();

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
          _allOfferTypes = [];
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
      final cities = await bloc.getCities('');

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
          _allCities = [];
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

  Future<void> _loadPackageTypesSilently() async {
    try {
      final packageTypes = await bloc.getPackageTypes();

      if (mounted) {
        setState(() {
          _allPackageTypes = List<PackageType>.from(packageTypes.data);
          _isLoadingPackageTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPackageTypes = false;
          _allPackageTypes = [];
        });
      }
      // Тихо повторяем через 3 секунды
      _retryLoadPackageTypes();
    }
  }

  Future<void> _retryLoadPackageTypes() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _allPackageTypes.isEmpty) {
      _loadPackageTypesSilently();
    }
  }

  Future<List<City>> _searchCities(String search) async {
    try {
      final result = await bloc.getCities(search);
      return result.data;
    } catch (e) {
      return [];
    }
  }

  Future<void> _showCitySelector({required bool isFromCity}) async {
    // Если города ещё не загружены, пробуем загрузить
    if (_allCities.isEmpty && !_isLoadingCities) {
      setState(() => _isLoadingCities = true);
      _loadCitiesSilently();
    }

    // Если всё ещё загружается или пусто, показываем диалог с индикатором
    if (_isLoadingCities || _allCities.isEmpty) {
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
        fromController.text = selectedCity?.name ?? '';
      } else {
        _selectedToCity = selectedCity;
        toController.text = selectedCity?.name ?? '';
      }
    });
  }

  void _showLoadingCityDialog(bool isFromCity) {
    final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

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
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                    AlwaysStoppedAnimation<Color>(Color(0xFF5B51FF)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).vfegrbfdthgbr5j45ehrw,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
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
    // Ждём максимум 15 секунд (30 итераций по 500мс)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Проверяем, закрыт ли диалог пользователем
      if (!Navigator.of(dialogContext).canPop()) return;

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
                fromController.text = selectedCity?.name ?? '';
              } else {
                _selectedToCity = selectedCity;
                toController.text = selectedCity?.name ?? '';
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

  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;

    return ThemeAwareScreen(
      isDark: isDark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isDark ? const Color(0xFF121212) : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              StreamBuilder<int>(
                stream: _notificationBloc.unreadCountStream,
                initialData: 0,
                builder: (context, snapshot) {
                  return BuildHeader(
                    context,
                    isDark: isDark,
                    unreadCount: snapshot.data ?? 0,
                    onNotificationsReturned: () {
                      _notificationBloc.fetchUnreadCount();
                    },
                  );
                },
              ),           Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 100),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: Image.asset(
                            "asset/add_offer.png",
                            color:
                            isDark ? Colors.white.withOpacity(0.9) : null,
                            colorBlendMode: isDark ? BlendMode.modulate : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          child: Text(S.of(context).bvfv2r),
                        ),
                        const SizedBox(height: 8),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFFB0B0B0)
                                : const Color(0xFF8E8E93),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          child: Text(
                            S.of(context).bgfbgbgfbgf,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildLabel(S.of(context).bgfbgfbgf,
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildOfferTypeDropdown(isDark),
                        const SizedBox(height: 20),
                        _buildLabel(S.of(context).nhgnhg4,
                            isRequired: true, isDark: isDark),
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
                        _buildLabel(S.of(context).hythyt4,
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildCityField(
                          controller: fromController,
                          hint: S.of(context).kiukiuku6,
                          selectedCity: _selectedFromCity,
                          onTap: () => _showCitySelector(isFromCity: true),
                          onClear: () {
                            setState(() {
                              _selectedFromCity = null;
                              fromController.clear();
                            });
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel(S.of(context).kiuykiu67,
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildCityField(
                          controller: toController,
                          hint: S.of(context).lkiuliuu6,
                          selectedCity: _selectedToCity,
                          onTap: () => _showCitySelector(isFromCity: false),
                          onClear: () {
                            setState(() {
                              _selectedToCity = null;
                              toController.clear();
                            });
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        ..._buildDateTimeFields(isDark),
                        _buildLabel(S.of(context).mjjhm6,
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: maxWeightController,
                          hint: '0',
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                            TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  final text = newValue.text.replaceAll(',', '.');

                                  if (text.split('.').length > 2) {
                                    return oldValue;
                                  }

                                  return TextEditingValue(
                                    text: text,
                                    selection: TextSelection.collapsed(
                                        offset: text.length),
                                  );
                                }),
                          ],
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel(S.of(context).bgfbgf34 + " (\$)",
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: priceController,
                          hint: '0',
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                            TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  final text = newValue.text.replaceAll(',', '.');

                                  if (text.split('.').length > 2) {
                                    return oldValue;
                                  }

                                  return TextEditingValue(
                                    text: text,
                                    selection: TextSelection.collapsed(
                                        offset: text.length),
                                  );
                                }),
                          ],
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel(S.of(context).vfdbg2r3,
                            isRequired: true, isDark: isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: descriptionController,
                          hint: S.of(context).bdfbd2w,
                          maxLines: 5,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
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
                                    : (isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFE5E5EA)),
                                foregroundColor: _isFormValid
                                    ? Colors.white
                                    : (isDark
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF8E8E93)),
                                elevation: 0,
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFE5E5EA),
                                disabledForegroundColor: isDark
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF8E8E93),
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
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "asset/micro.png",
                                    color: _isFormValid
                                        ? Colors.white
                                        : (isDark
                                        ? const Color(0xFF6B7280)
                                        : Colors.grey),
                                    width: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    S.of(context).bgfbgf3,
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
        ),
      ),
    );
  }

  Widget _buildOfferTypeDropdown(bool isDark) {
    return _buildDropdownField(
      hint: S.of(context).bgfbgfb3,
      value: selectedOfferType,
      icon: "asset/search.png",
      onChanged: (value) {
        setState(() {
          selectedOfferType = value;
          flightDateController.clear();
          flightTimeController.clear();
          flightNumberController.clear();
          deliveryDateFromController.clear();
          deliveryDateToController.clear();
          purchaseDateFromController.clear();
          purchaseDateToController.clear();
        });
      },
      items: _allOfferTypes.map((type) => type.code).toList(),
      displayNames: Map.fromEntries(
        _allOfferTypes.map((type) => MapEntry(type.code, type.name)),
      ),
      isDark: isDark,
    );
  }

  List<Widget> _buildDateTimeFields(bool isDark) {
    if (selectedOfferType == null) return [];

    switch (selectedOfferType) {
      case 'courier':
        return [
          _buildLabel(S.of(context).bgfbgf3, isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildDateField(
              flightDateController, S.of(context).bgbgfg334, isDark),
          const SizedBox(height: 20),
          _buildLabel(S.of(context).bgfbgf3434,
              isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildTimeField(flightTimeController, isDark),
          const SizedBox(height: 20),
          _buildLabel(S.of(context).flightNumber,
              isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildTextField(
            controller: flightNumberController,
            hint: S.of(context).enterTheFlightNumber,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
        ];

      case 'sender':
        return [
          _buildLabel(S.of(context).bgdfbg345,
              isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildDateField(
              deliveryDateFromController, S.of(context).bgfbgf4554, isDark),
          const SizedBox(height: 20),
          _buildLabel(S.of(context).bgfgbfbgf345,
              isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildDateField(
              deliveryDateToController, S.of(context).bgfdbgf345, isDark),
          const SizedBox(height: 20),
        ];

      case 'buyer':
        return [
          _buildLabel(S.of(context).bgfb3, isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildDateField(
              purchaseDateFromController, S.of(context).bgfbggfbgf34, isDark),
          const SizedBox(height: 20),
          _buildLabel(S.of(context).vfdv34, isRequired: true, isDark: isDark),
          const SizedBox(height: 8),
          _buildDateField(
              purchaseDateToController, S.of(context).bgfbggfbgf34, isDark),
          const SizedBox(height: 20),
        ];

      default:
        return [];
    }
  }

  Widget _buildDateField(
      TextEditingController controller, String hint, bool isDark) {
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
          lastDate: DateTime.now().add(Duration(days: 365 * 10)),
          locale: Localizations.localeOf(context),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF5B51FF),
                  onPrimary: Colors.white,
                  surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  onSurface: isDark ? Colors.white : Colors.black,
                ),
                dialogBackgroundColor:
                isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.text =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        }
      },
      isDark: isDark,
    );
  }

  Widget _buildTimeField(TextEditingController controller, bool isDark) {
    return _buildTextField(
      controller: controller,
      hint: S.of(context).vfdvfddfv24,
      suffixIcon: Icons.access_time,
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Localizations.override(
              context: context,
              locale: Localizations.localeOf(context),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF5B51FF),
                      onPrimary: Colors.white,
                      surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      onSurface: isDark ? Colors.white : Colors.black,
                    ),
                    dialogBackgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  ),
                  child: child!,
                ),
              ),
            );
          },
        );
        if (time != null) {
          controller.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }
      },
      isDark: isDark,
    );
  }

  Future<void> _submitOffer() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final packageType = _selectedPackageTypeCodes.first;

      final maxWeight =
      double.parse(maxWeightController.text.replaceAll(',', '.'));
      final price = double.parse(priceController.text.replaceAll(',', '.'));

      final request = CourierOfferModel(
        offerType: selectedOfferType!,
        cityFromId: _selectedFromCity!.id,
        cityToId: _selectedToCity!.id,
        flightDate:
        selectedOfferType == 'courier' ? flightDateController.text : '',
        flightTime:
        selectedOfferType == 'courier' ? flightTimeController.text : '',
        flightNumber:
        selectedOfferType == 'courier' ? flightNumberController.text.trim() : null,
        deliveryDateFrom: selectedOfferType == 'sender'
            ? deliveryDateFromController.text
            : '',
        deliveryDateTo:
        selectedOfferType == 'sender' ? deliveryDateToController.text : '',
        purchaseDate:
        selectedOfferType == 'buyer' ? purchaseDateFromController.text : '',
        purchaseTime:
        selectedOfferType == 'buyer' ? purchaseDateToController.text : '',
        packageType: packageType,
        maxWeightKg: maxWeight.round(),
        pricePerKg: price,
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
        showIOSStyleMessage(context, S.of(context).vfdvfd24);
        _clearAllFields();
      }
    } catch (e, stackTrace) {

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
      flightNumberController.clear();
      deliveryDateFromController.clear();
      deliveryDateToController.clear();
      purchaseDateFromController.clear();
      purchaseDateToController.clear();
      maxWeightController.clear();
      priceController.clear();
      descriptionController.clear();
      _selectedFromCity = null;
      _selectedToCity = null;
      _selectedPackageTypeCodes.clear();
      selectedOfferType = null;
    });
  }

  Widget _buildLabel(String text,
      {bool isRequired = false, required bool isDark}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
          children: [
            if (isRequired)
              TextSpan(
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
    required VoidCallback onClear,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: selectedCity != null
              ? Border.all(color: const Color(0xFF5B51FF), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: Text(selectedCity.name),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF8E8E93),
                    ),
                    child: Text(
                        '${selectedCity.countryName} (${selectedCity.countryCode})'),
                  ),
                ],
              )
                  : AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFC7C7CC),
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
                    Icons.clear,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              )
            else
              Icon(
                Icons.location_on_outlined,
                color:
                isDark ? const Color(0xFF6B7280) : const Color(0xFFC7C7CC),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFFC7C7CC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: suffixIcon != null
              ? Icon(
            suffixIcon,
            color: isDark
                ? const Color(0xFF6B7280)
                : const Color(0xFFC7C7CC),
            size: 20,
          )
              : null,
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
    required Map<String, String> displayNames,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 10,
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
                Image.asset(
                  icon,
                  width: 20,
                  color: const Color(0xFF5B51FF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 15,
                      color: value != null
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFC7C7CC)),
                    ),
                    child: Text(
                      value != null ? (displayNames[value] ?? value) : hint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                displayNames[item] ?? item,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            ),
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            offset: const Offset(0, -6),
            maxHeight: 300,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  CreatePostBloc provideBloc() {
    return CreatePostBloc();
  }
}