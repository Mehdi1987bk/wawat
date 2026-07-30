import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../presentation/resourses/wawat_dark.dart';
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
  // Тёмный режим: пастельные подложки → мягкий графит-акцент, тёмно-синие/зелёные
  // акценты → яркие читаемые. cancelled → красный (явно «отменено»); declined/
  // expired остаются нейтральным графитом.
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
    'declined' =>
      DealVisual(PhosphorIconsFill.xCircle, neutralColor, neutralBg),
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
  const fallbacks = {
    'accept': 'Qəbul et',
    'decline': 'Rədd et',
    'counter': 'Qarşı təklif',
    'picked_up': 'Malı götürdüm',
    'picked-up': 'Malı götürdüm',
    'delivered': 'Çatdırdım',
    'complete': 'Malı aldım, təsdiqlə',
    'dispute': 'Problem bildir',
    'cancel': 'Ləğv et',
    'review': 'Rəy yaz',
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

/// Normalizes the API's `picked_up` action id to the mockup/UI's `picked-up` spelling.
String dealNormalizeAction(String action) =>
    action == 'picked_up' ? 'picked-up' : action;

const _azMonths = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avqust',
  'sentyabr',
  'oktyabr',
  'noyabr',
  'dekabr',
];

/// Formats an ISO date/datetime string as "24 iyul", matching the mockup's date style.
String dealShortDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return '${date.day} ${_azMonths[date.month - 1]}';
}

String dealPackageLabel(String? code) {
  return switch (code) {
    'documents' => 'Sənədlər',
    'small_parcel' => 'Kiçik bağlama',
    'electronics' => 'Elektronika',
    'clothing' => 'Geyim',
    'food' => 'Qida',
    'other' => 'Digər',
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
