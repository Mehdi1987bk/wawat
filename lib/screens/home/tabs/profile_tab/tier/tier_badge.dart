import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/wawat_content.dart';

/// Compact tier badge — a mini gradient medal + the (localized) tier label,
/// tinted in the tier's colour. Matches the "Statusum" page so a user's level
/// reads the same everywhere (profile header, public profile). Works for every
/// tier including `new`/`standard`.
class TierBadge extends StatelessWidget {
  final String tier;
  final Map<String, String> content;

  const TierBadge({
    super.key,
    required this.tier,
    this.content = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = tierBadgeColors(tier, isDark);
    final label =
        WawatContent.text(content, 'enum.user_tier.$tier', tierLabel(tier));
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 9, 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniMedal(tier: tier),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: colors.$2,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMedal extends StatelessWidget {
  final String tier;

  const _MiniMedal({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tierGradient(tier),
          stops: const [0.0, 0.53, 1.0],
        ),
      ),
      child: Icon(tierIcon(tier), size: 11, color: Colors.white),
    );
  }
}

// ── tier visuals (shared with the Statusum page's design language) ──

IconData tierIcon(String key) {
  switch (key) {
    case 'new':
      return PhosphorIconsFill.sparkle;
    case 'standard':
      return PhosphorIconsFill.shield;
    case 'bronze':
      return PhosphorIconsFill.medal;
    case 'silver':
      return PhosphorIconsFill.medal;
    case 'gold':
      return PhosphorIconsFill.trophy;
    case 'platinum':
      return PhosphorIconsFill.crownSimple;
    default:
      return PhosphorIconsFill.medal;
  }
}

List<Color> tierGradient(String key) {
  switch (key) {
    case 'new':
      return const [Color(0xFFEEF2F6), Color(0xFFCBD5E1), Color(0xFF94A3B8)];
    case 'standard':
      return const [Color(0xFFDCE3EC), Color(0xFFAEB9C8), Color(0xFF7E8CA1)];
    case 'bronze':
      return const [Color(0xFFF3CFA6), Color(0xFFCB8A4C), Color(0xFF96552A)];
    case 'silver':
      return const [Color(0xFFF5F8FB), Color(0xFFC3CDD9), Color(0xFF8F9BAC)];
    case 'gold':
      return const [Color(0xFFFDEAA6), Color(0xFFF0C04C), Color(0xFFC4922B)];
    case 'platinum':
      return const [Color(0xFFECF1FF), Color(0xFFC2CDEA), Color(0xFF8C9BC6)];
    default:
      return const [Color(0xFFEEF2F6), Color(0xFFCBD5E1), Color(0xFF94A3B8)];
  }
}

/// Localized tier labels via CMS `enum.user_tier.{key}`, with the AZ text as
/// inline fallback (same keys the badge resolves at its render site).
String tierLabel(String key) {
  switch (key) {
    case 'new':
      return tr('enum.user_tier.new', 'Yeni');
    case 'standard':
      return tr('enum.user_tier.standard', 'Standart');
    case 'bronze':
      return tr('enum.user_tier.bronze', 'Bürünc');
    case 'silver':
      return tr('enum.user_tier.silver', 'Gümüş');
    case 'gold':
      return tr('enum.user_tier.gold', 'Qızıl');
    case 'platinum':
      return tr('enum.user_tier.platinum', 'Platin');
    default:
      return key;
  }
}

/// (background, foreground) for the badge pill, per tier + theme.
(Color, Color) tierBadgeColors(String key, bool isDark) {
  if (isDark) {
    return switch (key) {
      'bronze' => (WawatDark.tierBronzeBg, WawatDark.tierBronzeText),
      'silver' => (WawatDark.tierSilverBg, WawatDark.tierSilverText),
      'gold' => (WawatDark.tierGoldBg, WawatDark.tierGoldText),
      'platinum' => (WawatDark.tierPlatinumBg, WawatDark.tierPlatinumText),
      'standard' => (WawatDark.brandChip, WawatDark.brandText),
      _ => (WawatDark.surfaceAlt, WawatDark.textSecondary),
    };
  }
  return switch (key) {
    'bronze' => (const Color(0xFFEFE1D0), const Color(0xFF9A5B2A)),
    'silver' => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
    'gold' => (const Color(0xFFFDECC8), const Color(0xFFB67C00)),
    'platinum' => (const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
    'standard' => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
    _ => (const Color(0xFFF1F5F9), const Color(0xFF64748B)),
  };
}
