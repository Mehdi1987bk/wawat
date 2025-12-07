import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/presentation/resourses/theme_provider.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_history_widget.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/user_details_setting.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/offer_models.dart';
import '../../../../data/network/response/user.dart';
import '../home_tab/home_tab_screen.dart';

class ProfileTabScreen extends BaseScreen {
  ProfileTabScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState
    extends BaseState<ProfileTabScreen, ProfileTabBloc> {
  @override
  Widget body() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return StreamBuilder<User>(
      stream: bloc.userDetails,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.getCardBg(isDark),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildProfileHeader(snapshot.requireData, isDark),
                              const SizedBox(height: 16),
                              _buildStatsCard(context, snapshot.requireData, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildThemeToggle(themeProvider, isDark),
                        const SizedBox(height: 24),
                        FutureBuilder<OfferListResponse>(
                          future: bloc.myOffers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data?.data == null) {
                              return const SizedBox();
                            }
                            return DeliveryHistoryWidget(response: snapshot.requireData);
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildMenuSection(snapshot.requireData, isDark),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                BuildHeader(context),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBg(isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Color(0xFF1E1E2E), Color(0xFF2D2D44)]
                      : [Color(0xFFFEF3C7), Color(0xFFFCD34D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Color(0xFFFCD34D) : Color(0xFFD97706),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Темная тема' : 'Светлая тема',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Переключиться на светлую' : 'Переключиться на темную',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Color(0xFF9CA3AF) : Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.1,
              child: Switch(
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: Color(0xFF5B5BFF),
                activeTrackColor: Color(0xFFB847FF).withOpacity(0.5),
                inactiveThumbColor: Color(0xFFD1D5DB),
                inactiveTrackColor: Color(0xFFE5E7EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B5BFF), Color(0xFFB847FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
            // Container(
            //               width: 80,
            //               height: 80,
            //               decoration: BoxDecoration(
            //                 shape: BoxShape.circle,
            //                 gradient: const LinearGradient(
            //                   colors: [Color(0xFF5B5BFF), Color(0xFFB847FF)],
            //                   begin: Alignment.topLeft,
            //                   end: Alignment.bottomRight,
            //                 ),
            //               ),
            //               child: ClipRRect(
            //                 borderRadius: BorderRadius.circular(40),
            //                 child: Image.network(
            //                   user.name,
            //                   fit: BoxFit.cover,
            //
            //                 ),
            //               ),
            //             ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                padding: EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2857DA),
                ),
                child: Image.asset(
                  "asset/prof_1.png",
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Wawat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    "asset/prof_3.png",
                    width: 16,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    child: const Text(
                      'Проверен',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'example@mail.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '+7 (999) 123-45-67',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, User user, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: "asset/prof_ic_1.png",
                value: '24',
                label: 'Доставки',
                context: context,
                isDark: isDark,
              ),
              _buildStatItem(
                icon: "asset/prof_ic_2.png",
                value: user.rating?.average.toString() ?? "0",
                label: 'Рейтинг',
                context: context,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: "asset/prof_ic_3.png",
                value: '18',
                label: 'Отзывы',
                context: context,
                isDark: isDark,
              ),
              _buildStatItem(
                icon: "asset/prof_ic_4.png",
                value: '2 года',
                label: 'На сайте',
                context: context,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      {required String icon,
      required String value,
      required String label,
      required BuildContext context,
      required bool isDark}) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1B28) : Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            icon,
            width: 24,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuSection(User user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (BuildContext context) {
              return EditProfileScreen(
                user: user,
              );
            })),
            child: _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Настройки',
              subtitle: 'Управление аккаунтом',
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Верификация',
            subtitle: 'Подтвердить документы',
            bgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: 'Отзывы',
            subtitle: 'Посмотреть отзывы',
            bgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFFCD34D),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.logout_outlined,
            title: 'Выйти',
            subtitle: 'Выход из аккаунта',
            bgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFFCA5A5),
            isLogout: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required bool isDark,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? bgColor.withOpacity(0.2) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLogout
                        ? const Color(0xFFDC2626)
                        : AppColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 24,
            color: isDark ? Color(0xFF6B7280) : Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }
}
