import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../generated/l10n.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onTapMenu;

  const ConversationItem({
    Key? key,
    required this.conversation,
    required this.onTap,
    required this.onTapMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 20, right: 16, top: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              width: 1,
              color: AppColors.appColor.withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 5, top: 5, bottom: 5, right: 10),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: isDark
                                  ? WawatColors.primary.withOpacity(0.2)
                                  : WawatColors.primary.withOpacity(0.1),
                              backgroundImage:
                                  conversation.user.avatarUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          conversation.user.avatarUrl)
                                      : null,
                              child: conversation.user.avatarUrl.isEmpty
                                  ? Text(
                                      conversation.user.fullname[0]
                                          .toUpperCase(),
                                      style: WawatTextStyles.h2.copyWith(
                                        color: WawatColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            if (conversation.user.isOnline)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: WawatColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: WawatDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            style: WawatTextStyles.bodyBold
                                                .copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            child: Text(
                                              conversation.user.fullname,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        if (conversation.user.isVerified ==
                                            true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  "asset/prof_3.png",
                                                  width: 16,
                                                ),
                                                const SizedBox(width: 3),
                                                  Text(
                                                  S.of(context).bgfbgf4,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF4CAF50),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (conversation.isPinned) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.push_pin,
                                            size: 14,
                                            color: WawatColors.warning,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: WawatDimensions.spacingSm),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: WawatTextStyles.caption.copyWith(
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : WawatColors.textSecondary,
                                    ),
                                    child: Text(
                                      conversation.lastMessage?.timeString ??
                                          '',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      style: WawatTextStyles.body.copyWith(
                                        color: conversation.unreadCount > 0
                                            ? WawatColors.primary
                                            : (isDark
                                                ? const Color(0xFF9CA3AF)
                                                : WawatColors.textSecondary),
                                        fontWeight: conversation.unreadCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      child: Text(
                                        conversation.unreadCount > 0
                                            ? (conversation.unreadCount > 99
                                                ? '99+'
                                                : '${conversation.unreadCount} ' + S.of(context).bgbgffbgfg4)
                                            : conversation.lastMessagePreview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 30,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onTapMenu,
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 48,
                        width: 50,
                        child: Icon(
                          Icons.more_horiz,
                          color:
                              isDark ? const Color(0xFF9CA3AF) : Colors.black54,
                        ),
                      ),
                    ),
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
