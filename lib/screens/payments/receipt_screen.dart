import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/network/response/receipt.dart';
import '../../main.dart';
import '../../presentation/common/async_button.dart';
import '../../presentation/resourses/theme_colors.dart';
import '../../presentation/resourses/wawat_dark.dart';
import '../../services/telemetry/telemetry.dart';
import '../../services/wawat_content.dart';
import 'receipt_pdf.dart';

/// One receipt screen for EVERY payment type (promotions/VIP, listing-quota,
/// future). Everything is printed straight from the backend's [Receipt] block
/// (already localized); only the header icon/label differ by [Receipt.kind].
/// The PDF is the backend's ([Receipt.pdfUrl]) — see receipt_pdf.dart.
class ReceiptScreen extends StatefulWidget {
  final Receipt receipt;
  final Map<String, String> content;

  /// Test seams; default to the app's authenticated Dio and the native store.
  final Dio? dio;
  final ReceiptPdfStore store;

  const ReceiptScreen({
    super.key,
    required this.receipt,
    this.content = const {},
    this.dio,
    this.store = const ReceiptPdfStore(),
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Receipt get _r => widget.receipt;
  Map<String, String> get _c => widget.content;

  String _t(String key, String fb) => WawatContent.text(_c, key, fb);

  /// Downloaded once per screen — a second tap re-saves/re-opens the same
  /// bytes instead of hitting the (rate-limited) endpoint again.
  ReceiptPdfFile? _pdf;

  /// Android opens the PDF in another app, so a snackbar shown right away
  /// expires unseen — it is shown when the user comes back instead.
  AppLifecycleListener? _onReturn;

  @override
  void dispose() {
    _onReturn?.dispose();
    super.dispose();
  }

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [_card(isDark, paid, statusColor)],
        ),
      ),
      // As the Scaffold's bottom bar (not inside the body) so the "saved" /
      // error snackbar rises above the buttons instead of covering them.
      bottomNavigationBar: _r.isPaid && _r.pdfUrl != null
          ? _bottomBar(isDark)
          : null,
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
                  child: const Text(
                    'W',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wawatair',
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                // Status pill.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(_r.status, paid),
                        color: statusColor,
                        size: 14,
                      ),
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
                    fontWeight: FontWeight.w800,
                  ),
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
                  child: Icon(
                    _kindIcon(_r.kind),
                    size: 18,
                    color: cBrandText(isDark),
                  ),
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
              _t(
                'receipt.footer',
                'Bu qəbz avtomatik yaradılıb · dəstək: {email}',
              ).replaceAll('{email}', _r.supportEmail),
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
        child: Row(
          children: [
            Expanded(
              child: AsyncActionButton(
                color: cBrandFill,
                height: 52,
                borderRadius: 16,
                onPressed: _downloadPdf,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      PhosphorIconsFill.filePdf,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _t('receipt.download_pdf', 'PDF yüklə'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Sharing stays available, but as a separate secondary action —
            // the main button really saves the file.
            SizedBox(
              width: 52,
              child: AsyncActionButton(
                color: cBrandSoft(isDark),
                height: 52,
                borderRadius: 16,
                onPressed: _sharePdf,
                child: Tooltip(
                  message: _t('receipt.share', 'Paylaş'),
                  child: Icon(
                    PhosphorIconsBold.shareNetwork,
                    color: cBrandText(isDark),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashed(bool isDark) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    child: CustomPaint(painter: _DashedLinePainter(cLine(isDark))),
  );

  Future<ReceiptPdfFile> _fetchPdf() async =>
      _pdf ??= await downloadReceiptPdf(widget.dio ?? sl.get<Dio>(), _r);

  /// «PDF yüklə»: download the server PDF, save it where the user can find it
  /// (Android → Downloads, iOS → Documents) and open it.
  Future<void> _downloadPdf() async {
    try {
      final saved = await widget.store.save(await _fetchPdf());
      final opened = await widget.store.open(
        saved,
        subject: _t('receipt.title', 'Qəbz'),
      );
      if (!mounted) return;
      if (!opened) {
        _snack(
          _t(
            'receipt.pdf_saved_no_viewer',
            'Qəbz saxlanıldı, amma telefonda PDF açan proqram tapılmadı.',
          ),
        );
      } else if (saved.location == ReceiptPdfLocation.downloads) {
        _snackOnReturn(
          _t(
            'receipt.pdf_saved_downloads',
            'Qəbz «Yükləmələr» qovluğunda saxlanıldı.',
          ),
        );
      }
    } catch (error, stack) {
      _reportPdfError(error, stack, 'download');
    }
  }

  Future<void> _sharePdf() async {
    try {
      await widget.store.share(
        await _fetchPdf(),
        subject: _t('receipt.title', 'Qəbz'),
      );
    } catch (error, stack) {
      _reportPdfError(error, stack, 'share');
    }
  }

  /// Every failure goes to Crashlytics with its real cause; the user gets a
  /// text that says WHICH side failed (connection / server / device).
  void _reportPdfError(Object error, StackTrace stack, String action) {
    final failure = error is ReceiptPdfException
        ? error.failure
        : (error is DioException
              ? ReceiptPdfFailure.network
              : ReceiptPdfFailure.save);
    Telemetry.instance.error(
      error,
      stack,
      reason: 'receipt_pdf_failed',
      context: {
        'action': action,
        'kind': _r.kind,
        'failure': failure.name,
        if (error is ReceiptPdfException && error.statusCode != null)
          'status': error.statusCode,
      },
    );
    if (!mounted) return;
    _snack(_pdfErrorText(error, failure));
  }

  String _pdfErrorText(Object error, ReceiptPdfFailure failure) {
    switch (failure) {
      case ReceiptPdfFailure.network:
        return _t(
          'receipt.pdf_error_network',
          'İnternet bağlantısı yoxdur. Bağlantını yoxlayıb yenidən cəhd edin.',
        );
      case ReceiptPdfFailure.server:
      case ReceiptPdfFailure.notPdf:
        final serverMessage = error is ReceiptPdfException
            ? error.serverMessage
            : null;
        return serverMessage ??
            _t(
              'receipt.pdf_error_server',
              'Server qəbzi göndərə bilmədi. Bir az sonra yenidən cəhd edin.',
            );
      case ReceiptPdfFailure.save:
        return _t(
          'receipt.pdf_error_save',
          'Qəbzi telefonda saxlamaq alınmadı.',
        );
    }
  }

  void _snackOnReturn(String text) {
    _onReturn?.dispose();
    _onReturn = AppLifecycleListener(
      onResume: () {
        _onReturn?.dispose();
        _onReturn = null;
        if (mounted) _snack(text);
      },
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
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
      'receipt.status.$key',
      fallbacks[key] ?? (paid ? 'Ödənildi' : '—'),
    );
  }
}

IconData _kindIcon(String kind) {
  switch (kind) {
    case 'promotion':
      return PhosphorIconsFill.rocketLaunch;
    case 'listing_quota':
      return PhosphorIconsFill.note;
    case 'verification':
      return PhosphorIconsFill.sealCheck;
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
