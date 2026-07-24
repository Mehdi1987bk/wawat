import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/network/response/city.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../services/theme_manager.dart';

class CitySelector extends StatefulWidget {
  final List<City> initialCities;
  final City? selectedCity;
  final Future<List<City>> Function(String search) onSearch;
  final bool isLoading;

  const CitySelector({
    Key? key,
    required this.initialCities,
    required this.selectedCity,
    required this.onSearch,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<City> _cities = [];
  List<City> _cachedCities = []; // Кэш для плавности
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cities = widget.initialCities;
    _cachedCities = widget.initialCities;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    // Если пустой запрос - сразу показываем начальный список
    if (query.isEmpty) {
      setState(() {
        _cities = widget.initialCities;
        _cachedCities = widget.initialCities;
        _errorMessage = null;
        _isSearching = false;
      });
      _scrollToTop();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _cities = widget.initialCities;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      // Не очищаем _cities - показываем старые данные пока грузятся новые
    });

    try {
      final results = await widget.onSearch(query);
      if (mounted) {
        setState(() {
          _cities = results;
          _cachedCities = results;
          _isSearching = false;
        });
        _scrollToTop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          // При ошибке показываем кэшированные данные + сообщение
          _cities = _cachedCities;
          _errorMessage = e.toString();
        });

        // Показываем снэкбар с ошибкой, но не блокируем UI
        _showErrorSnackBar();
      }
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),

          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: S.of(context).retry,
          textColor: Colors.white,
          onPressed: () => _performSearch(_searchController.text),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _cities = widget.initialCities;
      _cachedCities = widget.initialCities;
      _errorMessage = null;
      _isSearching = false;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    // Прокручиваем список вверх после обновления UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
              Container(
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
                    Text(
                      S.of(context).tnhyj5brgbdfg,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      return TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: S.of(context).nu6j5yhtge65h4tgre,
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF8E8E93),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF8E8E93),
                            size: 20,
                          ),
                          suffixIcon: _buildSuffixIcon(isDark, value.text),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cities list
              Expanded(
                child: Stack(
                  children: [
                    // Основной список
                    widget.isLoading && _cities.isEmpty
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B51FF),
                      ),
                    )
                        : _cities.isEmpty
                        ? _buildEmptyWidget(isDark)
                        : _buildCitiesList(isDark),

                    // Мини-индикатор загрузки сверху (не блокирует UI)
                    if (_isSearching)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF5B51FF).withOpacity(0.5),
                          ),
                          minHeight: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon(bool isDark, String text) {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF5B51FF),
          ),
        ),
      );
    }

    if (text.isNotEmpty) {
      return GestureDetector(
        onTap: _clearSearch,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.cancel,
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF8E8E93),
            size: 20,
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildEmptyWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? const Color(0xFF4A4A4A) : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).nthybgtefr4terfd,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesList(bool isDark) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isSearching ? 0.6 : 1.0,
      child: ListView.separated(
        controller: _scrollController,
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
              if (isSelected) {
                Navigator.pop(context, null);
              } else {
                Navigator.pop(context, city);
              }
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF5B51FF)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${city.countryName} (${city.countryCode})',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93),
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
      onSearch: onSearch,
      isLoading: isLoading,
    ),
  );
}
