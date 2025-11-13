import 'package:buking/screens/home/tabs/home_tab/widget/search_form_page.dart';
import 'package:buking/screens/home/tabs/home_tab/widget/wawat_courier_card.dart';
import 'package:flutter/material.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../presentation/resourses/wawat_text_styles.dart';
  import '../../../auth/auth_modal/auth_required_modal.dart';
import '../../../auth/login/login_modal.dart';
import '../../../auth/registration/registration_modal.dart';
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
  Widget body() {
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
                    SearchFormWidget(),
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
      color: Colors.white,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Image.asset(
            "asset/home_ban.png",
            width: 127,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
          child: Text(
            'Ищи тех, кто летит — и передавай посылки надёжно и быстро',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: WawatColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
          child: Text(
            'Быстрая и безопасная доставка посылок по всему миру',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: WawatColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }


  Widget _buildPopularOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingMd),
          child: Center(
            child: Text(
              'Популярные предложения',
              style: WawatTextStyles.h2,
            ),
          ),
        ),
        SizedBox(height: WawatDimensions.spacingMd),
        ListView.builder(
          padding: EdgeInsets.only(bottom: 30),
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
              color:
                  isSelected ? WawatColors.primary : WawatColors.textSecondary,
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
