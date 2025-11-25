import 'package:flutter/material.dart';
import '../../../../../data/network/response/city.dart';

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Выберите город',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'Поиск города...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF8E8E93),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
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
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Города не найдены',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredCities.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = widget.selectedCity?.id == city.id;

                return InkWell(
                  onTap: () {
                    widget.onCitySelected(city);
                  },
                  child: Container(
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
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF5B51FF)
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${city.countryName} (${city.countryCode})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8E8E93),
                                ),
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