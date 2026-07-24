import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';

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
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;
  final ValueChanged<String>? onRetry;
  final ValueChanged<ChatMessage>? onLongPress;
  final ValueChanged<String>? onReview;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.shipment,
    this.onShipmentAction,
    this.onRetry,
    this.onLongPress,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == 'system_card' && message.card != null) {
      return _SystemCardMessage(
        message: message,
        shipmentData: shipment,
        onShipmentAction: onShipmentAction,
        onReview: onReview,
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
                        color: isMyMessage ? _brand : Colors.white,
                        border: isMyMessage
                            ? null
                            : Border.all(color: _border, width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMyMessage ? 18 : 6),
                          bottomRight: Radius.circular(isMyMessage ? 6 : 18),
                        ),
                        boxShadow: isMyMessage
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
                          color: isMyMessage ? Colors.white : _ink900,
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
                        style: const TextStyle(
                          color: _ink400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (message.editedAt != null) ...[
                        const Text(' · ',
                            style: TextStyle(color: _ink400, fontSize: 10)),
                        const Text(
                          'redaktə edildi',
                          style: TextStyle(
                            color: _ink400,
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
    switch (message.deliveryStatus) {
      case ChatMessageDeliveryStatus.sending:
        return const Icon(
          PhosphorIconsRegular.clock,
          color: _ink400,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      case ChatMessageDeliveryStatus.sent:
        return Icon(
          PhosphorIconsBold.checks,
          color: message.isRead == true ? _brand : _ink400,
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
    return CircleAvatar(
      radius: 12,
      backgroundColor: _brand50,
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
                fontWeight: FontWeight.w900,
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
            color: Colors.white,
            border: Border.all(color: _border),
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
                    color: _brand50,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: _brand50,
                    alignment: Alignment.center,
                    child: const Icon(
                      PhosphorIconsRegular.image,
                      color: _ink400,
                    ),
                  ),
                ),
              if (caption != null && caption!.trim().isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    caption!,
                    style: const TextStyle(
                      color: _ink700,
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
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;
  final ValueChanged<String>? onReview;

  const _SystemCardMessage({
    required this.message,
    this.shipmentData,
    this.onShipmentAction,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final card = message.card!;
    if (card.type == 'proposal') {
      return _ProposalCard(
        message: message,
        card: card,
        shipment: shipmentData,
        onShipmentAction: onShipmentAction,
      );
    }

    final visual = _cardVisual(card.type);
    final actions =
        _supportedActions(shipmentData?.availableActions ?? const []);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(visual.icon, color: visual.color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    card.label.isEmpty
                        ? _fallbackCardLabel(card.type)
                        : card.label,
                    style: TextStyle(
                      color: visual.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (actions.isNotEmpty &&
              card.shipmentId != null &&
              onShipmentAction != null) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map(
                    (action) => _ActionButton(
                      label: _actionLabel(action),
                      icon: _actionIcon(action),
                      color: _brand50,
                      textColor: _brand,
                      onTap: () => onShipmentAction!(
                        card.shipmentId!,
                        action,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (card.type == 'completed' &&
              card.shipmentId != null &&
              onReview != null) ...[
            const SizedBox(height: 8),
            _ActionButton(
              label: 'Rəy yaz',
              icon: PhosphorIconsFill.star,
              color: _brand,
              textColor: Colors.white,
              onTap: () => onReview!(card.shipmentId!),
            ),
          ],
          const SizedBox(height: 3),
          Text(
            message.timeString(context),
            style: const TextStyle(
              color: _ink400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ChatMessage message;
  final ChatCard card;
  final ShipmentData? shipment;
  final Future<void> Function(String shipmentId, String action)?
      onShipmentAction;

  const _ProposalCard({
    required this.message,
    required this.card,
    this.shipment,
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
    final note = payload['note']?.toString();
    final actions = shipment?.isAwaitingMe == true
        ? _supportedActions(shipment?.availableActions ?? const [])
        : const <String>[];
    final canAct = actions.isNotEmpty &&
        card.shipmentId != null &&
        card.shipmentId!.isNotEmpty &&
        onShipmentAction != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.88,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _ink900.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _brand50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsFill.paperPlaneTilt,
                          color: _brand, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.isMine
                                ? 'Təklifin göndərildi'
                                : 'Çatdırılma təklifi',
                            style: const TextStyle(
                              color: _ink900,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (route.isNotEmpty)
                            Text(
                              route,
                              style: const TextStyle(
                                color: _ink400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (shipment != null && !shipment!.isAwaitingMe)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          children: [
                            Icon(PhosphorIconsFill.clock,
                                color: Color(0xFFD97706), size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Cavab gözlənilir',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _ink900.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TermBox(label: 'Çəki', value: weight),
                      ),
                      Container(width: 1, height: 38, color: _border),
                      Expanded(
                        child: _TermBox(
                          label: 'Ümumi qiymət',
                          value: price,
                          valueColor: _brand,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (packageType.isNotEmpty) _Chip(text: packageType),
                    if (note != null && note.isNotEmpty)
                      Text(
                        '“$note”',
                        style: const TextStyle(color: _ink400, fontSize: 11),
                      ),
                  ],
                ),
                if (canAct) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actions
                        .map(
                          (action) => _ActionButton(
                            label: _actionLabel(action),
                            icon: _actionIcon(action),
                            color: action == 'accept' ? _brand : _brand50,
                            textColor:
                                action == 'accept' ? Colors.white : _brand,
                            onTap: () => onShipmentAction!(
                              card.shipmentId!,
                              action,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.timeString(context),
            style: const TextStyle(color: _ink400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TermBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _TermBox({
    required this.label,
    required this.value,
    this.valueColor = _ink900,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ink400,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _ink900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _ink600,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
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

String _actionLabel(String action) {
  return switch (action) {
    'accept' => 'Qəbul et',
    'decline' => 'Rədd et',
    'counter' => 'Dəyiş',
    'picked-up' => 'Mal götürüldü',
    'delivered' => 'Çatdırıldı',
    'complete' => 'Tamamla',
    'dispute' => 'Problem bildir',
    'cancel' => 'Ləğv et',
    _ => action,
  };
}

IconData _actionIcon(String action) {
  return switch (action) {
    'accept' => PhosphorIconsBold.check,
    'decline' => PhosphorIconsRegular.x,
    'counter' => PhosphorIconsFill.arrowsClockwise,
    'picked-up' => PhosphorIconsFill.package,
    'delivered' => PhosphorIconsFill.mapPinArea,
    'complete' => PhosphorIconsFill.sealCheck,
    'dispute' => PhosphorIconsFill.warningOctagon,
    'cancel' => PhosphorIconsFill.prohibit,
    _ => PhosphorIconsRegular.circle,
  };
}

class _CardVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const _CardVisual(this.icon, this.color, this.background);
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
