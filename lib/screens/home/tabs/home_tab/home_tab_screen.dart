import 'package:flutter/material.dart';
import '../../../../presentation/bloc/base_screen.dart';
 import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../../wawat/modals/auth_required_modal.dart';
import '../../../../wawat/modals/login_modal.dart';
import '../../../../wawat/modals/registration_modal.dart';
import '../../../../wawat/widgets/wawat_button.dart';
import '../../../../wawat/widgets/wawat_courier_card.dart';
import '../../../../wawat/widgets/wawat_input_field.dart';
import 'home_tab_bloc.dart';

class HomeTabScreen extends BaseScreen {
  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends BaseState<HomeTabScreen, HomeTabBloc> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _categoryController = TextEditingController();

  int _selectedTab = 0;

  // Тестовые данные курьеров
  final List<CourierData> _popularCouriers = [
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
      rating: 4.9,
      description: 'Нужно передать документы и небольшой подарок',
      route: 'Лондон → Москва',
      date: '18 дек',
      time: '09:15',
      weight: 'до 2 кг',
      price: 'до \$30',
    ),
    CourierData(
      name: 'Дмитрий В.',
      role: 'Покупатель',
      isVerified: false,
      rating: 4.9,
      description: 'Покупаю электронику, нужна помощь с доставкой',
      route: 'Лондон → Москва',
      date: '18 дек',
      time: '09:15',
      weight: 'до 2 кг',
      price: 'до \$30',
    ),
  ];

  void _showAuthRequiredModal() {
    AuthRequiredModal.show(
      context,
      onRegister: () => _showRegistrationModal(),
      onLogin: () => _showLoginModal(),
    );
  }

  void _showRegistrationModal() {
    RegistrationModal.show(
      context,
      onLogin: () => _showLoginModal(),
    );
  }

  void _showLoginModal() {
    LoginModal.show(
      context,
      onRegister: () => _showRegistrationModal(),
    );
  }

  void _handleSearch() {
    // TODO: Implement search logic
    Navigator.pushNamed(context, '/search-results');
  }


  @override
  Widget body()  {
    return Scaffold(
      backgroundColor: WawatColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildHeroSection(),
                    _buildSearchForm(),
                    SizedBox(height: WawatDimensions.spacingLg),
                    _buildPopularOffers(),
                  ],
                ),
              ),
            ),
            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(WawatDimensions.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'asset/logo.png',
            fit: BoxFit.fitWidth,
            height: 40,
          ),
          Image.asset(
            'asset/notif_aa.png',
            fit: BoxFit.fitWidth,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingMd),
      padding: EdgeInsets.all(WawatDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: WawatColors.primaryGradient,
        borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: WawatDimensions.spacingMd),
          Text(
            'Ищи тех, кто летит — и передавай посылки надёжно и быстро',
            style: WawatTextStyles.h3.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: WawatDimensions.spacingSm),
          Text(
            'Быстрая и безопасная доставка посылок по всему миру',
            style: WawatTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
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
        children: [
          WawatDropdownField(
            label: 'ОТКУДА',
            placeholder: 'Город отправления',
            prefixIcon: Icon(Icons.location_on, size: WawatDimensions.iconMedium),
            onTap: () {
              // TODO: Show city picker
            },
          ),
          SizedBox(height: WawatDimensions.spacingMd),
          WawatDropdownField(
            label: 'КУДА',
            placeholder: 'Город назначения',
            prefixIcon: Icon(Icons.location_on, size: WawatDimensions.iconMedium),
            onTap: () {
              // TODO: Show city picker
            },
          ),
          SizedBox(height: WawatDimensions.spacingMd),
          WawatDropdownField(
            label: 'ДАТА С',
            placeholder: 'ДД.МММ.ГГГГ',
            prefixIcon: Icon(Icons.calendar_today, size: WawatDimensions.iconMedium),
            onTap: () {
              // TODO: Show date picker
            },
          ),
          SizedBox(height: WawatDimensions.spacingMd),
          WawatDropdownField(
            label: 'ДАТА ПО',
            placeholder: 'ДД.МММ.ГГГГ',
            prefixIcon: Icon(Icons.calendar_today, size: WawatDimensions.iconMedium),
            onTap: () {
              // TODO: Show date picker
            },
          ),
          SizedBox(height: WawatDimensions.spacingMd),
          WawatDropdownField(
            label: 'КАТЕГОРИЯ',
            placeholder: '🔍 Все категории',
            onTap: () {
              // TODO: Show category picker
            },
          ),
          SizedBox(height: WawatDimensions.spacingLg),
          WawatButton(
            text: '🔍 ПОИСК',
            onPressed: _handleSearch,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingMd),
          child: Text(
            'Популярные предложения',
            style: WawatTextStyles.h2,
          ),
        ),
        SizedBox(height: WawatDimensions.spacingMd),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _popularCouriers.length,
          itemBuilder: (context, index) {
            return WawatCourierCard(
              courier: _popularCouriers[index],
              onDetails: () {
                // TODO: Show courier details
              },
              onMessage: _showAuthRequiredModal,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: WawatDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: WawatColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: WawatColors.shadowLight,
            blurRadius: WawatDimensions.shadowBlurLight,
            offset: Offset(0, -WawatDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.search, 'Поиск', 0),
          _buildBottomNavItem(Icons.chat_bubble_outline, 'Чаты', 1),
          _buildBottomNavItem(Icons.add_circle, 'Подать', 2),
          _buildBottomNavItem(Icons.favorite_outline, 'Избранное', 3),
          _buildBottomNavItem(Icons.person_outline, 'Аккаунт', 4),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        if (index == 4) {
          // Account tab - show auth modal
          _showAuthRequiredModal();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? WawatColors.primary : WawatColors.textSecondary,
            size: WawatDimensions.bottomNavIconSize,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: WawatTextStyles.caption.copyWith(
              color: isSelected ? WawatColors.primary : WawatColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _categoryController.dispose();
    super.dispose();
  }


  @override
  HomeTabBloc provideBloc() {
    return HomeTabBloc();
  }
}
