import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/network/response/city.dart';
import '../../../../../services/theme_manager.dart';

class CitySelector extends StatefulWidget {
  final List<City> cities;
  final City? selectedCity;
  final Function(City) onCitySelected;
  final bool isLoading;

  const CitySelector({
    Key? key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities.where((city) {
          return city.name.toLowerCase().contains(query) ||
              city.countryName.toLowerCase().contains(query);
        }).toList();
      }
    });
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
                    : _filteredCities.isEmpty
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
                  itemCount: _filteredCities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA),
                  ),
                  itemBuilder: (context, index) {
                    final city = _filteredCities[index];
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
  required List<City> cities,
  required City? selectedCity,
  bool isLoading = false,
}) {
  return showModalBottomSheet<City>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CitySelector(
      cities: cities,
      selectedCity: selectedCity,
      onCitySelected: (city) => Navigator.pop(context, city),
      isLoading: isLoading,
    ),
  );
}
