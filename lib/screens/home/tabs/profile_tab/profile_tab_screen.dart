import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/see_more_offers/delivery_full_list_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/verification/verification_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_history_widget.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/logout_dialog_content.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/user_details_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/offer_models.dart';
import '../../../../data/network/response/user.dart';
import '../../../../services/theme_manager.dart';
 import '../../home_screen.dart';
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                              _buildMenuSection(snapshot.requireData, isDark),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                      BuildHeader(context,isDark),
                    ],
                  ),
                );
              }
              return SizedBox();
            },
          );
      },
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }

  Widget _buildProfileHeader(User user, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.avatar != null)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(user.avatar ?? ""),
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (user.avatar == null)
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                    child: Text(user.fullname),
                  ),
                ],
              ),
              if (user.isVerified == true)
                Row(
                  children: [
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
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                ),
                child: Text(user.email ?? ""),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                ),
                child: Text(user.phone ?? ""),
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

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
    required BuildContext context,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF000000),
            ),
            child: Text(value),
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
          // ===== ПЕРЕКЛЮЧАТЕЛЬ ТЕМНОЙ ТЕМЫ =====
          Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              return GestureDetector(
                onTap: () {
                  themeManager.toggleTheme();
                },
                child: _buildThemeToggleItem(
                  icon: themeManager.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  title: 'Тема оформления',
                  subtitle: themeManager.isDarkMode ? 'Тёмная тема включена' : 'Светлая тема включена',
                  bgColor: themeManager.isDarkMode
                      ? const Color(0xFF1E1E3F)
                      : const Color(0xFFFEF3C7),
                  iconColor: themeManager.isDarkMode
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFFCD34D),
                  isDarkMode: themeManager.isDarkMode,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return VerificationScreen(user: user);
                })),
            child: _buildMenuItem(
              icon: Icons.shield_outlined,
              title: 'Верификация',
              subtitle: 'Подтвердить документы',
              bgColor: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF10B981),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return DeliveryFullListScreen();
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.access_time_filled,
              title: 'Обьявления',
              subtitle: 'Истории обьявления',
              bgColor: WawatColors.primary.withOpacity(0.1),
              iconColor: WawatColors.primary,
              isDark: isDark,
            ),
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

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return EditProfileScreen(user: user);
                },
              ),
            ),
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

          GestureDetector(
            onTap: () => showLogoutBottomSheet(
                title: "Выйти",
                description:"Вы уверены, что хотите выйти?",
                yes: "Да, выйти",
                no: "Нет, отменить",
                context: context,
                onConfirmLogout: () {
                  bloc.logout.then(
                        (value) {
                      return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) {
                          return HomeScreen();
                        },
                      ), (route) => false);
                    },
                  );
                }),
            child: _buildMenuItem(
              icon: Icons.logout_outlined,
              title: 'Выйти',
              subtitle: 'Выход из аккаунта',
              bgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFFCA5A5),
              isLogout: true,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  void showLogoutBottomSheet({
    required BuildContext context,
    required VoidCallback onConfirmLogout,
    String? title,
    String? description,
    String? yes,
    String? no,
  }) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      builder: (_) => LogoutDialogContent(
        onConfirmLogout: onConfirmLogout,
        no: no,
        yes: yes,
        title: title,
        description: description,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
              color: bgColor,
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLogout
                        ? const Color(0xFFDC2626)
                        : (isDark ? Colors.white : const Color(0xFF000000)),
                  ),
                  child: Text(title),
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
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                  ),
                  child: Text(title),
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
          _buildCustomSwitch(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool isOn) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isOn
            ? const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: isOn ? null : const Color(0xFFE5E7EB),
        boxShadow: [
          BoxShadow(
            color: isOn
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isOn ? Icons.dark_mode : Icons.light_mode,
            size: 16,
            color: isOn ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

class CircularAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CircularAvatar({
    Key? key,
    this.imageUrl,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5BFF), Color(0xFFB847FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size / 2,
      ),
    );
  }
}
