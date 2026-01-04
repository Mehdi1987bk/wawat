import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../services/theme_aware_screen.dart';
import '../../../../../../services/theme_manager.dart';

class CourierRatingsTab extends StatelessWidget {
  final Data data;

  const CourierRatingsTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
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
            child: Column(
              children: [
                if (data.reviewsReceived.isEmpty)
                  Container(
                    height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : Colors.grey[600],
                            ),
                            child: Center(
                              child: Text(
                                S.of(context).bgrfw3542rfsd,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...data.reviewsReceived.asMap().entries.map((entry) {
                    int index = entry.key;
                    Review review = entry.value;
                    return _buildReviewCard(review, isDark);
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                decoration: const BoxDecoration(
                  color: Color(0xFF5B5BFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.author.fullname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: Text(review.author.fullname),
                    ),
                  ],
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
                    : (isDark ? const Color(0xFF4A4A4A) : Colors.grey[300]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[700],
              height: 1.4,
            ),
            child: Text(review.comment),
          ),
        ],
      ),
    );
  }
}
