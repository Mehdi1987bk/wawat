import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../presentation/resourses/app_colors.dart';
import '../../presentation/resourses/theme_provider.dart';

class BottomBar extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  const BottomBar({
    super.key,
    required this.onChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      color: AppColors.getCardBg(isDark),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavigationItem(
            index: 0,
            selectedIndex: selectedIndex,
            label: 'Поиск',
            svgIcon: 'asset/tab1.svg',
            onChanged: onChanged,
            isCentral: false,
            isDark: isDark,
          ),
          BottomNavigationItem(
            index: 1,
            selectedIndex: selectedIndex,
            label: 'Чаты',
            svgIcon: 'asset/tab2.svg',
            onChanged: onChanged,
            isCentral: false,
            isDark: isDark,
          ),
          BottomNavigationItem(
            index: 2,
            selectedIndex: selectedIndex,
            label: 'Подать',
            svgIcon: 'asset/tab3.svg',
            onChanged: onChanged,
            isCentral: true, // Центральная кнопка с градиентом
            isDark: isDark,
          ),
          BottomNavigationItem(
            index: 3,
            selectedIndex: selectedIndex,
            label: 'Избранное',
            svgIcon: 'asset/tab4.svg',
            onChanged: onChanged,
            isCentral: false,
            isDark: isDark,
          ),
          BottomNavigationItem(
            index: 4,
            selectedIndex: selectedIndex,
            label: 'Аккаунт',
            svgIcon: 'asset/tab5.svg',
            onChanged: onChanged,
            isCentral: false,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final String svgIcon;
  final ValueChanged<int> onChanged;
  final bool isCentral;
  final bool isDark;

  const BottomNavigationItem({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.svgIcon,
    required this.onChanged,
    this.isCentral = false,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    final Color activeColor = Color(0xFF2857DA);
    final Color inactiveColor = isDark ? Color(0xFF6B7280) : Color(0xFF9E9E9E);

    // Градиент для центральной кнопки
    final gradient = LinearGradient(
      colors: [Color(0xFF2662EA), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.17,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          gradient: isCentral && isSelected ? gradient : null,
          color: isCentral && isSelected
              ? Colors.white
              : (isSelected
                  ? (isDark ? Color(0xFF1E1F28) : Color(0xFFEFF6FF))
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Обычная кнопка
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCentral && isSelected
                    ? Colors.white.withOpacity(0.3)
                    : (isSelected
                        ? (isDark
                            ? Color(0xFF2A2B38)
                            : Color(0xFFDBEAFE))
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                svgIcon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isCentral && isSelected
                      ? Colors.white
                      : (isSelected ? activeColor : inactiveColor),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isCentral && isSelected
                    ? Colors.white
                    : (isSelected ? activeColor : inactiveColor),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
