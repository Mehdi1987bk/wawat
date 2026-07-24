import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/wawat_content.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _brand700 = Color(0xFF024FA3);
const _ink900 = Color(0xFF0F172A);

/// Sticky bar under the thread header showing the conversation's active deal
/// (§3A.2). Colour/icon/hint follow the shipment status; amber when it's the
/// current user's turn. Tapping opens the deal detail screen.
class DealPinBar extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;
  final VoidCallback onTap;

  const DealPinBar({
    super.key,
    required this.shipment,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _visual();
    // On graphite, lift the deliberately-dark hint hues to their palette
    // equivalents so they stay legible; light mode keeps the exact hint colour.
    final hintColor = isDark ? _darkHint(visual.hintColor) : visual.hintColor;
    final tileColor = isDark ? _darkHint(visual.tileColor) : visual.tileColor;
    final title = [
      shipment.statusLabel.isNotEmpty ? shipment.statusLabel : _statusFallback(),
      if (shipment.route.isNotEmpty) shipment.route,
    ].join(' · ');

    return Material(
      color: isDark ? WawatDark.surface : visual.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: isDark
                      ? WawatDark.divider
                      : _ink900.withValues(alpha: 0.07)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(13, 8, 13, 9),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.surfaceAlt : visual.tileBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(visual.icon, color: tileColor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : _ink900,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _hint(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hintColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(PhosphorIconsBold.caretRight, color: tileColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _t(String key, String fallback) =>
      WawatContent.text(content, key, fallback);

  String _statusFallback() {
    return switch (shipment.status) {
      'proposal_pending' => 'Təklif gözləyir',
      'accepted' => 'Qəbul olundu',
      'picked_up' => 'Mal götürüldü',
      'delivered' => 'Çatdırıldı',
      'disputed' => 'Mübahisəli',
      'completed' => 'Tamamlandı',
      'auto_completed' => 'Avtomatik tamamlandı',
      _ => 'Sövdələşmə',
    };
  }

  String _hint() {
    final price = shipment.priceTotal;
    switch (shipment.status) {
      case 'proposal_pending':
        if (shipment.isAwaitingMe) {
          return _t('chat.pinbar.your_turn', 'Sizin növbəniz — cavab verin');
        }
        final waiting = _t('chat.pinbar.awaiting_reply', 'Cavab gözlənilir');
        return price == null ? waiting : '$waiting · ${_money(price)}';
      case 'accepted':
        return shipment.isCarrier
            ? _t('chat.pinbar.accepted_carrier', 'Malı göndərəndən götürün')
            : _t('chat.pinbar.accepted_sender', 'Daşıyıcı malı götürəcək');
      case 'picked_up':
        return _t('chat.pinbar.picked_up', 'Yolda');
      case 'delivered':
        return _t('chat.pinbar.delivered', 'Malı aldınızsa təsdiqləyin');
      case 'disputed':
        return _t('chat.pinbar.disputed', 'Araşdırılır');
      case 'completed':
      case 'auto_completed':
        return _t('chat.pinbar.completed', 'Rəy yazın — təcrübəni bölüşün');
      default:
        return '';
    }
  }

  String _money(double value) => '${value.toStringAsFixed(0)} ₼';

  /// Maps a light-mode status hue to its graphite-palette equivalent so text
  /// and icons stay legible on the dark surface. Brand blue stays brand blue.
  Color _darkHint(Color light) {
    if (light == const Color(0xFF8A5D00) || light == const Color(0xFFB67C00)) {
      return WawatDark.warning; // pending amber
    }
    if (light == _brand700) {
      return WawatDark.brand; // accepted/picked/delivered dark blue
    }
    if (light == const Color(0xFFDC2626)) {
      return WawatDark.danger; // disputed red
    }
    if (light == const Color(0xFF059669)) {
      return WawatDark.success; // completed green
    }
    return light;
  }

  _PinVisual _visual() {
    switch (shipment.status) {
      case 'proposal_pending':
        final iconData = shipment.isAwaitingMe
            ? PhosphorIconsFill.hourglassMedium
            : PhosphorIconsFill.paperPlaneTilt;
        return const _PinVisual(
          background: Color(0xFFFEF6E7),
          tileBackground: Color(0xFFFDECC8),
          tileColor: Color(0xFFB67C00),
          hintColor: Color(0xFF8A5D00),
          icon: PhosphorIconsFill.hourglassMedium,
        ).withIcon(iconData);
      case 'accepted':
        return const _PinVisual(
          background: _brand50,
          tileBackground: Color(0xFFCFE3FD),
          tileColor: _brand,
          hintColor: _brand700,
          icon: PhosphorIconsFill.handshake,
        );
      case 'picked_up':
        return const _PinVisual(
          background: _brand50,
          tileBackground: Color(0xFFCFE3FD),
          tileColor: _brand,
          hintColor: _brand700,
          icon: PhosphorIconsFill.package,
        );
      case 'delivered':
        return const _PinVisual(
          background: _brand50,
          tileBackground: Color(0xFFCFE3FD),
          tileColor: _brand,
          hintColor: _brand700,
          icon: PhosphorIconsFill.mapPinArea,
        );
      case 'disputed':
        return const _PinVisual(
          background: Color(0xFFFEF2F2),
          tileBackground: Color(0xFFFEE2E2),
          tileColor: Color(0xFFDC2626),
          hintColor: Color(0xFFDC2626),
          icon: PhosphorIconsFill.warningOctagon,
        );
      case 'completed':
      case 'auto_completed':
      default:
        return const _PinVisual(
          background: Color(0xFFECFDF5),
          tileBackground: Color(0xFFD1FAE5),
          tileColor: Color(0xFF059669),
          hintColor: Color(0xFF059669),
          icon: PhosphorIconsFill.sealCheck,
        );
    }
  }
}

class _PinVisual {
  final Color background;
  final Color tileBackground;
  final Color tileColor;
  final Color hintColor;
  final IconData icon;

  const _PinVisual({
    required this.background,
    required this.tileBackground,
    required this.tileColor,
    required this.hintColor,
    required this.icon,
  });

  _PinVisual withIcon(IconData newIcon) => _PinVisual(
        background: background,
        tileBackground: tileBackground,
        tileColor: tileColor,
        hintColor: hintColor,
        icon: newIcon,
      );
}
