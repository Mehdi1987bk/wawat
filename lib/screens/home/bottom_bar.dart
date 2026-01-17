import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../services/theme_manager.dart';
import 'tabs/home_tab/notification/unread_chat_bloc.dart';

class BottomBar extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  const BottomBar({
    super.key,
    required this.onChanged,
    required this.selectedIndex,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late final UnreadChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl.get<UnreadChatBloc>();
  }

  @override
  void didUpdateWidget(BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем счетчик при любой смене табов
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _chatBloc.fetchUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

    return StreamBuilder<int>(
      stream: _chatBloc.unreadCountStream,
      initialData: 0,
      builder: (context, snapshot) {
        final unreadChatCount = snapshot.data ?? 0;

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
                    selectedIndex: widget.selectedIndex,
                    label: S.of(context).nhhfge4,
                    svgIcon: 'asset/tab1.svg',
                    onChanged: widget.onChanged,
                    isCentral: false,
                    isDark: isDark,
                  ),
                  BottomNavigationItem(
                    index: 1,
                    selectedIndex: widget.selectedIndex,
                    label: S.of(context).mjhmhjmj5,
                    svgIcon: 'asset/tab2.svg',
                    onChanged: widget.onChanged,
                    isCentral: false,
                    isDark: isDark,
                    badgeCount: unreadChatCount,
                  ),
                  BottomNavigationItem(
                    index: 2,
                    selectedIndex: widget.selectedIndex,
                    label: S.of(context).nhnnh5,
                    svgIcon: 'asset/tab3.svg',
                    onChanged: widget.onChanged,
                    isCentral: true,
                    isDark: isDark,
                  ),
                  BottomNavigationItem(
                    index: 3,
                    selectedIndex: widget.selectedIndex,
                    label: S.of(context).gbfbgfgb,
                    svgIcon: 'asset/tab4.svg',
                    onChanged: widget.onChanged,
                    isCentral: false,
                    isDark: isDark,
                  ),
                  BottomNavigationItem(
                    index: 4,
                    selectedIndex: widget.selectedIndex,
                    label: S.of(context).vfdvfdvfd,
                    svgIcon: 'asset/tab5.svg',
                    onChanged: widget.onChanged,
                    isCentral: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
  final int badgeCount;

  const BottomNavigationItem({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.svgIcon,
    required this.onChanged,
    this.isCentral = false,
    required this.isDark,
    this.badgeCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    final Color activeColor = isDark ? Colors.white : const Color(0xFF2857DA);
    final Color inactiveColor =
        isDark ? const Color(0xFF6B7280) : Color(0xFF9E9E9E);

     final Color bgColor = isCentral && isSelected
        ? Colors.transparent
        : (isSelected
            ? (isDark ? const Color(0xFF2A2A2A) : Color(0xFFEFF6FF))
            : Colors.transparent);

    final Color iconBgColor = isCentral && isSelected
        ? Colors.white.withOpacity(0.3)
        : (isSelected
            ? (isDark ? const Color(0xFF3A3A3A) : Color(0xFFFFFFFF))
            : Colors.transparent);

    final Color iconColor = isCentral && isSelected
        ? Colors.white
        : (isSelected ? activeColor : inactiveColor);

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
                color: isCentral && isSelected
                    ? null
                    : Color.lerp(Colors.transparent, bgColor, value),
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
                  Stack(
                    clipBehavior: Clip.none,
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
                              BlendMode.srcIn),
                        ),
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: badgeCount > 9 ? 5 : 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF5252).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
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
