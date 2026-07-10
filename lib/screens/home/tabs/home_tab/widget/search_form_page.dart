import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/city.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../listings/listing_feed_bloc.dart';
import '../search/search_offer_list_screen.dart';
import 'city_selector.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

String _contentText(Map<String, String> content, String key,
    [String? fallback]) {
  final value = content[key];
  if (value == null || value.trim().isEmpty) return fallback ?? key;
  return value;
}

class SearchFormWidget extends StatefulWidget {
  final ListingFeedBloc bloc;
  final bool compact;
  final ValueChanged<ListingFilterState>? onSearch;

  const SearchFormWidget({
    super.key,
    required this.bloc,
    this.compact = false,
    this.onSearch,
  });

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  City? _fromCity;
  City? _toCity;
  String? _type;
  bool _citiesTouched = false;

  List<City> _initialCities = [];
  bool _isLoadingCities = true;

  @override
  void initState() {
    super.initState();
    _fromCity = widget.bloc.filters.cityFrom;
    _toCity = widget.bloc.filters.cityTo;
    _type = widget.bloc.filters.type;
    _loadInitialCities();
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
      sort: 'relevance',
    );
  }

  void _performSearch() {
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
                const SizedBox(height: 11),
                _TypeSegment(
                  value: _type,
                  content: content,
                  onChanged: (value) => setState(() => _type = value),
                ),
                const SizedBox(height: 11),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _performSearch,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _brand,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _brand.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                            fontWeight: FontWeight.w900,
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
                    fontWeight: FontWeight.w900,
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
                          isSelected ? FontWeight.w800 : FontWeight.w600,
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
                        fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w900,
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
          fontWeight: FontWeight.w900,
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
            fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w800,
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
            fontWeight: FontWeight.w900,
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
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
