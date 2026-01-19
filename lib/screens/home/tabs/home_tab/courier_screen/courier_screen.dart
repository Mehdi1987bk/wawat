import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_documents_tab.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_offers_tab.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_profile_card.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_ratings_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/network/request/create_review_request.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../data/network/response/partner_user_response.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import 'courier_details_bloc.dart';

class CourierDetailsScreen extends BaseScreen {
  final int courierId;

  CourierDetailsScreen({
    Key? key,
    required this.courierId,
  }) : super(key: key);

  @override
  State<CourierDetailsScreen> createState() => _CourierDetailsScreenState();
}

class _CourierDetailsScreenState
    extends BaseState<CourierDetailsScreen, CourierDetailsBloc> {
  int _selectedTab = 0;

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          child: SafeArea(
            child: FutureBuilder<PartnerUserResponse>(
              future: bloc.getUserById(widget.courierId ?? 0),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.requireData.data;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        CourierProfileCard(
                          data: data,
                          onReviewSubmitted: (CreateReviewRequest request) {
                             print(
                                'Review Request ID: ${request.reviewRequestId}');
                            print('Target ID: ${request.targetId}');
                            print('Rating: ${request.rating}');
                            print('Comment: ${request.comment}');
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTabButtons(isDark),
                        const SizedBox(height: 16),
                        _buildTabContent(data),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF5B5BFF),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButtons(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabButton(index: 0, icon: Icons.description, isDark: isDark),
          _buildTabButton(index: 1, icon: Icons.star_outline, isDark: isDark),
          _buildTabButton(
              index: 2, icon: Icons.airplanemode_active_rounded, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5B5BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF6B7280) : Colors.grey[400]),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Data data) {
    switch (_selectedTab) {
      case 0:
        return CourierDocumentsTab(data: data);
      case 1:
        return CourierRatingsTab(data: data);
      case 2:
        return CourierOffersTab(data: data);
      default:
        return const SizedBox();
    }
  }

  @override
  CourierDetailsBloc provideBloc() {
    return CourierDetailsBloc();
  }
}
