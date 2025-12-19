import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/network/response/city.dart';
import '../../../../../services/theme_manager.dart';

class CitySelector extends StatefulWidget {
  final List<City> initialCities;
  final City? selectedCity;
  final Function(City) onCitySelected;
  final Future<List<City>> Function(String search) onSearch;
  final bool isLoading;

  const CitySelector({
    Key? key,
    required this.initialCities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _cities = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cities = widget.initialCities;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.onSearch(query);
      if (mounted) {
        setState(() {
          _cities = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5EA),
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Выберите город'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF8E8E93),
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
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Поиск города...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF8E8E93),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF8E8E93),
                        size: 20,
                      ),
                      suffixIcon: _isSearching
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
                child: widget.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5B51FF),
                  ),
                )
                    : _cities.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDark ? const Color(0xFF4A4A4A) : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
                        ),
                        child: const Text('Города не найдены'),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _cities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA),
                  ),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
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
                            ? const Color(0xFF5B51FF).withOpacity(0.05)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF5B51FF)
                                          : (isDark ? Colors.white : Colors.black),
                                    ),
                                    child: Text(city.name),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93),
                                    ),
                                    child: Text('${city.countryName} (${city.countryCode})'),
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
      },
    );
  }
}

/// Функция для показа City Selector Bottom Sheet
Future<City?> showCitySelector({
  required BuildContext context,
  required List<City> initialCities,
  required City? selectedCity,
  required Future<List<City>> Function(String search) onSearch,
  bool isLoading = false,
}) {
  return showModalBottomSheet<City>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CitySelector(
      initialCities: initialCities,
      selectedCity: selectedCity,
      onCitySelected: (city) => Navigator.pop(context, city),
      onSearch: onSearch,
      isLoading: isLoading,
    ),
  );
}
