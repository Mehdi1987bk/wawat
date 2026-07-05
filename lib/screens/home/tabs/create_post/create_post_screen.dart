import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/request/create_listing_request.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/package_types_response.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../services/theme_aware_screen.dart';
import '../../../../services/theme_manager.dart';
import '../home_tab/widget/city_selector.dart';
import '../listings/widgets/listing_card.dart';
import 'create_post_bloc.dart';

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

class CreatePostScreen extends BaseScreen<CreatePostBloc> {
  CreatePostScreen({super.key});

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
    _loadRefs();
  }

  Future<void> _loadRefs() async {
    try {
      final cities = await bloc.getCities('');
      final packages = await bloc.getPackageTypes();
      if (!mounted) return;
      setState(() {
        _initialCities = cities.data;
        _packageTypes = packages.data;
      });
    } catch (_) {}
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
            _CreateHeroHeader(onClose: () => Navigator.of(context).maybePop()),
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
          title: _title,
          onBack: () {
            if (_step == 0) {
              setState(() => _type = null);
            } else {
              setState(() => _step--);
            }
          },
          step: _step + 1,
          accent: _accent,
          softAccent: _accentSoft,
        ),
        _Stepper(step: _step, accent: _accent),
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
          primaryLabel: _step == 2
              ? (_isSubmitting ? 'Dərc olunur...' : 'Dərc et')
              : _step == 1
                  ? 'Önizləməyə keç'
                  : 'Davam et',
          secondaryLabel: _step == 2 ? 'Düzəliş' : null,
          onPrimary: _isSubmitting ? null : _next,
          onSecondary: _step == 2 ? () => setState(() => _step = 1) : null,
        ),
      ],
    );
  }

  String get _title {
    if (_type == null) return 'Yeni elan';
    if (_step == 0) return _isTrip ? 'Səfər elanı' : 'Göndəriş elanı';
    if (_step == 1) return _isTrip ? 'Səfər detalları' : 'Göndəriş detalları';
    return 'Önizləmə';
  }

  Widget _buildTypeSelect(bool isDark) {
    return Column(
      children: [
        _TypeCard(
          icon: Icons.flight_takeoff,
          title: 'Səfər elanı',
          description:
              'Səyahət edirəm, çantamda yer var — çəki və qiymət təyin edirəm.',
          chips: const ['Uçuş tarixi', 'Boş çəki', '1 kq qiyməti'],
          accent: _brand,
          softAccent: _brand50,
          onTap: () => setState(() {
            _type = 'trip';
            _step = 0;
            _errors.clear();
          }),
        ),
        const SizedBox(height: 12),
        _TypeCard(
          icon: Icons.inventory_2,
          title: 'Göndəriş elanı',
          description:
              'Bağlamam var, aparacaq səyahətçi axtarıram — çatdırılma aralığı seçirəm.',
          chips: const ['Çatdırılma aralığı', 'Çəki', 'Bağlama növü'],
          accent: _amber,
          softAccent: _amber50,
          onTap: () => setState(() {
            _type = 'shipment_post';
            _step = 0;
            _errors.clear();
          }),
        ),
        const SizedBox(height: 14),
        _InfoBox(
          text:
              'Elanın moderasiyadan keçdikdən sonra Kəşf lentində görünür. Qadağan olunmuş məzmun avtomatik yoxlanılır.',
          accent: _brand,
        ),
      ],
    );
  }

  Widget _buildRouteStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIntro(
          title: _isTrip ? 'Haradan hara uçursan?' : 'Bağlama haradan hara?',
          subtitle: _isTrip
              ? 'Şəhərləri seç — sistem uyğun göndərişləri tapacaq.'
              : 'Göndərmək istədiyin marşrutu seç.',
        ),
        const SizedBox(height: 18),
        _RoutePickerCard(
          accent: _accent,
          from: _CityPickerTile(
            label: 'Haradan',
            city: _fromCity,
            icon: Icons.circle,
            accent: _accent,
            error: _errors['city_from_id'],
            onTap: () => _pickCity(isFrom: true),
            onClear: () => setState(() => _fromCity = null),
          ),
          to: _CityPickerTile(
            label: 'Hara',
            city: _toCity,
            icon: Icons.location_on,
            accent: _accent,
            error: _errors['city_to_id'],
            onTap: () => _pickCity(isFrom: false),
            onClear: () => setState(() => _toCity = null),
          ),
          onSwap: _swapCities,
        ),
        const SizedBox(height: 18),
        if (_isTrip)
          const _QuickRoutes(
            routes: ['Bakı → Moskva', 'Bakı → Dubai', 'Gəncə → London'],
          )
        else
          _InfoBox(
            text:
                'Bu marşrutda yaxın tarixlərdə uyğun səyahətçilər tapıla bilər.',
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
          from: _fromCity?.name ?? 'Haradan',
          to: _toCity?.name ?? 'Hara',
          onTap: () => setState(() => _step = 0),
        ),
        const SizedBox(height: 14),
        if (_isTrip) ...[
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Uçuş tarixi',
                  value: _flightDate,
                  accent: _accent,
                  error: _errors['flight_date'],
                  onChanged: (value) => setState(() => _flightDate = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeTile(
                  label: 'Saat',
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
            label: 'Reys nömrəsi · istəyə bağlı',
            hint: 'məs. J2 5432',
            error: _errors['flight_number'],
          ),
          const SizedBox(height: 12),
          _WeightStepper(
            controller: _maxWeight,
            label: 'Boş çəki',
            hint: 'Aparacağın maksimum çəki — limit 32 kq.',
            accent: _accent,
            error: _errors['max_weight_kg'],
            onMinus: () => _adjustWeight(_maxWeight, -0.5),
            onPlus: () => _adjustWeight(_maxWeight, 0.5),
          ),
          const SizedBox(height: 10),
          _Input(
            controller: _price,
            label: 'Qiymət (1 kq üçün)',
            hint: '8',
            suffix: '₼ / kq',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            error: _errors['price_per_kg'],
          ),
          const _FieldHint('Maksimum 99 ₼/kq.'),
          const SizedBox(height: 10),
          _SwitchRow(
            value: _allowNegotiation,
            accent: _accent,
            label: 'Qiymətdə danışıq olar',
            onChanged: (value) => setState(() => _allowNegotiation = value),
          ),
        ] else ...[
          _FieldLabel(icon: Icons.calendar_month, text: 'Çatdırılma aralığı'),
          _DateRangeRow(
            from: _deliveryFrom,
            to: _deliveryTo,
            accent: _accent,
            fromError: _errors['delivery_date_from'],
            toError: _errors['delivery_date_to'],
            onFromChanged: (value) => setState(() => _deliveryFrom = value),
            onToChanged: (value) => setState(() => _deliveryTo = value),
          ),
          const _FieldHint('Bağlamanın çatması üçün uyğun tarix aralığı.'),
          const SizedBox(height: 10),
          _WeightStepper(
            controller: _shipmentWeight,
            label: 'Bağlamanın çəkisi',
            hint: '2.5',
            accent: _accent,
            error: _errors['weight_kg'],
            onMinus: () => _adjustWeight(_shipmentWeight, -0.5),
            onPlus: () => _adjustWeight(_shipmentWeight, 0.5),
          ),
          const _FieldHint('Təxmini çəki — limit 32 kq.'),
        ],
        const SizedBox(height: 16),
        _FieldLabel(
          icon: Icons.inventory_2_outlined,
          text: _isTrip ? 'Hansı bağlamaları götürürsən?' : 'Bağlama növü',
        ),
        if (_errors['package_type_codes'] != null)
          _ErrorText(_errors['package_type_codes']!),
        _PackageGrid(
          packageTypes: _packageTypes,
          selectedCodes: _selectedPackages,
          accent: _accent,
          softAccent: _accentSoft,
          onToggle: (item) {
            setState(() {
              _selectedPackages.contains(item.code)
                  ? _selectedPackages.remove(item.code)
                  : _selectedPackages.add(item.code);
            });
          },
        ),
        const SizedBox(height: 14),
        _Input(
          controller: _description,
          label: 'Qeyd · istəyə bağlı',
          hint: _isTrip
              ? 'Nə götürə bilərsən, şərtlər, əlaqə vaxtı...'
              : 'Bağlama haqqında, kövrəklik, əlaqə...',
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
    final preview = _previewListing();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(
            icon: Icons.visibility, text: 'Elanın belə görünəcək'),
        const SizedBox(height: 8),
        ListingCard(
          listing: preview,
          packageNamesByCode: {
            for (final item in _packageTypes) item.code: item.name,
          },
          isCompact: false,
          actionsEnabled: false,
        ),
        _InfoBox(
          text: _isTrip
              ? 'Dərc etdikdən sonra elan moderasiyaya düşür və təsdiqləndikdə lentdə görünür.'
              : 'Göndəriş elanında qiymət yoxdur — səyahətçilər sənə təklif göndərəcək.',
          accent: _accent,
        ),
      ],
    );
  }

  Widget _buildSuccess(bool isDark, ListingResponse response) {
    final matches = response.meta?.matches ?? 0;
    final remaining = response.meta?.remainingListings;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 58, 20, 24),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: _emerald, size: 58),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Elan yoxlanışa göndərildi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink900,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Moderasiyadan keçdikdən sonra Kəşf lentində görünəcək — adətən bir neçə dəqiqə çəkir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (remaining != null)
                    _ResultTile(
                      icon: Icons.layers,
                      title:
                          'Daha $remaining ${_isTrip ? 'səfər' : 'göndəriş'} elanı yarada bilərsən',
                      subtitle: 'Limit server cavabından götürüldü',
                      accent: _brand,
                    ),
                  const SizedBox(height: 12),
                  _ResultTile(
                    icon: matches > 0
                        ? (_isTrip ? Icons.inventory_2 : Icons.flight_takeoff)
                        : Icons.notifications_active,
                    title: matches > 0
                        ? '$matches ${_isTrip ? 'göndəriş' : 'səyahətçi'} səni gözləyir'
                        : 'Hələ uyğun elan yoxdur',
                    subtitle:
                        '${_fromCity?.name ?? '-'} → ${_toCity?.name ?? '-'}',
                    accent: matches > 0 ? _brand : _ink500,
                    highlighted: matches > 0,
                  ),
                ],
              ),
            ),
          ),
          _BottomCta(
            primaryLabel: 'Elanlarım',
            secondaryLabel: 'Yeni elan',
            onPrimary: () {
              Navigator.of(context).maybePop();
            },
            onSecondary: _reset,
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
    if (_fromCity == null) _errors['city_from_id'] = 'Şəhər seç';
    if (_toCity == null) _errors['city_to_id'] = 'Şəhər seç';
    if (_fromCity != null && _toCity != null && _fromCity!.id == _toCity!.id) {
      _errors['city_to_id'] = 'Şəhərlər fərqli olmalıdır';
    }
    setState(() {});
    return _errors.isEmpty;
  }

  bool _validateDetails() {
    if (_selectedPackages.isEmpty) {
      _errors['package_type_codes'] = 'Ən azı bir növ seç';
    }
    if (_isTrip) {
      if (_flightDate == null) _errors['flight_date'] = 'Tarix seç';
      if (_flightTime == null) _errors['flight_time'] = 'Saat seç';
      if (_parseDouble(_maxWeight.text) == null) {
        _errors['max_weight_kg'] = 'Çəki yaz';
      }
      if (_parseDouble(_price.text) == null) {
        _errors['price_per_kg'] = 'Qiymət yaz';
      }
    } else {
      if (_deliveryFrom == null) _errors['delivery_date_from'] = 'Tarix seç';
      if (_deliveryTo == null) _errors['delivery_date_to'] = 'Tarix seç';
      if (_deliveryFrom != null &&
          _deliveryTo != null &&
          _deliveryTo!.isBefore(_deliveryFrom!)) {
        _errors['delivery_date_to'] = 'Son tarix başlanğıcdan sonra olmalıdır';
      }
      if (_parseDouble(_shipmentWeight.text) == null) {
        _errors['weight_kg'] = 'Çəki yaz';
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
        pricePerKg: _parseDouble(_price.text),
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

  Listing _previewListing() {
    return Listing(
      id: 'preview',
      type: _type!,
      typeLabel: _isTrip ? 'Səfər' : 'Göndəriş',
      status: 'moderation',
      statusLabel: 'Moderasiyada',
      cityFrom: _fromCity?.name,
      cityTo: _toCity?.name,
      packageTypeCodes: _selectedPackages.toList(),
      description: _emptyToNull(_description.text),
      flightDate: _date(_flightDate),
      flightTime: _time(_flightTime),
      flightNumber: _emptyToNull(_flightNumber.text),
      maxWeightKg: _parseDouble(_maxWeight.text),
      reservedKg: 0,
      pricePerKg: _parseDouble(_price.text),
      allowPriceNegotiation: _allowNegotiation,
      deliveryDateFrom: _date(_deliveryFrom),
      deliveryDateTo: _date(_deliveryTo),
      weightKg: _parseDouble(_shipmentWeight.text),
    );
  }

  void _reset() {
    setState(() {
      _successResponse = null;
      _type = null;
      _step = 0;
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
  final String title;
  final VoidCallback onBack;
  final int? step;
  final Color accent;
  final Color softAccent;

  const _TopBar({
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
            child: Icon(Icons.arrow_back, color: color, size: 24),
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
                'Addım $step/3',
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
  final VoidCallback onClose;

  const _CreateHeroHeader({required this.onClose});

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
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeni elan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pulsuz · yoxlanışdan sonra dərc olunur',
                        style: TextStyle(
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
  final int step;
  final Color accent;

  const _Stepper({required this.step, required this.accent});

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
            ? const Icon(Icons.check, color: Colors.white, size: 15)
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
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
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
              Text('Marşrut',
                  style: TextStyle(
                      color: step >= 0 ? accent : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
              Text('Detallar',
                  style: TextStyle(
                      color: step >= 1 ? accent : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
              Text('Önizləmə',
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
                child: Icon(Icons.swap_vert, color: accent, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickRoutes extends StatelessWidget {
  final List<String> routes;

  const _QuickRoutes({required this.routes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tez seçim',
          style: TextStyle(
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
                (route) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x120F172A)),
                  ),
                  child: Text(
                    route,
                    style: const TextStyle(
                      color: _ink800,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: softAccent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Icon(isTrip ? Icons.flight_takeoff : Icons.inventory_2,
                color: accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: _RouteText(from)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward, color: accent, size: 20),
                  ),
                  Flexible(child: _RouteText(to)),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: _ink400, size: 22),
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
        fontSize: 15,
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
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.chips,
    required this.accent,
    required this.softAccent,
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
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : _ink900,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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
            const Icon(Icons.arrow_forward, color: _ink400, size: 20),
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
          Icon(Icons.info, color: accent, size: 18),
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
                Icon(icon, color: accent, size: icon == Icons.circle ? 10 : 19),
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
                    child: const Icon(Icons.close, color: _ink400, size: 18),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down, color: _ink400),
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
                fontSize: 16,
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
  final DateTime? from;
  final DateTime? to;
  final Color accent;
  final String? fromError;
  final String? toError;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const _DateRangeRow({
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
                value: from,
                placeholder: '05.07',
                error: fromError,
                onChanged: onFromChanged,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: _ink400, size: 22),
            ),
            Expanded(
              child: _DateBox(
                value: to,
                placeholder: '12.07',
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
  final DateTime? value;
  final String placeholder;
  final String? error;
  final ValueChanged<DateTime?> onChanged;

  const _DateBox({
    required this.value,
    required this.placeholder,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 3)),
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
            const Icon(Icons.calendar_month_outlined, color: _ink400, size: 19),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Color accent;
  final String? error;
  final ValueChanged<DateTime?> onChanged;

  const _DateTile({
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
        _FieldShell(
          label: label,
          value: value == null ? null : DateFormat('d MMM yyyy').format(value!),
          icon: Icons.calendar_month,
          error: error,
          onTap: () async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now.add(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 365 * 3)),
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
  final String label;
  final TimeOfDay? value;
  final Color accent;
  final String? error;
  final ValueChanged<TimeOfDay?> onChanged;

  const _TimeTile({
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
        _FieldShell(
          label: label,
          value: value == null
              ? null
              : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}',
          icon: Icons.schedule,
          error: error,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
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
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClear,
                child: const Icon(Icons.close, color: _ink400, size: 17),
              )
            else
              Icon(icon, color: _ink400, size: 17),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? error;

  const _Input({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffix,
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
        _SectionTitle(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : _ink900),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            hintStyle: const TextStyle(color: _ink400),
            suffixStyle: const TextStyle(
              color: _ink500,
              fontWeight: FontWeight.w800,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: error == null ? const Color(0x120F172A) : Colors.red),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: error == null ? const Color(0x120F172A) : Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brand),
            ),
          ),
        ),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

class _WeightStepper extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accent;
  final String? error;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _WeightStepper({
    required this.controller,
    required this.label,
    required this.hint,
    required this.accent,
    required this.error,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(icon: Icons.scale_outlined, text: label),
        Row(
          children: [
            _RoundStepButton(
              icon: Icons.remove,
              color: const Color(0xFFE7E8EE),
              iconColor: _ink800,
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
                  hintText: hint == '2.5' ? hint : null,
                  suffixText: 'kq',
                  filled: true,
                  fillColor: const Color(0xFFF4F6FA),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  suffixStyle: const TextStyle(
                    color: _ink400,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color:
                          error == null ? const Color(0x120F172A) : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color:
                          error == null ? const Color(0x120F172A) : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: accent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _RoundStepButton(
              icon: Icons.add,
              color: accent.withValues(alpha: 0.10),
              iconColor: accent,
              onTap: onPlus,
            ),
          ],
        ),
        if (error != null) _ErrorText(error!),
      ],
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
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
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
            Icon(Icons.handshake, color: accent, size: 22),
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
                icon: _packageIcon(item),
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

  IconData _packageIcon(PackageType item) {
    final code = item.code.toLowerCase();
    final name = item.name.toLowerCase();
    if (code.contains('doc') || name.contains('sənəd')) {
      return Icons.description;
    }
    if (code.contains('elect') || name.contains('elektr')) {
      return Icons.phone_android;
    }
    if (code.contains('food') || name.contains('qida')) {
      return Icons.restaurant;
    }
    if (code.contains('cloth') || name.contains('geyim')) {
      return Icons.checkroom;
    }
    return Icons.inventory_2_outlined;
  }
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
            if (selected) Icon(Icons.check_circle, color: accent, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const _BottomCta({
    required this.primaryLabel,
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
              child: _SecondaryAction(
                label: secondaryLabel!,
                onTap: onSecondary!,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: _PrimaryAction(
              label: primaryLabel,
              accent: _brand,
              onTap: onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  const _PrimaryAction({
    required this.label,
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
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.label,
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
        child: Text(
          label,
          style: const TextStyle(
            color: _brand,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
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

  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accent),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _ink400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
