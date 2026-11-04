import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../data/network/response/chat_response.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/localization_service.dart';
import 'package:buking/services/date_labels.dart';
import '../../../../../../services/wawat_content.dart';

const dealBrand = Color(0xFF017BFE);
const dealBrand50 = Color(0xFFEAF3FE);
const dealBrand700 = Color(0xFF024FA3);
const dealAmber100 = Color(0xFFFDECC8);
const dealAmber700 = Color(0xFF8A5D00);
const dealEmerald50 = Color(0xFFECFDF5);
const dealEmerald600 = Color(0xFF059669);
const dealRed50 = Color(0xFFFEF2F2);
const dealRed600 = Color(0xFFDC2626);
const dealInk900 = Color(0xFF0F172A);
const dealInk700 = Color(0xFF334155);
const dealInk600 = Color(0xFF475569);
const dealInk500 = Color(0xFF64748B);
const dealInk400 = Color(0xFF94A3B8);
const dealInk300 = Color(0xFFCBD5E1);
const dealInk200 = Color(0xFFE2E8F0);
const dealInk100 = Color(0xFFF1F5F9);
const dealScreenBg = Color(0xFFF4F6F9);

const List<String> dealTerminalStatuses = [
  'completed',
  'auto_completed',
  'disputed',
  'declined',
  'cancelled',
  'expired',
];

bool dealIsTerminal(String status) => dealTerminalStatuses.contains(status);

class DealVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const DealVisual(this.icon, this.color, this.background);
}

DealVisual dealStatusVisual(String status, [bool isDark = false]) {
  final Color brandColor = isDark ? WawatDark.brand : dealBrand700;
  final Color brandBg = isDark ? WawatDark.brandSoft : dealBrand50;
  final Color amberColor = isDark ? WawatDark.warning : dealAmber700;
  final Color amberBg = isDark ? WawatDark.surfaceAlt : dealAmber100;
  final Color emeraldColor = isDark ? WawatDark.success : dealEmerald600;
  final Color emeraldBg = isDark ? WawatDark.surfaceAlt : dealEmerald50;
  final Color redColor = isDark ? WawatDark.danger : dealRed600;
  final Color redBg = isDark ? WawatDark.surfaceAlt : dealRed50;
  final Color neutralColor = isDark ? WawatDark.textSecondary : dealInk500;
  final Color neutralBg = isDark ? WawatDark.surfaceAlt : dealInk100;
  return switch (status) {
    'proposal_pending' =>
      DealVisual(PhosphorIconsFill.hourglassMedium, amberColor, amberBg),
    'accepted' => DealVisual(PhosphorIconsFill.handshake, brandColor, brandBg),
    'picked_up' => DealVisual(PhosphorIconsFill.package, brandColor, brandBg),
    'delivered' =>
      DealVisual(PhosphorIconsFill.mapPinLine, brandColor, brandBg),
    'completed' =>
      DealVisual(PhosphorIconsFill.sealCheck, emeraldColor, emeraldBg),
    'auto_completed' =>
      DealVisual(PhosphorIconsFill.checkCircle, emeraldColor, emeraldBg),
    'disputed' => DealVisual(PhosphorIconsFill.warningOctagon, redColor, redBg),
    'declined' => DealVisual(PhosphorIconsFill.xCircle, redColor, redBg),
    'cancelled' => DealVisual(PhosphorIconsFill.prohibit, redColor, redBg),
    'expired' =>
      DealVisual(PhosphorIconsFill.clockCountdown, neutralColor, neutralBg),
    _ => DealVisual(PhosphorIconsFill.paperPlaneTilt, brandColor, brandBg),
  };
}

String dealStatusLabel(Map<String, String> content, String status,
    [String? apiLabel]) {
  if (apiLabel != null && apiLabel.isNotEmpty) return apiLabel;
  return WawatContent.text(content, 'enum.shipment_status.$status', status);
}

String dealActionLabel(Map<String, String> content, String action) {
  final fallbacks = {
    'accept': tr('deals.action.accept', 'Qəbul et'),
    'decline': tr('deals.action.decline', 'Rədd et'),
    'counter': tr('deals.action.counter', 'Qarşı təklif'),
    'picked_up': tr('deals.action.picked_up', 'Malı götürdüm'),
    'picked-up': tr('deals.action.picked_up', 'Malı götürdüm'),
    'delivered': tr('deals.action.delivered', 'Çatdırdım'),
    'complete': tr('deals.action.complete', 'Malı aldım, təsdiqlə'),
    'dispute': tr('deals.action.dispute', 'Problem bildir'),
    'cancel': tr('deals.action.cancel', 'Ləğv et'),
    'withdraw': tr('deals.action.withdraw', 'Təklifi geri götür'),
    'review': tr('deals.action.review', 'Rəy yaz'),
  };
  final key = action == 'picked-up' ? 'picked_up' : action;
  return WawatContent.text(
    content,
    'deals.action.$key',
    fallbacks[action] ?? action,
  );
}

IconData dealActionIcon(String action) {
  return switch (action) {
    'accept' => PhosphorIconsBold.check,
    'decline' => PhosphorIconsBold.x,
    'counter' => PhosphorIconsBold.arrowUUpLeft,
    'picked_up' || 'picked-up' => PhosphorIconsFill.package,
    'delivered' => PhosphorIconsFill.mapPinLine,
    'complete' => PhosphorIconsFill.sealCheck,
    'dispute' => PhosphorIconsFill.warningOctagon,
    'cancel' => PhosphorIconsFill.prohibit,
    'review' => PhosphorIconsFill.star,
    _ => PhosphorIconsRegular.circle,
  };
}

String dealNormalizeAction(String action) =>
    action == 'picked_up' ? 'picked-up' : action;

String dealShortDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return '${date.day} ${monthFull(date.month)}';
}

String dealPackageLabel(String? code) {
  return switch (code) {
    'documents' => tr('enum.package_type.documents', 'Sənədlər'),
    'small_parcel' => tr('enum.package_type.small_parcel', 'Kiçik bağlama'),
    'electronics' => tr('enum.package_type.electronics', 'Elektronika'),
    'clothing' => tr('enum.package_type.clothing', 'Geyim'),
    'food' => tr('enum.package_type.food', 'Qida'),
    'other' => tr('enum.package_type.other', 'Digər'),
    _ => code ?? '',
  };
}

List<String> dealSupportedActions(List<String> actions) {
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
  return actions.map(dealNormalizeAction).where(supported.contains).toList();
}

List<DealAction> dealActionsOf(
    ShipmentData shipment, Map<String, String> content) {
  final actions = shipment.actions;
  if (actions != null) return actions;

  DealAction legacy(
    String key, {
    required String style,
    String? endpoint,
    bool needsInput = false,
    bool confirm = false,
  }) =>
      DealAction(
        key: key,
        label: dealActionLabel(content, key),
        style: style,
        endpoint: endpoint ?? key,
        needsInput: needsInput,
        confirm: confirm,
      );

  if (shipment.status == 'proposal_pending' && !shipment.isAwaitingMe) {
    return [
      legacy('withdraw', style: 'danger', endpoint: 'cancel', needsInput: true),
    ];
  }

  final result = <DealAction>[];
  for (final id in dealSupportedActions(shipment.availableActions)) {
    switch (id) {
      case 'accept':
        result.add(legacy('accept', style: 'primary'));
      case 'decline':
        result.add(legacy('decline', style: 'danger'));
      case 'counter':
        result.add(legacy('counter', style: 'secondary', needsInput: true));
      case 'picked-up':
        result.add(legacy('picked_up',
            style: 'primary', endpoint: 'picked-up', confirm: true));
      case 'delivered':
        result.add(legacy('delivered', style: 'primary', confirm: true));
      case 'complete':
        result.add(legacy('complete', style: 'primary', confirm: true));
      case 'dispute':
        result.add(legacy('dispute', style: 'danger', needsInput: true));
      case 'cancel':
        result.add(legacy('cancel', style: 'danger', needsInput: true));
    }
  }
  return result;
}
