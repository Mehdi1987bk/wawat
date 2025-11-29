import 'package:buking/screens/home/tabs/profile_tab/settings/personal_info_tab/personal_info_tab_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/privacy_tab/privacy_tab_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/user.dart';
import '../settings/experience_tab/experience_tab_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
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
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Редактировать профиль',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                unselectedLabelColor: const Color(0xFFC7C7CC),
                tabs: [
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
  }
}
