import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/localization_service.dart';
import '../../../services/wawat_content.dart';

const _brand = Color(0xFF0271EB);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachImage;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool hasAttachment;
  final String? disabledText;
  final Map<String, String> content;

  /// When non-null, the disabled (blocked-by-me) banner becomes tappable and
  /// shows an "unblock" affordance that runs this — so the user can unblock
  /// straight from the composer without opening the menu.
  final VoidCallback? onDisabledTap;

  /// Active reply target — shows the quoted-message preview bar above the input.
  final ChatReplyRef? replyTo;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    this.onChanged,
    this.enabled = true,
    this.hasAttachment = false,
    this.disabledText,
    this.content = const {},
    this.onDisabledTap,
    this.replyTo,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncText);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncText);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _syncText() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(widget.content, key, fallback);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!widget.enabled) {
      final canUnblock = widget.onDisabledTap != null;
      final banner = Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: 20, vertical: canUnblock ? 14 : 18),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surface : Colors.white,
          border: Border(
            top: BorderSide(
                color: isDark
                    ? WawatDark.divider
                    : _ink900.withValues(alpha: 0.06)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsFill.prohibitInset,
                    color: isDark ? WawatDark.iconMuted : _ink400, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    widget.disabledText ?? _t('chat.input.blocked'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (canUnblock) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.brandSoft : const Color(0xFFEAF3FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsBold.lockOpen,
                        color: isDark ? WawatDark.brandText : _brand, size: 16),
                    const SizedBox(width: 7),
                    Text(
                      _t('chat.action.unblock', 'Blokdan çıxar'),
                      style: TextStyle(
                        color: isDark ? WawatDark.brandText : _brand,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

      return ColoredBox(
        color: isDark ? WawatDark.surface : Colors.white,
        child: SafeArea(
          top: false,
          child: canUnblock
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDisabledTap,
                  child: banner,
                )
              : banner,
        ),
      );
    }

    // Send is available with typed text OR a pending attachment (e.g. a picked
    // image sitting in the preview bar above). Attaching is reached only via the
    // "+" button, so the right slot is purely a send affordance now.
    final canSend = _hasText || widget.hasAttachment;

    return ColoredBox(
      color: isDark ? WawatDark.surface : Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyTo != null) _buildReplyBar(isDark, widget.replyTo!),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              decoration: BoxDecoration(
                color: isDark ? WawatDark.surface : Colors.white,
                border: Border(
                  top: BorderSide(
                      color: widget.replyTo != null
                          ? Colors.transparent
                          : (isDark
                              ? WawatDark.divider
                              : _ink900.withValues(alpha: 0.06))),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showAttachOptions,
                    icon: Icon(PhosphorIconsRegular.plusCircle,
                        color: isDark ? WawatDark.icon : _ink500, size: 28),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      decoration: BoxDecoration(
                        color: isDark
                            ? WawatDark.surfaceAlt
                            : _ink900.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(22),
                        // Focus highlight on the pill itself, so the blue outline
                        // lands on the visual edge (radius 22) — not inset like the
                        // theme's default InputDecorator border.
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? (isDark ? WawatDark.focusRing : _brand)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        onChanged: widget.onChanged,
                        minLines: 1,
                        maxLines: 4,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5000),
                        ],
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(
                          color: isDark ? WawatDark.textPrimary : _ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: _t('chat.input.placeholder'),
                          hintStyle: TextStyle(
                            color: isDark ? WawatDark.textMuted : _ink400,
                            fontWeight: FontWeight.w500,
                          ),
                          // Drop the theme's filled/outline borders — the container
                          // owns the fill, shape and focus outline now.
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: canSend ? widget.onSend : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: canSend ? _brand : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: _brand.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        PhosphorIconsFill.paperPlaneTilt,
                        color: canSend
                            ? Colors.white
                            : (isDark ? WawatDark.iconMuted : _ink400),
                        size: 19,
                      ),
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

  Widget _buildReplyBar(bool isDark, ChatReplyRef reply) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        border: Border(
          top: BorderSide(
              color:
                  isDark ? WawatDark.divider : _ink900.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? WawatDark.brandText : _brand,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('chat.reply.to', '{name}-ə cavab',
                      {'name': reply.authorName}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? WawatDark.brandText : _brand,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    if (reply.isImage) ...[
                      Icon(PhosphorIconsFill.image,
                          size: 12,
                          color: isDark ? WawatDark.textMuted : _ink400),
                      const SizedBox(width: 3),
                    ],
                    Expanded(
                      child: Text(
                        reply.previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textSecondary : _ink500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (reply.isImage) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CachedNetworkImage(
                imageUrl: reply.imageUrl!,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const SizedBox(width: 36, height: 36),
              ),
            ),
          ],
          IconButton(
            onPressed: widget.onCancelReply,
            icon: Icon(PhosphorIconsBold.x,
                size: 18, color: isDark ? WawatDark.iconMuted : _ink400),
          ),
        ],
      ),
    );
  }

  void _showAttachOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? WawatDark.surface : Colors.white,
      barrierColor: isDark ? WawatDark.scrim : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.grab : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                _AttachTile(
                  icon: PhosphorIconsRegular.image,
                  label: _t('chat.attach.image'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAttachImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttachTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? WawatDark.brandSoft : const Color(0xFFEAF3FE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDark ? WawatDark.brandText : _brand),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? WawatDark.textPrimary : _ink900,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
