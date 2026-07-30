import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../presentation/resourses/wawat_dark.dart';
import '../wawat_app.dart';

const _brand = Color(0xFF017BFE);

/// The parsed `new_message_notification` payload the banner needs.
class NotificationBannerData {
  final String chatId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String messageType; // text | image

  const NotificationBannerData({
    required this.chatId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.messageType,
  });

  factory NotificationBannerData.fromMap(Map<String, dynamic> m) {
    String? s(String k) {
      final v = m[k]?.toString().trim() ?? '';
      return v.isEmpty ? null : v;
    }

    return NotificationBannerData(
      chatId: s('chatId') ?? '',
      senderName: s('senderName') ?? 'Wawat Air',
      senderAvatar: s('senderAvatar'),
      message: m['message']?.toString() ?? '',
      messageType: s('messageType') ?? 'text',
    );
  }

  /// One-line preview — photo messages arrive with an empty body.
  String get preview {
    final trimmed = message.trim();
    if (messageType == 'image') return trimmed.isEmpty ? '📷 Şəkil' : trimmed;
    return trimmed.isEmpty ? 'Yeni mesaj' : trimmed;
  }

  String get initials {
    final parts = senderName.trim().split(RegExp(r'\s+'));
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

/// Shows the in-app new-message banner above everything (via the root overlay),
/// replacing any banner already on screen. [onTap] opens the chat.
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
    final title = d ? WawatDark.textPrimary : const Color(0xFF0F172A);
    final sub = d ? WawatDark.textSecondary : const Color(0xFF64748B);
    final border = d ? WawatDark.border : const Color(0xFFE7EBF0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onOpen();
        _close();
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < 0) _close(); // swipe up
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: d ? 0.45 : 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _avatar(d),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.data.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: title,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(PhosphorIconsFill.chatCircle,
                          size: 15, color: _brand),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.data.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: sub,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(bool d) {
    final url = widget.data.senderAvatar;
    final ring = _brand.withValues(alpha: d ? 0.22 : 0.14);
    final fallback = Container(
      alignment: Alignment.center,
      color: ring,
      child: Text(
        widget.data.initials,
        style: TextStyle(
          color: d ? const Color(0xFF7FB6FF) : _brand,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: ClipOval(
        child: (url == null || url.isEmpty)
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
