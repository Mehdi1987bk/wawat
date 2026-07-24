import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _brand100 = Color(0xFFCFE3FD);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _emerald = Color(0xFF22C55E);

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onTapMenu;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onTapMenu,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: unread
          ? (isDark ? WawatDark.brandSoft : _brand50.withValues(alpha: 0.4))
          : (isDark ? WawatDark.surface : Colors.white),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _Avatar(user: conversation.user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.user.fullname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink900,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (conversation.user.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(PhosphorIconsFill.sealCheck,
                              color: _brand, size: 14),
                        ],
                        if (conversation.isPinned) ...[
                          const Spacer(),
                          Icon(PhosphorIconsFill.pushPin,
                              color: isDark ? WawatDark.iconMuted : _ink400,
                              size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _PreviewIcon(type: conversation.lastMessage?.type),
                        if (conversation.lastMessage != null)
                          const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            conversation.lastMessagePreview(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread
                                  ? (isDark
                                      ? WawatDark.textPrimary
                                      : _ink900)
                                  : (isDark
                                      ? WawatDark.textSecondary
                                      : _ink500),
                              fontSize: 13,
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    conversation.lastMessage?.timeString(context) ?? '',
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (unread)
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        color: _brand,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onTapMenu,
                      behavior: HitTestBehavior.translucent,
                      child: SizedBox(
                        width: 28,
                        height: 22,
                        child: Icon(PhosphorIconsBold.dotsThreeVertical,
                            color: isDark ? WawatDark.iconMuted : _ink400,
                            size: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ChatUser user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: user.avatarUrl.isEmpty
              ? (isDark ? WawatDark.brandSoft : _brand100)
              : (isDark ? WawatDark.surface : Colors.white),
          backgroundImage: user.avatarUrl.isEmpty
              ? null
              : CachedNetworkImageProvider(user.avatarUrl),
          child: user.avatarUrl.isEmpty
              ? Text(
                  user.initials,
                  style: const TextStyle(
                    color: _brand,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        if (user.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: _emerald,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDark ? WawatDark.surface : Colors.white,
                    width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  final String? type;

  const _PreviewIcon({this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = switch (type) {
      'image' => PhosphorIconsRegular.image,
      'system_card' => PhosphorIconsRegular.paperPlaneTilt,
      _ => null,
    };
    if (icon == null) return const SizedBox.shrink();
    return Icon(icon, color: isDark ? WawatDark.iconMuted : _ink400, size: 15);
  }
}
