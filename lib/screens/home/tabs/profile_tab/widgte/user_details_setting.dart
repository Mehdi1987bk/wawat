
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/user.dart';
import '../../../../../services/theme_manager.dart';
import '../settings/experience_tab/experience_tab_screen.dart';
import '../settings/personal_info_tab/personal_info_tab_screen.dart';
import '../settings/privacy_tab/privacy_tab_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: const Text('Редактировать профиль'),
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
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                        colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
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
                        user: widget.user,
                      ),
                      PrivacyTab(
                        showPhoneTab: widget.user.privacy?.showPhone ?? false,
                        showEmailTab: widget.user.privacy?.showEmail ?? false,
                        showActivityTime:
                        widget.user.privacy?.showActivityTime ?? false,
                        showNewMessages:
                        widget.user.notifications?.notifyNewMessages ?? false,
                        showNewReviews:
                        widget.user.notifications?.notifyNewReviews ?? false,
                        showMarketing:
                        widget.user.notifications?.notifyMarketing ?? false,
                      ),
                      ExperienceTab(
                        user: widget.user,
                      ),
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
}
