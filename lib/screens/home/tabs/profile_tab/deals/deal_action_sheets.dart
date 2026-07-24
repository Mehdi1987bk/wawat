import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/chat_response.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import 'widgets/deal_status.dart';

const _cancelReasons = [
  'plans_changed',
  'terms_disagreement',
  'counterpart_unresponsive',
  'found_another',
  'other',
];

const _disputeReasons = [
  ['not_arrived', 'Mal çatmadı'],
  ['damaged', 'Mal zədəli / əskik'],
  ['lost_contact', 'Əlaqə kəsildi'],
  ['other', 'Digər'],
];

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.6)
        : dealInk900.withValues(alpha: 0.45),
    builder: builder,
  );
}

class _SheetShell extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SheetShell({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.iconMuted : dealInk200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool isDark;

  const _SheetField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: isDark ? WawatDark.textSecondary : dealInk600,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
              color: isDark ? WawatDark.textPrimary : dealInk900,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? WawatDark.textMuted : dealInk400,
                fontWeight: FontWeight.w500),
            filled: true,
            fillColor:
                isDark ? WawatDark.surfaceAlt : dealInk900.withValues(alpha: 0.02),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: isDark ? WawatDark.border : dealInk900.withValues(alpha: 0.07)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: isDark ? WawatDark.border : dealInk900.withValues(alpha: 0.07)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: dealBrand, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

Future<Map<String, dynamic>?> showDealCounterOfferSheet(
  BuildContext context, {
  required Map<String, String> content,
  required ShipmentData shipment,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final weightController = TextEditingController(text: shipment.weightKg?.toString() ?? '');
  final priceController = TextEditingController(text: shipment.priceTotal?.toStringAsFixed(0) ?? '');
  final noteController = TextEditingController();
  return _showSheet<Map<String, dynamic>>(
    context,
    (sheetContext) => _SheetShell(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsBold.arrowUUpLeft, color: dealBrand, size: 18),
              const SizedBox(width: 8),
              Text(
                WawatContent.text(content, 'deals.counter.title', 'Qarşı təklif'),
                style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : dealInk900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            WawatContent.text(
              content,
              'deals.counter.hint',
              'Şərtləri dəyişib göndər — qarşı tərəf təsdiqləyəcək.',
            ),
            style: TextStyle(
                color: isDark ? WawatDark.textMuted : dealInk500,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          _SheetField(
            isDark: isDark,
            label: '${WawatContent.text(content, 'deals.terms.weight', 'Çəki')} (kq)',
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _SheetField(
            isDark: isDark,
            label: '${WawatContent.text(content, 'deals.terms.price', 'Qiymət')} (₼)',
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _SheetField(
            isDark: isDark,
            label: WawatContent.text(content, 'deals.note_optional', 'Qeyd (istəyə bağlı)'),
            controller: noteController,
            maxLines: 2,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop({
                  if (weightController.text.trim().isNotEmpty)
                    'weight_kg': double.tryParse(weightController.text.trim()),
                  if (priceController.text.trim().isNotEmpty)
                    'price_total': double.tryParse(priceController.text.trim()),
                  if (noteController.text.trim().isNotEmpty) 'note': noteController.text.trim(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dealBrand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(PhosphorIconsFill.paperPlaneTilt,
                  size: 17, color: Colors.white),
              label: Text(
                WawatContent.text(content, 'deals.counter.submit', 'Qarşı təklifi göndər'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(
                WawatContent.text(content, 'common.cancel', 'İmtina et'),
                style: TextStyle(
                    color: isDark ? WawatDark.textMuted : dealInk500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>?> showDealCancelSheet(
  BuildContext context, {
  required Map<String, String> content,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final noteController = TextEditingController();
  var selected = _cancelReasons.first;
  return _showSheet<Map<String, dynamic>>(
    context,
    (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) => _SheetShell(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(PhosphorIconsFill.prohibit, color: dealRed600, size: 18),
                const SizedBox(width: 8),
                Text(
                  WawatContent.text(content, 'deals.cancel.title', 'Sövdələşməni ləğv et'),
                  style: TextStyle(
                      color: isDark ? WawatDark.textPrimary : dealInk900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'deals.cancel.hint',
                'Səbəbi seçin — qarşı tərəfə bildiriləcək.',
              ),
              style: TextStyle(
                  color: isDark ? WawatDark.textMuted : dealInk500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            for (final reason in _cancelReasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReasonOption(
                  isDark: isDark,
                  label: WawatContent.text(content, 'enum.shipment_cancel_reason.$reason', reason),
                  selected: selected == reason,
                  onTap: () => setState(() => selected = reason),
                ),
              ),
            const SizedBox(height: 4),
            _SheetField(
              isDark: isDark,
              label: WawatContent.text(content, 'deals.note_optional', 'Qeyd (istəyə bağlı)'),
              controller: noteController,
              maxLines: 2,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop({
                    'reason_code': selected,
                    if (noteController.text.trim().isNotEmpty) 'reason_note': noteController.text.trim(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealRed600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(PhosphorIconsFill.prohibit,
                    size: 17, color: Colors.white),
                label: Text(
                  WawatContent.text(content, 'deals.action.cancel', 'Ləğv et'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  WawatContent.text(content, 'common.back', 'Geri'),
                  style: TextStyle(
                      color: isDark ? WawatDark.textMuted : dealInk500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>?> showDealDisputeSheet(
  BuildContext context, {
  required Map<String, String> content,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final reasonController = TextEditingController();
  var selected = _disputeReasons.first[0];
  return _showSheet<Map<String, dynamic>>(
    context,
    (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) => _SheetShell(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(PhosphorIconsFill.warningOctagon, color: dealRed600, size: 18),
                const SizedBox(width: 8),
                Text(
                  WawatContent.text(content, 'deals.dispute.title', 'Problem bildir'),
                  style: TextStyle(
                      color: isDark ? WawatDark.textPrimary : dealInk900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'deals.dispute.hint',
                'Nə baş verdiyini yazın — admin araşdıracaq. Sövdələşmə «Mübahisəli» statusuna keçəcək.',
              ),
              style: TextStyle(
                  color: isDark ? WawatDark.textMuted : dealInk500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            for (final entry in _disputeReasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReasonOption(
                  isDark: isDark,
                  label: WawatContent.text(content, 'deals.dispute_reason.${entry[0]}', entry[1]),
                  selected: selected == entry[0],
                  onTap: () => setState(() => selected = entry[0]),
                ),
              ),
            const SizedBox(height: 4),
            _SheetField(
              isDark: isDark,
              label: '',
              controller: reasonController,
              hint: 'Ətraflı izah edin…',
              maxLines: 3,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final detail = reasonController.text.trim();
                  final reasonLabel = _disputeReasons.firstWhere((e) => e[0] == selected)[1];
                  final reason = detail.isEmpty ? reasonLabel : '$reasonLabel: $detail';
                  Navigator.of(sheetContext).pop({'reason': reason});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealRed600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(PhosphorIconsFill.flag,
                    size: 17, color: Colors.white),
                label: Text(
                  WawatContent.text(content, 'deals.dispute.submit', 'Problemi göndər'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  WawatContent.text(content, 'common.back', 'Geri'),
                  style: TextStyle(
                      color: isDark ? WawatDark.textMuted : dealInk500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> showDealConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String body,
  required Map<String, String> content,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: isDark ? WawatDark.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: isDark ? WawatDark.brandSoft : dealBrand50,
                  borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? WawatDark.textPrimary : dealInk900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? WawatDark.textMuted : dealInk500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  WawatContent.text(content, 'deals.confirm.yes', 'Bəli, təsdiqlə'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                WawatContent.text(content, 'deals.confirm.no', 'İmtina'),
                style: TextStyle(
                    color: isDark ? WawatDark.textMuted : dealInk500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

Future<Map<String, dynamic>?> showDealReviewSheet(
  BuildContext context, {
  required Map<String, String> content,
  required String counterpartName,
  String? counterpartAvatar,
  int initialRating = 5,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final commentController = TextEditingController();
  var rating = initialRating.clamp(1, 5);
  final selectedTraits = <String>{};
  const traits = [
    ['on_time', 'Vaxtında'],
    ['polite', 'Nəzakətli'],
    ['careful', 'Diqqətli'],
  ];
  return _showSheet<Map<String, dynamic>>(
    context,
    (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) => _SheetShell(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? WawatDark.surfaceAlt : dealInk100,
                    backgroundImage:
                        counterpartAvatar != null ? CachedNetworkImageProvider(counterpartAvatar) : null,
                    child: counterpartAvatar == null
                        ? Icon(PhosphorIconsFill.user,
                            color: isDark ? WawatDark.textMuted : dealInk400, size: 26)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    counterpartName,
                    style: TextStyle(
                        color: isDark ? WawatDark.textPrimary : dealInk900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final value = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() => rating = value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            value <= rating ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                            color: const Color(0xFFF5B301),
                            size: 30,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SheetField(
              isDark: isDark,
              label: '',
              controller: commentController,
              hint: WawatContent.text(content, 'deals.review.prompt', 'Təcrübəni bir neçə sözlə yaz…'),
              maxLines: 3,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final trait in traits)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (!selectedTraits.add(trait[0])) selectedTraits.remove(trait[0]);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selectedTraits.contains(trait[0])
                            ? dealEmerald50
                            : (isDark ? WawatDark.surfaceAlt : dealInk100),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        WawatContent.text(content, 'deals.review.trait.${trait[0]}', trait[1]),
                        style: TextStyle(
                          color: selectedTraits.contains(trait[0])
                              ? dealEmerald600
                              : (isDark ? WawatDark.textSecondary : dealInk600),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final traitSuffix =
                      selectedTraits.map((code) => traits.firstWhere((t) => t[0] == code)[1]).join(', ');
                  final comment = [commentController.text.trim(), traitSuffix]
                      .where((e) => e.isNotEmpty)
                      .join(' · ');
                  Navigator.of(sheetContext).pop({
                    'rating': rating,
                    if (comment.isNotEmpty) 'comment': comment,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(PhosphorIconsFill.paperPlaneTilt,
                    size: 17, color: Colors.white),
                label: Text(
                  WawatContent.text(content, 'deals.review.submit', 'Rəyi göndər'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReasonOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ReasonOption({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.brandSoft : dealBrand50.withValues(alpha: 0.6))
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? dealBrand
                  : (isDark ? WawatDark.border : dealInk900.withValues(alpha: 0.08)),
              width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? dealBrand : Colors.transparent,
                border: Border.all(
                    color: selected ? dealBrand : (isDark ? WawatDark.iconMuted : dealInk300),
                    width: 2),
              ),
              child: selected ? const Icon(PhosphorIconsBold.check, size: 11, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: isDark ? WawatDark.textSecondary : dealInk700,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
