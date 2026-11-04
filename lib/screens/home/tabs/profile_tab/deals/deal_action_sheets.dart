import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/chat_response.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/wawat_content.dart';
import 'widgets/deal_status.dart';

const dealCancelReasonCodes = [
  'plans_changed',
  'terms_disagreement',
  'counterpart_unresponsive',
  'found_another',
  'other',
];

const _packageCodes = [
  'documents',
  'small_parcel',
  'electronics',
  'clothing',
  'food',
  'other',
];

const dealDisputeMinLength = 5;
const dealDisputeMaxLength = 1000;

typedef DealConfirmSubmit = Future<bool> Function(BuildContext context);

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showAppBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: isDark ? WawatDark.scrim : dealInk900.withValues(alpha: 0.45),
    builder: builder,
  );
}

class _SheetShell extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SheetShell({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                      color: isDark ? WawatDark.grab : dealInk200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? hint;
  final bool isDark;

  const _SheetHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final hint = this.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : dealInk900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (hint != null && hint.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            hint,
            style: TextStyle(
                color: isDark ? WawatDark.textMuted : dealInk500,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool hasError;
  final double bottomSpacing;
  final bool isDark;

  const _SheetField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.hint,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.hasError = false,
    this.bottomSpacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    final idleBorder = hasError
        ? (isDark ? WawatDark.danger : dealRed600)
        : (isDark ? WawatDark.border : dealInk900.withValues(alpha: 0.07));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
                color: isDark ? WawatDark.textSecondary : dealInk600,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
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
            fillColor: isDark
                ? WawatDark.surfaceAlt
                : dealInk900.withValues(alpha: 0.02),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: idleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: idleBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: hasError
                      ? (isDark ? WawatDark.danger : dealRed600)
                      : dealBrand,
                  width: 1.5),
            ),
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}

class _SheetSubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SheetSubmitButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: Icon(icon, size: 17, color: Colors.white),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SheetBackButton extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SheetBackButton({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          label,
          style: TextStyle(
              color: isDark ? WawatDark.textMuted : dealInk500,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

mixin _SubmitsBody<T extends StatefulWidget> on State<T> {
  bool _closing = false;

  Future<void> submitBody(
    Map<String, dynamic> body,
    DealConfirmSubmit? confirm,
  ) async {
    if (_closing) return;
    _closing = true;
    try {
      if (confirm != null) {
        FocusScope.of(context).unfocus();
        final confirmed = await confirm(context);
        if (!confirmed || !mounted) return;
      }
      Navigator.of(context).pop(body);
    } finally {
      _closing = false;
    }
  }
}

class DealCounterPrefill {
  final double? weightKg;
  final double? priceTotal;
  final String? packageTypeCode;

  const DealCounterPrefill({
    this.weightKg,
    this.priceTotal,
    this.packageTypeCode,
  });

  factory DealCounterPrefill.fromPayload(Map<String, dynamic> payload) {
    return DealCounterPrefill(
      weightKg: _toNumber(payload['weight_kg']),
      priceTotal: _toNumber(payload['price_total']),
      packageTypeCode: _toCode(payload['package_type_code']),
    );
  }

  factory DealCounterPrefill.fromShipment(ShipmentData shipment) {
    return DealCounterPrefill(
      weightKg: shipment.weightKg,
      priceTotal: shipment.priceTotal,
      packageTypeCode: _toCode(shipment.packageTypeCode),
    );
  }

  static double? _toNumber(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString().trim().replaceAll(',', '.') ?? '');
    return number != null && number.isFinite && number > 0 ? number : null;
  }

  static String? _toCode(dynamic value) {
    final code = value?.toString().trim() ?? '';
    return code.isEmpty ? null : code;
  }
}

String _plainNumber(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

double? _parseNumber(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.'));

bool _isBadNumber(String raw) {
  if (raw.trim().isEmpty) return false;
  final value = _parseNumber(raw);
  return value == null || !value.isFinite || value <= 0;
}

Future<Map<String, dynamic>?> showDealCounterOfferSheet(
  BuildContext context, {
  required Map<String, String> content,
  DealCounterPrefill prefill = const DealCounterPrefill(),
  String? note,
  String? title,
  DealConfirmSubmit? confirmSubmit,
}) {
  return _showSheet<Map<String, dynamic>>(
    context,
    (_) => _CounterOfferSheet(
      content: content,
      prefill: prefill,
      note: note,
      title: title,
      confirmSubmit: confirmSubmit,
    ),
  );
}

class _CounterOfferSheet extends StatefulWidget {
  final Map<String, String> content;
  final DealCounterPrefill prefill;
  final String? note;
  final String? title;
  final DealConfirmSubmit? confirmSubmit;

  const _CounterOfferSheet({
    required this.content,
    required this.prefill,
    this.note,
    this.title,
    this.confirmSubmit,
  });

  @override
  State<_CounterOfferSheet> createState() => _CounterOfferSheetState();
}

class _CounterOfferSheetState extends State<_CounterOfferSheet>
    with _SubmitsBody {
  late final TextEditingController _weight;
  late final TextEditingController _price;
  late final TextEditingController _note;
  String? _packageCode;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(text: _plainNumber(widget.prefill.weightKg))
      ..addListener(_refresh);
    _price =
        TextEditingController(text: _plainNumber(widget.prefill.priceTotal))
          ..addListener(_refresh);
    _note = TextEditingController(text: widget.note ?? '')
      ..addListener(_refresh);
    _packageCode = widget.prefill.packageTypeCode;
  }

  @override
  void dispose() {
    _weight.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _canSubmit {
    if (_isBadNumber(_weight.text) || _isBadNumber(_price.text)) return false;
    return _weight.text.trim().isNotEmpty ||
        _price.text.trim().isNotEmpty ||
        _packageCode != null ||
        _note.text.trim().isNotEmpty;
  }

  void _submit() {
    if (!_canSubmit) return;
    final weight = _parseNumber(_weight.text);
    final price = _parseNumber(_price.text);
    final note = _note.text.trim();
    submitBody({
      if (weight != null) 'weight_kg': weight,
      if (price != null) 'price_total': price,
      if (_packageCode != null) 'package_type_code': _packageCode,
      if (note.isNotEmpty) 'note': note,
    }, widget.confirmSubmit);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = widget.content;
    final title = widget.title?.trim() ?? '';
    final prefilled = widget.prefill.packageTypeCode;
    final packageCodes = [
      if (prefilled != null && !_packageCodes.contains(prefilled)) prefilled,
      ..._packageCodes,
    ];
    final numberFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      LengthLimitingTextInputFormatter(10),
    ];
    return _SheetShell(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            isDark: isDark,
            icon: PhosphorIconsBold.arrowUUpLeft,
            iconColor: isDark ? WawatDark.brandText : dealBrand,
            title:
                title.isNotEmpty ? title : tr('deals.counter.title', 'Qarşı təklif'),
            hint: WawatContent.text(
              content,
              'deals.counter.hint',
              'Şərtləri dəyişib göndər — qarşı tərəf təsdiqləyəcək.',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SheetField(
                  isDark: isDark,
                  label:
                      '${WawatContent.text(content, 'deals.terms.weight', 'Çəki')} (kq)',
                  controller: _weight,
                  hasError: _isBadNumber(_weight.text),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: numberFormatters,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetField(
                  isDark: isDark,
                  label:
                      '${WawatContent.text(content, 'deals.terms.price', 'Qiymət')} (\$)',
                  controller: _price,
                  hasError: _isBadNumber(_price.text),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: numberFormatters,
                ),
              ),
            ],
          ),
          Text(
            WawatContent.text(content, 'deals.terms.package', 'Bağlama'),
            style: TextStyle(
                color: isDark ? WawatDark.textSecondary : dealInk600,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in packageCodes)
                _ChoiceChip(
                  isDark: isDark,
                  label: dealPackageLabel(code),
                  selected: _packageCode == code,
                  onTap: () => setState(
                      () => _packageCode = _packageCode == code ? null : code),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _SheetField(
            isDark: isDark,
            label: tr('deals.note_optional', 'Qeyd (istəyə bağlı)'),
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
          ),
          _SheetSubmitButton(
            label: tr('deals.counter.submit', 'Qarşı təklifi göndər'),
            icon: PhosphorIconsFill.paperPlaneTilt,
            color: dealBrand,
            onPressed: _canSubmit ? _submit : null,
          ),
          _SheetBackButton(
            isDark: isDark,
            label: WawatContent.text(content, 'common.cancel', 'İmtina et'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ChoiceChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.brandSoft : dealBrand50)
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? dealBrand
                : (isDark
                    ? WawatDark.border
                    : dealInk900.withValues(alpha: 0.08)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDark ? WawatDark.brandText : dealBrand700)
                : (isDark ? WawatDark.textSecondary : dealInk700),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> showDealCancelSheet(
  BuildContext context, {
  required Map<String, String> content,
  String? initialReasonCode,
  String? initialNote,
  String? title,
  String? submitLabel,
  DealConfirmSubmit? confirmSubmit,
}) {
  return _showSheet<Map<String, dynamic>>(
    context,
    (_) => _CancelSheet(
      content: content,
      initialReasonCode: initialReasonCode,
      initialNote: initialNote,
      title: title,
      submitLabel: submitLabel,
      confirmSubmit: confirmSubmit,
    ),
  );
}

class _CancelSheet extends StatefulWidget {
  final Map<String, String> content;
  final String? initialReasonCode;
  final String? initialNote;
  final String? title;
  final String? submitLabel;
  final DealConfirmSubmit? confirmSubmit;

  const _CancelSheet({
    required this.content,
    this.initialReasonCode,
    this.initialNote,
    this.title,
    this.submitLabel,
    this.confirmSubmit,
  });

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> with _SubmitsBody {
  late final TextEditingController _note =
      TextEditingController(text: widget.initialNote ?? '');
  late String? _reasonCode =
      dealCancelReasonCodes.contains(widget.initialReasonCode)
          ? widget.initialReasonCode
          : null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _reasonCode;
    if (code == null) return;
    final note = _note.text.trim();
    submitBody({
      'reason_code': code,
      if (note.isNotEmpty) 'reason_note': note,
    }, widget.confirmSubmit);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = widget.content;
    final title = widget.title?.trim() ?? '';
    final submitLabel = widget.submitLabel?.trim() ?? '';
    return _SheetShell(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            isDark: isDark,
            icon: PhosphorIconsFill.prohibit,
            iconColor: isDark ? WawatDark.dangerText : dealRed600,
            title: title.isNotEmpty
                ? title
                : tr('deals.cancel.title', 'Sövdələşməni ləğv et'),
            hint: WawatContent.text(
              content,
              'deals.cancel.hint',
              'Səbəbi seçin — qarşı tərəfə bildiriləcək.',
            ),
          ),
          const SizedBox(height: 12),
          for (final reason in dealCancelReasonCodes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReasonOption(
                isDark: isDark,
                label: WawatContent.text(
                    content, 'enum.shipment_cancel_reason.$reason'),
                selected: _reasonCode == reason,
                onTap: () => setState(() => _reasonCode = reason),
              ),
            ),
          const SizedBox(height: 4),
          _SheetField(
            isDark: isDark,
            label: tr('deals.note_optional', 'Qeyd (istəyə bağlı)'),
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
          ),
          _SheetSubmitButton(
            label: submitLabel.isNotEmpty
                ? submitLabel
                : WawatContent.text(content, 'deals.action.cancel', 'Ləğv et'),
            icon: PhosphorIconsFill.prohibit,
            color: dealRed600,
            onPressed: _reasonCode == null ? null : _submit,
          ),
          _SheetBackButton(
            isDark: isDark,
            label: WawatContent.text(content, 'common.back', 'Geri'),
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>?> showDealDisputeSheet(
  BuildContext context, {
  required Map<String, String> content,
  String? initialReason,
  String? title,
  DealConfirmSubmit? confirmSubmit,
}) {
  return _showSheet<Map<String, dynamic>>(
    context,
    (_) => _DisputeSheet(
      content: content,
      initialReason: initialReason,
      title: title,
      confirmSubmit: confirmSubmit,
    ),
  );
}

class _DisputeSheet extends StatefulWidget {
  final Map<String, String> content;
  final String? initialReason;
  final String? title;
  final DealConfirmSubmit? confirmSubmit;

  const _DisputeSheet({
    required this.content,
    this.initialReason,
    this.title,
    this.confirmSubmit,
  });

  @override
  State<_DisputeSheet> createState() => _DisputeSheetState();
}

class _DisputeSheetState extends State<_DisputeSheet> with _SubmitsBody {
  late final TextEditingController _reason =
      TextEditingController(text: widget.initialReason ?? '');

  @override
  void initState() {
    super.initState();
    _reason.addListener(_refresh);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  int get _length => _reason.text.trim().runes.length;

  bool get _canSubmit =>
      _length >= dealDisputeMinLength && _length <= dealDisputeMaxLength;

  void _submit() {
    if (!_canSubmit) return;
    submitBody({'reason': _reason.text.trim()}, widget.confirmSubmit);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = widget.content;
    final title = widget.title?.trim() ?? '';
    final length = _length;
    final tooShort = length < dealDisputeMinLength;
    final tooLong = length > dealDisputeMaxLength;
    final muted = isDark ? WawatDark.textMuted : dealInk500;
    final alert = isDark ? WawatDark.dangerText : dealRed600;
    return _SheetShell(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            isDark: isDark,
            icon: PhosphorIconsFill.warningOctagon,
            iconColor: alert,
            title: title.isNotEmpty
                ? title
                : tr('deals.dispute.title', 'Problem bildir'),
            hint: WawatContent.text(
              content,
              'deals.dispute.hint',
              'Nə baş verdiyini yazın — admin araşdıracaq. Sövdələşmə «Mübahisəli» statusuna keçəcək.',
            ),
          ),
          const SizedBox(height: 14),
          _SheetField(
            isDark: isDark,
            label: tr('deals.dispute.question', 'Nə baş verdi?'),
            controller: _reason,
            hint: tr('deals.dispute.detail_hint', 'Ətraflı izah edin…'),
            minLines: 4,
            maxLines: 6,
            autofocus: true,
            hasError: tooLong,
            bottomSpacing: 6,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [
              LengthLimitingTextInputFormatter(dealDisputeMaxLength),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: tooShort
                    ? Text(
                        tr(
                          'deals.dispute.min_length',
                          'Ən azı {count} simvol yazın',
                          {'count': '$dealDisputeMinLength'},
                        ),
                        style: TextStyle(
                            color: muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              Text(
                '$length/$dealDisputeMaxLength',
                style: TextStyle(
                    color: tooLong ? alert : muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SheetSubmitButton(
            label: tr('deals.dispute.submit', 'Problemi göndər'),
            icon: PhosphorIconsFill.flag,
            color: dealRed600,
            onPressed: _canSubmit ? _submit : null,
          ),
          _SheetBackButton(
            isDark: isDark,
            label: WawatContent.text(content, 'common.back', 'Geri'),
          ),
        ],
      ),
    );
  }
}

Future<bool> showDealActionConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  bool danger = false,
}) async {
  final message = tr('deals.confirm.sure', 'Əminsiniz?');
  var cancelLabel = tr('deals.confirm.cancel', 'Ləğv et');
  if (cancelLabel.trim().toLowerCase() == confirmLabel.trim().toLowerCase()) {
    cancelLabel = tr('common.back', 'Geri');
  }

  final platform = Theme.of(context).platform;
  final bool? confirmed;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final blue = TextStyle(
          color: CupertinoColors.activeBlue.resolveFrom(dialogContext),
        );
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              textStyle: blue,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: danger,
              isDefaultAction: !danger,
              textStyle: danger ? null : blue,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  } else {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = danger
        ? (isDark ? WawatDark.dangerText : dealRed600)
        : (isDark ? WawatDark.brandText : dealBrand);
    confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? WawatDark.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
              color: isDark ? WawatDark.textPrimary : dealInk900,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(
              color: isDark ? WawatDark.textSecondary : dealInk600,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
                foregroundColor: isDark ? WawatDark.textSecondary : dealInk600),
            child: Text(cancelLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
  return confirmed == true;
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
                    backgroundImage: counterpartAvatar != null
                        ? CachedNetworkImageProvider(counterpartAvatar)
                        : null,
                    child: counterpartAvatar == null
                        ? Icon(PhosphorIconsFill.user,
                            color: isDark ? WawatDark.textMuted : dealInk400,
                            size: 26)
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
                            value <= rating
                                ? PhosphorIconsFill.star
                                : PhosphorIconsRegular.star,
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
              hint: tr('deals.review.prompt', 'Təcrübəni bir neçə sözlə yaz…'),
              maxLines: 3,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final trait in traits)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (!selectedTraits.add(trait[0]))
                        selectedTraits.remove(trait[0]);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selectedTraits.contains(trait[0])
                            ? (isDark ? WawatDark.successBg : dealEmerald50)
                            : (isDark ? WawatDark.surfaceAlt : dealInk100),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tr('deals.review_tag.${trait[0]}', trait[1]),
                        style: TextStyle(
                          color: selectedTraits.contains(trait[0])
                              ? (isDark ? WawatDark.success : dealEmerald600)
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
            ListenableBuilder(
              listenable: commentController,
              builder: (context, _) {
                final requiresComment = rating <= 3;
                final hasComment = commentController.text.trim().isNotEmpty;
                final canSubmit = !requiresComment || hasComment;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (requiresComment && !hasComment) ...[
                      Row(
                        children: [
                          const Icon(PhosphorIconsFill.info,
                              size: 13, color: Color(0xFFF5B301)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              WawatContent.text(
                                  content,
                                  'deals.review.comment_required',
                                  'Aşağı qiymət üçün şərh vacibdir.'),
                              style: const TextStyle(
                                  color: Color(0xFFB67C00),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: canSubmit
                            ? () {
                                final traitSuffix = selectedTraits
                                    .map((code) => traits
                                        .firstWhere((t) => t[0] == code)[1])
                                    .join(', ');
                                final comment = [
                                  commentController.text.trim(),
                                  traitSuffix
                                ].where((e) => e.isNotEmpty).join(' · ');
                                Navigator.of(sheetContext).pop({
                                  'rating': rating,
                                  if (comment.isNotEmpty) 'comment': comment,
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dealBrand,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              dealBrand.withValues(alpha: 0.4),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(PhosphorIconsFill.paperPlaneTilt,
                            size: 17, color: Colors.white),
                        label: Text(
                          tr('deals.review.submit', 'Rəyi göndər'),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
              ? (isDark
                  ? WawatDark.brandSoft
                  : dealBrand50.withValues(alpha: 0.6))
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? dealBrand
                  : (isDark
                      ? WawatDark.border
                      : dealInk900.withValues(alpha: 0.08)),
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
                    color: selected
                        ? dealBrand
                        : (isDark ? WawatDark.iconMuted : dealInk300),
                    width: 2),
              ),
              child: selected
                  ? const Icon(PhosphorIconsBold.check,
                      size: 11, color: Colors.white)
                  : null,
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
