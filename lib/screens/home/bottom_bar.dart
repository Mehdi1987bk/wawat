import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../services/theme_manager.dart';

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
    final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
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
                isCentral: true,
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
        ),
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
    final Color inactiveColor = isDark ? const Color(0xFF6B7280) : Color(0xFF9E9E9E);

    // Цвета для состояний
    final Color bgColor = isCentral && isSelected
        ? Colors.transparent
        : (isSelected
        ? (isDark ? const Color(0xFF2A2A2A) : Color(0xFFEFF6FF))
        : Colors.transparent);

    final Color iconBgColor = isCentral && isSelected
        ? Colors.white.withOpacity(0.3)
        : (isSelected
        ? (isDark ? const Color(0xFF3A3A3A) : Color(0xFFDBEAFE))
        : Colors.transparent);

    final Color iconColor = isCentral && isSelected
        ? Colors.white
        : (isSelected ? activeColor : inactiveColor);

    // Градиент для центральной кнопки
    final gradient = LinearGradient(
      colors: [Color(0xFF2662EA), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.17,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              decoration: BoxDecoration(
                gradient: isCentral && isSelected ? gradient : null,
                color: isCentral && isSelected ? null : Color.lerp(Colors.transparent, bgColor, value),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isCentral && isSelected
                    ? [
                  BoxShadow(
                    color: Color(0xFF2662EA).withOpacity(0.3 * value),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.transparent, iconBgColor, value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      svgIcon,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        Color.lerp(inactiveColor, iconColor, value)!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color.lerp(inactiveColor, iconColor, value),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
