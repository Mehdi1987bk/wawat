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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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

class BottomNavigationItem extends StatefulWidget {
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
  State<BottomNavigationItem> createState() => _BottomNavigationItemState();
}

class _BottomNavigationItemState extends State<BottomNavigationItem> {
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _wasSelected = widget.selectedIndex == widget.index;
  }

  @override
  void didUpdateWidget(BottomNavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем состояние после rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _wasSelected = widget.selectedIndex == widget.index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selectedIndex == widget.index;
    final Color activeColor = Color(0xFF2857DA);
    final Color inactiveColor = widget.isDark ? const Color(0xFF6B7280) : Color(0xFF9E9E9E);

    // Градиент для центральной кнопки
    final gradient = LinearGradient(
      colors: [Color(0xFF2662EA), Color(0xFF9333EA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Анимация только при активации (becoming selected), мгновенная смена при деактивации
    final bool shouldAnimate = isSelected && !_wasSelected;
    final Duration animDuration = shouldAnimate
        ? const Duration(milliseconds: 200)
        : Duration.zero;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onChanged(widget.index),
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeOut,
        width: MediaQuery.of(context).size.width * 0.17,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          gradient: widget.isCentral && isSelected ? gradient : null,
          color: widget.isCentral && isSelected
              ? null
              : (isSelected
              ? (widget.isDark ? const Color(0xFF2A2A2A) : Color(0xFFEFF6FF))
              : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.isCentral && isSelected
              ? [
            BoxShadow(
              color: Color(0xFF2662EA).withOpacity(0.3),
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
            AnimatedContainer(
              duration: animDuration,
              curve: Curves.easeOut,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isCentral && isSelected
                    ? Colors.white.withOpacity(0.3)
                    : (isSelected
                    ? (widget.isDark ? const Color(0xFF3A3A3A) : Color(0xFFDBEAFE))
                    : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                widget.svgIcon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  widget.isCentral && isSelected
                      ? Colors.white
                      : (isSelected ? activeColor : inactiveColor),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: animDuration,
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: widget.isCentral && isSelected
                    ? Colors.white
                    : (isSelected ? activeColor : inactiveColor),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
