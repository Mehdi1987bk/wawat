import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../presentation/resourses/wawat_dark.dart';
import '../wawat_app.dart';
import 'notification_visual.dart';

const _brand = Color(0xFF017BFE);

/// Which kind of live banner to render: a chat message (avatar + sender +
/// preview) or a general notification (type-icon + title + body).
enum BannerKind { chat, notification }

/// The parsed payload the banner needs — unified over both the chat
/// (`new_message_notification`) and all-types (`new_notification`) events.
class NotificationBannerData {
  final BannerKind kind;
  final String title; // sender name (chat) / notification title
  final String subtitle; // message preview (chat) / notification body
  final String? avatarUrl; // chat sender OR general-notification actor avatar
  final String? notificationType; // notification only → drives the type icon
  final bool hasActor; // notification with an actor → show avatar, not the icon
  final String? actorName; // for avatar initials (title may not be the name)
  final int? rating; // review_received → 1–5 stars
  final String? reviewComment; // review_received → comment text

  const NotificationBannerData._({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.notificationType,
    this.hasActor = false,
    this.actorName,
    this.rating,
    this.reviewComment,
  });

  /// Chat banner from a `new_message_notification` payload (unchanged behavior).
  factory NotificationBannerData.fromMap(Map<String, dynamic> m) {
    String? s(String k) {
      final v = m[k]?.toString().trim() ?? '';
      return v.isEmpty ? null : v;
    }

    final messageType = s('messageType') ?? 'text';
    final message = m['message']?.toString().trim() ?? '';
    final preview = messageType == 'image'
        ? (message.isEmpty ? '📷 Şəkil' : message)
        : (message.isEmpty ? 'Yeni mesaj' : message);
    return NotificationBannerData._(
      kind: BannerKind.chat,
      title: s('senderName') ?? 'Wawat Air',
      subtitle: preview,
      avatarUrl: s('senderAvatar'),
    );
  }

  /// General notification banner from a `new_notification` payload. When an
  /// [actorName]/[actorAvatarUrl] is present the leading slot shows the actor's
  /// avatar instead of the type icon; review notifications also carry
  /// [rating]/[comment] to render stars + text.
  factory NotificationBannerData.notification({
    required String title,
    String? body,
    required String type,
    String? actorName,
    String? actorAvatarUrl,
    int? rating,
    String? comment,
  }) {
    final t = title.trim();
    final actorAvatar = actorAvatarUrl?.trim();
    final actorNm = actorName?.trim();
    return NotificationBannerData._(
      kind: BannerKind.notification,
      title: t.isEmpty ? 'Wawat Air' : t,
      subtitle: (body ?? '').trim(),
      notificationType: type,
      avatarUrl: (actorAvatar?.isNotEmpty ?? false) ? actorAvatar : null,
      hasActor: (actorNm?.isNotEmpty ?? false) ||
          (actorAvatar?.isNotEmpty ?? false),
      actorName: (actorNm?.isNotEmpty ?? false) ? actorNm : null,
      rating: rating,
      reviewComment: (comment?.trim().isNotEmpty ?? false) ? comment!.trim() : null,
    );
  }

  bool get isChat => kind == BannerKind.chat;

  /// Show the circular avatar (vs. the square type-icon) for chats and for any
  /// notification that carries an actor.
  bool get showsAvatar => isChat || hasActor;

  String get initials {
    final source = (actorName?.isNotEmpty ?? false) ? actorName! : title;
    final parts = source.trim().split(RegExp(r'\s+'));
    final buf = StringBuffer();
    for (final p in parts) {
      if (p.isEmpty) continue;
      buf.write(p[0].toUpperCase());
      if (buf.length == 2) break;
    }
    final out = buf.toString();
    return out.isEmpty ? '?' : out;
  }
}

OverlayEntry? _current;

/// Shows the in-app banner above everything (via the root overlay), replacing
/// any banner already on screen. Works for both chat and general notifications;
/// [onTap] performs the kind-appropriate navigation.
void showNotificationBanner(
  NotificationBannerData data, {
  required VoidCallback onTap,
}) {
  final overlay = navigatorKey.currentState?.overlay;
  if (overlay == null) return;

  _current?.remove();
  _current = null;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _NotificationBanner(
      data: data,
      onOpen: onTap,
      remove: () {
        if (_current == entry) _current = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _NotificationBanner extends StatefulWidget {
  final NotificationBannerData data;
  final VoidCallback onOpen;
  final VoidCallback remove;

  const _NotificationBanner({
    required this.data,
    required this.onOpen,
    required this.remove,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 4500), _close);
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted) await _c.reverse();
    widget.remove();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: _c,
              child: _card(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(bool d) {
    final surface = d ? WawatDark.surface : Colors.white;
    final titleColor = d ? WawatDark.textPrimary : const Color(0xFF0F172A);
    final sub = d ? WawatDark.textSecondary : const Color(0xFF64748B);
    final timeColor = d ? WawatDark.textMuted : const Color(0xFF94A3B8);
    final border =
        d ? WawatDark.border : const Color(0xFF0F172A).withValues(alpha: 0.05);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < 0) _close(); // swipe up
      },
      // A Material host gives the card proper text defaults (kills the "missing
      // Material" yellow underline), an ink ripple on tap, and the elevation.
      child: Material(
        color: surface,
        elevation: d ? 0 : 12,
        shadowColor: Colors.black.withValues(alpha: d ? 0 : 0.22),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            widget.onOpen();
            _close();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _leading(d),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              'indi',
                              style: TextStyle(
                                color: timeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // review_received → a row of stars for the rating.
                      if (widget.data.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            final filled = i < widget.data.rating!;
                            return Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: Icon(
                                filled
                                    ? PhosphorIconsFill.star
                                    : PhosphorIconsRegular.star,
                                size: 12,
                                color: const Color(0xFFFBBF24),
                              ),
                            );
                          }),
                        ),
                      ],
                      if (_subtitleText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _subtitleText,
                          maxLines: widget.data.isChat ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: sub,
                            fontSize: 12.5,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  /// Review notifications show the comment as the body; everything else shows
  /// the server-provided subtitle.
  String get _subtitleText {
    final data = widget.data;
    if (data.rating != null && (data.reviewComment?.isNotEmpty ?? false)) {
      return data.reviewComment!;
    }
    return data.subtitle;
  }

  /// Chat / actor notifications → circular avatar with a small type badge;
  /// system notification → rounded-square type-icon chip (same icon/color the
  /// notification list uses).
  Widget _leading(bool d) {
    if (widget.data.showsAvatar) {
      return SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _avatarCircle(d),
            Positioned(right: -3, bottom: -3, child: _badge(d)),
          ],
        ),
      );
    }
    final v = notificationVisual(widget.data.notificationType ?? '', d);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: v.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(v.icon, color: v.color, size: 22),
    );
  }

  /// The circular avatar: the actor's photo, or a brand-gradient chip with the
  /// initials as a fallback (matches the design's gradient avatars).
  Widget _avatarCircle(bool d) {
    final url = widget.data.avatarUrl;
    final fallback = Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF017BFE), Color(0xFF024FA3)],
        ),
      ),
      child: Text(
        widget.data.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (url == null || url.isEmpty) {
      return SizedBox(width: 46, height: 46, child: fallback);
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  /// Small solid-colour badge on the avatar carrying the type icon (chat-circle
  /// for messages, handshake/check/star/… for the notification type).
  Widget _badge(bool d) {
    final IconData icon;
    final Color color;
    if (widget.data.isChat) {
      icon = PhosphorIconsFill.chatCircle;
      color = _brand;
    } else {
      // Always the saturated (light-theme) colour — a solid badge with a white
      // glyph needs contrast in both themes, not the dark theme's pastel FG.
      final v = notificationVisual(widget.data.notificationType ?? '', false);
      icon = v.icon;
      color = v.color;
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: d ? WawatDark.surface : Colors.white,
          width: 2.5,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 11),
    );
  }
}
