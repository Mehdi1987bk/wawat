import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/country.dart';
import '../../../../generated/l10n.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../services/theme_manager.dart';

class CountryCodeSelector extends StatelessWidget {
  final Country? selectedCountry;
  final List<Country> countries;
  final ValueChanged<Country> onChanged;
  final bool isLoading;
  final bool enabled; // ✅ Добавлен параметр

  const CountryCodeSelector({
    Key? key,
    required this.selectedCountry,
    required this.countries,
    required this.onChanged,
    this.isLoading = false,
    this.enabled = true, // ✅ По умолчанию true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return GestureDetector(
          onTap: (isLoading || !enabled) ? null : () => _showCountryPicker(context, isDark), // ✅ Проверка enabled
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
            child: Opacity( // ✅ Визуальная индикация disabled состояния
              opacity: enabled ? 1.0 : 0.5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    )
                  else if (selectedCountry != null) ...[
                    Text(
                      selectedCountry!.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedCountry!.callingCode ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ] else
                    Text(
                      '+...',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        countries: countries,
        selectedCountry: selectedCountry,
        onChanged: onChanged,
        isDark: isDark,
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final ValueChanged<Country> onChanged;
  final bool isDark;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
    required this.isDark,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries
        .where((c) => c.callingCode != null)
        .toList();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries
            .where((c) => c.callingCode != null)
            .toList();
      } else {
        _filteredCountries = widget.countries
            .where((c) =>
        c.callingCode != null &&
            (c.name.toLowerCase().contains(query.toLowerCase()) ||
                c.callingCode!.contains(query) ||
                c.code.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.public,
                  color: widget.isDark
                      ? const Color(0xFF6366F1)
                      : WawatColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).nbtynt7,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).mjh5y,
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white38 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isDark ? Colors.white38 : Colors.grey,
                ),
                filled: true,
                fillColor: widget.isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = widget.selectedCountry?.id == country.id;

                return ListTile(
                  onTap: () {
                    widget.onChanged(country);
                    Navigator.pop(context);
                  },
                  leading: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.callingCode ?? '',
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF6366F1)
                              : WawatColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: widget.isDark
                              ? const Color(0xFF6366F1)
                              : WawatColors.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  tileColor: isSelected
                      ? (widget.isDark
                      ? const Color(0xFF6366F1).withOpacity(0.1)
                      : WawatColors.primary.withOpacity(0.05))
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}