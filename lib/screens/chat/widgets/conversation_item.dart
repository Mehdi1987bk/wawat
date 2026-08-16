import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/localization_service.dart';

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

  /// Localized "message deleted" text, shown as the preview when the last
  /// message is a deleted tombstone.
  final String? deletedLabel;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onTapMenu,
    this.deletedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastDeleted = conversation.lastMessageIsDeleted;

    return Material(
      color: unread
          ? (isDark ? WawatDark.brandSoft : _brand50.withValues(alpha: 0.4))
          : (isDark ? WawatDark.surface : Colors.white),
      child: InkWell(
        onTap: onTap,
        // Long-press anywhere on the row opens the same options as the 3-dots.
        onLongPress: onTapMenu,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _Avatar(
                user: conversation.user,
                blocked: conversation.isBlocked,
              ),
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
                        _PreviewIcon(
                          type: conversation.lastMessage?.type,
                          deleted: lastDeleted,
                        ),
                        if (conversation.lastMessage != null)
                          const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lastDeleted
                                ? (deletedLabel ??
                                    tr('chat.message.deleted', 'Mesaj silindi'))
                                : conversation.lastMessagePreview(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: lastDeleted
                                  ? (isDark ? WawatDark.textMuted : _ink400)
                                  : unread
                                      ? (isDark
                                          ? WawatDark.textPrimary
                                          : _ink900)
                                      : (isDark
                                          ? WawatDark.textSecondary
                                          : _ink500),
                              fontSize: 13,
                              fontStyle: lastDeleted
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: !lastDeleted && unread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
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
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 44,
                        height: 30,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(PhosphorIconsBold.dotsThreeVertical,
                              color: isDark ? WawatDark.iconMuted : _ink400,
                              size: 20),
                        ),
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
  final bool blocked;

  const _Avatar({required this.user, this.blocked = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark ? WawatDark.surface : Colors.white;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dim the avatar a touch when the peer is blocked, so the row reads as
        // muted even before the badge registers.
        Opacity(
          opacity: blocked ? 0.55 : 1,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: user.avatarUrl.isEmpty
                ? (isDark ? WawatDark.brandSoft : _brand100)
                : (isDark ? WawatDark.surface : Colors.white),
            backgroundImage: user.avatarThumbUrl.isEmpty
                ? null
                : CachedNetworkImageProvider(user.avatarThumbUrl),
            child: user.avatarUrl.isEmpty
                ? Text(
                    user.initials,
                    style: TextStyle(
                      color: isDark ? WawatDark.brandText : _brand,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
        ),
        // Blocked takes precedence over the online dot — a blocked peer must not
        // read as "online".
        if (blocked)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
              ),
              alignment: Alignment.center,
              child: const Icon(PhosphorIconsBold.prohibit,
                  color: Colors.white, size: 10),
            ),
          )
        else if (user.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: _emerald,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  final String? type;
  final bool deleted;

  const _PreviewIcon({this.type, this.deleted = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // A deleted last message overrides its original type icon with a prohibit
    // mark, matching the tombstone in the thread.
    final icon = deleted
        ? PhosphorIconsRegular.prohibit
        : switch (type) {
            'image' => PhosphorIconsRegular.image,
            'system_card' => PhosphorIconsRegular.paperPlaneTilt,
            _ => null,
          };
    if (icon == null) return const SizedBox.shrink();
    return Icon(icon, color: isDark ? WawatDark.iconMuted : _ink400, size: 15);
  }
}
