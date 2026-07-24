import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';

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

  /// Whether this proposal is the newest one for its shipment. Older (superseded)
  /// proposals are shown as plain cards without accept/reject/change buttons.
  final bool isCurrentOffer;
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;
  final ValueChanged<String>? onRetry;
  final ValueChanged<ChatMessage>? onLongPress;
  final ValueChanged<String>? onReview;
  final VoidCallback? onSupport;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.shipment,
    this.isCurrentOffer = true,
    this.onShipmentAction,
    this.onRetry,
    this.onLongPress,
    this.onReview,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (message.type == 'system_card' && message.card != null) {
      return _SystemCardMessage(
        message: message,
        shipmentData: shipment,
        isCurrentOffer: isCurrentOffer,
        onShipmentAction: onShipmentAction,
        onReview: onReview,
        onSupport: onSupport,
      );
    }

    final imageUrl = message.image?.url ?? message.file?.url;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final localImagePath = message.localImagePath;

    return GestureDetector(
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
              _SmallAvatar(user: message.user),
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
                      child: Text(
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
                          'redaktə edildi',
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsFill.warningCircle,
                color: Color(0xFFEF4444),
                size: 13,
              ),
              SizedBox(width: 3),
              Text(
                'Yenidən cəhd',
                style: TextStyle(
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
              ? _brand
              : (isDark ? WawatDark.textMuted : _ink400),
          size: 14,
        );
    }
  }
}

class _SmallAvatar extends StatelessWidget {
  final ChatUser? user;

  const _SmallAvatar({this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 12,
      backgroundColor: isDark ? WawatDark.brandSoft : _brand50,
      backgroundImage: user?.avatarUrl.isNotEmpty == true
          ? CachedNetworkImageProvider(user!.avatarUrl)
          : null,
      child: user?.avatarUrl.isNotEmpty == true
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
  }
}

class _ImageBubble extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final bool isMine;
  final String? caption;
  final String time;

  const _ImageBubble({
    required this.imageUrl,
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
  final File? localFile;
  final String title;

  const _ImageViewer({
    this.imageUrl,
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
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;
  final ValueChanged<String>? onReview;
  final VoidCallback? onSupport;

  const _SystemCardMessage({
    required this.message,
    this.shipmentData,
    this.isCurrentOffer = true,
    this.onShipmentAction,
    this.onReview,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final card = message.card!;
    return switch (card.type) {
      'proposal' => _ProposalCard(
          message: message,
          card: card,
          shipment: shipmentData,
          isCurrentOffer: isCurrentOffer,
          onShipmentAction: onShipmentAction,
        ),
      'completed' => _CompletedCard(
          message: message,
          card: card,
          onReview: onReview,
        ),
      'disputed' => _DisputedCard(
          message: message,
          card: card,
          shipment: shipmentData,
          onSupport: onSupport,
        ),
      'cancelled' => _CancelledCard(
          message: message,
          card: card,
          shipment: shipmentData,
        ),
      _ => _PillCard(message: message, card: card),
    };
  }
}

/// Narrow centred status pill — accepted/picked_up/delivered/declined/expired/
/// auto_completed (§13.1 compact).
class _PillCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;

  const _PillCard({required this.message, required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _cardVisual(card.type);
    // On graphite, lift the deliberately-dark status hue to its palette
    // equivalent so it stays legible on the dark pill; light keeps it exactly.
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

/// Reusable compact card shell centred in the thread (§3A.4).
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

/// Icon tile at the head of a compact card.
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
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;

  const _ProposalCard({
    required this.message,
    required this.card,
    this.shipment,
    this.isCurrentOffer = true,
    this.onShipmentAction,
  });

  @override
  Widget build(BuildContext context) {
    final payload = card.payload;
    final weight = _formatValue(payload['weight_kg'], suffix: ' kq');
    final price = _formatValue(payload['price_total'], suffix: ' ₼');
    final from = _formatCity(payload['city_from'], payload['city_from_name']);
    final to = _formatCity(payload['city_to'], payload['city_to_name']);
    final route = [from, to].where((e) => e.isNotEmpty).join(' → ');
    final packageType = _packageLabel(payload['package_type_code']);
    final subtitle = [route, packageType, weight]
        .where((e) => e.trim().isNotEmpty)
        .join(' · ');
    final awaitingMe = shipment?.isAwaitingMe == true;
    final actions = awaitingMe
        ? _supportedActions(shipment?.availableActions ?? const [])
        : const <String>[];
    // Only the newest proposal for this shipment is actionable. Older proposals
    // were superseded by a newer counter-offer and must stay read-only.
    final canAct = isCurrentOffer &&
        actions.isNotEmpty &&
        card.shipmentId != null &&
        card.shipmentId!.isNotEmpty &&
        onShipmentAction != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DealCardShell(
      time: message.timeString(context),
      trailingUnderTime: message.isMine
          ? Icon(PhosphorIconsBold.checks,
              color: message.isRead == true
                  ? _brand
                  : (isDark ? WawatDark.textMuted : _ink400),
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
                                ? 'Təklifin göndərildi'
                                : 'Çatdırılma təklifi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (message.isMine &&
                            !awaitingMe &&
                            isCurrentOffer) ...[
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
                              'gözlənilir',
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
          if (canAct) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (actions.contains('decline'))
                  Expanded(
                    child: _DealButton(
                      label: 'Rədd',
                      background: isDark
                          ? const Color(0xFF3A1E1E)
                          : const Color(0xFFFEECEC),
                      textColor: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626),
                      onTap: () =>
                          onShipmentAction!(card.shipmentId!, 'decline'),
                    ),
                  ),
                if (actions.contains('decline') &&
                    (actions.contains('counter') || actions.contains('accept')))
                  const SizedBox(width: 6),
                if (actions.contains('counter'))
                  Expanded(
                    child: _DealButton(
                      label: 'Dəyiş',
                      background: isDark ? WawatDark.brandSoft : _brand50,
                      textColor: isDark ? WawatDark.brandText : _brand,
                      onTap: () =>
                          onShipmentAction!(card.shipmentId!, 'counter'),
                    ),
                  ),
                if (actions.contains('counter') && actions.contains('accept'))
                  const SizedBox(width: 6),
                if (actions.contains('accept'))
                  Expanded(
                    flex: 3,
                    child: _DealButton(
                      label: 'Qəbul',
                      icon: PhosphorIconsBold.check,
                      background: _brand,
                      textColor: Colors.white,
                      shadow: true,
                      onTap: () =>
                          onShipmentAction!(card.shipmentId!, 'accept'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ValueChanged<String>? onReview;

  const _CompletedCard({
    required this.message,
    required this.card,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final payload = card.payload;
    final price = _formatValue(payload['price_total'], suffix: ' ₼');
    final from = _formatCity(payload['city_from'], payload['city_from_name']);
    final to = _formatCity(payload['city_to'], payload['city_to_name']);
    final subtitle = [
      [from, to].where((e) => e.isNotEmpty).join(' → '),
      price,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DealCardShell(
      time: message.timeString(context),
      child: Row(
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
                  'Sövdələşmə tamamlandı',
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
              label: 'Rəy',
              icon: PhosphorIconsFill.star,
              background: isDark ? WawatDark.brandSoft : _brand50,
              textColor: isDark ? WawatDark.brandText : _brand,
              onTap: () => onReview!(card.shipmentId!),
            ),
          ],
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

  const _DisputedCard({
    required this.message,
    required this.card,
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
      child: Row(
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
                  'Problem bildirildi',
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
              label: 'Dəstək',
              icon: PhosphorIconsRegular.headset,
              background: isDark ? WawatDark.surface : Colors.white,
              textColor: isDark ? WawatDark.textSecondary : _ink600,
              bordered: true,
              onTap: onSupport!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ShipmentData? shipment;

  const _CancelledCard({
    required this.message,
    required this.card,
    this.shipment,
  });

  @override
  Widget build(BuildContext context) {
    final reasonLabel = shipment?.cancelReasonLabel ??
        card.payload['reason_label']?.toString() ??
        card.payload['reason_note']?.toString() ??
        card.payload['reason']?.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DealCardShell(
      time: message.timeString(context),
      child: Row(
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
                  'Sövdələşmə ləğv edildi',
                  style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : _ink900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reasonLabel != null && reasonLabel.isNotEmpty)
                  Text(
                    'Səbəb: $reasonLabel',
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
        ],
      ),
    );
  }
}

class _DealButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color textColor;
  final bool shadow;
  final VoidCallback onTap;

  const _DealButton({
    required this.label,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.icon,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: _brand.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 15),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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

List<String> _supportedActions(List<String> actions) {
  const supported = {
    'accept',
    'decline',
    'counter',
    'picked-up',
    'delivered',
    'complete',
    'dispute',
    'cancel',
  };
  return actions
      .map((action) => action == 'picked_up' ? 'picked-up' : action)
      .where(supported.contains)
      .toList();
}

class _CardVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const _CardVisual(this.icon, this.color, this.background);
}

/// Maps a light-mode status-pill hue to its graphite-palette equivalent so the
/// icon and label stay legible on the dark pill. Brand blue → brand text.
Color _darkCardColor(Color light) {
  if (light == const Color(0xFF047857)) return WawatDark.success; // done green
  if (light == const Color(0xFFDC2626)) return WawatDark.dangerText; // declined
  if (light == const Color(0xFFD97706)) return WawatDark.warning; // disputed
  if (light == const Color(0xFF4F46E5)) {
    return WawatDark.tierPlatinumText; // delivered indigo
  }
  if (light == _brand) return WawatDark.brandText; // brand blue
  if (light == _ink500) return WawatDark.textMuted; // cancelled/expired slate
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
    'accepted' => 'Təklif qəbul edildi',
    'declined' => 'Təklif rədd edildi',
    'picked_up' => 'Mal götürüldü',
    'delivered' => 'Çatdırıldı',
    'completed' => 'Sövdələşmə tamamlandı',
    'auto_completed' => 'Avtomatik tamamlandı',
    'disputed' => 'Problem bildirildi',
    'cancelled' => 'Ləğv edildi',
    'expired' => 'Vaxtı keçdi',
    _ => 'Təklif',
  };
}

String _formatValue(dynamic value, {required String suffix}) {
  if (value == null) return '';
  final text = value.toString();
  if (text.isEmpty) return '';
  return '$text$suffix';
}

String _formatCity(dynamic city, dynamic fallback) {
  if (city is Map) {
    return city['name']?.toString() ?? city['title']?.toString() ?? '';
  }
  return fallback?.toString() ?? '';
}

String _packageLabel(dynamic value) {
  return switch (value?.toString()) {
    'documents' => 'Sənədlər',
    'small_parcel' => 'Kiçik bağlama',
    'electronics' => 'Elektronika',
    'clothing' => 'Geyim',
    'food' => 'Qida',
    'other' => 'Digər',
    _ => value?.toString() ?? '',
  };
}
