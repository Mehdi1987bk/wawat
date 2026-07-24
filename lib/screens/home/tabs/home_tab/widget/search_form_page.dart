import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/listing_feed_bloc.dart';
import '../search/search_offer_list_screen.dart';
import 'city_selector.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

String _contentText(Map<String, String> content, String key,
    [String? fallback]) {
  return WawatContent.text(content, key, fallback);
}

class SearchFormWidget extends StatefulWidget {
  final ListingFeedBloc bloc;
  final bool compact;
  final bool advanced;
  final ValueChanged<ListingFilterState>? onSearch;

  /// Search-entry mode (screens 1/1b): hides the standalone type segment and
  /// shows an «Ətraflı» accordion toggle that reveals the filters inline.
  final bool showAdvancedToggle;
  final bool advancedOpen;
  final ValueChanged<bool>? onAdvancedToggle;

  const SearchFormWidget({
    super.key,
    required this.bloc,
    this.compact = false,
    this.advanced = false,
    this.onSearch,
    this.showAdvancedToggle = false,
    this.advancedOpen = false,
    this.onAdvancedToggle,
  });

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  City? _fromCity;
  City? _toCity;
  String? _type;
  bool _citiesTouched = false;
  late String _sort;
  late List<String> _packageTypes;
  late bool _verifiedOnly;
  late bool _following;
  String? _dateFrom;
  String? _dateTo;
  double? _ratingMin;
  String? _tierMin;

  List<City> _initialCities = [];
  List<PackageType> _packages = [];
  bool _isLoadingCities = true;
  final _weightMin = TextEditingController();
  final _weightMax = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromCity = widget.bloc.filters.cityFrom;
    _toCity = widget.bloc.filters.cityTo;
    _type = widget.bloc.filters.type;
    _sort = widget.bloc.filters.sort;
    _packageTypes = [...widget.bloc.filters.packageTypes];
    _verifiedOnly = widget.bloc.filters.verifiedOnly;
    _following = widget.bloc.filters.following;
    _dateFrom = widget.bloc.filters.dateFrom;
    _dateTo = widget.bloc.filters.dateTo;
    _ratingMin = widget.bloc.filters.ratingMin;
    _tierMin = widget.bloc.filters.tierMin;
    _weightMin.text = _numberText(widget.bloc.filters.weightMin);
    _weightMax.text = _numberText(widget.bloc.filters.weightMax);
    _priceMin.text = _numberText(widget.bloc.filters.priceMin);
    _priceMax.text = _numberText(widget.bloc.filters.priceMax);
    _loadInitialCities();
    if (widget.advanced || widget.showAdvancedToggle) _loadPackages();
  }

  @override
  void dispose() {
    _weightMin.dispose();
    _weightMax.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final response = await widget.bloc.loadPackageTypes();
      if (mounted) setState(() => _packages = response.data);
    } catch (_) {}
  }

  Future<void> _loadInitialCities() async {
    try {
      final response = await widget.bloc.getCities('');
      if (!mounted) return;
      final defaultFromCity = _citiesTouched
          ? _fromCity
          : _fromCity ?? _findDefaultFromCity(response.data);
      setState(() {
        _initialCities = response.data;
        _fromCity = defaultFromCity;
        _isLoadingCities = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  City? _findDefaultFromCity(List<City> cities) {
    for (final city in cities) {
      final name = city.name.trim().toLowerCase();
      if (name == 'bakı' || name == 'baki' || name == 'baku') {
        return city;
      }
    }
    return null;
  }

  Future<List<City>> _searchCities(String search) async {
    try {
      final response = await widget.bloc.getCities(search);
      return response.data;
    } catch (_) {
      return [];
    }
  }

  Future<void> _pickCity({required bool isFrom}) async {
    if (_initialCities.isEmpty && !_isLoadingCities) {
      setState(() => _isLoadingCities = true);
      await _loadInitialCities();
    }

    if (!mounted) return;
    final selected = await showCitySelector(
      context: context,
      initialCities: _initialCities,
      selectedCity: isFrom ? _fromCity : _toCity,
      onSearch: _searchCities,
      isLoading: _isLoadingCities,
    );

    if (!mounted) return;
    setState(() {
      _citiesTouched = true;
      if (isFrom) {
        _fromCity = selected;
      } else {
        _toCity = selected;
      }
    });
  }

  void _swapCities() {
    setState(() {
      _citiesTouched = true;
      final from = _fromCity;
      _fromCity = _toCity;
      _toCity = from;
    });
  }

  ListingFilterState _filters() {
    return ListingFilterState(
      type: _type,
      cityFrom: _fromCity,
      cityTo: _toCity,
      packageTypes: _packageTypes,
      verifiedOnly: _verifiedOnly,
      following: _following,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      weightMin: _parseNumber(_weightMin.text),
      weightMax: _parseNumber(_weightMax.text),
      priceMin: _parseNumber(_priceMin.text),
      priceMax: _parseNumber(_priceMax.text),
      ratingMin: _ratingMin,
      tierMin: _tierMin,
      sort: _sort,
    );
  }

  double? _parseNumber(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _numberText(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  void _resetAdvancedFilters() {
    setState(() {
      _type = null;
      _sort = 'relevance';
      _packageTypes = [];
      _verifiedOnly = false;
      _following = false;
      _dateFrom = null;
      _dateTo = null;
      _ratingMin = null;
      _tierMin = null;
      _weightMin.clear();
      _weightMax.clear();
      _priceMin.clear();
      _priceMax.clear();
    });
  }

  void _performSearch() {
    if (_fromCity == null || _toCity == null) return;

    final filters = _filters();
    if (widget.onSearch != null) {
      widget.onSearch!(filters);
      return;
    }
    if (widget.compact) {
      widget.bloc.setFilters(filters);
      widget.bloc.refreshList();
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => SearchOfferListScreen(filters: filters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<Map<String, String>>(
      stream: widget.bloc.listingContent,
      initialData: const {},
      builder: (context, snapshot) {
        final content = snapshot.data ?? const {};
        final canSearch = _fromCity != null && _toCity != null;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, widget.compact ? 8 : 0, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: _brand.withValues(alpha: isDark ? 0.10 : 0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        _CityField(
                          icon: PhosphorIconsFill.circle,
                          iconSize: 9,
                          label: _fromCity?.name ??
                              _contentText(content, 'search.from_placeholder'),
                          country: _fromCity?.countryName,
                          isSelected: _fromCity != null,
                          onTap: () => _pickCity(isFrom: true),
                          onClear: _fromCity == null
                              ? null
                              : () => setState(() {
                                    _citiesTouched = true;
                                    _fromCity = null;
                                  }),
                        ),
                        const SizedBox(height: 10),
                        _CityField(
                          icon: PhosphorIconsFill.mapPin,
                          iconSize: 18,
                          label: _toCity?.name ??
                              _contentText(content, 'search.to_placeholder'),
                          country: _toCity?.countryName,
                          isSelected: _toCity != null,
                          onTap: () => _pickCity(isFrom: false),
                          onClear: _toCity == null
                              ? null
                              : () => setState(() {
                                    _citiesTouched = true;
                                    _toCity = null;
                                  }),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 14,
                      top: 35,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _swapCities,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0x0F0F172A),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            PhosphorIconsBold.arrowsDownUp,
                            color: _brand,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.showAdvancedToggle) ...[
                  const SizedBox(height: 12),
                  _AdvancedToggle(
                    label: _contentText(content, 'search.advanced'),
                    open: widget.advancedOpen,
                    onTap: () =>
                        widget.onAdvancedToggle?.call(!widget.advancedOpen),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: widget.advancedOpen
                        ? _buildInlineFilters(content)
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  const SizedBox(height: 11),
                  _TypeSegment(
                    value: _type,
                    content: content,
                    onChanged: (value) => setState(() => _type = value),
                  ),
                  if (widget.advanced) ...[
                    const SizedBox(height: 18),
                    _buildAdvancedFilters(content),
                  ],
                  const SizedBox(height: 11),
                ],
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: canSearch ? _performSearch : null,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: canSearch
                          ? _brand
                          : isDark
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: canSearch
                          ? [
                              BoxShadow(
                                color: _brand.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIconsRegular.magnifyingGlass,
                            color: Colors.white, size: 19),
                        const SizedBox(width: 8),
                        Text(
                          _contentText(content, 'search.button'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFilters(Map<String, String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _contentText(content, 'search.filters_title'),
              style: const TextStyle(
                color: _ink900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _resetAdvancedFilters,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _contentText(content, 'common.reset'),
                  style: const TextStyle(
                    color: _brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        _SectionTitle(_contentText(content, 'search.filter_package_type')),
        if (_packages.isEmpty)
          const LinearProgressIndicator(
            minHeight: 3,
            color: _brand,
            backgroundColor: _brand50,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final package in _packages)
                _FilterChip(
                  label: package.name,
                  selected: _packageTypes.contains(package.code),
                  onTap: () {
                    setState(() {
                      _packageTypes.contains(package.code)
                          ? _packageTypes.remove(package.code)
                          : _packageTypes.add(package.code);
                    });
                  },
                ),
            ],
          ),
        const SizedBox(height: 18),
        _SectionTitle(_contentText(content, 'search.filter_date')),
        Row(
          children: [
            Expanded(
              child: _DateBox(
                label: _contentText(content, 'search.date_from'),
                value: _dateFrom,
                onChanged: (value) => setState(() => _dateFrom = value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateBox(
                label: _contentText(content, 'search.date_to'),
                value: _dateTo,
                onChanged: (value) => setState(() => _dateTo = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle(_contentText(content, 'search.filter_weight')),
        Row(
          children: [
            Expanded(
              child: _NumberBox(
                controller: _weightMin,
                label: _contentText(content, 'search.weight_min'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NumberBox(
                controller: _weightMax,
                label: _contentText(content, 'search.weight_max'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle(_contentText(content, 'search.filter_price')),
        Row(
          children: [
            Expanded(
              child: _NumberBox(
                controller: _priceMin,
                label: _contentText(content, 'search.price_min'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NumberBox(
                controller: _priceMax,
                label: _contentText(content, 'search.price_max'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle(_contentText(content, 'search.filter_rating')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: _contentText(content, 'search.filter_any'),
              selected: _ratingMin == null,
              onTap: () => setState(() => _ratingMin = null),
            ),
            _FilterChip(
              label: '4.5+',
              selected: _ratingMin == 4.5,
              onTap: () => setState(() => _ratingMin = 4.5),
            ),
            _FilterChip(
              label: '4.8+',
              selected: _ratingMin == 4.8,
              onTap: () => setState(() => _ratingMin = 4.8),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle(_contentText(content, 'search.filter_tier')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _tierChip(content, 'search.filter_any', null),
            _tierChip(content, 'tier.bronze_plus', 'bronze'),
            _tierChip(content, 'tier.silver_plus', 'silver'),
            _tierChip(content, 'tier.gold_plus', 'gold'),
            _tierChip(content, 'tier.platinum', 'platinum'),
          ],
        ),
        const SizedBox(height: 18),
        _AdvancedSwitchRow(
          label: _contentText(content, 'search.verified_only'),
          icon: PhosphorIconsFill.sealCheck,
          value: _verifiedOnly,
          onChanged: (value) => setState(() => _verifiedOnly = value),
        ),
        const SizedBox(height: 10),
        _AdvancedSwitchRow(
          label: _contentText(content, 'search.following_only'),
          icon: PhosphorIconsRegular.userCheck,
          value: _following,
          onChanged: (value) => setState(() => _following = value),
        ),
      ],
    );
  }

  Widget _tierChip(
    Map<String, String> content,
    String key,
    String? value,
  ) {
    return _FilterChip(
      label: _contentText(content, key),
      selected: _tierMin == value,
      onTap: () => setState(() => _tierMin = value),
    );
  }

  /// Inline filters shown under the «Ətraflı» accordion (design screen 1b).
  /// Same fields/order/components as the full-screen filter panel (screen 8).
  Widget _buildInlineFilters(Map<String, String> content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(_contentText(content, 'search.filter_type', 'Elan tipi')),
          _TypeSegment(
            value: _type,
            content: content,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_package_type')),
          if (_packages.isEmpty)
            const LinearProgressIndicator(
              minHeight: 3,
              color: _brand,
              backgroundColor: _brand50,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final package in _packages)
                  _FilterChip(
                    label: package.name,
                    selected: _packageTypes.contains(package.code),
                    onTap: () {
                      setState(() {
                        _packageTypes.contains(package.code)
                            ? _packageTypes.remove(package.code)
                            : _packageTypes.add(package.code);
                      });
                    },
                  ),
              ],
            ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_price')),
          Row(
            children: [
              Expanded(
                child: _NumberBox(
                  controller: _priceMin,
                  label: _contentText(content, 'search.price_min'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberBox(
                  controller: _priceMax,
                  label: _contentText(content, 'search.price_max'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_weight')),
          Row(
            children: [
              Expanded(
                child: _NumberBox(
                  controller: _weightMin,
                  label: _contentText(content, 'search.weight_min'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberBox(
                  controller: _weightMax,
                  label: _contentText(content, 'search.weight_max'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_date')),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  label: _contentText(content, 'search.date_from'),
                  value: _dateFrom,
                  onChanged: (value) => setState(() => _dateFrom = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateBox(
                  label: _contentText(content, 'search.date_to'),
                  value: _dateTo,
                  onChanged: (value) => setState(() => _dateTo = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_rating')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: _contentText(content, 'search.filter_any'),
                selected: _ratingMin == null,
                onTap: () => setState(() => _ratingMin = null),
              ),
              _FilterChip(
                label: '4.5+',
                selected: _ratingMin == 4.5,
                onTap: () => setState(() => _ratingMin = 4.5),
              ),
              _FilterChip(
                label: '4.8+',
                selected: _ratingMin == 4.8,
                onTap: () => setState(() => _ratingMin = 4.8),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_tier')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tierChip(content, 'search.filter_any', null),
              _tierChip(content, 'tier.bronze_plus', 'bronze'),
              _tierChip(content, 'tier.silver_plus', 'silver'),
              _tierChip(content, 'tier.gold_plus', 'gold'),
              _tierChip(content, 'tier.platinum', 'platinum'),
            ],
          ),
          const SizedBox(height: 18),
          _AdvancedSwitchRow(
            label: _contentText(content, 'search.verified_only'),
            icon: PhosphorIconsFill.sealCheck,
            value: _verifiedOnly,
            onChanged: (value) => setState(() => _verifiedOnly = value),
          ),
          const SizedBox(height: 10),
          _AdvancedSwitchRow(
            label: _contentText(content, 'search.following_only'),
            icon: PhosphorIconsRegular.userCheck,
            value: _following,
            onChanged: (value) => setState(() => _following = value),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AdvancedToggle extends StatelessWidget {
  final String label;
  final bool open;
  final VoidCallback onTap;

  const _AdvancedToggle({
    required this.label,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(PhosphorIconsBold.slidersHorizontal,
                color: _brand, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: _brand,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              open
                  ? PhosphorIconsBold.caretUp
                  : PhosphorIconsBold.caretDown,
              color: _brand,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class ListingFilterSheet extends StatefulWidget {
  final ListingFeedBloc bloc;
  final ListingFilterState initialFilters;

  const ListingFilterSheet({
    super.key,
    required this.bloc,
    required this.initialFilters,
  });

  @override
  State<ListingFilterSheet> createState() => _ListingFilterSheetState();
}

class _ListingFilterSheetState extends State<ListingFilterSheet> {
  late ListingFilterState _filters;
  List<PackageType> _packages = [];
  final _weightMin = TextEditingController();
  final _weightMax = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _weightMin.text = _filters.weightMin?.toString() ?? '';
    _weightMax.text = _filters.weightMax?.toString() ?? '';
    _priceMin.text = _filters.priceMin?.toString() ?? '';
    _priceMax.text = _filters.priceMax?.toString() ?? '';
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final response = await widget.bloc.loadPackageTypes();
      if (!mounted) return;
      setState(() => _packages = response.data);
    } catch (_) {}
  }

  @override
  void dispose() {
    _weightMin.dispose();
    _weightMax.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final title = isDark ? Colors.white : _ink900;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Filtrlər',
                  style: TextStyle(
                    color: title,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.pop(context),
                  child: Icon(PhosphorIconsBold.x, color: title, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Növ'),
            _TypeSegment(
              value: _filters.type,
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(
                  type: value,
                  clearType: value == null,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle('Sıralama'),
            _ChoiceWrap(
              selected: _filters.sort,
              values: const {
                'relevance': 'Uyğunluq',
                'date_asc': 'Tarix ↑',
                'date_desc': 'Tarix ↓',
                'price_asc': 'Qiymət ↑',
                'price_desc': 'Qiymət ↓',
                'weight_desc': 'Çəki ↓',
                'rating_desc': 'Reytinq',
              },
              onChanged: (value) => setState(
                () => _filters = _filters.copyWith(sort: value),
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle('Bağlama növləri'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _packages.map((package) {
                final selected = _filters.packageTypes.contains(package.code);
                return _FilterChip(
                  label: package.name,
                  selected: selected,
                  onTap: () {
                    final next = [..._filters.packageTypes];
                    selected
                        ? next.remove(package.code)
                        : next.add(package.code);
                    setState(
                        () => _filters = _filters.copyWith(packageTypes: next));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _SectionTitle('Tarix'),
            Row(
              children: [
                Expanded(
                  child: _DateBox(
                    label: 'Başlanğıc',
                    value: _filters.dateFrom,
                    onChanged: (value) => setState(
                      () => _filters = _filters.copyWith(
                        dateFrom: value,
                        clearDateFrom: value == null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateBox(
                    label: 'Son',
                    value: _filters.dateTo,
                    onChanged: (value) => setState(
                      () => _filters = _filters.copyWith(
                        dateTo: value,
                        clearDateTo: value == null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Çəki və qiymət'),
            Row(
              children: [
                Expanded(
                    child: _NumberBox(controller: _weightMin, label: 'Min kq')),
                const SizedBox(width: 10),
                Expanded(
                    child: _NumberBox(controller: _weightMax, label: 'Max kq')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _NumberBox(controller: _priceMin, label: 'Min ₼')),
                const SizedBox(width: 10),
                Expanded(
                    child: _NumberBox(controller: _priceMax, label: 'Max ₼')),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label: 'Sıfırla',
                    onTap: () => setState(() {
                      _filters = ListingFilterState(
                        cityFrom: widget.initialFilters.cityFrom,
                        cityTo: widget.initialFilters.cityTo,
                      );
                      _weightMin.clear();
                      _weightMax.clear();
                      _priceMin.clear();
                      _priceMax.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _PrimaryButton(
                    label: 'Nəticələri göstər',
                    onTap: () {
                      Navigator.pop(
                        context,
                        _filters.copyWith(
                          weightMin: _parse(_weightMin.text),
                          weightMax: _parse(_weightMax.text),
                          priceMin: _parse(_priceMin.text),
                          priceMax: _parse(_priceMax.text),
                          clearWeightMin: _weightMin.text.trim().isEmpty,
                          clearWeightMax: _weightMax.text.trim().isEmpty,
                          clearPriceMin: _priceMin.text.trim().isEmpty,
                          clearPriceMax: _priceMax.text.trim().isEmpty,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double? _parse(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }
}

class _CityField extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final String? country;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _CityField({
    required this.icon,
    required this.iconSize,
    required this.label,
    this.country,
    required this.isSelected,
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
        height: 52,
        padding: const EdgeInsets.only(left: 14, right: 52),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0x120F172A),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _brand : _ink400, size: iconSize),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? (isDark ? Colors.white : _ink900)
                          : _ink400,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (country != null && country!.isNotEmpty)
                    Text(
                      country!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClear,
                child:
                    const Icon(PhosphorIconsBold.x, color: _ink400, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  final String? value;
  final Map<String, String> content;
  final ValueChanged<String?> onChanged;

  const _TypeSegment({
    required this.value,
    this.content = const {},
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0x0D0F172A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _segment(_contentText(content, 'search.type_all'), null),
          _segment(content['enum.listing_type.trip'] ?? 'Səfər', 'trip'),
          _segment(content['enum.listing_type.shipment_post'] ?? 'Göndəriş',
              'shipment_post'),
        ],
      ),
    );
  }

  Widget _segment(String label, String? itemValue) {
    final selected = value == itemValue;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onChanged(itemValue),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _brand : _ink500,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : _ink900,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  final String selected;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;

  const _ChoiceWrap({
    required this.selected,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.entries.map((entry) {
        return _FilterChip(
          label: entry.value,
          selected: selected == entry.key,
          onTap: () => onChanged(entry.key),
        );
      }).toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _brand50 : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: selected ? _brand : const Color(0x120F172A)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _brand : _ink500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (date != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(date));
        }
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x120F172A)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value == null ? _ink400 : _ink900,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onChanged(null),
                child:
                    const Icon(PhosphorIconsBold.x, color: _ink400, size: 17),
              )
            else
              const Icon(PhosphorIconsRegular.calendarBlank,
                  color: _ink400, size: 17),
          ],
        ),
      ),
    );
  }
}

class _NumberBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NumberBox({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x120F172A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x120F172A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _brand),
        ),
      ),
    );
  }
}

class _AdvancedSwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AdvancedSwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0x120F172A),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? _brand : _ink400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : _ink800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: _brand,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
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
          color: _brand,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
