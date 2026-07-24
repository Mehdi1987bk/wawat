import 'dart:ui';

import 'package:buking/screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../../presentation/resourses/wawat_dark.dart';
import '../../services/theme_manager.dart';

const _brand = Color(0xFF0271EB);

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
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl.get<UnreadChatBloc>();
    _chatBloc.fetchUnreadCount();
    _chatBloc.reconnectRealtime();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _chatBloc.fetchUnreadCount();
        _chatBloc.reconnectRealtime();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;

    return StreamBuilder<int>(
      stream: _chatBloc.unreadCountStream,
      initialData: 0,
      builder: (context, snapshot) {
        final unreadChatCount = snapshot.data ?? 0;

        final bottomInset = MediaQuery.of(context).padding.bottom;
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 64 + bottomInset,
              decoration: BoxDecoration(
                color: isDark
                    ? WawatDark.bar.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: cLine(isDark),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BottomNavigationItem(
                        index: 0,
                        selectedIndex: widget.selectedIndex,
                        label: 'Kəşf',
                        icon: PhosphorIconsFill.compass,
                        onChanged: widget.onChanged,
                        isDark: isDark,
                      ),
                      BottomNavigationItem(
                        index: 1,
                        selectedIndex: widget.selectedIndex,
                        label: S.of(context).searchbtrrevfdsc,
                        icon: PhosphorIconsRegular.magnifyingGlass,
                        onChanged: widget.onChanged,
                        isDark: isDark,
                      ),
                      _CenterPostButton(
                        onTap: () => widget.onChanged(2),
                      ),
                      BottomNavigationItem(
                        index: 3,
                        selectedIndex: widget.selectedIndex,
                        label: S.of(context).mjhmhjmj5,
                        icon: PhosphorIconsRegular.chatCircle,
                        onChanged: widget.onChanged,
                        isDark: isDark,
                        badgeCount: unreadChatCount,
                      ),
                      BottomNavigationItem(
                        index: 4,
                        selectedIndex: widget.selectedIndex,
                        label: S.of(context).vfdvfdvfd,
                        icon: PhosphorIconsRegular.user,
                        onChanged: widget.onChanged,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
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
  final IconData icon;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final int badgeCount;

  const BottomNavigationItem({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.isDark,
    this.badgeCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    final Color activeColor = isDark ? cBrandText(isDark) : _brand;
    final Color inactiveColor = cMuted(isDark);
    final Color iconColor = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: iconColor),
                if (badgeCount > 0)
                  Positioned(
                    top: 1,
                    right: -5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _brand,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? WawatDark.bar : Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPostButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterPostButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Center(
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _brand.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsBold.plus,
              size: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
