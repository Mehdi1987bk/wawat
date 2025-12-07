import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';

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
    return Container(
      margin: EdgeInsets.only(left: 20, right: 16, top: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(width: 1, color: AppColors.appColor.withOpacity(0.3))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 10),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: WawatColors.primary.withOpacity(0.1),
                      backgroundImage: conversation.user.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                              conversation.user.avatarUrl)
                          : null,
                      child: conversation.user.avatarUrl.isEmpty
                          ? Text(
                              conversation.user.fullname[0].toUpperCase(),
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
                              color: Colors.white,
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
                                  child: Text(
                                    conversation.user.fullname,
                                    style: WawatTextStyles.bodyBold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (conversation.user.isVerified == true)
                                  Container(
                                    padding: EdgeInsets.symmetric(
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
                                        SizedBox(width: 3),
                                        Text(
                                          'Проверен',
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
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.push_pin,
                                    size: 14,
                                    color: WawatColors.warning,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: WawatDimensions.spacingSm),
                          Text(
                            conversation.lastMessage?.timeString ?? '',
                            style: WawatTextStyles.caption,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessagePreview,
                              style: WawatTextStyles.body.copyWith(
                                color: conversation.unreadCount > 0
                                    ? WawatColors.textPrimary
                                    : WawatColors.textSecondary,
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
                            SizedBox(width: WawatDimensions.spacingSm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: WawatColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : conversation.unreadCount.toString(),
                                style: WawatTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          GestureDetector(
                              onTap: onTapMenu,
                              behavior: HitTestBehavior.translucent,
                              child: Icon(Icons.more_horiz))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
