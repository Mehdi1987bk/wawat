import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../data/network/response/chat_response.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/localization_service.dart';
import '../../../../../../services/wawat_content.dart';
import 'deal_flightpath.dart';
import 'deal_status.dart';

class DealCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;
  final VoidCallback onTap;

  const DealCard({
    super.key,
    required this.shipment,
    required this.content,
    required this.onTap,
  });

  ShipmentParty? get _counterpart =>
      shipment.isCarrier ? shipment.sender : shipment.carrier;

  bool get _awaitingReceiptConfirm =>
      shipment.status == 'delivered' && shipment.isAwaitingMe;

  bool get _awaitingProposalReply =>
      shipment.status == 'proposal_pending' && shipment.isAwaitingMe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = dealStatusVisual(shipment.status, isDark);
    final counterpart = _counterpart;
    final isTerminal = dealIsTerminal(shipment.status);

    Color? ringColor;
    if (_awaitingProposalReply) ringColor = const Color(0xFFF5B301);
    if (_awaitingReceiptConfirm) ringColor = dealBrand.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isTerminal ? 0.95 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surface : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: ringColor ??
                  (isDark
                      ? WawatDark.border
                      : dealInk900.withValues(alpha: 0.06)),
              width: ringColor != null ? 2 : 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: dealInk900.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(
                    icon: visual.icon,
                    color: visual.color,
                    background: visual.background,
                    label: dealStatusLabel(
                        content, shipment.status, shipment.statusLabel),
                  ),
                  if (shipment.myRole != null)
                    _RoleChip(role: shipment.myRole!, content: content),
                ],
              ),
              const SizedBox(height: 10),
              DealFlightPath(
                cityFrom: shipment.cityFrom ?? '',
                cityTo: shipment.cityTo ?? '',
                muted: isTerminal,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? WawatDark.border : dealInk200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (counterpart != null)
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  isDark ? WawatDark.surfaceAlt : dealInk100,
                              backgroundImage:
                                  counterpart.avatarThumbUrl.isEmpty
                                      ? null
                                      : CachedNetworkImageProvider(
                                          counterpart.avatarThumbUrl),
                              child: counterpart.avatarThumbUrl.isEmpty
                                  ? Icon(PhosphorIconsFill.user,
                                      size: 14,
                                      color: isDark
                                          ? WawatDark.iconMuted
                                          : dealInk400)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      counterpart.fullname,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? WawatDark.textSecondary
                                            : dealInk700,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (counterpart.isVerified) ...[
                                    const SizedBox(width: 3),
                                    Icon(PhosphorIconsFill.sealCheck,
                                        size: 13, color: dealBrand),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (shipment.priceTotal != null)
                          Text(
                            '${shipment.priceTotal!.toStringAsFixed(0)} \$',
                            style: TextStyle(
                              color:
                                  isDark ? WawatDark.textPrimary : dealInk900,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          [
                            if (shipment.weightKg != null)
                              '${shipment.weightKg} kq',
                            dealPackageLabel(shipment.packageTypeCode),
                          ].where((e) => e.isNotEmpty).join(' · '),
                          style: TextStyle(
                            color: isDark ? WawatDark.textMuted : dealInk400,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ..._footer(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _footer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_awaitingProposalReply) {
      return [
        const SizedBox(height: 10),
        _HintBanner(
          icon: PhosphorIconsFill.handPointing,
          color: isDark ? WawatDark.warning : dealAmber700,
          background: isDark ? WawatDark.surfaceAlt : dealAmber100,
          text: WawatContent.text(content, 'deals.your_turn',
              tr('deals.your_turn', 'Sizin növbəniz — cavab verin')),
        ),
      ];
    }
    if (_awaitingReceiptConfirm) {
      return [
        const SizedBox(height: 10),
        _HintBanner(
          icon: PhosphorIconsFill.checkCircle,
          color: isDark ? WawatDark.brand : dealBrand700,
          background: isDark ? WawatDark.brandSoft : dealBrand50,
          text: WawatContent.text(
            content,
            'deals.confirm_receipt_hint',
            tr('deals.confirm_receipt_hint', 'Malı aldınız? Təsdiqləyin'),
          ),
        ),
      ];
    }
    if (shipment.status == 'completed') {
      return [
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark ? WawatDark.brandSoft : dealBrand50,
              foregroundColor: isDark ? WawatDark.brand : dealBrand700,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(PhosphorIconsFill.star, size: 15),
            label: Text(
              WawatContent.text(content, 'deals.action.review',
                  tr('deals.action.review', 'Rəy yaz')),
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ];
    }
    if (shipment.status == 'cancelled') {
      final reason = shipment.cancelReasonLabel;
      return [
        const SizedBox(height: 10),
        _MutedLine(
          icon: PhosphorIconsRegular.info,
          text: [
            if (reason != null && reason.isNotEmpty)
              '${WawatContent.text(content, 'deals.reason_prefix', tr('deals.reason_prefix', 'Səbəb'))}: $reason',
            dealShortDate(shipment.createdAt),
          ].where((e) => e.isNotEmpty).join(' · '),
        ),
      ];
    }
    if (shipment.status == 'declined') {
      return [
        const SizedBox(height: 10),
        _MutedLine(
          icon: PhosphorIconsRegular.clockCounterClockwise,
          text: dealShortDate(shipment.createdAt),
        ),
      ];
    }
    if (shipment.status == 'expired') {
      return [
        const SizedBox(height: 10),
        _MutedLine(
          icon: PhosphorIconsRegular.clockCounterClockwise,
          text: [
            WawatContent.text(content, 'deals.expired_unanswered',
                tr('deals.expired_unanswered', 'Cavabsız qaldı')),
            dealShortDate(shipment.createdAt),
          ].where((e) => e.isNotEmpty).join(' · '),
        ),
      ];
    }
    if (shipment.travelDate != null) {
      return [
        const SizedBox(height: 10),
        _MutedLine(
          icon: PhosphorIconsRegular.calendarBlank,
          text:
              '${WawatContent.text(content, 'deals.terms.trip_date', tr('deals.terms.trip_date', 'Səfər'))}: '
              '${dealShortDate(shipment.travelDate)}',
        ),
      ];
    }
    return const [];
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String label;

  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  final Map<String, String> content;

  const _RoleChip({required this.role, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSender = role == 'sender';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            isDark ? WawatDark.surfaceAlt : dealInk900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSender
                ? PhosphorIconsFill.paperPlaneTilt
                : PhosphorIconsFill.airplaneTilt,
            size: 11,
            color: isDark ? WawatDark.textSecondary : dealInk700,
          ),
          const SizedBox(width: 4),
          Text(
            WawatContent.text(
              content,
              isSender ? 'deals.role.sender' : 'deals.role.carrier',
              isSender
                  ? tr('deals.role.sender', 'Göndərən')
                  : tr('deals.role.carrier', 'Daşıyıcı'),
            ),
            style: TextStyle(
              color: isDark ? WawatDark.textSecondary : dealInk700,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String text;

  const _HintBanner({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MutedLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? WawatDark.textMuted : dealInk400;
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: color, fontSize: 11.5, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
