import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../../services/theme_manager.dart';
import '../../widget/wawat_courier_card.dart';

class CourierOffersTab extends StatelessWidget {
  final Data data;

  const CourierOffersTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        if (data.offers.active.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: isDark ? cFaint(true) : const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(height: 16),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? cText2(true) : const Color(0xFF6B7280),
                    ),
                    child: Text(S.of(context).ynbreg4t3gfwr3gf),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.offers.active.length,
          itemBuilder: (BuildContext context, int index) {
            return WawatCourierCard(
              detailsActiv: false,
              courier: data.offers.active[index],
            );
          },
        );
      },
    );
  }
}
