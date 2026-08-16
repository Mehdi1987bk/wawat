import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/network/response/receipt.dart';
import '../../presentation/common/async_button.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../../presentation/resourses/wawat_dark.dart';
import '../../services/wawat_content.dart';

/// One receipt screen for EVERY payment type (promotions/VIP, listing-quota,
/// future). Everything is printed straight from the backend's [Receipt] block
/// (already localized); only the header icon/label differ by [Receipt.kind].
class ReceiptScreen extends StatefulWidget {
  final Receipt receipt;
  final Map<String, String> content;

  const ReceiptScreen({
    super.key,
    required this.receipt,
    this.content = const {},
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Receipt get _r => widget.receipt;
  Map<String, String> get _c => widget.content;

  String _t(String key, String fb) => WawatContent.text(_c, key, fb);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paid = _r.isPaid;
    final statusColor = _statusFg(_r.status, paid, isDark);

    return Scaffold(
      backgroundColor: cScreen(isDark),
      appBar: AppBar(
        backgroundColor: cBar(isDark),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: cBar(isDark),
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: cText3(isDark)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _t('receipt.title', 'Qəbz'),
          style: TextStyle(
            color: cText(isDark),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_card(isDark, paid, statusColor)],
              ),
            ),
            if (_r.isPaid) _bottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _card(bool isDark, bool paid, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: cCard(isDark),
        borderRadius: BorderRadius.circular(24),
        border: cCardBorder(isDark),
        boxShadow: cCardShadow(isDark, [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                // Brand mark.
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cBrandFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('W',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                Text('Wawatair',
                    style: TextStyle(
                        color: cText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                // Status pill.
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(_r.status, paid),
                          color: statusColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel(_r.status, paid),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _money(_r.amount, _r.currency),
                  style: TextStyle(
                      color: cText(isDark),
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          _dashed(isDark),
          // Service line (title) + receipt number — the only kind-specific bit
          // is the leading icon.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cBrandSoft(isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_kindIcon(_r.kind),
                      size: 18, color: cBrandText(isDark)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _r.title,
                        style: TextStyle(
                          color: cText(isDark),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_r.number.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _r.number,
                          style: TextStyle(
                            color: cMuted(isDark),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _dashed(isDark),
          // Line items — printed verbatim (backend-localized).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              children: [
                for (final item in _r.items)
                  _ReceiptRow(
                    label: item.label,
                    value: item.value,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
          _dashed(isDark),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              _t('receipt.footer',
                      'Bu qəbz avtomatik yaradılıb · dəstək: {email}')
                  .replaceAll('{email}', _r.supportEmail),
              textAlign: TextAlign.center,
              style: TextStyle(color: cMuted(isDark), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: cBar(isDark),
        border: Border(top: BorderSide(color: cLine(isDark))),
      ),
      child: SafeArea(
        top: false,
        child: AsyncActionButton(
          color: cBrandFill,
          height: 52,
          borderRadius: 16,
          onPressed: _downloadPdf,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(PhosphorIconsFill.filePdf,
                  color: Colors.white, size: 18),
              const SizedBox(width: 7),
              Text(
                _t('receipt.download_pdf', 'PDF yüklə'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashed(bool isDark) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomPaint(painter: _DashedLinePainter(cLine(isDark))),
      );

  Future<void> _downloadPdf() async {
    try {
      final bytes = await _buildReceiptPdf(_r, _c);
      final dir = await getTemporaryDirectory();
      final safeNumber = _r.number.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${dir.path}/wawatair_receipt_$safeNumber.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: _t('receipt.title', 'Qəbz'),
        text: _t('receipt.share_text', 'Wawatair · {title} · {amount}')
            .replaceAll('{title}', _r.title)
            .replaceAll('{amount}', _money(_r.amount, _r.currency)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_t('receipt.pdf_error', 'PDF yaradıla bilmədi.')),
        ));
    }
  }

  // ── status/kind helpers ──

  Color _statusFg(String status, bool paid, bool isDark) {
    if (paid || status == 'paid') {
      return isDark ? WawatDark.success : const Color(0xFF059669);
    }
    switch (status) {
      case 'awaiting_provider':
        return isDark ? WawatDark.warning : const Color(0xFFB45309);
      case 'refunded':
        return isDark ? WawatDark.textSecondary : const Color(0xFF64748B);
      default: // failed | none
        return isDark ? WawatDark.danger : const Color(0xFFEF4444);
    }
  }

  IconData _statusIcon(String status, bool paid) {
    if (paid || status == 'paid') return PhosphorIconsFill.checkCircle;
    switch (status) {
      case 'awaiting_provider':
        return PhosphorIconsFill.hourglass;
      case 'refunded':
        return PhosphorIconsFill.arrowUUpLeft;
      default:
        return PhosphorIconsFill.xCircle;
    }
  }

  String _statusLabel(String status, bool paid) {
    // Honor `paid` like _statusFg/_statusIcon do (fromJson coerces an
    // empty status to 'none', so a paid receipt must still read "Ödənildi").
    final key = (paid || status == 'paid') ? 'paid' : status;
    const fallbacks = {
      'paid': 'Ödənildi',
      'awaiting_provider': 'Gözləyir',
      'failed': 'Uğursuz',
      'refunded': 'Geri qaytarıldı',
      'none': '—',
    };
    return _t(
        'receipt.status.$key', fallbacks[key] ?? (paid ? 'Ödənildi' : '—'));
  }
}

IconData _kindIcon(String kind) {
  switch (kind) {
    case 'promotion':
      return PhosphorIconsFill.rocketLaunch;
    case 'listing_quota':
      return PhosphorIconsFill.note;
    default:
      return PhosphorIconsFill.receipt;
  }
}

/// "6.99 AZN" — integer amounts drop the decimals.
String _money(double amount, String currency) {
  final n = amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  return currency.isEmpty ? n : '$n $currency';
}

// ══════════════════════ PDF (client-side) ══════════════════════

/// Builds the receipt PDF from the [Receipt] fields. Loads NotoSans so
/// Azerbaijani/Turkish glyphs render instead of tofu boxes.
Future<List<int>> _buildReceiptPdf(
    Receipt r, Map<String, String> content) async {
  final doc = pw.Document();
  pw.Font? base;
  pw.Font? bold;
  try {
    base =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    bold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
  } catch (_) {
    // Fall back to the built-in font if the asset can't be loaded.
  }
  final theme = (base != null)
      ? pw.ThemeData.withFont(base: base, bold: bold ?? base)
      : null;

  String t(String key, String fb) => WawatContent.text(content, key, fb);
  const blue = PdfColor.fromInt(0xFF017BFE);
  const ink = PdfColor.fromInt(0xFF0F172A);
  const muted = PdfColor.fromInt(0xFF64748B);

  pw.Widget row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(label,
                  style: const pw.TextStyle(fontSize: 11, color: muted)),
            ),
            pw.SizedBox(width: 12),
            // Flexible so a long value (reference/token/note) wraps inside the
            // card instead of overflowing off the page — mirrors the on-screen
            // _ReceiptRow.
            pw.Flexible(
              child: pw.Text(value,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: ink)),
            ),
          ],
        ),
      );

  final paid = r.isPaid;
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (ctx) => pw.Center(
        child: pw.Container(
          width: 360,
          padding: const pw.EdgeInsets.all(22),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Column(children: [
                  pw.Container(
                    width: 40,
                    height: 40,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: blue,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text('W',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Wawatair',
                      style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          color: ink)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    paid ? t('receipt.status.paid', 'Ödənildi') : r.status,
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: paid
                            ? const PdfColor.fromInt(0xFF059669)
                            : const PdfColor.fromInt(0xFFEF4444)),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(_money(r.amount, r.currency),
                      style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: ink)),
                ]),
              ),
              pw.SizedBox(height: 14),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(r.title,
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: ink)),
                  ),
                  if (r.number.isNotEmpty)
                    pw.Text(r.number,
                        style: const pw.TextStyle(fontSize: 10, color: muted)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: const PdfColor.fromInt(0xFFE2E8F0)),
              pw.SizedBox(height: 4),
              for (final item in r.items) row(item.label, item.value),
              pw.SizedBox(height: 6),
              pw.Divider(color: const PdfColor.fromInt(0xFFE2E8F0)),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  r.supportEmail,
                  style: const pw.TextStyle(fontSize: 9, color: muted),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return doc.save();
}

// ══════════════════════ small widgets ══════════════════════

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cText2(isDark),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
