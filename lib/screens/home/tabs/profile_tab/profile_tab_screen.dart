import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:buking/screens/home/tabs/profile_tab/privacy_policy/privacy_policy_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/see_more_offers/delivery_full_list_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/support/support_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/verification/verification_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_history_widget.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/localization_pop_up.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/logout_dialog_content.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/user_details_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/offer_models.dart';
import '../../../../data/network/response/user.dart';
import '../../../../generated/l10n.dart';
import '../../../../services/theme_manager.dart';
import '../../home_screen.dart';
import '../home_tab/home_tab_screen.dart';
import '../home_tab/notification/unread_notif_bloc.dart';
import '../home_tab/widget/build_header.dart';
import 'courier_reviews_page.dart';
import 'faq/faq_screen.dart';

class ProfileTabScreen extends BaseScreen {
  ProfileTabScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState
    extends BaseState<ProfileTabScreen, ProfileTabBloc> {
  @override
  bool get useSystemOverlay => false;
  late final UnreadNotificationBloc _notificationBloc; // <- ДОБАВИТЬ

  @override
  void initState() {
    // <- ДОБАВИТЬ весь метод
    super.initState();
    _notificationBloc = UnreadNotificationBloc();
    _notificationBloc.init();
  }

  @override
  void dispose() {
    // <- ДОБАВИТЬ весь метод
    _notificationBloc.dispose();
    super.dispose();
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return StreamBuilder<User>(
          stream: bloc.userDetails,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).dsvfsd,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(S.of(context).fds),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : WawatColors.primary,
                ),
              );
            }

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
                            margin:
                                EdgeInsets.only(left: 16, right: 16, top: 20),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.3 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                const SizedBox(height: 20),
                                _buildProfileHeader(
                                    snapshot.requireData, isDark),
                                const SizedBox(height: 16),
                                _buildStatsCard(
                                    context, snapshot.requireData, isDark),
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
                  StreamBuilder<int>(
                    stream: _notificationBloc.unreadCountStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      return BuildHeader(
                        context,
                        isDark: isDark,
                        unreadCount: snapshot.data ?? 0,
                        onNotificationsReturned: () {
                          _notificationBloc.fetchUnreadCount();
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }

  Widget _buildLanguageItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required bool isDarkMode,
    required String currentLanguage,
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
                    color: isDarkMode
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF000000),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.2),
                  iconColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLanguage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                      child: Text(
                        S.of(context).h46h46,
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
                  color: isDark
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF6B7280),
                ),
                child: Text(user.email ?? ""),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF6B7280),
                ),
                child: Text(
                    (user.country?.callingCode ?? "") + (user.phone ?? "")),
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
                icon: Icons.airplanemode_active_rounded,
                value: user.stats?.deliveriesCount.toString() ?? "",
                label: S.of(context).gbgrbyhe435,
                context: context,
                isDark: isDark,
              ),
              _buildStatItem(
                icon: "asset/prof_ic_2.png",
                value: user.stats?.ratingAvg.toString() ?? "",
                label: S.of(context).hgg4235gb,
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
                value: user.stats?.reviewsReceivedCount.toString() ?? "",
                label: S.of(context).bgfh364,
                context: context,
                isDark: isDark,
              ),
              _buildStatItem(
                icon: "asset/prof_ic_4.png",
                value: (user.stats?.yearsOnPlatform?.toStringAsFixed(0) ?? "") +
                    ' ' +
                    S.of(context).bgfbg33,
                label: S.of(context).htr345gfd,
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
    required dynamic icon, // ✅ Изменено на dynamic - теперь можно передать String или IconData
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
          // ✅ Условный рендеринг - проверяем тип
          icon is IconData
              ? Icon(
            icon,
            size: 24,
            color: const Color(0xFF3B82F6),
          )
              : Image.asset(
            icon as String,
            width: 24,
            height: 24, // ✅ Добавлена высота для симметрии
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
          StreamBuilder<Locale?>(
              stream: bloc.locale,
              builder: (context, snapshot) {
                final currentLocale = snapshot.data ?? const Locale("en");

                return GestureDetector(
                  onTap: () => _showMenu(snapshot.data),
                  child: _buildLanguageItem(
                    icon: Icons.language,
                    title: S.of(context).languandff,
                    subtitle: S.of(context).vgfb35,
                    bgColor: isDark
                        ? const Color(0xFF1E3A2F)
                        : const Color(0xFFDCFCE7),
                    iconColor: isDark
                        ? const Color(0xFF10B981)
                        : const Color(0xFF059669),
                    isDarkMode: isDark,
                    currentLanguage: currentLocale.languageCode,
                  ),
                );
              }),
          const SizedBox(height: 12),
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
                  title: S.of(context).fggdf345,
                  subtitle: themeManager.isDarkMode
                      ? S.of(context).bfd4r53gfd
                      : S.of(context).bgfb453,
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
              title: S.of(context).bdb4w5gfd,
              subtitle: S.of(context).bdfgt43refg,
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
              title: S.of(context).bdfbfd43tgfd,
              subtitle: S.of(context).bdfbertgfvdre,
              bgColor: WawatColors.primary.withOpacity(0.1),
              iconColor: WawatColors.primary,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return MyRevievsScreen(
                    courierId: user.id ?? 0,
                  );
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.star_outline,
              title: S.of(context).nfgn53tgdfg,
              subtitle: S.of(context).bgf43bgfd3,
              bgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFFCD34D),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return SupportScreen();
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.headset_mic_rounded,
              title: S.of(context).bgfbgfeerfdfd,
              subtitle: S.of(context).bgbgf34fdg,
              bgColor: Color(0xFF031B7A).withOpacity(0.9),
              iconColor: Colors.white,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return EditProfileScreen();
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.settings_outlined,
              title: S.of(context).bgfbgf34gvfd,
              subtitle: S.of(context).nfngret4,
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return PrivacyPolicyScreen();
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.privacy_tip,
              title: S.of(context).privacyPolicy,
              subtitle: S.of(context).privacyPolicyvfev,
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return FaqScreen();
                },
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.question_answer_outlined,
              title: S.of(context).faq,
              subtitle: S.of(context).viewFaq,
              bgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showLogoutBottomSheet(
                title: S.of(context).ngfngfn44,
                description: S.of(context).vxer3,
                yes: S.of(context).bg33a,
                no: S.of(context).bnbv3h,
                context: context,
                onConfirmLogout: () {
                  bloc.logout().then(
                    // ИСПРАВЛЕНО: Добавлены скобки ()
                    (value) {
                      return Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(
                        builder: (BuildContext context) {
                          return HomeScreen();
                        },
                      ), (route) => false);
                    },
                  );
                }),
            child: _buildMenuItem(
              icon: Icons.logout_outlined,
              title: S.of(context).bgd32,
              subtitle: S.of(context).bgfnyuj3,
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

  void _showMenu(Locale? locale) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      builder: (_) {
        return LocalizationPopUp(
          currentLocale: locale,
          onChanged: (Locale newLocale) {
            bloc.setLocale(newLocale);
          },
        );
      },
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
                    color: isDarkMode
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF000000),
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
