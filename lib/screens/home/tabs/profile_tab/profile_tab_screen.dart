import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_history_widget.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/user_details_setting.dart';
import 'package:buking/screens/home/tabs/profile_tab/widgte/delivery_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Container(
      child: StreamBuilder<User>(
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
                              color: Colors.white,
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
                                _buildProfileHeader(snapshot.requireData),
                                const SizedBox(height: 16),
                                _buildStatsCard(context, snapshot.requireData),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<OfferListResponse>(
                            future: bloc.myOffers,
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
                          _buildMenuSection(snapshot.requireData),
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
      ),
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }

  Widget _buildProfileHeader(User user) {
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
                  const Text(
                    'Wawat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
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

  Widget _buildStatsCard(BuildContext context, User user) {
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
              ),
              _buildStatItem(
                icon: "asset/prof_ic_2.png",
                value: user.rating?.average.toString() ?? "0",
                label: 'Рейтинг',
                context: context,
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
              ),
              _buildStatItem(
                icon: "asset/prof_ic_4.png",
                value: '2 года',
                label: 'На сайте',
                context: context,
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
      required BuildContext context}) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
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


  Widget _buildMenuSection(User user) {
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
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Верификация',
            subtitle: 'Подтвердить документы',
            bgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: 'Отзывы',
            subtitle: 'Посмотреть отзывы',
            bgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFFCD34D),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.logout_outlined,
            title: 'Выйти',
            subtitle: 'Выход из аккаунта',
            bgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFFCA5A5),
            isLogout: true,
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
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLogout
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF000000),
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
          const Icon(
            Icons.chevron_right,
            size: 24,
            color: Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }
}
