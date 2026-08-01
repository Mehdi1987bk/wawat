import 'dart:async';
import 'package:buking/generated/l10n.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/city.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';

class CitySelector extends StatefulWidget {
  final List<City> cities;
  final City? selectedCity;
  final Function(City) onCitySelected;
  final Function(String) onSearchChanged;
  final bool isLoading;
  final bool isDark;

  const CitySelector({
    Key? key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.onSearchChanged,
    this.isLoading = false,
    this.isDark = false,
  }) : super(key: key);

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Отменяем предыдущий таймер если он есть
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Создаем новый таймер на 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.isDark ? WawatDark.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? WawatDark.grab : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? WawatDark.textPrimary : Colors.black,
                  ),
                  child: Text(S.of(context).bgrhtrgrfr445),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.isDark
                        ? WawatDark.icon
                        : const Color(0xFF8E8E93),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? WawatDark.surfaceAlt
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isDark ? WawatDark.textPrimary : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).hyrh5h4tgerwfs,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: widget.isDark
                        ? WawatDark.placeholder
                        : const Color(0xFF8E8E93),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: widget.isDark
                        ? WawatDark.iconMuted
                        : const Color(0xFF8E8E93),
                    size: 20,
                  ),
                  suffixIcon: widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5B51FF),
                            ),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: widget.isDark
                                    ? WawatDark.iconMuted
                                    : const Color(0xFF8E8E93),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cities list
          Expanded(
            child: widget.isLoading && widget.cities.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B51FF),
                    ),
                  )
                : widget.cities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: widget.isDark
                                  ? WawatDark.iconMuted
                                  : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.isDark
                                    ? WawatDark.textSecondary
                                    : Colors.grey.shade600,
                              ),
                              child: Text(
                                _searchController.text.isEmpty
                                    ? S.of(context).juu76j5yh4rtge
                                    : S.of(context).tyju65y4htge3rwfs,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        // Reserve the Android system-nav inset so the last city
                        // clears the gesture bar at the sheet's bottom edge.
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8 + MediaQuery.of(context).viewPadding.bottom,
                        ),
                        itemCount: widget.cities.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: widget.isDark
                              ? WawatDark.divider
                              : const Color(0xFFE5E5EA),
                        ),
                        itemBuilder: (context, index) {
                          final city = widget.cities[index];
                          final isSelected = widget.selectedCity?.id == city.id;

                          return InkWell(
                            onTap: () {
                              widget.onCitySelected(city);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              color: isSelected
                                  ? const Color(0xFF5B51FF).withOpacity(0.1)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF5B51FF)
                                                : (widget.isDark
                                                    ? WawatDark.textPrimary
                                                    : Colors.black),
                                          ),
                                          child: Text(city.name),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: widget.isDark
                                                ? WawatDark.textSecondary
                                                : const Color(0xFF8E8E93),
                                          ),
                                          child: Text(
                                              '${city.countryName} (${city.countryCode})'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF5B51FF),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
