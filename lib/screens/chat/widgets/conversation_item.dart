import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationItem({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(WawatDimensions.spacingMd),
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
                                if (conversation.user.isVerified) ...[
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: WawatColors.info,
                                  ),
                                ],
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
