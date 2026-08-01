import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../presentation/common/app_bottom_sheet.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';

/// The app's primary listing-type filter, rendered as a prominent trigger
/// button that opens a bottom-sheet picker (Hamısı / Səfər / Göndəriş).
///
/// Data: `value` is null (all) | 'trip' | 'shipment_post'. Labels come from the
/// CMS; per-type icons match the rest of the app (plane = blue, parcel = amber).
class ListingTypeFilter extends StatelessWidget {
  final String? value;
  final Map<String, String> content;
  final ValueChanged<String?> onChanged;

  const ListingTypeFilter({
    super.key,
    required this.value,
    required this.content,
    required this.onChanged,
  });

  List<_TypeOption> _options() => [
        _TypeOption(
          value: null,
          label: WawatContent.text(content, 'search.type_all', 'Hamısı'),
          icon: PhosphorIconsBold.squaresFour,
          accent: _Accent.brand,
        ),
        _TypeOption(
          value: 'trip',
          label: WawatContent.text(content, 'enum.listing_type.trip', 'Səfər'),
          icon: PhosphorIconsBold.airplaneTilt,
          accent: _Accent.brand,
        ),
        _TypeOption(
          value: 'shipment_post',
          label: WawatContent.text(
              content, 'enum.listing_type.shipment_post', 'Göndəriş'),
          icon: PhosphorIconsBold.package,
          accent: _Accent.amber,
        ),
      ];

  _TypeOption _active(List<_TypeOption> options) => options.firstWhere(
        (o) => o.value == value,
        orElse: () => options.first,
      );

  Future<void> _open(BuildContext context) async {
    final options = _options();
    final selected = await showAppBottomSheet<_TypeResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeFilterSheet(
        content: content,
        options: options,
        activeValue: value,
      ),
    );
    if (selected != null) onChanged(selected.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = _options();
    final active = _active(options);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // Brand-tinted so the primary filter reads as the important control.
          color: cBrandSoft(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? WawatDark.brand.withValues(alpha: 0.45)
                : cBrandFill.withValues(alpha: 0.30),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cBrandFill.withValues(alpha: isDark ? 0.28 : 0.16),
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _IconChip(icon: active.icon, accent: active.accent, isDark: isDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cText(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretDown,
                size: 16, color: cBrandText(isDark)),
          ],
        ),
      ),
    );
  }
}

// ── bottom-sheet picker ──

class _TypeFilterSheet extends StatelessWidget {
  final Map<String, String> content;
  final List<_TypeOption> options;
  final String? activeValue;

  const _TypeFilterSheet({
    required this.content,
    required this.options,
    required this.activeValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: cCard(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Reserve the OS navigation-bar inset (the sheet helper doesn't).
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.grab : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            WawatContent.text(content, 'search.filter_type', 'Elan tipi'),
            style: TextStyle(
              color: cText(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final option in options)
            _TypeRow(
              option: option,
              selected: option.value == activeValue,
              isDark: isDark,
              onTap: () => Navigator.pop(context, _TypeResult(option.value)),
            ),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final _TypeOption option;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeRow({
    required this.option,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? cBrandSoft(isDark)
              : (isDark ? cFill(isDark) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: cBrandFill.withValues(alpha: 0.9), width: 1.4)
              : null,
        ),
        child: Row(
          children: [
            _IconChip(icon: option.icon, accent: option.accent, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? cBrandText(isDark) : cText(isDark),
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(PhosphorIconsFill.checkCircle,
                  size: 20, color: cBrandText(isDark)),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final _Accent accent;
  final bool isDark;

  const _IconChip({
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg;
    switch (accent) {
      case _Accent.brand:
        fg = isDark ? WawatDark.brandText : cBrandFill;
        break;
      case _Accent.amber:
        fg = isDark ? const Color(0xFFF4C64D) : const Color(0xFFEAB308);
        break;
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

enum _Accent { brand, amber }

class _TypeOption {
  final String? value;
  final String label;
  final IconData icon;
  final _Accent accent;

  const _TypeOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });
}

/// Wrapper so a null selection (Hamısı) can round-trip through the sheet's
/// nullable `showAppBottomSheet<_TypeResult>` result.
class _TypeResult {
  final String? value;
  const _TypeResult(this.value);
}
