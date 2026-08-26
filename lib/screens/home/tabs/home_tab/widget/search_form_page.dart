import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/listing_feed_bloc.dart';
import '../search/search_offer_list_screen.dart';
import 'city_selector.dart';
import 'listing_type_filter.dart';

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

/// Price fields show a per-kilogram price, so they go through the shared CMS
/// normaliser: USD instead of any leftover ₼, and the unit as `kq/$`.
String _priceLabel(Map<String, String> content, String key) =>
    WawatContent.priceLabel(content, key);

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
    logSearchEvent(filters,
        source: widget.compact ? 'inline_form' : 'search_form');
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
              color: cCard(isDark),
              borderRadius: BorderRadius.circular(26),
              border: cCardBorder(isDark),
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
                            color: isDark ? WawatDark.surfaceAlt : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? WawatDark.border
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
                          child: Icon(
                            PhosphorIconsBold.arrowsDownUp,
                            color: isDark ? WawatDark.brandText : _brand,
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
                  ListingTypeFilter(
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
                              ? WawatDark.disabledBg
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _contentText(content, 'search.filters_title'),
              style: TextStyle(
                color: cText(isDark),
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
                  style: TextStyle(
                    color: cBrandText(isDark),
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
          LinearProgressIndicator(
            minHeight: 3,
            color: cBrandText(isDark),
            backgroundColor: cBrandSoft(isDark),
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
                label: _priceLabel(content, 'search.price_min'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NumberBox(
                controller: _priceMax,
                label: _priceLabel(content, 'search.price_max'),
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
    // Single-select minimum-tier threshold ("value and above"); "Any" (null)
    // clears it. Sent to the API as `tier_min`.
    return _FilterChip(
      label: _contentText(content, key),
      selected: _tierMin == value,
      onTap: () => setState(() => _tierMin = value),
    );
  }

  /// Inline filters shown under the «Ətraflı» accordion (design screen 1b).
  /// Same fields/order/components as the full-screen filter panel (screen 8).
  Widget _buildInlineFilters(Map<String, String> content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cLine(isDark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              _contentText(content, 'search.filter_type', 'Elan tipi')),
          ListingTypeFilter(
            value: _type,
            content: content,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 18),
          _SectionTitle(_contentText(content, 'search.filter_package_type')),
          if (_packages.isEmpty)
            LinearProgressIndicator(
              minHeight: 3,
              color: cBrandText(isDark),
              backgroundColor: cBrandSoft(isDark),
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
                  label: _priceLabel(content, 'search.price_min'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberBox(
                  controller: _priceMax,
                  label: _priceLabel(content, 'search.price_max'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = cBrandText(isDark);
    // Soft-brand pill so the "open more filters" toggle reads as an emphasised
    // button rather than a plain text link.
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: cBrandSoft(isDark),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsBold.slidersHorizontal, color: brand, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: brand,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                open ? PhosphorIconsBold.caretUp : PhosphorIconsBold.caretDown,
                color: brand,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
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
          color: isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? WawatDark.border : const Color(0x120F172A),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? cBrandText(isDark) : cMuted(isDark),
                size: iconSize),
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
                          ? (isDark ? WawatDark.textPrimary : _ink900)
                          : cMuted(isDark),
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
                      style: TextStyle(
                        color: cMuted(isDark),
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
                    Icon(PhosphorIconsBold.x, color: cMuted(isDark), size: 18),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: TextStyle(
          color: cText(Theme.of(context).brightness == Brightness.dark),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.brandBadge : _brand50)
              : (isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? (isDark ? WawatDark.brand : _brand)
                : (isDark ? WawatDark.border : const Color(0x120F172A)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? cBrandText(isDark)
                : (isDark ? WawatDark.textMuted : _ink500),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? WawatDark.border : const Color(0x120F172A)),
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
                      ? (isDark ? WawatDark.placeholder : _ink400)
                      : cText(isDark),
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
                    Icon(PhosphorIconsBold.x, color: cMuted(isDark), size: 17),
              )
            else
              Icon(PhosphorIconsRegular.calendarBlank,
                  color: cMuted(isDark), size: 17),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Numeric keyboards have no return/Done key on Android, so tapping
      // anywhere outside the field must close it.
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: TextStyle(color: cText(isDark)),
      decoration: InputDecoration(
        hintText: label,
        hintStyle:
            isDark ? const TextStyle(color: WawatDark.placeholder) : null,
        filled: true,
        fillColor: isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? WawatDark.border : const Color(0x120F172A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? WawatDark.border : const Color(0x120F172A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? WawatDark.focusRing : _brand),
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
        color: isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? WawatDark.border : const Color(0x120F172A),
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: value ? cBrandText(isDark) : cMuted(isDark), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink800,
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
