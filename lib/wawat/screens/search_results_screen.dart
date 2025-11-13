import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';
import '../../screens/home/tabs/home_tab/widget/wawat_courier_card.dart';
import '../widgets/wawat_button.dart';
 import '../widgets/wawat_chip.dart';

/// Экран результатов поиска
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _sortBy = 'По рейтингу';

  // Тестовые данные результатов
  final List<CourierData> _searchResults = [
    CourierData(
      name: 'Алексей К.',
      role: 'Курьер',
      isVerified: true,
      rating: 4.9,
      description: 'Опытный курьер, более 100 успешных доставок',
      route: 'Лондон → Москва',
      date: '18 дек',
      time: '09:15',
      weight: 'до 2 кг',
      price: 'до \$30',
    ),
    CourierData(
      name: 'Максим Р.',
      role: 'Отправитель',
      isVerified: true,
      rating: 4.8,
      description: 'Нужно передать документы и небольшой подарок',
      route: 'Баку → Киев',
      date: '20 окт',
      time: '14:30',
      weight: 'до 3 кг',
      price: 'до \$40',
    ),
    CourierData(
      name: 'Дмитрий В.',
      role: 'Покупатель',
      isVerified: false,
      rating: 4.7,
      description: 'Покупаю электронику, нужна помощь с доставкой',
      route: 'Лондон → Москва',
      date: '18 дек',
      time: '09:15',
      weight: 'до 5 кг',
      price: 'до \$50',
    ),
    CourierData(
      name: 'Елена С.',
      role: 'Курьер',
      isVerified: true,
      rating: 4.9,
      description: 'Надежная доставка, всегда вовремя',
      route: 'Лондон → Москва',
      date: '19 дек',
      time: '10:00',
      weight: 'до 2 кг',
      price: 'до \$25',
    ),
    CourierData(
      name: 'Игорь П.',
      role: 'Курьер',
      isVerified: true,
      rating: 4.6,
      description: 'Быстрая и аккуратная доставка',
      route: 'Лондон → Москва',
      date: '21 дек',
      time: '11:15',
      weight: 'до 3 кг',
      price: 'до \$35',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WawatColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterInfo(),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return WawatCourierCard(
                    courier: _searchResults[index],
                    onDetails: () {
                      // TODO: Show courier details
                    },
                    onMessage: () {
                      // TODO: Show message screen
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(WawatDimensions.spacingMd),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(child: SizedBox()),
          WawatOutlineButton(
            text: '🔎 Фильтры',
            onPressed: () {
              // TODO: Show filters
            },
            height: 36,
          ),
          SizedBox(width: WawatDimensions.spacingSm),
          WawatOutlineButton(
            text: '📍 На карте',
            onPressed: () {
              // TODO: Show map
            },
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingMd),
      padding: EdgeInsets.all(WawatDimensions.spacingMd),
      decoration: BoxDecoration(
        color: WawatColors.backgroundWhite,
        borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: WawatColors.shadowLight,
            blurRadius: WawatDimensions.shadowBlurLight,
            offset: Offset(0, WawatDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Результаты поиска',
            style: WawatTextStyles.h3,
          ),
          SizedBox(height: WawatDimensions.spacingSm),

          // Active Filters
          Wrap(
            spacing: WawatDimensions.spacingSm,
            runSpacing: WawatDimensions.spacingXs,
            children: [
              WawatChip(
                text: '📍 Баку',
                type: WawatChipType.gray,
                onDelete: () {
                  // TODO: Remove filter
                },
              ),
              WawatChip(
                text: '👤 Киев',
                type: WawatChipType.gray,
                onDelete: () {
                  // TODO: Remove filter
                },
              ),
              WawatChip(
                text: '📅 2025-10-17',
                type: WawatChipType.gray,
                onDelete: () {
                  // TODO: Remove filter
                },
              ),
            ],
          ),
          SizedBox(height: WawatDimensions.spacingMd),

          // Sort and Stats
          Row(
            children: [
              Expanded(
                child: Text(
                  'Найдено ${_searchResults.length} курьеров',
                  style: WawatTextStyles.body,
                ),
              ),
              // Sort Dropdown
              GestureDetector(
                onTap: () {
                  _showSortOptions();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: WawatDimensions.spacingSm,
                    vertical: WawatDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: WawatColors.inputBorder),
                    borderRadius: BorderRadius.circular(WawatDimensions.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortBy,
                        style: WawatTextStyles.caption,
                      ),
                      SizedBox(width: WawatDimensions.spacingXs),
                      Icon(
                        Icons.arrow_drop_down,
                        size: WawatDimensions.iconMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: WawatDimensions.spacingXs),

          // Stats
          Text(
            'Показано ${_searchResults.length} из ${_searchResults.length}',
            style: WawatTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(WawatDimensions.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('По рейтингу'),
                onTap: () {
                  setState(() {
                    _sortBy = 'По рейтингу';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('По цене'),
                onTap: () {
                  setState(() {
                    _sortBy = 'По цене';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('По дате'),
                onTap: () {
                  setState(() {
                    _sortBy = 'По дате';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
