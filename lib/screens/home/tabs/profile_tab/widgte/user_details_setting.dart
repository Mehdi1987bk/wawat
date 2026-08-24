import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/user.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../services/theme_manager.dart';
import '../profile_tab_bloc.dart';
import '../settings/change_password_tab/change_password_tab_screen.dart';
import '../settings/experience_tab/experience_tab_screen.dart';
import '../settings/personal_info_tab/personal_info_tab_screen.dart';
import '../settings/privacy_tab/privacy_tab_screen.dart';

class EditProfileScreen extends BaseScreen {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState
    extends BaseState<EditProfileScreen, ProfileTabBloc>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 🔥 Изменено на 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget body() {
    return StreamBuilder<User>(
      stream: bloc.userDetails,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              final isDark = themeManager.isDarkMode;
              return Scaffold(
                backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
                body: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              child:   Text(S.of(context).vfgbhyujkerg3),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Tab Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFC7C7CC),
                          tabs: const [
                            Tab(
                              child: SizedBox(
                                width: double.infinity,
                                child: Icon(Icons.person, size: 24),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: double.infinity,
                                child: Icon(Icons.bookmark_outline, size: 24),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: double.infinity,
                                child: Icon(Icons.shield, size: 24),
                              ),
                            ),
                            // 🔥 Новая вкладка для пароля
                            Tab(
                              child: SizedBox(
                                width: double.infinity,
                                child: Icon(Icons.key, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            PersonalInfoTab(
                              user: snapshot.requireData,
                            ),
                            PrivacyTab(
                              showPhoneTab:
                              snapshot.requireData.privacy?.showPhone ??
                                  false,
                              showEmailTab:
                              snapshot.requireData.privacy?.showEmail ??
                                  false,
                              showActivityTime: snapshot
                                  .requireData.privacy?.showActivityTime ??
                                  false,
                              showNewMessages: snapshot.requireData
                                  .notifications?.notifyNewMessages ??
                                  false,
                              showNewReviews: snapshot.requireData.notifications
                                  ?.notifyNewReviews ??
                                  false,
                              showMarketing: snapshot.requireData.notifications
                                  ?.notifyMarketing ??
                                  false,
                            ),
                            ExperienceTab(
                              user: snapshot.requireData,
                            ),
                            ChangePasswordTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }
}
