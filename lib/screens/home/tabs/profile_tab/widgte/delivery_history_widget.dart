import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../home_tab/widget/wawat_courier_card.dart';
import '../see_more_offers/delivery_full_list_screen.dart';

class DeliveryHistoryWidget extends StatelessWidget {
  final OfferListResponse response;

  const DeliveryHistoryWidget({Key? key, required this.response})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offers = response.data ?? [];

    if (offers.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: WawatDark.border) : null,
        ),
        child: Text(
          S.of(context).gbdyh5g,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? WawatDark.textMuted : Color(0xFF6B7280),
          ),
        ),
      );
    }

    final displayOffers = offers.take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: WawatDark.border) : null,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).bfdgbt5,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? WawatDark.textPrimary : Color(0xFF000000),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return DeliveryFullListScreen();
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? cBrandFill : const Color(0xFF5B5BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      S.of(context).bgnhju46,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...displayOffers.map((offer) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WawatCourierCard(
                  sendMessageActiv: false,
                  detailsActiv: false,
                  courier: offer,
                  onFavoriteToggle: (v) {},
                ));
          }).toList(),
        ],
      ),
    );
  }
}
