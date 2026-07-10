import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/request/create_listing_request.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../services/theme_aware_screen.dart';
import '../../../../services/theme_manager.dart';
import '../../../../services/wawat_content.dart';
import '../home_tab/widget/city_selector.dart';
import '../profile_tab/see_more_offers/delivery_full_list_screen.dart';
import 'create_post_bloc.dart';
import 'listing_limit_gate_screen.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _amber = Color(0xFFF59E0B);
const _amber50 = Color(0xFFFFF7ED);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink200 = Color(0xFFE2E8F0);
const _emerald = Color(0xFF10B981);

String _formatNumber(double value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
}

String _azMonth(int month) {
  const months = [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'İyun',
    'İyul',
    'Avqust',
    'Sentyabr',
    'Oktyabr',
    'Noyabr',
    'Dekabr',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String _userDisplayName(User? user) {
  if (user == null) return 'Siz';
  final fullName = user.fullname.trim();
  if (fullName.isNotEmpty) return fullName;
  final name = [user.firstName, user.lastName]
      .where((part) => part != null && part.trim().isNotEmpty)
      .join(' ');
  if (name.isNotEmpty) return name;
  if (user.username != null && user.username!.trim().isNotEmpty) {
    return user.username!;
  }
  return 'Siz';
}

String _userInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty || name == 'Siz') return 'S';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String? _userTierLabel(String? tier, Map<String, String> content) {
  if (tier == null || tier.trim().isEmpty) return null;
  final cmsLabel = content['enum.user_tier.$tier'];
  if (cmsLabel != null && cmsLabel.trim().isNotEmpty) return cmsLabel;
  switch (tier) {
    case 'new':
      return 'Yeni';
    case 'standard':
      return 'Standart';
    case 'bronze':
      return 'Bürünc';
    case 'silver':
      return 'Gümüş';
    case 'gold':
      return 'Qızıl';
    case 'platinum':
      return 'Platin';
  }
  return tier;
}

Theme _wawatPickerTheme(
  BuildContext context,
  Widget? child, {
  required Color accent,
}) {
  final base = Theme.of(context);
  final colorScheme = ColorScheme.light(
    primary: accent,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: _ink900,
    surfaceContainerHighest: const Color(0xFFF4F6FA),
    outline: _ink200,
  );

  return Theme(
    data: base.copyWith(
      colorScheme: colorScheme,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: Colors.white,
        headerForegroundColor: _ink900,
        rangePickerBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        dayStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        weekdayStyle: const TextStyle(
          color: _ink800,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        yearStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        dialBackgroundColor: const Color(0xFFF4F6FA),
        dialHandColor: accent,
        dialTextColor: _ink900,
        entryModeIconColor: _ink900,
        hourMinuteColor: const Color(0xFFF4F6FA),
        hourMinuteTextColor: _ink900,
        dayPeriodColor: const Color(0xFFF4F6FA),
        dayPeriodTextColor: _ink900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

Future<DateTime?> _showWawatDatePicker({
  required BuildContext context,
  required Map<String, String> content,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required Color accent,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: WawatContent.text(content, 'picker.date_help'),
    cancelText: WawatContent.text(content, 'common.cancel'),
    confirmText: WawatContent.text(content, 'common.confirm'),
    builder: (context, child) => _wawatPickerTheme(
      context,
      child,
      accent: accent,
    ),
  );
}

Future<TimeOfDay?> _showWawatTimePicker({
  required BuildContext context,
  required Map<String, String> content,
  required TimeOfDay initialTime,
  required Color accent,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: WawatContent.text(content, 'picker.time_help'),
    cancelText: WawatContent.text(content, 'common.cancel'),
    confirmText: WawatContent.text(content, 'common.confirm'),
    builder: (context, child) => _wawatPickerTheme(
      context,
      child,
      accent: accent,
    ),
  );
}

class CreatePostScreen extends BaseScreen<CreatePostBloc> {
  final String? initialType;

  CreatePostScreen({super.key, this.initialType});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState
    extends BaseState<CreatePostScreen, CreatePostBloc> {
  String? _type;
  int _step = 0;
  bool _isSubmitting = false;

  City? _fromCity;
  City? _toCity;
  List<City> _initialCities = [];
  List<PackageType> _packageTypes = [];
  Map<String, String> _listingContent = const {};
  List<_QuickRoute> _quickRoutes = const [
    _QuickRoute('Bakı', 'Moskva'),
    _QuickRoute('Bakı', 'Dubai'),
    _QuickRoute('Gəncə', 'London'),
  ];
  final Set<String> _selectedPackages = {};
  final Map<String, String> _errors = {};

  DateTime? _flightDate;
  TimeOfDay? _flightTime;
  final _flightNumber = TextEditingController();
  final _maxWeight = TextEditingController();
  final _price = TextEditingController();
  bool _allowNegotiation = false;

  DateTime? _deliveryFrom;
  DateTime? _deliveryTo;
  final _shipmentWeight = TextEditingController();
  final _description = TextEditingController();

  ListingResponse? _successResponse;

  bool get _isTrip => _type == 'trip';

  Color get _accent => _isTrip ? _brand : _amber;

  Color get _accentSoft => _isTrip ? _brand50 : _amber50;

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _loadRefs();
    _refreshCurrentUser();
  }

  Future<void> _refreshCurrentUser() async {
    try {
      await bloc.refreshCurrentUser();
    } catch (_) {}
  }

  Future<void> _loadRefs() async {
    try {
      final citiesFuture = bloc.getCities('');
      final packagesFuture = bloc.getPackageTypes();
      final contentFuture = bloc.getListingContent();
      final routesFuture = _loadQuickRoutes();
      final cities = await citiesFuture;
      final packages = await packagesFuture;
      final content = await contentFuture;
      final routes = await routesFuture;
      if (!mounted) return;
      setState(() {
        _initialCities = cities.data;
        _packageTypes = packages.data;
        _listingContent = content;
        if (routes.isNotEmpty) {
          _quickRoutes = routes;
        }
      });
    } catch (_) {}
  }

  Future<List<_QuickRoute>> _loadQuickRoutes() async {
    try {
      final response = await bloc.getTrendingRoutes();
      final routes = _parseQuickRoutes(response.data);
      if (routes.isNotEmpty) return routes;
    } catch (_) {}

    try {
      final cities = await bloc.getPopularCities();
      if (cities.data.length < 2) return const [];
      return [
        for (var i = 0; i < cities.data.length - 1 && i < 3; i++)
          _QuickRoute(cities.data[i].name, cities.data[i + 1].name),
      ];
    } catch (_) {
      return const [];
    }
  }

  List<_QuickRoute> _parseQuickRoutes(Object? data) {
    if (data is! List) return const [];
    return data
        .map(_quickRouteFromRaw)
        .whereType<_QuickRoute>()
        .take(3)
        .toList();
  }

  _QuickRoute? _quickRouteFromRaw(Object? raw) {
    if (raw is! Map) return null;
    final from = _cityNameFromRaw(raw['from'] ?? raw['city_from']);
    final to = _cityNameFromRaw(raw['to'] ?? raw['city_to']);
    if (from == null || to == null) return null;
    return _QuickRoute(from, to);
  }

  String? _cityNameFromRaw(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    if (raw is Map) {
      final name = raw['name'] ?? raw['title'] ?? raw['label'];
      if (name is String && name.trim().isNotEmpty) return name.trim();
    }
    return null;
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: const Color(0xFFEEF1F6),
          darkBackgroundColor: const Color(0xFF101010),
          child: SizedBox.expand(
            child: _successResponse == null
                ? _buildWizard(isDark)
                : _buildSuccess(isDark, _successResponse!),
          ),
        );
      },
    );
  }

  Widget _buildWizard(bool isDark) {
    if (_type == null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _CreateHeroHeader(
              content: _listingContent,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            Transform.translate(
              offset: const Offset(0, -36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTypeSelect(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _TopBar(
          content: _listingContent,
          title: _title,
          onBack: () {
            if (_step == 0) {
              setState(() {
                _type = null;
                _clearFormFields();
              });
            } else {
              setState(() => _step--);
            }
          },
          step: _step + 1,
          accent: _accent,
          softAccent: _accentSoft,
        ),
        _Stepper(content: _listingContent, step: _step, accent: _accent),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, _step == 0 ? 20 : 16, 16, 104),
            child: _step == 0
                ? _buildRouteStep(isDark)
                : _step == 1
                    ? _buildDetailsStep(isDark)
                    : _buildPreviewStep(),
          ),
        ),
        _BottomCta(
          primaryKey: _step == 2
              ? 'create.publish'
              : _step == 1
                  ? 'create.go_preview'
                  : 'common.continue',
          primaryLabel: _step == 2
              ? (_isSubmitting
                  ? _listingText('create.publishing')
                  : _listingText('create.publish'))
              : _step == 1
                  ? _listingText('create.go_preview')
                  : _listingText('common.continue'),
          secondaryKey: _step == 2 ? 'common.edit' : null,
          secondaryLabel: _step == 2 ? _listingText('common.edit') : null,
          onPrimary: _isSubmitting ? null : _next,
          onSecondary: _step == 2 ? () => setState(() => _step = 1) : null,
        ),
      ],
    );
  }

  String get _title {
    if (_type == null) return _listingText('create.title');
    if (_step == 0) {
      return _isTrip
          ? _listingText('create.trip_title')
          : _listingText('create.shipment_title');
    }
    if (_step == 1) {
      return _isTrip
          ? _listingText('create.trip_details_title')
          : _listingText(
              'create.shipment_details_title',
            );
    }
    return _listingText('create.preview_title');
  }

  Widget _buildTypeSelect(bool isDark) {
    return StreamBuilder<User>(
      stream: bloc.userDetails,
      builder: (context, snapshot) {
        final quota = snapshot.data?.listingQuota;
        final tripQuota = quota?.trip;
        final shipmentQuota = quota?.shipmentPost;

        return Column(
          children: [
            _TypeCard(
              icon: PhosphorIconsFill.airplaneTakeoff,
              title: _listingText('create.trip_title'),
              description: _listingText(
                'create.trip_description',
              ),
              chips: [
                _listingText('create.chip.flight_date'),
                _listingText('create.chip.empty_weight'),
                _listingText('create.chip.price_per_kg'),
              ],
              accent: _brand,
              softAccent: _brand50,
              quotaLabel: _quotaLabel(tripQuota),
              quotaIsFull: tripQuota?.remaining == 0,
              onTap: () => _selectType('trip', tripQuota),
            ),
            const SizedBox(height: 12),
            _TypeCard(
              icon: PhosphorIconsFill.package,
              title: _listingText('create.shipment_title'),
              description: _listingText(
                'create.shipment_description',
              ),
              chips: [
                _listingText(
                  'create.chip.delivery_range',
                ),
                _listingText('create.chip.weight'),
                _listingText('create.chip.package_type'),
              ],
              accent: _amber,
              softAccent: _amber50,
              quotaLabel: _quotaLabel(shipmentQuota),
              quotaIsFull: shipmentQuota?.remaining == 0,
              onTap: () => _selectType('shipment_post', shipmentQuota),
            ),
            const SizedBox(height: 14),
            _InfoBox(
              text: _listingText(
                'create.moderation_notice',
              ),
              accent: _brand,
            ),
          ],
        );
      },
    );
  }

  String? _quotaLabel(ListingQuotaItem? quota) {
    if (quota == null) return null;
    if (quota.remaining <= 0) {
      return _listingText('listing.limit_reached_short');
    }
    return _listingText('listing.remaining_template')
        .replaceAll('{count}', '${quota.remaining}');
  }

  String _listingText(String key, [String? fallback]) {
    final value = _listingContent[key];
    if (value == null || value.trim().isEmpty) return fallback ?? key;
    return value;
  }

  String _enumText(String key, [String? fallback]) {
    return _listingText(key, fallback);
  }

  Future<void> _selectType(String type, [ListingQuotaItem? quota]) async {
    if (quota != null && quota.remaining <= 0) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ListingLimitGateScreen(
            type: type,
            quota: quota,
          ),
        ),
      );
      await _refreshCurrentUser();
      return;
    }
    setState(() {
      _successResponse = null;
      _type = type;
      _step = 0;
      _clearFormFields();
    });
  }

  void _clearFormFields() {
    _fromCity = null;
    _toCity = null;
    _selectedPackages.clear();
    _errors.clear();
    _flightDate = null;
    _flightTime = null;
    _deliveryFrom = null;
    _deliveryTo = null;
    _allowNegotiation = false;
    _flightNumber.clear();
    _maxWeight.clear();
    _price.clear();
    _shipmentWeight.clear();
    _description.clear();
  }

  Widget _buildRouteStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIntro(
          title: _isTrip
              ? _listingText('create.route_trip_title')
              : _listingText(
                  'create.route_shipment_title',
                ),
          subtitle: _isTrip
              ? _listingText(
                  'create.route_trip_subtitle',
                )
              : _listingText(
                  'create.route_shipment_subtitle',
                ),
        ),
        const SizedBox(height: 18),
        _RoutePickerCard(
          accent: _accent,
          from: _CityPickerTile(
            label: _listingText('search.from_placeholder'),
            city: _fromCity,
            icon: PhosphorIconsFill.circle,
            accent: _accent,
            error: _errors['city_from_id'],
            onTap: () => _pickCity(isFrom: true),
            onClear: () => setState(() => _fromCity = null),
          ),
          to: _CityPickerTile(
            label: _listingText('search.to_placeholder'),
            city: _toCity,
            icon: PhosphorIconsFill.mapPin,
            accent: _accent,
            error: _errors['city_to_id'],
            onTap: () => _pickCity(isFrom: false),
            onClear: () => setState(() => _toCity = null),
          ),
          onSwap: _swapCities,
        ),
        const SizedBox(height: 18),
        if (_isTrip)
          _QuickRoutes(
            content: _listingContent,
            routes: _quickRoutes,
            onSelected: _applyQuickRoute,
          )
        else
          _InfoBox(
            text: _listingText(
              'create.route_shipment_hint',
            ),
            accent: _amber,
          ),
      ],
    );
  }

  Widget _buildDetailsStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteSummary(
          isTrip: _isTrip,
          accent: _accent,
          softAccent: _accentSoft,
          from: _fromCity?.name ?? _listingText('search.from_placeholder'),
          to: _toCity?.name ?? _listingText('search.to_placeholder'),
          onTap: () => setState(() => _step = 0),
        ),
        const SizedBox(height: 14),
        if (_isTrip) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DateTile(
                  content: _listingContent,
                  label: _listingText('create.flight_date'),
                  value: _flightDate,
                  accent: _accent,
                  error: _errors['flight_date'],
                  onChanged: (value) => setState(() => _flightDate = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeTile(
                  content: _listingContent,
                  label: _listingText('create.flight_time'),
                  value: _flightTime,
                  accent: _accent,
                  error: _errors['flight_time'],
                  onChanged: (value) => setState(() => _flightTime = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Input(
            controller: _flightNumber,
            label: _listingText(
              'create.flight_number_label',
            ),
            hint: _listingText('create.flight_number_hint'),
            helperText: _listingText(
              'create.flight_number_helper',
            ),
            error: _errors['flight_number'],
          ),
          const SizedBox(height: 12),
          _WeightStepper(
            controller: _maxWeight,
            label: _listingText('create.empty_weight'),
            hint: '0',
            helperText: _listingText(
              'create.max_weight_helper',
            ),
            accent: _accent,
            error: _errors['max_weight_kg'],
            onMinus: () => _adjustWeight(_maxWeight, -0.5),
            onPlus: () => _adjustWeight(_maxWeight, 0.5),
          ),
          const SizedBox(height: 10),
          if (!_allowNegotiation) ...[
            _Input(
              controller: _price,
              label: _listingText(
                'create.price_per_kg_label',
              ),
              hint: '8',
              suffix: '₼ / kq',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelIcon: PhosphorIconsRegular.tag,
              error: _errors['price_per_kg'],
            ),
            _FieldHint(_listingText('create.price_helper')),
            const SizedBox(height: 10),
          ],
          _SwitchRow(
            value: _allowNegotiation,
            accent: _accent,
            label: _listingText(
              'create.allow_price_negotiation',
            ),
            onChanged: (value) => setState(() {
              _allowNegotiation = value;
              if (value) {
                _price.clear();
                _errors.remove('price_per_kg');
              }
            }),
          ),
        ] else ...[
          _FieldLabel(
              icon: PhosphorIconsRegular.calendarBlank,
              text: _listingText(
                'create.delivery_range',
              )),
          _DateRangeRow(
            content: _listingContent,
            from: _deliveryFrom,
            to: _deliveryTo,
            accent: _accent,
            fromError: _errors['delivery_date_from'],
            toError: _errors['delivery_date_to'],
            onFromChanged: (value) => setState(() => _deliveryFrom = value),
            onToChanged: (value) => setState(() => _deliveryTo = value),
          ),
          _FieldHint(_listingText(
            'create.delivery_range_helper',
          )),
          const SizedBox(height: 10),
          _WeightStepper(
            controller: _shipmentWeight,
            label: _listingText('create.package_weight'),
            hint: '2.5',
            helperText: _listingText(
              'create.package_weight_helper',
            ),
            accent: _accent,
            error: _errors['weight_kg'],
            onMinus: () => _adjustWeight(_shipmentWeight, -0.5),
            onPlus: () => _adjustWeight(_shipmentWeight, 0.5),
          ),
        ],
        const SizedBox(height: 16),
        _FieldLabel(
          icon: _isTrip
              ? PhosphorIconsRegular.archive
              : PhosphorIconsRegular.archive,
          text: _isTrip
              ? _listingText(
                  'create.accepted_packages_title',
                )
              : _listingText('create.package_type_title'),
        ),
        if (_errors['package_type_codes'] != null)
          _ErrorText(_errors['package_type_codes']!),
        if (_isTrip)
          _SelectedPackagesButton(
            content: _listingContent,
            packageTypes: _packageTypes,
            selectedCodes: _selectedPackages,
            accent: _accent,
            softAccent: _accentSoft,
            onTap: _showPackageSheet,
          )
        else
          _PackageGrid(
            packageTypes: _packageTypes,
            selectedCodes: _selectedPackages,
            accent: _accent,
            softAccent: _accentSoft,
            onToggle: _togglePackage,
          ),
        const SizedBox(height: 14),
        _Input(
          controller: _description,
          label: _listingText('create.note_label'),
          hint: _isTrip
              ? _listingText(
                  'create.trip_note_hint',
                )
              : _listingText(
                  'create.shipment_note_hint',
                ),
          maxLines: _isTrip ? 4 : 3,
          error: _errors['description'],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_description.text.length} / 2000',
            style: const TextStyle(
              color: _ink400,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(
          icon: PhosphorIconsFill.eye,
          text: _listingText('create.preview_section'),
        ),
        const SizedBox(height: 8),
        if (_isTrip)
          StreamBuilder<User>(
            stream: bloc.userDetails,
            builder: (context, snapshot) {
              return _TripPreviewCard(
                content: _listingContent,
                from: _fromCity?.name ?? 'Bakı',
                fromCountry: _fromCity?.countryName ?? 'Azərbaycan',
                to: _toCity?.name ?? 'İstanbul',
                toCountry: _toCity?.countryName ?? 'Türkiyə',
                flightDate: _flightDate,
                flightTime: _flightTime,
                maxWeight: _parseDouble(_maxWeight.text),
                price: _allowNegotiation ? null : _parseDouble(_price.text),
                allowNegotiation: _allowNegotiation,
                selectedPackages: _packageTypes
                    .where((item) => _selectedPackages.contains(item.code))
                    .toList(),
                owner: snapshot.data,
                typeLabel: _enumText('enum.listing_type.trip'),
                tierLabels: _listingContent,
              );
            },
          )
        else
          StreamBuilder<User>(
            stream: bloc.userDetails,
            builder: (context, snapshot) {
              return _ShipmentPreviewCard(
                content: _listingContent,
                from: _fromCity?.name ?? 'Gəncə',
                fromCountry: _fromCity?.countryName ?? 'Azərbaycan',
                to: _toCity?.name ?? 'Berlin',
                toCountry: _toCity?.countryName ?? 'Almaniya',
                deliveryFrom: _deliveryFrom,
                deliveryTo: _deliveryTo,
                weight: _parseDouble(_shipmentWeight.text),
                selectedPackages: _packageTypes
                    .where((item) => _selectedPackages.contains(item.code))
                    .toList(),
                owner: snapshot.data,
                typeLabel: _enumText('enum.listing_type.shipment_post'),
                tierLabels: _listingContent,
              );
            },
          ),
        const SizedBox(height: 16),
        _isTrip
            ? _PreviewInfoBanner(content: _listingContent)
            : _ShipmentInfoBanner(content: _listingContent),
      ],
    );
  }

  Widget _buildSuccess(bool isDark, ListingResponse response) {
    final matches = response.meta?.matches ?? 0;
    final displayMatches = matches > 0 ? matches : 3;
    final remaining = response.meta?.remainingListings;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 58, 24, 24),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.checkCircle,
                        color: _emerald, size: 58),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _listingText(
                      'create.success_title',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _listingText(
                      'create.success_subtitle',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _ink500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (remaining != null)
                    _ResultTile(
                      icon: PhosphorIconsFill.stack,
                      title: _listingText(
                        _isTrip
                            ? 'create.success_remaining_trip'
                            : 'create.success_remaining_shipment',
                      ).replaceAll('{count}', '$remaining'),
                      subtitle: _listingText(
                        _isTrip
                            ? 'create.success_quota_trip'
                            : 'create.success_quota_shipment',
                      ).replaceAll('{used}', '${3 - remaining}'),
                      accent: _brand,
                    ),
                  const SizedBox(height: 12),
                  _ResultTile(
                    icon: _isTrip
                        ? PhosphorIconsFill.package
                        : PhosphorIconsFill.airplaneTakeoff,
                    title: _listingText(
                      _isTrip
                          ? 'create.success_matches_shipments'
                          : 'create.success_matches_travelers',
                    ).replaceAll('{count}', '$displayMatches'),
                    subtitle:
                        '${_fromCity?.name ?? '-'} → ${_toCity?.name ?? '-'}',
                    accent: _brand,
                    highlighted: true,
                    actionLabel: _listingText(
                      _isTrip
                          ? 'create.success_view_shipments'
                          : 'create.success_view_travelers',
                    ),
                  ),
                ],
              ),
            ),
          ),
          _SuccessBottomCta(
            content: _listingContent,
            onNewListing: _reset,
            onMyListings: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DeliveryFullListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _swapCities() {
    setState(() {
      final from = _fromCity;
      _fromCity = _toCity;
      _toCity = from;
    });
  }

  Future<void> _applyQuickRoute(_QuickRoute route) async {
    final from = await _findCityByName(route.from);
    final to = await _findCityByName(route.to);
    if (!mounted) return;
    setState(() {
      _fromCity = from;
      _toCity = to;
      _errors
        ..remove('city_from_id')
        ..remove('city_to_id');
    });
  }

  void _togglePackage(PackageType item) {
    setState(() {
      _selectedPackages.contains(item.code)
          ? _selectedPackages.remove(item.code)
          : _selectedPackages.add(item.code);
      if (_selectedPackages.isNotEmpty) {
        _errors.remove('package_type_codes');
      }
    });
  }

  Future<void> _showPackageSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _PackageTypeSheet(
              packageTypes: _packageTypes,
              selectedCodes: _selectedPackages,
              accent: _accent,
              softAccent: _accentSoft,
              content: _listingContent,
              onToggle: (item) {
                _togglePackage(item);
                setSheetState(() {});
              },
            );
          },
        );
      },
    );
  }

  Future<City?> _findCityByName(String name) async {
    City? fromList(List<City> cities) {
      final normalized = _normalizeCityName(name);
      for (final city in cities) {
        if (_normalizeCityName(city.name) == normalized) return city;
      }
      return null;
    }

    final local = fromList(_initialCities);
    if (local != null) return local;

    try {
      final response = await bloc.getCities(name);
      final found = fromList(response.data);
      if (found != null) return found;
      return response.data.isNotEmpty ? response.data.first : null;
    } catch (_) {
      return null;
    }
  }

  String _normalizeCityName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ə', 'e')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c');
  }

  void _adjustWeight(TextEditingController controller, double delta) {
    final current = _parseDouble(controller.text) ?? 0;
    final next = (current + delta).clamp(0.0, 32.0);
    controller.text = next % 1 == 0 ? next.toInt().toString() : next.toString();
    setState(() {});
  }

  Future<void> _pickCity({required bool isFrom}) async {
    final selected = await showCitySelector(
      context: context,
      initialCities: _initialCities,
      selectedCity: isFrom ? _fromCity : _toCity,
      onSearch: (search) async => (await bloc.getCities(search)).data,
      isLoading: _initialCities.isEmpty,
    );
    if (!mounted) return;
    setState(() {
      if (isFrom) {
        _fromCity = selected;
      } else {
        _toCity = selected;
      }
    });
  }

  Future<void> _next() async {
    _errors.clear();
    if (_step == 0 && !_validateRoute()) return;
    if (_step == 1 && !_validateDetails()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await _submit();
  }

  bool _validateRoute() {
    if (_fromCity == null) {
      _errors['city_from_id'] = _listingText('validation.city_required');
    }
    if (_toCity == null) {
      _errors['city_to_id'] = _listingText('validation.city_required');
    }
    if (_fromCity != null && _toCity != null && _fromCity!.id == _toCity!.id) {
      _errors['city_to_id'] = _listingText(
        'validation.cities_must_differ',
      );
    }
    setState(() {});
    return _errors.isEmpty;
  }

  bool _validateDetails() {
    if (_selectedPackages.isEmpty) {
      _errors['package_type_codes'] =
          _listingText('validation.package_required');
    }
    if (_isTrip) {
      if (_flightDate == null) {
        _errors['flight_date'] = _listingText('validation.date_required');
      }
      if (_flightTime == null) {
        _errors['flight_time'] = _listingText('validation.time_required');
      }
      if (_parseDouble(_maxWeight.text) == null) {
        _errors['max_weight_kg'] = _listingText('validation.weight_required');
      }
      if (!_allowNegotiation && _parseDouble(_price.text) == null) {
        _errors['price_per_kg'] = _listingText('validation.price_required');
      }
    } else {
      if (_deliveryFrom == null) {
        _errors['delivery_date_from'] =
            _listingText('validation.date_required');
      }
      if (_deliveryTo == null) {
        _errors['delivery_date_to'] = _listingText('validation.date_required');
      }
      if (_deliveryFrom != null &&
          _deliveryTo != null &&
          _deliveryTo!.isBefore(_deliveryFrom!)) {
        _errors['delivery_date_to'] = _listingText(
          'validation.end_date_after_start',
        );
      }
      if (_parseDouble(_shipmentWeight.text) == null) {
        _errors['weight_kg'] = _listingText('validation.weight_required');
      }
    }
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await bloc.createListing(
        _request(),
        _idempotencyKey(),
      );
      if (!mounted) return;
      setState(() => _successResponse = response);
    } catch (error) {
      final parsed = bloc.parseValidationErrors(error);
      if (mounted && parsed.isNotEmpty) {
        setState(() {
          _errors
            ..clear()
            ..addAll(parsed);
          _step = parsed.keys.any(_isRouteField) ? 0 : 1;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _isRouteField(String field) {
    return field == 'city_from_id' || field == 'city_to_id';
  }

  double? _tripPriceForApi() {
    return _allowNegotiation ? 0.01 : _parseDouble(_price.text);
  }

  CreateListingRequest _request() {
    if (_isTrip) {
      return CreateListingRequest(
        type: 'trip',
        cityFromId: _fromCity!.id,
        cityToId: _toCity!.id,
        packageTypeCodes: _selectedPackages.toList(),
        flightDate: _date(_flightDate),
        flightTime: _time(_flightTime),
        flightNumber: _emptyToNull(_flightNumber.text),
        maxWeightKg: _parseDouble(_maxWeight.text),
        pricePerKg: _tripPriceForApi(),
        allowPriceNegotiation: _allowNegotiation,
        description: _emptyToNull(_description.text),
      );
    }
    return CreateListingRequest(
      type: 'shipment_post',
      cityFromId: _fromCity!.id,
      cityToId: _toCity!.id,
      packageTypeCodes: _selectedPackages.toList(),
      deliveryDateFrom: _date(_deliveryFrom),
      deliveryDateTo: _date(_deliveryTo),
      weightKg: _parseDouble(_shipmentWeight.text),
      description: _emptyToNull(_description.text),
    );
  }

  void _reset() {
    setState(() {
      _successResponse = null;
      _type = null;
      _step = 0;
      _clearFormFields();
    });
  }

  String _idempotencyKey() {
    return 'listing-${DateTime.now().microsecondsSinceEpoch}-${_type ?? 'x'}';
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  String? _date(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String? _time(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _flightNumber.dispose();
    _maxWeight.dispose();
    _price.dispose();
    _shipmentWeight.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  CreatePostBloc provideBloc() {
    return CreatePostBloc();
  }
}

class _TopBar extends StatelessWidget {
  final Map<String, String> content;
  final String title;
  final VoidCallback onBack;
  final int? step;
  final Color accent;
  final Color softAccent;

  const _TopBar({
    required this.content,
    required this.title,
    required this.onBack,
    required this.step,
    required this.accent,
    required this.softAccent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : _ink900;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x0F0F172A))),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onBack,
            child: Icon(PhosphorIconsRegular.arrowLeft, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (step != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: softAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                WawatContent.text(content, 'create.step_template')
                    .replaceAll('{step}', '$step')
                    .replaceAll('{total}', '3'),
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateHeroHeader extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onClose;

  const _CreateHeroHeader({required this.content, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 166,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F7BF4), Color(0xFF0257AE)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeroArcPainter())),
          Positioned(
            left: 20,
            right: 20,
            top: 38,
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onClose,
                  child: const Icon(PhosphorIconsBold.x,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WawatContent.text(content, 'create.title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        WawatContent.text(content, 'create.free_after_review'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArcPainter extends CustomPainter {
  const _HeroArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(-20, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.18,
        size.width + 28,
        size.height * 0.56,
      );
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.50);
    canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.66), 3.5, dotPaint);
    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.56),
      3.5,
      Paint()..color = const Color(0xFFD8E200).withValues(alpha: 0.80),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Stepper extends StatelessWidget {
  final Map<String, String> content;
  final int step;
  final Color accent;

  const _Stepper({
    required this.content,
    required this.step,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot(int index) {
      final completed = step > index;
      final active = step == index;
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: completed || active ? accent : const Color(0xFFE9EDF2),
          shape: BoxShape.circle,
        ),
        child: completed
            ? const Icon(PhosphorIconsBold.check, color: Colors.white, size: 15)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: active ? Colors.white : _ink400,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
      );
    }

    Widget line(bool active) {
      return Expanded(
        child: Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? accent : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 15, 32, 15),
      child: Column(
        children: [
          Row(
            children: [
              dot(0),
              line(step > 0),
              dot(1),
              line(step > 1),
              dot(2),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(WawatContent.text(content, 'create.step_route'),
                  style: TextStyle(
                      color: step >= 0 ? accent : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
              Text(WawatContent.text(content, 'create.step_details'),
                  style: TextStyle(
                      color: step >= 1 ? accent : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
              Text(WawatContent.text(content, 'create.step_preview'),
                  style: TextStyle(
                      color: step >= 2 ? accent : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepIntro({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink900,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _ink500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoutePickerCard extends StatelessWidget {
  final Widget from;
  final Widget to;
  final Color accent;
  final VoidCallback onSwap;

  const _RoutePickerCard({
    required this.from,
    required this.to,
    required this.accent,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              from,
              const SizedBox(height: 10),
              to,
            ],
          ),
          Positioned(
            right: 12,
            top: 46,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onSwap,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x0F0F172A)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(PhosphorIconsBold.arrowsDownUp,
                    color: accent, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickRoute {
  final String from;
  final String to;

  const _QuickRoute(this.from, this.to);

  String get label => '$from → $to';
}

class _QuickRoutes extends StatelessWidget {
  final Map<String, String> content;
  final List<_QuickRoute> routes;
  final ValueChanged<_QuickRoute> onSelected;

  const _QuickRoutes({
    required this.content,
    required this.routes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          WawatContent.text(content, 'create.quick_select'),
          style: const TextStyle(
            color: _ink500,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: routes
              .map(
                (route) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => onSelected(route),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x120F172A)),
                    ),
                    child: Text(
                      route.label,
                      style: const TextStyle(
                        color: _ink800,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RouteSummary extends StatelessWidget {
  final bool isTrip;
  final Color accent;
  final Color softAccent;
  final String from;
  final String to;
  final VoidCallback onTap;

  const _RouteSummary({
    required this.isTrip,
    required this.accent,
    required this.softAccent,
    required this.from,
    required this.to,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: softAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
                isTrip
                    ? PhosphorIconsFill.airplaneTakeoff
                    : PhosphorIconsFill.package,
                color: accent,
                size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: _RouteText(from)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(PhosphorIconsRegular.arrowRight,
                        color: accent, size: 16),
                  ),
                  Flexible(child: _RouteText(to)),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.pencilSimple,
                color: _ink400, size: 21),
          ],
        ),
      ),
    );
  }
}

class _RouteText extends StatelessWidget {
  final String text;

  const _RouteText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _ink900,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> chips;
  final Color accent;
  final Color softAccent;
  final String? quotaLabel;
  final bool quotaIsFull;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.chips,
    required this.accent,
    required this.softAccent,
    this.quotaLabel,
    this.quotaIsFull = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isDark ? Colors.white10 : const Color(0x0F0F172A)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: softAccent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : _ink900,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (quotaLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: quotaIsFull
                                ? _amber50
                                : softAccent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            quotaLabel!,
                            style: TextStyle(
                              color: quotaIsFull ? _amber : accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: _ink500,
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chips
                        .map(
                          (chip) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: softAccent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.arrowRight,
                color: _ink400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  final Color accent;

  const _InfoBox({
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.info, color: accent, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _ink500,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityPickerTile extends StatelessWidget {
  final String label;
  final City? city;
  final IconData icon;
  final Color accent;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _CityPickerTile({
    required this.label,
    required this.city,
    required this.icon,
    required this.accent,
    required this.error,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: error == null ? const Color(0x120F172A) : Colors.red),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: accent,
                    size: icon == PhosphorIconsFill.circle ? 10 : 19),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city?.name ?? label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: city == null
                              ? _ink400
                              : (isDark ? Colors.white : _ink900),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (city?.countryName.isNotEmpty == true)
                        Text(
                          city!.countryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink400,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (city != null)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onClear,
                    child: const Icon(PhosphorIconsBold.x,
                        color: _ink400, size: 18),
                  )
                else
                  const Icon(PhosphorIconsRegular.caretDown, color: _ink400),
              ],
            ),
          ),
        ),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FieldLabel({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: _ink400, size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink800,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldHint extends StatelessWidget {
  final String text;

  const _FieldHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _ink400,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  final Map<String, String> content;
  final DateTime? from;
  final DateTime? to;
  final Color accent;
  final String? fromError;
  final String? toError;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const _DateRangeRow({
    required this.content,
    required this.from,
    required this.to,
    required this.accent,
    required this.fromError,
    required this.toError,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _DateBox(
                content: content,
                value: from,
                placeholder: '05.07',
                accent: accent,
                error: fromError,
                onChanged: onFromChanged,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(PhosphorIconsRegular.arrowRight,
                  color: _ink400, size: 22),
            ),
            Expanded(
              child: _DateBox(
                content: content,
                value: to,
                placeholder: '12.07',
                accent: accent,
                error: toError,
                onChanged: onToChanged,
              ),
            ),
          ],
        ),
        if (fromError != null) _ErrorText(fromError!),
        if (toError != null) _ErrorText(toError!),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final Map<String, String> content;
  final DateTime? value;
  final String placeholder;
  final Color accent;
  final String? error;
  final ValueChanged<DateTime?> onChanged;

  const _DateBox({
    required this.content,
    required this.value,
    required this.placeholder,
    required this.accent,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final now = DateTime.now();
        final date = await _showWawatDatePicker(
          context: context,
          content: content,
          initialDate: value ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 3)),
          accent: accent,
        );
        if (date != null) onChanged(date);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: error == null ? const Color(0x120F172A) : Colors.red),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? placeholder
                    : DateFormat('dd.MM').format(value!),
                style: const TextStyle(
                  color: _ink900,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(PhosphorIconsRegular.calendarBlank,
                color: _ink400, size: 19),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final Map<String, String> content;
  final String label;
  final DateTime? value;
  final Color accent;
  final String? error;
  final ValueChanged<DateTime?> onChanged;

  const _DateTile({
    required this.content,
    required this.label,
    required this.value,
    required this.accent,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineFieldLabel(
          icon: PhosphorIconsRegular.calendarBlank,
          text: label,
        ),
        const SizedBox(height: 8),
        _FieldShell(
          label: '01.07.2026',
          value: value == null ? null : DateFormat('d MMM yyyy').format(value!),
          icon: PhosphorIconsRegular.caretDown,
          error: error,
          onTap: () async {
            final now = DateTime.now();
            final date = await _showWawatDatePicker(
              context: context,
              content: content,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now.add(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 365 * 3)),
              accent: accent,
            );
            if (date != null) onChanged(date);
          },
          onClear: value == null ? null : () => onChanged(null),
        ),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final Map<String, String> content;
  final String label;
  final TimeOfDay? value;
  final Color accent;
  final String? error;
  final ValueChanged<TimeOfDay?> onChanged;

  const _TimeTile({
    required this.content,
    required this.label,
    required this.value,
    required this.accent,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InlineFieldLabel(
          icon: PhosphorIconsRegular.clock,
          text: label,
        ),
        const SizedBox(height: 8),
        _FieldShell(
          label: '14:30',
          value: value == null
              ? null
              : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}',
          icon: PhosphorIconsRegular.caretDown,
          error: error,
          onTap: () async {
            final time = await _showWawatTimePicker(
              context: context,
              content: content,
              initialTime: value ?? TimeOfDay.now(),
              accent: accent,
            );
            if (time != null) onChanged(time);
          },
          onClear: value == null ? null : () => onChanged(null),
        ),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

class _FieldShell extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FieldShell({
    required this.label,
    required this.value,
    required this.icon,
    required this.error,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: error == null ? const Color(0x120F172A) : Colors.red),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value == null
                      ? _ink400
                      : (isDark ? Colors.white : _ink900),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClear,
                child:
                    const Icon(PhosphorIconsBold.x, color: _ink400, size: 17),
              )
            else
              Icon(icon, color: _ink400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InlineFieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InlineFieldLabel({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _ink400, size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: _ink800,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? helperText;
  final String? suffix;
  final IconData? labelIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? error;

  const _Input({
    required this.controller,
    required this.label,
    required this.hint,
    this.helperText,
    this.suffix,
    this.labelIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelIcon == null)
          _SectionTitle(label)
        else
          _FieldLabel(icon: labelIcon!, text: label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : _ink900,
            fontWeight: FontWeight.w800,
            fontSize: maxLines > 1 ? 15 : 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F6FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 18 : 14,
            ),
            hintStyle: const TextStyle(
              color: _ink400,
              fontWeight: FontWeight.w600,
            ),
            suffixStyle: const TextStyle(
              color: _ink400,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                  color: error == null ? const Color(0x120F172A) : Colors.red),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                  color: error == null ? const Color(0x120F172A) : Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: _brand),
            ),
          ),
        ),
        if (helperText != null) _FieldHint(helperText!),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

class _WeightStepper extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? helperText;
  final Color accent;
  final String? error;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _WeightStepper({
    required this.controller,
    required this.label,
    required this.hint,
    this.helperText,
    required this.accent,
    required this.error,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, valueState, _) {
        final value =
            double.tryParse(valueState.text.replaceAll(',', '.')) ?? 0;
        final canDecrease = value > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(icon: PhosphorIconsRegular.scales, text: label),
            Row(
              children: [
                _RoundStepButton(
                  icon: PhosphorIconsRegular.minus,
                  color: canDecrease
                      ? accent.withValues(alpha: 0.10)
                      : const Color(0xFFE7E8EE),
                  iconColor: canDecrease ? accent : _ink800,
                  onTap: onMinus,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      suffixText: 'kq',
                      filled: true,
                      fillColor: const Color(0xFFF4F6FA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      suffixStyle: const TextStyle(
                        color: _ink400,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: error == null
                              ? const Color(0x120F172A)
                              : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: error == null
                              ? const Color(0x120F172A)
                              : Colors.red,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _RoundStepButton(
                  icon: PhosphorIconsRegular.plus,
                  color: accent.withValues(alpha: 0.10),
                  iconColor: accent,
                  onTap: onPlus,
                ),
              ],
            ),
            if (helperText != null) _FieldHint(helperText!),
            if (error != null) _ErrorText(error!),
          ],
        );
      },
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoundStepButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final bool value;
  final Color accent;
  final String label;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.value,
    required this.accent,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x080F172A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsFill.handshake, color: accent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _ink800,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? accent : _ink200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : _ink900,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PackageGrid extends StatelessWidget {
  final List<PackageType> packageTypes;
  final Set<String> selectedCodes;
  final Color accent;
  final Color softAccent;
  final ValueChanged<PackageType> onToggle;

  const _PackageGrid({
    required this.packageTypes,
    required this.selectedCodes,
    required this.accent,
    required this.softAccent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (packageTypes.isEmpty) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(color: _brand)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 2;
        return Wrap(
          spacing: 20,
          runSpacing: 14,
          children: packageTypes.map((item) {
            final selected = selectedCodes.contains(item.code);
            return SizedBox(
              width: itemWidth,
              child: _PackageChip(
                icon: _packageIconFor(item),
                label: item.name,
                selected: selected,
                accent: accent,
                softAccent: softAccent,
                onTap: () => onToggle(item),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SelectedPackagesButton extends StatelessWidget {
  final Map<String, String> content;
  final List<PackageType> packageTypes;
  final Set<String> selectedCodes;
  final Color accent;
  final Color softAccent;
  final VoidCallback onTap;

  const _SelectedPackagesButton({
    required this.content,
    required this.packageTypes,
    required this.selectedCodes,
    required this.accent,
    required this.softAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = packageTypes
        .where((item) => selectedCodes.contains(item.code))
        .take(2)
        .toList();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x120F172A)),
        ),
        child: Row(
          children: [
            Expanded(
              child: selected.isEmpty
                  ? Text(
                      WawatContent.text(content, 'create.package_select'),
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (var i = 0; i < selected.length; i++) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_packageIconFor(selected[i]),
                                  color: accent, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                selected[i].name,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          if (i != selected.length - 1)
                            const Text(
                              '·',
                              style: TextStyle(
                                color: _ink400,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
            if (selectedCodes.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: softAccent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  WawatContent.text(content, 'create.package_selected_count')
                      .replaceAll('{count}', '${selectedCodes.length}'),
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              Icon(PhosphorIconsRegular.caretDown, color: accent, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TripPreviewCard extends StatelessWidget {
  final Map<String, String> content;
  final String from;
  final String fromCountry;
  final String to;
  final String toCountry;
  final DateTime? flightDate;
  final TimeOfDay? flightTime;
  final double? maxWeight;
  final double? price;
  final bool allowNegotiation;
  final List<PackageType> selectedPackages;
  final User? owner;
  final String typeLabel;
  final Map<String, String> tierLabels;

  const _TripPreviewCard({
    required this.content,
    required this.from,
    required this.fromCountry,
    required this.to,
    required this.toCountry,
    required this.flightDate,
    required this.flightTime,
    required this.maxWeight,
    required this.price,
    required this.allowNegotiation,
    required this.selectedPackages,
    required this.owner,
    required this.typeLabel,
    required this.tierLabels,
  });

  @override
  Widget build(BuildContext context) {
    final weightText = _formatNumber(maxWeight ?? 0);
    final ownerName = _userDisplayName(owner);
    final ownerInitials = _userInitials(ownerName);
    final ownerTier = _userTierLabel(owner?.tier, tierLabels);
    final ownerRating =
        owner?.ratingAvg ?? owner?.stats?.ratingAvg ?? owner?.rating?.average;
    final ownerRatingCount =
        owner?.ratingCount ?? owner?.stats?.ratingCount ?? owner?.rating?.count;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0F0F172A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _brand50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsFill.airplaneTakeoff,
                        color: _brand, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      typeLabel.toUpperCase(),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(PhosphorIconsRegular.heart, color: _ink200, size: 28),
            ],
          ),
          const SizedBox(height: 28),
          _PreviewRoute(
            from: from,
            fromCountry: fromCountry,
            to: to,
            toCountry: toCountry,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DateTimePill(
                  flightDate: flightDate,
                  flightTime: flightTime,
                ),
              ),
              const Spacer(),
              if (allowNegotiation)
                Text(
                  WawatContent.text(content, 'create.negotiable'),
                  style: const TextStyle(
                    color: _brand,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                Text.rich(
                  TextSpan(
                    text: _formatNumber(price ?? 0),
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    children: const [
                      TextSpan(text: ' ₼', style: TextStyle(fontSize: 20)),
                      TextSpan(
                        text: '/kq',
                        style: TextStyle(
                          color: _ink400,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selectedPackages.map((item) {
                return _PreviewChip(label: item.name);
              }),
              if ((maxWeight ?? 0) > 0)
                _PreviewChip(
                  label: '$weightText kq',
                  icon: PhosphorIconsRegular.scales,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x0F0F172A)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFCFE3FD),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  ownerInitials,
                  style: const TextStyle(
                    color: Color(0xFF024FA3),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ownerName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink900,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (owner?.isVerified == true) ...[
                          const SizedBox(width: 5),
                          const Icon(PhosphorIconsFill.sealCheck,
                              color: _brand, size: 18),
                        ],
                        if (ownerTier != null) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              ownerTier,
                              style: const TextStyle(
                                color: _ink500,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (ownerRating != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(PhosphorIconsFill.star,
                              color: Color(0xFFF59E0B), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(ownerRating),
                            style: const TextStyle(
                              color: _ink800,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (ownerRatingCount != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($ownerRatingCount)',
                              style: const TextStyle(
                                color: _ink500,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _userDisplayName(User? user) {
    if (user == null) return 'Siz';
    final fullName = user.fullname.trim();
    if (fullName.isNotEmpty) return fullName;
    final name = [user.firstName, user.lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) return name;
    if (user.username != null && user.username!.trim().isNotEmpty) {
      return user.username!;
    }
    return 'Siz';
  }

  String _userInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty || name == 'Siz') return 'S';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _PreviewChip({
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x0A0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _ink500, size: 15),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: _ink500,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentPreviewCard extends StatelessWidget {
  final Map<String, String> content;
  final String from;
  final String fromCountry;
  final String to;
  final String toCountry;
  final DateTime? deliveryFrom;
  final DateTime? deliveryTo;
  final double? weight;
  final List<PackageType> selectedPackages;
  final User? owner;
  final String typeLabel;
  final Map<String, String> tierLabels;

  const _ShipmentPreviewCard({
    required this.content,
    required this.from,
    required this.fromCountry,
    required this.to,
    required this.toCountry,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.weight,
    required this.selectedPackages,
    required this.owner,
    required this.typeLabel,
    required this.tierLabels,
  });

  @override
  Widget build(BuildContext context) {
    final weightText = _formatNumber(weight ?? 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0F0F172A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _amber50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsFill.package,
                        color: _amber, size: 16),
                    const SizedBox(width: 7),
                    Text(
                      typeLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(PhosphorIconsRegular.heart, color: _ink200, size: 28),
            ],
          ),
          const SizedBox(height: 28),
          _PreviewRoute(
            from: from,
            fromCountry: fromCountry,
            to: to,
            toCountry: toCountry,
            accent: _amber,
            softAccent: _amber50,
            icon: PhosphorIconsFill.package,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _PreviewChip(
                label: _shipmentDateRange(deliveryFrom, deliveryTo),
                icon: PhosphorIconsRegular.calendarBlank,
              ),
              if ((weight ?? 0) > 0)
                _PreviewChip(
                  label: '$weightText kq',
                  icon: PhosphorIconsRegular.scales,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedPackages
                .map((item) => _PreviewChip(label: item.name))
                .toList(),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x0F0F172A)),
          const SizedBox(height: 14),
          _PreviewOwnerRow(owner: owner, tierLabels: tierLabels),
        ],
      ),
    );
  }

  String _shipmentDateRange(DateTime? from, DateTime? to) {
    if (from == null || to == null) return '5–12 İyul';
    final month = _azMonth(to.month);
    return '${from.day}–${to.day} $month';
  }
}

class _PreviewOwnerRow extends StatelessWidget {
  final User? owner;
  final Map<String, String> tierLabels;

  const _PreviewOwnerRow({
    required this.owner,
    required this.tierLabels,
  });

  @override
  Widget build(BuildContext context) {
    final ownerName = _userDisplayName(owner);
    final ownerInitials = _userInitials(ownerName);
    final ownerTier = _userTierLabel(owner?.tier, tierLabels);
    final ownerRating =
        owner?.ratingAvg ?? owner?.stats?.ratingAvg ?? owner?.rating?.average;
    final ownerRatingCount =
        owner?.ratingCount ?? owner?.stats?.ratingCount ?? owner?.rating?.count;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFCFE3FD),
            shape: BoxShape.circle,
          ),
          child: Text(
            ownerInitials,
            style: const TextStyle(
              color: Color(0xFF024FA3),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink900,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (owner?.isVerified == true) ...[
                    const SizedBox(width: 5),
                    const Icon(PhosphorIconsFill.sealCheck,
                        color: _brand, size: 18),
                  ],
                  if (ownerTier != null) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        ownerTier,
                        style: const TextStyle(
                          color: _ink500,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (ownerRating != null) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(PhosphorIconsFill.star,
                        color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(ownerRating),
                      style: const TextStyle(
                        color: _ink800,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (ownerRatingCount != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '($ownerRatingCount)',
                        style: const TextStyle(
                          color: _ink500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewRoute extends StatelessWidget {
  final String from;
  final String fromCountry;
  final String to;
  final String toCountry;
  final Color accent;
  final Color softAccent;
  final IconData icon;

  const _PreviewRoute({
    required this.from,
    required this.fromCountry,
    required this.to,
    required this.toCountry,
    this.accent = _brand,
    this.softAccent = _brand50,
    this.icon = PhosphorIconsFill.airplaneTilt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PreviewCity(
            city: from,
            country: fromCountry,
            align: CrossAxisAlignment.end,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: _RouteDots(
            accent: accent,
            softAccent: softAccent,
            icon: icon,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PreviewCity(
            city: to,
            country: toCountry,
            align: CrossAxisAlignment.start,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _PreviewCity extends StatelessWidget {
  final String city;
  final String country;
  final CrossAxisAlignment align;
  final TextAlign textAlign;

  const _PreviewCity({
    required this.city,
    required this.country,
    required this.align,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: const TextStyle(
            color: _ink900,
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          country,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: const TextStyle(
            color: _ink400,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RouteDots extends StatelessWidget {
  final Color accent;
  final Color softAccent;
  final IconData icon;

  const _RouteDots({
    required this.accent,
    required this.softAccent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        Container(
          width: 14,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: accent.withValues(alpha: 0.28),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: softAccent, shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 16),
        ),
        Container(
          width: 14,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: accent.withValues(alpha: 0.28), width: 2),
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 2),
          ),
        ),
      ],
    );
  }
}

class _DateTimePill extends StatelessWidget {
  final DateTime? flightDate;
  final TimeOfDay? flightTime;

  const _DateTimePill({
    required this.flightDate,
    required this.flightTime,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        flightDate == null ? '15 Jul' : DateFormat('d MMM').format(flightDate!);
    final time = flightTime == null
        ? '17:10'
        : '${flightTime!.hour.toString().padLeft(2, '0')}:${flightTime!.minute.toString().padLeft(2, '0')}';
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _brand50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.calendarDots, color: _brand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: date,
                style: const TextStyle(
                  color: _ink900,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text: ' · $time',
                    style: const TextStyle(color: _brand),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewInfoBanner extends StatelessWidget {
  final Map<String, String> content;

  const _PreviewInfoBanner({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _brand50.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(PhosphorIconsFill.shieldCheck, color: _brand, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: WawatContent.text(
                  content,
                  'create.preview_moderation_prefix',
                ),
                children: [
                  TextSpan(
                    text: WawatContent.text(
                      content,
                      'create.preview_moderation_bold',
                    ),
                    style: const TextStyle(color: _ink900),
                  ),
                  TextSpan(
                    text: WawatContent.text(
                      content,
                      'create.preview_moderation_suffix',
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                color: _ink500,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentInfoBanner extends StatelessWidget {
  final Map<String, String> content;

  const _ShipmentInfoBanner({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _amber50.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(PhosphorIconsFill.info, color: _amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: WawatContent.text(
                  content,
                  'create.preview_shipment_price_prefix',
                ),
                children: [
                  TextSpan(
                    text: WawatContent.text(
                      content,
                      'create.preview_shipment_price_bold',
                    ),
                    style: const TextStyle(color: _ink900),
                  ),
                  TextSpan(
                    text: WawatContent.text(
                      content,
                      'create.preview_shipment_price_suffix',
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                color: _ink500,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTypeSheet extends StatelessWidget {
  final List<PackageType> packageTypes;
  final Set<String> selectedCodes;
  final Color accent;
  final Color softAccent;
  final ValueChanged<PackageType> onToggle;
  final Map<String, String> content;

  const _PackageTypeSheet({
    required this.packageTypes,
    required this.selectedCodes,
    required this.accent,
    required this.softAccent,
    required this.onToggle,
    this.content = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 6,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  WawatContent.text(
                    content,
                    'create.package_type_title',
                  ),
                  style: const TextStyle(
                    color: _ink900,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                WawatContent.text(content, 'create.package_min_one'),
                style: const TextStyle(
                  color: _ink400,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            WawatContent.text(
              content,
              'create.package_sheet_subtitle',
            ),
            style: const TextStyle(
              color: _ink500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packageTypes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.95,
            ),
            itemBuilder: (context, index) {
              final item = packageTypes[index];
              final selected = selectedCodes.contains(item.code);
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onToggle(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected ? softAccent : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? accent : const Color(0x120F172A),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _packageIconFor(item),
                        color: selected ? accent : _ink500,
                        size: 21,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? accent : _ink800,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(PhosphorIconsFill.checkCircle,
                            color: accent, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _PrimaryAction(
            label: WawatContent.text(
              content,
              'create.package_confirm',
            ).replaceAll('{count}', '${selectedCodes.length}'),
            accent: accent,
            onTap: selectedCodes.isEmpty
                ? null
                : () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

IconData _packageIconFor(PackageType item) {
  final code = item.code.toLowerCase();
  final name = item.name.toLowerCase();
  if (code.contains('doc') || name.contains('sənəd')) {
    return PhosphorIconsFill.fileText;
  }
  if (code.contains('elect') || name.contains('elektr')) {
    return PhosphorIconsRegular.deviceMobile;
  }
  if (code.contains('food') || name.contains('qida')) {
    return PhosphorIconsRegular.forkKnife;
  }
  if (code.contains('cloth') || name.contains('geyim')) {
    return PhosphorIconsRegular.shoppingBag;
  }
  if (code.contains('small') || name.contains('kiçik')) {
    return PhosphorIconsRegular.cube;
  }
  return PhosphorIconsRegular.dotsThreeCircle;
}

class _PackageChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final Color softAccent;
  final VoidCallback onTap;

  const _PackageChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.softAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? softAccent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? accent : const Color(0x120F172A),
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? accent : _ink800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? accent : _ink800,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (selected)
              Icon(PhosphorIconsFill.checkCircle, color: accent, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String primaryKey;
  final String primaryLabel;
  final String? secondaryKey;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const _BottomCta({
    required this.primaryKey,
    required this.primaryLabel,
    required this.secondaryKey,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
              color: isDark ? Colors.white10 : const Color(0x0F0F172A)),
        ),
      ),
      child: Row(
        children: [
          if (secondaryLabel != null) ...[
            Expanded(
              flex: 10,
              child: _SecondaryAction(
                label: secondaryLabel!,
                icon: _secondaryCtaIcon(secondaryKey!),
                onTap: onSecondary!,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: secondaryLabel != null ? 16 : 1,
            child: _PrimaryAction(
              label: primaryLabel,
              icon: _primaryCtaIcon(primaryKey),
              accent: _brand,
              onTap: onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  IconData? _primaryCtaIcon(String key) {
    if (key == 'create.publish') return PhosphorIconsBold.paperPlaneTilt;
    if (key == 'create.success_my_listings') {
      return PhosphorIconsBold.listBullets;
    }
    if (key == 'create.go_preview') return PhosphorIconsRegular.arrowRight;
    return null;
  }

  IconData? _secondaryCtaIcon(String key) {
    if (key == 'common.edit') return PhosphorIconsBold.pencilSimple;
    if (key == 'create.success_new_listing') return PhosphorIconsBold.plus;
    return null;
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color accent;
  final VoidCallback? onTap;

  const _PrimaryAction({
    required this.label,
    this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _brand50,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: _ink500, size: 19),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: _ink500,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBottomCta extends StatelessWidget {
  final VoidCallback onNewListing;
  final VoidCallback onMyListings;
  final Map<String, String> content;

  const _SuccessBottomCta({
    required this.onNewListing,
    required this.onMyListings,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0x0F0F172A)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SuccessCtaButton(
              label: WawatContent.text(content, 'create.success_new_listing'),
              icon: PhosphorIconsBold.plus,
              background: const Color(0x0A0F172A),
              foreground: _ink500,
              onTap: onNewListing,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SuccessCtaButton(
              label: WawatContent.text(content, 'create.success_my_listings'),
              icon: PhosphorIconsBold.listBullets,
              background: _brand50,
              foreground: _brand,
              onTap: onMyListings,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SuccessCtaButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool highlighted;
  final String? actionLabel;

  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.highlighted = false,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(highlighted ? 16 : 14),
      decoration: BoxDecoration(
        color: highlighted
            ? _brand50
            : (isDark ? const Color(0xFF1E1E1E) : const Color(0x080F172A)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? _brand.withValues(alpha: 0.25)
              : (isDark ? Colors.white10 : const Color(0x0F0F172A)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: highlighted ? 46 : 40,
                height: highlighted ? 46 : 40,
                decoration: BoxDecoration(
                  color: highlighted ? accent : Colors.white,
                  borderRadius: BorderRadius.circular(highlighted ? 16 : 12),
                  boxShadow: highlighted
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  color: highlighted ? Colors.white : accent,
                  size: highlighted ? 22 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : _ink900,
                        fontSize: highlighted ? 14 : 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _ink500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _brand,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.arrowRight,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;

  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
