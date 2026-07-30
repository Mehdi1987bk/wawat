import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/network/response/partner_user_response.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../../../data/network/response/reviews_response.dart';
import '../../../../generated/l10n.dart';
import '../home_tab/courier_screen/courier_details_bloc.dart';
import '../home_tab/courier_screen/courier_screen.dart';

class MyRevievsScreen extends BaseScreen {
  final int courierId;

  MyRevievsScreen({
    Key? key,
    required this.courierId,
  }) : super(key: key);

  @override
  State<MyRevievsScreen> createState() => _MyRevievsScreenState();
}

class _MyRevievsScreenState
    extends BaseState<MyRevievsScreen, CourierDetailsBloc> {
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
              future: bloc.getUserById(widget.courierId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.requireData.data;
                  return Column(
                    children: [
                      _buildHeader(data, isDark),
                      const SizedBox(height: 16),
                      _buildTabButtons(isDark),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _selectedTab == 0
                              ? FutureBuilder<ReviewsResponse>(
                                  future: bloc.myAboutReviev(),
                                  builder: (context, reviewsSnapshot) {
                                    if (reviewsSnapshot.hasData) {
                                      final reviewsData =
                                          reviewsSnapshot.requireData.data;
                                      return _buildReceivedReviews(
                                          reviewsData, isDark);
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? cBrandText(isDark)
                                            : const Color(0xFF5B5BFF),
                                      ),
                                    );
                                  },
                                )
                              : FutureBuilder<ReviewsResponse>(
                                  future: bloc.myAboutLeft(),
                                  builder: (context, reviewsSnapshot) {
                                    if (reviewsSnapshot.hasData) {
                                      final reviewsData =
                                          reviewsSnapshot.requireData.data;
                                      return _buildLeftReviews(
                                          reviewsData, isDark);
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? cBrandText(isDark)
                                            : const Color(0xFF5B5BFF),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color:
                        isDark ? cBrandText(isDark) : const Color(0xFF5B5BFF),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Data data, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cCard(isDark) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: cCardBorder(isDark),
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? cFill(isDark) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: isDark ? cText(isDark) : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? cText(isDark) : const Color(0xFF1A1A1A),
                  ),
                  child: Text(
                    S.of(context).listingHistory,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? cText(isDark) : const Color(0xFF1A1A1A),
                      ),
                      child: Text(
                        (data.stats.ratingAvg).toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? cCard(isDark) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: cCardBorder(isDark),
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
        children: [
          _buildTabButton(
              index: 0, title: S.of(context).hbfgh3, isDark: isDark),
          _buildTabButton(
              index: 1, title: S.of(context).gert3tger, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
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
            color: isSelected
                ? (isDark ? cBrandFill : const Color(0xFF5B5BFF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? cMuted(isDark) : Colors.grey[400]),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Полученные отзывы (из data.reviewsReceived)
  Widget _buildReceivedReviews(List<ReviewModel> reviews, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (reviews.isEmpty)
            _buildEmptyState(S.of(context).bvfdgb43, isDark)
          else
            ...reviews.map((review) {
              return _buildLeftReviewCard(
                  review,
                  review.author?.id ?? 0,
                  review.author?.avatarThumbUrl ?? review.author?.avatar,
                  isDark);
            }).toList(),
        ],
      ),
    );
  }

  // Оставленные отзывы (из ReviewsResponse)
  Widget _buildLeftReviews(List<ReviewModel> reviews, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (reviews.isEmpty)
            _buildEmptyState(S.of(context).bfdtw4ew4, isDark)
          else
            ...reviews.map((review) {
              return _buildLeftReviewCard(
                  review,
                  review.target?.id ?? 0,
                  review.target?.avatarThumbUrl ?? review.target?.avatar,
                  isDark);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Container(
      height: 300,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? cText2(isDark) : Colors.grey[600],
          ),
          child: Text(message),
        ),
      ),
    );
  }

  // Карточка для полученных отзывов (Review)
  Widget _buildReceivedReviewCard(Review review, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? cCard(isDark) : Colors.white,
        border: cCardBorder(isDark),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? cBrandFill : const Color(0xFF5B5BFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.author.fullname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? cText(isDark) : Colors.black,
                  ),
                  child: Text(review.author.fullname),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 14,
                color: index < review.rating
                    ? Colors.amber
                    : (isDark ? cFaint(isDark) : Colors.grey[300]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? cText2(isDark) : Colors.grey[700],
              height: 1.4,
            ),
            child: Text(review.comment ?? ""),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftReviewCard(
      ReviewModel review, int id, String? url, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? cCard(isDark) : Colors.white,
        border: cCardBorder(isDark),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return CourierDetailsScreen(
                      courierId: id,
                    );
                  },
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: url != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? cText(isDark) : Colors.black,
                    ),
                    child: Text(
                        (review.author?.fullname ?? review.target?.fullname) ??
                            ""),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 14,
                color:
                    index < (int.tryParse(review.rating.toString() ?? '0') ?? 0)
                        ? Colors.amber
                        : (isDark ? cFaint(isDark) : Colors.grey[300]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? cText2(isDark) : Colors.grey[700],
              height: 1.4,
            ),
            child: Text(review.comment ?? ''),
          ),
        ],
      ),
    );
  }

  @override
  CourierDetailsBloc provideBloc() {
    return CourierDetailsBloc();
  }
}
