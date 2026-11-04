import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/localization_service.dart';
import '../../home/tabs/profile_tab/deals/deal_action_runner.dart';
import '../../home/tabs/profile_tab/deals/widgets/deal_action_buttons.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _border = Color(0x0F0F172A);

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;
  final ShipmentData? shipment;

  final bool isCurrentOffer;

  final void Function(ChatMessage message, DealAction action)? onDealAction;

  final DealActionController? dealActions;
  final ValueChanged<String>? onRetry;
  final ValueChanged<ChatMessage>? onLongPress;
  final ValueChanged<String>? onReview;
  final VoidCallback? onSupport;

  final ValueChanged<ChatMessage>? onReply;

  final VoidCallback? onOpenProfile;

  final String? editedLabel;

  final String? deletedLabel;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.shipment,
    this.isCurrentOffer = true,
    this.onDealAction,
    this.dealActions,
    this.onRetry,
    this.onLongPress,
    this.onReview,
    this.onSupport,
    this.onReply,
    this.onOpenProfile,
    this.editedLabel,
    this.deletedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (message.isDeleted) {
      return _DeletedBubble(
        message: message,
        isMyMessage: isMyMessage,
        label: deletedLabel ??
            (isMyMessage
                ? tr('chat.message.deleted_by_you', 'Bu mesajı sildiniz')
                : tr('chat.message.deleted', 'Mesaj silindi')),
        onOpenProfile: onOpenProfile,
      );
    }
    if (message.type == 'system_card' && message.card != null) {
      return _SystemCardMessage(
        message: message,
        shipmentData: shipment,
        isCurrentOffer: isCurrentOffer,
        onDealAction: onDealAction,
        dealActions: dealActions,
        onReview: onReview,
        onSupport: onSupport,
      );
    }

    final imageUrl = message.image?.url ?? message.file?.url;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final localImagePath = message.localImagePath;

    final bubble = GestureDetector(
      onLongPress: message.deliveryStatus == ChatMessageDeliveryStatus.sent
          ? () => onLongPress?.call(message)
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMyMessage) ...[
              _SmallAvatar(user: message.user, onTap: onOpenProfile),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMyMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (hasImage || localImagePath != null)
                    _ImageBubble(
                      imageUrl: imageUrl,
                      cacheKey: 'chat-img-${message.id}',
                      localFile:
                          localImagePath == null ? null : File(localImagePath),
                      isMine: isMyMessage,
                      caption: message.body,
                      time: message.timeString(context),
                    )
                  else
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isMyMessage
                            ? _brand
                            : (isDark ? WawatDark.surface : Colors.white),
                        border: isMyMessage
                            ? null
                            : Border.all(
                                color: isDark ? WawatDark.border : _border,
                                width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMyMessage ? 18 : 6),
                          bottomRight: Radius.circular(isMyMessage ? 6 : 18),
                        ),
                        boxShadow: isMyMessage || isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.replyTo != null)
                            _ReplyQuote(
                              reply: message.replyTo!,
                              onMyBubble: isMyMessage,
                              isDark: isDark,
                            ),
                          Text(
                            message.body ?? '',
                            style: TextStyle(
                              color: isMyMessage
                                  ? Colors.white
                                  : (isDark ? WawatDark.textPrimary : _ink900),
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeString(context),
                        style: TextStyle(
                          color: isDark ? WawatDark.textMuted : _ink400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (message.editedAt != null) ...[
                        Text(' · ',
                            style: TextStyle(
                                color: isDark ? WawatDark.textMuted : _ink400,
                                fontSize: 10)),
                        Text(
                          editedLabel ??
                              tr('chat.message.edited', 'redaktə edildi'),
                          style: TextStyle(
                            color: isDark ? WawatDark.textMuted : _ink400,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (isMyMessage) ...[
                        const SizedBox(width: 3),
                        _DeliveryStatus(
                          message: message,
                          onRetry: onRetry,
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
    );

    if (onReply == null ||
        message.deliveryStatus != ChatMessageDeliveryStatus.sent) {
      return bubble;
    }
    return _SwipeToReply(
      messageId: message.id,
      isDark: isDark,
      onReply: () => onReply!(message),
      child: bubble,
    );
  }
}

class _DeletedBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;
  final String label;
  final VoidCallback? onOpenProfile;

  const _DeletedBubble({
    required this.message,
    required this.isMyMessage,
    required this.label,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? WawatDark.textMuted : _ink500;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            _SmallAvatar(user: message.user, onTap: onOpenProfile),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color:
                        isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isDark ? WawatDark.border : _border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMyMessage ? 18 : 6),
                      bottomRight: Radius.circular(isMyMessage ? 6 : 18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.prohibit, size: 14, color: fg),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontSize: 13.5,
                            height: 1.25,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.timeString(context),
                  style: TextStyle(
                    color: isDark ? WawatDark.textMuted : _ink400,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeToReply extends StatelessWidget {
  final Widget child;
  final String messageId;
  final bool isDark;
  final VoidCallback onReply;

  const _SwipeToReply({
    required this.child,
    required this.messageId,
    required this.isDark,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('reply-$messageId'),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.28},
      movementDuration: const Duration(milliseconds: 180),
      confirmDismiss: (_) async {
        HapticFeedback.selectionClick();
        onReply();
        return false;
      },
      background: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? WawatDark.surfaceAlt : _brand50,
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIconsBold.arrowBendUpLeft,
                size: 17, color: isDark ? WawatDark.brandText : _brand),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _ReplyQuote extends StatelessWidget {
  final ChatReplyRef reply;
  final bool onMyBubble;
  final bool isDark;

  const _ReplyQuote({
    required this.reply,
    required this.onMyBubble,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = onMyBubble ? Colors.white : _brand;
    final nameColor = onMyBubble ? Colors.white : _brand;
    final previewColor = onMyBubble
        ? Colors.white.withValues(alpha: 0.78)
        : (isDark ? WawatDark.textSecondary : _ink500);
    final bg = onMyBubble
        ? Colors.white.withValues(alpha: 0.16)
        : (isDark ? WawatDark.surfaceAlt : _brand.withValues(alpha: 0.07));
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: nameColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reply.isImage) ...[
                        Icon(PhosphorIconsFill.image,
                            size: 12, color: previewColor),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        child: Text(
                          reply.previewText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: previewColor, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (reply.isImage) ...[
              const SizedBox(width: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: reply.imageUrl!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const SizedBox(width: 30, height: 30),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeliveryStatus extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onRetry;

  const _DeliveryStatus({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (message.deliveryStatus) {
      case ChatMessageDeliveryStatus.sending:
        return Icon(
          PhosphorIconsRegular.clock,
          color: isDark ? WawatDark.textMuted : _ink400,
          size: 13,
        );
      case ChatMessageDeliveryStatus.failed:
        return GestureDetector(
          onTap: () => onRetry?.call(message.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsFill.warningCircle,
                color: Color(0xFFEF4444),
                size: 13,
              ),
              const SizedBox(width: 3),
              Text(
                tr('chat.retry', 'Yenidən cəhd'),
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case ChatMessageDeliveryStatus.sent:
        return Icon(
          PhosphorIconsBold.checks,
          color: message.isRead == true
              ? (isDark ? WawatDark.brandText : _brand)
              : (isDark ? WawatDark.iconMuted : _ink400),
          size: 14,
        );
    }
  }
}

class _SmallAvatar extends StatelessWidget {
  final ChatUser? user;
  final VoidCallback? onTap;

  const _SmallAvatar({this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatar = CircleAvatar(
      radius: 12,
      backgroundColor: isDark ? WawatDark.brandSoft : _brand50,
      backgroundImage: user?.avatarThumbUrl.isNotEmpty == true
          ? CachedNetworkImageProvider(user!.avatarThumbUrl)
          : null,
      child: user?.avatarThumbUrl.isNotEmpty == true
          ? null
          : Text(
              user?.initials ?? '?',
              style: const TextStyle(
                color: _brand,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
    if (onTap == null) return avatar;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: avatar,
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final String? imageUrl;
  final String? cacheKey;
  final File? localFile;
  final bool isMine;
  final String? caption;
  final String time;

  const _ImageBubble({
    required this.imageUrl,
    this.cacheKey,
    this.localFile,
    required this.isMine,
    this.caption,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _ImageViewer(
            imageUrl: imageUrl,
            cacheKey: cacheKey,
            localFile: localFile,
            title: time,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMine ? 18 : 6),
          bottomRight: Radius.circular(isMine ? 6 : 18),
        ),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surface : Colors.white,
            border: Border.all(color: isDark ? WawatDark.border : _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (localFile != null)
                Image.file(
                  localFile!,
                  height: 180,
                  width: 220,
                  fit: BoxFit.cover,
                )
              else
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  cacheKey: cacheKey,
                  useOldImageOnUrlChange: true,
                  height: 180,
                  width: 220,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: isDark ? WawatDark.brandSoft : _brand50,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: isDark ? WawatDark.brandSoft : _brand50,
                    alignment: Alignment.center,
                    child: Icon(
                      PhosphorIconsRegular.image,
                      color: isDark ? WawatDark.iconMuted : _ink400,
                    ),
                  ),
                ),
              if (caption != null && caption!.trim().isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    caption!,
                    style: TextStyle(
                      color: isDark ? WawatDark.textSecondary : _ink700,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String? cacheKey;
  final File? localFile;
  final String title;

  const _ImageViewer({
    this.imageUrl,
    this.cacheKey,
    this.localFile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B12),
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 13)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: localFile != null
              ? Image.file(localFile!, fit: BoxFit.contain)
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  cacheKey: cacheKey,
                  useOldImageOnUrlChange: true,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

class _SystemCardMessage extends StatelessWidget {
  final ChatMessage message;
  final ShipmentData? shipmentData;
  final bool isCurrentOffer;
  final void Function(ChatMessage message, DealAction action)? onDealAction;
  final DealActionController? dealActions;
  final ValueChanged<String>? onReview;
  final VoidCallback? onSupport;

  const _SystemCardMessage({
    required this.message,
    this.shipmentData,
    this.isCurrentOffer = true,
    this.onDealAction,
    this.dealActions,
    this.onReview,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final card = message.card!;
    final actions = _CardActions(
      message: message,
      card: card,
      controller: dealActions,
      onDealAction: onDealAction,
    );
    return switch (card.type) {
      'proposal' => _ProposalCard(
          message: message,
          card: card,
          shipment: shipmentData,
          isCurrentOffer: isCurrentOffer,
          actions: actions,
        ),
      'completed' => _CompletedCard(
          message: message,
          card: card,
          onReview: onReview,
          actions: actions,
        ),
      'disputed' => _DisputedCard(
          message: message,
          card: card,
          shipment: shipmentData,
          onSupport: onSupport,
          actions: actions,
        ),
      'cancelled' => _CancelledCard(
          message: message,
          card: card,
          shipment: shipmentData,
          actions: actions,
        ),
      _ => actions.isVisible
          ? _ActionStatusCard(message: message, card: card, actions: actions)
          : _PillCard(message: message, card: card),
    };
  }
}

class _CardActions extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final DealActionController? controller;
  final void Function(ChatMessage message, DealAction action)? onDealAction;

  const _CardActions({
    required this.message,
    required this.card,
    this.controller,
    this.onDealAction,
  });

  bool get isVisible =>
      card.actions.isNotEmpty &&
      (card.shipmentId?.isNotEmpty ?? false) &&
      onDealAction != null;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    Widget buttons({String? busyKey, bool locked = false}) => DealCardActions(
          actions: card.actions,
          busyKey: busyKey,
          locked: locked,
          onAction: (action) => onDealAction!(message, action),
        );
    final controller = this.controller;
    if (controller == null) return buttons();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => buttons(
        busyKey: controller.busyKey(message.id),
        locked: controller.isLocked(message.id),
      ),
    );
  }
}

class _ActionStatusCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final Widget actions;

  const _ActionStatusCard({
    required this.message,
    required this.card,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _cardVisual(card.type);
    final payload = card.payload;
    final price = _formatValue(payload['price_total'], suffix: ' \$');
    final subtitle = _dealSubtitle(payload);
    return _DealCardShell(
      time: message.timeString(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DealAvatar(
                icon: visual.icon,
                color: isDark ? _darkCardColor(visual.color) : visual.color,
                background: visual.background,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.label.isEmpty
                          ? _fallbackCardLabel(card.type)
                          : card.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? WawatDark.textMuted : _ink400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (price.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(
                    color: isDark ? WawatDark.brandText : _brand,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions,
        ],
      ),
    );
  }
}

class _PillCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;

  const _PillCard({required this.message, required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _cardVisual(card.type);
    final tone = isDark ? _darkCardColor(visual.color) : visual.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? WawatDark.surfaceAlt : visual.background,
              borderRadius: BorderRadius.circular(999),
              border: isDark ? Border.all(color: WawatDark.border) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(visual.icon, color: tone, size: 16),
                const SizedBox(width: 6),
                Text(
                  card.label.isEmpty
                      ? _fallbackCardLabel(card.type)
                      : card.label,
                  style: TextStyle(
                    color: tone,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message.timeString(context),
            style: TextStyle(
                color: isDark ? WawatDark.textMuted : _ink400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _DealCardShell extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color background;
  final String time;
  final Widget? trailingUnderTime;

  const _DealCardShell({
    required this.child,
    required this.time,
    this.borderColor,
    this.background = Colors.white,
    this.trailingUnderTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.86,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? WawatDark.surface : background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? WawatDark.border : (borderColor ?? _border)),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: _ink900.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: child,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                    color: isDark ? WawatDark.textMuted : _ink400,
                    fontSize: 10),
              ),
              if (trailingUnderTime != null) ...[
                const SizedBox(width: 4),
                trailingUnderTime!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DealAvatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _DealAvatar({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ShipmentData? shipment;
  final bool isCurrentOffer;
  final Widget actions;

  const _ProposalCard({
    required this.message,
    required this.card,
    required this.actions,
    this.shipment,
    this.isCurrentOffer = true,
  });

  @override
  Widget build(BuildContext context) {
    final payload = card.payload;
    final price = _formatValue(payload['price_total'], suffix: ' \$');
    final subtitle = _dealSubtitle(payload);
    final status = card.shipmentStatus ?? shipment?.status;
    final awaitingAnswer = message.isMine &&
        isCurrentOffer &&
        shipment?.isAwaitingMe != true &&
        (status == null
            ? card.actions.isNotEmpty
            : status == 'proposal_pending');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DealCardShell(
      time: message.timeString(context),
      trailingUnderTime: message.isMine
          ? Icon(PhosphorIconsBold.checks,
              color: message.isRead == true
                  ? (isDark ? WawatDark.brandText : _brand)
                  : (isDark ? WawatDark.iconMuted : _ink400),
              size: 13)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DealAvatar(
                icon: PhosphorIconsFill.paperPlaneTilt,
                color: isDark ? WawatDark.brandText : _brand,
                background: _brand50,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            message.isMine
                                ? tr('deals.proposal_sent',
                                    'Təklifin göndərildi')
                                : tr('deals.proposal_incoming',
                                    'Çatdırılma təklifi'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (awaitingAnswer) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3A2E12)
                                  : const Color(0xFFFEF6E7),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              tr('deals.awaiting_badge', 'gözlənilir'),
                              style: TextStyle(
                                color: isDark
                                    ? WawatDark.warning
                                    : const Color(0xFFB67C00),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? WawatDark.textMuted : _ink400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (price.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(
                    color: isDark ? WawatDark.brandText : _brand,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions,
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ValueChanged<String>? onReview;
  final Widget actions;

  const _CompletedCard({
    required this.message,
    required this.card,
    required this.actions,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final payload = card.payload;
    final price = _formatValue(payload['price_total'], suffix: ' \$');
    final from = _formatCity(payload['city_from'], payload['city_from_name']);
    final to = _formatCity(payload['city_to'], payload['city_to_name']);
    final subtitle = [
      [from, to].where((e) => e.isNotEmpty).join(' → '),
      price,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DealCardShell(
      time: message.timeString(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DealAvatar(
                icon: PhosphorIconsFill.sealCheck,
                color: isDark ? WawatDark.success : const Color(0xFF10B981),
                background: const Color(0xFFECFDF5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('deals.deal_completed', 'Sövdələşmə tamamlandı'),
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textMuted : _ink400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (card.shipmentId != null && onReview != null) ...[
                const SizedBox(width: 8),
                _SmallPill(
                  label: tr('deals.action_review', 'Rəy'),
                  icon: PhosphorIconsFill.star,
                  background: isDark ? WawatDark.brandSoft : _brand50,
                  textColor: isDark ? WawatDark.brandText : _brand,
                  onTap: () => onReview!(card.shipmentId!),
                ),
              ],
            ],
          ),
          actions,
        ],
      ),
    );
  }
}

class _DisputedCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ShipmentData? shipment;
  final VoidCallback? onSupport;
  final Widget actions;

  const _DisputedCard({
    required this.message,
    required this.card,
    required this.actions,
    this.shipment,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final reason = card.payload['reason']?.toString() ?? shipment?.note ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DealCardShell(
      time: message.timeString(context),
      borderColor: const Color(0xFFFDE68A),
      background: const Color(0xFFFFFBEB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DealAvatar(
                icon: PhosphorIconsFill.warningOctagon,
                color: isDark ? WawatDark.warning : const Color(0xFFD97706),
                background: const Color(0xFFFDE68A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('deals.disputed', 'Problem bildirildi'),
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reason.isNotEmpty)
                      Text(
                        reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textSecondary : _ink500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (onSupport != null) ...[
                const SizedBox(width: 8),
                _SmallPill(
                  label: tr('deals.support', 'Dəstək'),
                  icon: PhosphorIconsRegular.headset,
                  background: isDark ? WawatDark.surface : Colors.white,
                  textColor: isDark ? WawatDark.textSecondary : _ink600,
                  bordered: true,
                  onTap: onSupport!,
                ),
              ],
            ],
          ),
          actions,
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ShipmentData? shipment;
  final Widget actions;

  const _CancelledCard({
    required this.message,
    required this.card,
    required this.actions,
    this.shipment,
  });

  @override
  Widget build(BuildContext context) {
    final code = card.payload['cancel_reason_code']?.toString() ??
        card.payload['reason_code']?.toString();
    final reasonLabel = _nonBlank(shipment?.cancelReasonLabel) ??
        _nonBlank(card.payload['reason_label']?.toString()) ??
        _cancelReasonLabel(code) ??
        _nonBlank(card.payload['reason']?.toString());
    final note =
        (card.payload['cancel_reason_note'] ?? card.payload['reason_note'])
            ?.toString()
            .trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DealCardShell(
      time: message.timeString(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DealAvatar(
                icon: PhosphorIconsFill.prohibit,
                color: isDark ? WawatDark.icon : _ink500,
                background: _ink900.withValues(alpha: 0.05),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('deals.deal_cancelled', 'Sövdələşmə ləğv edildi'),
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reasonLabel != null && reasonLabel.isNotEmpty)
                      Text(
                        tr('chat.cancel_reason_line', 'Səbəb: {reason}',
                            {'reason': reasonLabel}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textMuted : _ink400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (note != null && note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '«$note»',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? WawatDark.textSecondary : _ink500,
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions,
        ],
      ),
    );
  }
}

String? _nonBlank(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

String? _cancelReasonLabel(String? code) {
  switch (code) {
    case 'plans_changed':
      return tr('deals.cancel_plans_changed', 'Planlar dəyişdi');
    case 'terms_disagreement':
      return tr('deals.cancel_terms_disagreement', 'Şərtlərlə razılaşmadıq');
    case 'counterpart_unresponsive':
      return tr(
          'deals.cancel_counterpart_unresponsive', 'Qarşı tərəf cavab vermir');
    case 'found_another':
      return tr('deals.cancel_found_another', 'Başqa variant tapdım');
    case 'other':
      return tr('common.other', 'Digər');
    default:
      return null;
  }
}

class _SmallPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color textColor;
  final bool bordered;
  final VoidCallback onTap;

  const _SmallPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: bordered
              ? Border.all(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.08))
              : null,
          boxShadow: bordered && !isDark
              ? [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const _CardVisual(this.icon, this.color, this.background);
}

Color _darkCardColor(Color light) {
  if (light == const Color(0xFF047857)) return WawatDark.success;
  if (light == const Color(0xFFDC2626)) return WawatDark.dangerText;
  if (light == const Color(0xFFD97706)) return WawatDark.warning;
  if (light == const Color(0xFF4F46E5)) {
    return WawatDark.tierPlatinumText;
  }
  if (light == _brand) return WawatDark.brandText;
  if (light == _ink500) return WawatDark.textMuted;
  return light;
}

_CardVisual _cardVisual(String type) {
  return switch (type) {
    'accepted' || 'completed' || 'auto_completed' => const _CardVisual(
        PhosphorIconsFill.checkCircle,
        Color(0xFF047857),
        Color(0xFFECFDF5),
      ),
    'declined' => const _CardVisual(
        PhosphorIconsFill.xCircle,
        Color(0xFFDC2626),
        Color(0xFFFEF2F2),
      ),
    'picked_up' => const _CardVisual(
        PhosphorIconsFill.package,
        _brand,
        _brand50,
      ),
    'delivered' => const _CardVisual(
        PhosphorIconsFill.mapPinArea,
        Color(0xFF4F46E5),
        Color(0xFFEEF2FF),
      ),
    'disputed' => const _CardVisual(
        PhosphorIconsFill.warningOctagon,
        Color(0xFFD97706),
        Color(0xFFFFFBEB),
      ),
    'cancelled' => const _CardVisual(
        PhosphorIconsFill.prohibit,
        _ink500,
        Color(0x0D0F172A),
      ),
    'expired' => const _CardVisual(
        PhosphorIconsFill.clockCountdown,
        _ink500,
        Color(0x0D0F172A),
      ),
    _ => const _CardVisual(
        PhosphorIconsFill.paperPlaneTilt,
        _brand,
        _brand50,
      ),
  };
}

String _fallbackCardLabel(String type) {
  return switch (type) {
    'accepted' => tr('deals.card_accepted', 'Təklif qəbul edildi'),
    'declined' => tr('deals.card_declined', 'Təklif rədd edildi'),
    'picked_up' => tr('deals.picked_up', 'Mal götürüldü'),
    'delivered' => tr('deals.delivered', 'Çatdırıldı'),
    'completed' => tr('deals.deal_completed', 'Sövdələşmə tamamlandı'),
    'auto_completed' => tr('deals.auto_completed', 'Avtomatik tamamlandı'),
    'disputed' => tr('deals.disputed', 'Problem bildirildi'),
    'cancelled' => tr('deals.cancelled_short', 'Ləğv edildi'),
    'expired' => tr('deals.expired', 'Vaxtı keçdi'),
    _ => tr('deals.proposal', 'Təklif'),
  };
}

String _formatValue(dynamic value, {required String suffix}) {
  if (value == null) return '';
  final text = value.toString();
  if (text.isEmpty) return '';
  return '$text$suffix';
}

String _dealSubtitle(Map<String, dynamic> payload) {
  final weight = _formatValue(payload['weight_kg'], suffix: ' kq');
  final from = _formatCity(payload['city_from'], payload['city_from_name']);
  final to = _formatCity(payload['city_to'], payload['city_to_name']);
  final route = [from, to].where((e) => e.isNotEmpty).join(' → ');
  final packageType = _packageLabel(payload['package_type_code']);
  return [route, packageType, weight]
      .where((e) => e.trim().isNotEmpty)
      .join(' · ');
}

String _formatCity(dynamic city, dynamic fallback) {
  if (city is Map) {
    return city['name']?.toString() ?? city['title']?.toString() ?? '';
  }
  return fallback?.toString() ?? '';
}

String _packageLabel(dynamic value) {
  return switch (value?.toString()) {
    'documents' => tr('deals.package_documents', 'Sənədlər'),
    'small_parcel' => tr('deals.package_small_parcel', 'Kiçik bağlama'),
    'electronics' => tr('deals.package_electronics', 'Elektronika'),
    'clothing' => tr('deals.package_clothing', 'Geyim'),
    'food' => tr('deals.package_food', 'Qida'),
    'other' => tr('common.other', 'Digər'),
    _ => value?.toString() ?? '',
  };
}
