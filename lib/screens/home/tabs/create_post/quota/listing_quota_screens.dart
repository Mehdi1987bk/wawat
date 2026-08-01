import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/api/listing_quota_api.dart';
import '../../../../../data/network/response/listing_quota_response.dart';
import '../../../../../data/network/response/receipt.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/common/async_button.dart';
import '../../../../../presentation/common/app_bottom_sheet.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import '../../../../payments/receipt_screen.dart';
import '../create_post_screen.dart';

/// Paid "increase listing limit" flow (mock payment, like VIP promo):
/// plans → confirm sheet → create order → pay → success/failure → receipt(PDF).
/// Prices/labels come from the backend; static chrome from CMS `listing_quota.*`
/// (with AZ fallbacks passed inline so it renders before /content resolves).

/// Currency glyph — matches the app-wide convention (AZN rendered as `$`).
const _kCurrency = r'$';

String _money(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _price(double v) => '${_money(v)} $_kCurrency';

String _apiError(Object error, Map<String, String> content) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      final m = (data['message'] as String).trim();
      if (m.isNotEmpty) return m;
    }
  }
  return WawatContent.text(
      content, 'common.error', 'Xəta baş verdi. Yenidən cəhd edin.');
}

String _qt(Map<String, String> content, String key, String fallback) =>
    WawatContent.text(content, key, fallback);

/// Entry — open the paid limit-increase flow for a given listing [type]
/// ('trip' | 'shipment_post'). [currentLimit] is shown on the success screen.
Future<void> openListingQuotaFlow(
  BuildContext context, {
  required String type,
  required int currentLimit,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => QuotaPlansScreen(type: type, currentLimit: currentLimit),
    ),
  );
}

// ══════════════════════ 1/2 · Plan selection ══════════════════════

class QuotaPlansScreen extends StatefulWidget {
  final String type;
  final int currentLimit;

  const QuotaPlansScreen({
    super.key,
    required this.type,
    required this.currentLimit,
  });

  @override
  State<QuotaPlansScreen> createState() => _QuotaPlansScreenState();
}

class _QuotaPlansScreenState extends State<QuotaPlansScreen> {
  final ListingQuotaApi _api = ListingQuotaApi(sl.get<Dio>());
  late Future<QuotaPricingResponse> _future;
  Map<String, String> _content = const {};
  int? _selectedExtra;

  bool get _isTrip => widget.type == 'trip';

  @override
  void initState() {
    super.initState();
    _future = _api.getPricing();
    WawatContent.loadGroups(const ['listing_quota', 'common', 'limit'])
        .then((c) {
      if (mounted) setState(() => _content = c);
    });
  }

  QuotaPlan? _selectedPlan(List<QuotaPlan> plans) {
    for (final p in plans) {
      if (p.extraListings == _selectedExtra) return p;
    }
    return plans.isEmpty ? null : plans.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: cCard(isDark),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<QuotaPricingResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _loading(isDark);
            }
            final typePricing = snapshot.data?.data.forType(widget.type);
            final plans = typePricing?.plans ?? const <QuotaPlan>[];
            if (snapshot.hasError || plans.isEmpty) {
              return _error(isDark);
            }
            // Default selection: the "best value" plan, else the +3 pack, else first.
            _selectedExtra ??= plans
                .firstWhere(
                  (p) => p.isBestValue,
                  orElse: () => plans.firstWhere(
                    (p) => p.extraListings == 3,
                    orElse: () => plans.first,
                  ),
                )
                .extraListings;
            final selected = _selectedPlan(plans);
            final typeLabel =
                typePricing?.label ?? (_isTrip ? 'səfər' : 'göndəriş');

            return Column(
              children: [
                _QuotaAppBar(
                  title: _qt(_content, 'listing_quota.title', 'Limiti artır'),
                  onClose: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark
                                ? WawatDark.warningBg
                                : const Color(0xFFFEF6E7),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            _isTrip
                                ? PhosphorIconsFill.stack
                                : PhosphorIconsFill.package,
                            color: isDark
                                ? WawatDark.warning
                                : const Color(0xFFE8A400),
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _qt(
                          _content,
                          'listing_quota.limit_full_title.${widget.type}',
                          'Aktiv $typeLabel limitin dolub',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cText(isDark),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _qt(
                          _content,
                          'listing_quota.limit_full_subtitle',
                          'Limiti artır və dərhal yenisini yarat.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cText2(isDark), fontSize: 13),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Icon(PhosphorIconsFill.rocketLaunch,
                              color: cBrandText(isDark), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _qt(_content, 'listing_quota.plans_header',
                                    'Limiti artır')
                                .toUpperCase(),
                            style: TextStyle(
                              color: cText2(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final plan in plans) ...[
                        _PlanCard(
                          plan: plan,
                          selected: plan.extraListings == _selectedExtra,
                          content: _content,
                          onTap: () => setState(
                              () => _selectedExtra = plan.extraListings),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _qt(
                          _content,
                          'listing_quota.secure_note',
                          'Ödəniş təhlükəsiz provayder səhifəsində aparılır',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cMuted(isDark), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _StickyBottom(
                  isDark: isDark,
                  children: [
                    // Opens the confirm sheet (instant) — no loader here; the
                    // sheet owns the create-order spinner.
                    _FilledButton(
                      color: cBrandFill,
                      onTap: selected == null ? null : () => _confirm(selected),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(PhosphorIconsFill.lightning,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 7),
                          Text(
                            selected == null
                                ? _qt(_content, 'listing_quota.pay_cta_empty',
                                    'Plan seç')
                                : '${_price(selected.price)} ${_qt(_content, 'listing_quota.pay_cta', 'ödə və limiti artır')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIconsBold.pause,
                                color: cText2(isDark), size: 17),
                            const SizedBox(width: 7),
                            Text(
                              _qt(_content, 'listing_quota.pause_instead',
                                  'və ya bir elanı dayandır'),
                              style: TextStyle(
                                color: cText2(isDark),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loading(bool isDark) => Column(
        children: [
          _QuotaAppBar(
            title: _qt(_content, 'listing_quota.title', 'Limiti artır'),
            onClose: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(color: cBrandText(isDark)),
            ),
          ),
        ],
      );

  Widget _error(bool isDark) => Column(
        children: [
          _QuotaAppBar(
            title: _qt(_content, 'listing_quota.title', 'Limiti artır'),
            onClose: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsFill.warningCircle,
                        color:
                            isDark ? WawatDark.danger : const Color(0xFFEF4444),
                        size: 34),
                    const SizedBox(height: 12),
                    Text(
                      _qt(_content, 'listing_quota.load_error',
                          'Planlar yüklənmədi. Yenidən cəhd et.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: cText2(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    AsyncActionButton(
                      color: cBrandFill,
                      width: 200,
                      height: 46,
                      onPressed: () async =>
                          setState(() => _future = _api.getPricing()),
                      child: Text(
                        _qt(_content, 'common.retry', 'Yenidən'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  // ── 3 · Confirm sheet → creates the order, returns it, then we open Processing ──
  Future<void> _confirm(QuotaPlan plan) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The sheet is non-dismissible while the order is being created, so a stray
    // barrier tap / swipe / back can't orphan an in-flight order.
    final order = await showAppBottomSheet<QuotaOrder>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor:
          isDark ? WawatDark.scrim : Colors.black.withValues(alpha: 0.45),
      builder: (_) => _ConfirmSheet(
        api: _api,
        plan: plan,
        type: widget.type,
        content: _content,
      ),
    );
    if (!mounted || order == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotaProcessingScreen(
          api: _api,
          order: order,
          type: widget.type,
          currentLimit: widget.currentLimit,
          content: _content,
        ),
      ),
    );
  }
}

// ══════════════════════ 4/6 · Processing (+ inline failure) ══════════════════════

class QuotaProcessingScreen extends StatefulWidget {
  final ListingQuotaApi api;
  final QuotaOrder order;
  final String type;
  final int currentLimit;
  final Map<String, String> content;

  const QuotaProcessingScreen({
    super.key,
    required this.api,
    required this.order,
    required this.type,
    required this.currentLimit,
    required this.content,
  });

  @override
  State<QuotaProcessingScreen> createState() => _QuotaProcessingScreenState();
}

class _QuotaProcessingScreenState extends State<QuotaProcessingScreen> {
  // Stable across retries so re-tapping never double-charges.
  late final String _idempotencyKey =
      'quota-pay-${widget.order.id}-${DateTime.now().microsecondsSinceEpoch}';
  bool _paying = true;
  String? _error;
  late QuotaOrder _order = widget.order;

  Map<String, String> get _content => widget.content;

  @override
  void initState() {
    super.initState();
    _submitPayment();
  }

  Future<void> _submitPayment() async {
    setState(() {
      _paying = true;
      _error = null;
    });
    try {
      final res = await widget.api.payOrder(
        _order.id,
        method: 'card',
        // Mock: simulate a successful provider callback.
        mockOutcome: 'success',
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      final o = res.data;
      if (o.isPaid) {
        await _goToSuccess(o, res.receipt);
      } else {
        setState(() {
          _order = o;
          _paying = false;
          _error = o.isPending ? null : (res.message ?? _failedText());
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = _apiError(e, _content);
      });
    }
  }

  /// Refetch /me (so create-post sees the grown limit) and read the fresh
  /// server-authoritative per-type limit, then show the success screen.
  Future<void> _goToSuccess(QuotaOrder o, Receipt? receipt) async {
    int? serverLimit;
    try {
      final repo = sl.get<AuthRepository>();
      await repo.customersMe();
      final me = await repo.userDetails.first;
      serverLimit = me.listingQuota?.forType(widget.type)?.limit;
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuotaSuccessScreen(
          order: o,
          type: widget.type,
          currentLimit: widget.currentLimit,
          serverLimit: serverLimit,
          receipt: receipt,
          content: _content,
        ),
      ),
    );
  }

  String _failedText() => _qt(_content, 'listing_quota.payment_failed_sub',
      'Məbləğ tutulmadı və limit dəyişmədi. Yenidən cəhd et.');

  Future<void> _refreshStatus() async {
    setState(() => _paying = true);
    try {
      final res = await widget.api.getOrder(_order.id);
      if (!mounted) return;
      final o = res.data;
      if (o.isPaid) {
        await _goToSuccess(o, res.receipt);
      } else {
        setState(() {
          _order = o;
          _paying = false;
          _error = o.isPending ? null : _failedText();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = _apiError(e, _content);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final failed = _error != null;
    // Block system back / iOS edge-swipe while the payment is in flight.
    return PopScope(
      canPop: !_paying,
      child: Scaffold(
        backgroundColor: cCard(isDark),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _QuotaAppBar(
                title: _qt(_content, 'listing_quota.title', 'Limiti artır'),
                onClose:
                    _paying ? null : () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_paying) ...[
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: cBrandText(isDark),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            _qt(_content, 'listing_quota.payment_pending',
                                'Ödəniş gözlənilir…'),
                            style: TextStyle(
                              color: cText(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _qt(
                              _content,
                              'listing_quota.payment_pending_sub',
                              'Ödəniş səhifəsində əməliyyatı tamamla. Bitən kimi nəticəni avtomatik göstərəcəyik.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: cText2(isDark),
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ] else if (failed) ...[
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? WawatDark.danger.withValues(alpha: 0.16)
                                  : const Color(0xFFFEECEC),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(PhosphorIconsFill.xCircle,
                                color: isDark
                                    ? WawatDark.danger
                                    : const Color(0xFFEF4444),
                                size: 44),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _qt(_content, 'listing_quota.payment_failed',
                                'Ödəniş keçmədi'),
                            style: TextStyle(
                              color: cText(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: cText2(isDark),
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ] else ...[
                          // pending (provider still processing)
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: cBrandText(isDark),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            _qt(_content, 'listing_quota.payment_pending',
                                'Ödəniş gözlənilir…'),
                            style: TextStyle(
                              color: cText(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!_paying)
                _StickyBottom(
                  isDark: isDark,
                  children: failed
                      ? [
                          AsyncActionButton(
                            color: cBrandFill,
                            height: 52,
                            borderRadius: 16,
                            // Re-attempt the SAME order with the SAME stable
                            // idempotency key — never mints a new order, so the
                            // server dedups (recovers a timed-out but-committed pay).
                            onPressed: _submitPayment,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(PhosphorIconsBold.arrowClockwise,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 7),
                                Text(
                                  _qt(_content, 'listing_quota.retry',
                                      'Yenidən cəhd et'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _GhostButton(
                            label: _qt(_content, 'common.close', 'Bağla'),
                            isDark: isDark,
                            onTap: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                          ),
                        ]
                      : [
                          AsyncActionButton(
                            color: cBrandSoft(isDark),
                            loaderColor: cBrandText(isDark),
                            height: 52,
                            borderRadius: 16,
                            onPressed: _refreshStatus,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsBold.arrowsClockwise,
                                    color: cBrandText(isDark), size: 18),
                                const SizedBox(width: 7),
                                Text(
                                  _qt(_content, 'listing_quota.refresh_status',
                                      'Statusu yenilə'),
                                  style: TextStyle(
                                      color: cBrandText(isDark),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _GhostButton(
                            label: _qt(_content, 'listing_quota.cancel_payment',
                                'Ödənişi ləğv et'),
                            isDark: isDark,
                            onTap: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                          ),
                        ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════ 5 · Success ══════════════════════

class QuotaSuccessScreen extends StatelessWidget {
  final QuotaOrder order;
  final String type;
  final int currentLimit;

  /// Fresh per-type limit from /me (server-authoritative); null → fall back to
  /// the arithmetic (currentLimit + extra), which the backend guarantees equals it.
  final int? serverLimit;

  /// Unified payment receipt — the "Qəbz" button shows only when it's paid.
  final Receipt? receipt;
  final Map<String, String> content;

  const QuotaSuccessScreen({
    super.key,
    required this.order,
    required this.type,
    required this.currentLimit,
    this.serverLimit,
    this.receipt,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final newLimit = serverLimit ?? (currentLimit + order.extraListings);
    return Scaffold(
      backgroundColor: cBrandFill,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.checkCircle,
                    color: Colors.white, size: 60),
              ),
              const SizedBox(height: 22),
              Text(
                _qt(content, 'listing_quota.success_title', 'Limitin artdı!'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  _qt(content, 'listing_quota.success_sub_prefix', 'İndi daha'),
                  '${order.extraListings}',
                  order.typeLabel,
                  _qt(content, 'listing_quota.success_sub_suffix',
                      'aktiv elan yarada bilərsən.'),
                ].where((s) => s.trim().isNotEmpty).join(' '),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _qt(content, 'listing_quota.new_limit', 'Yeni limit'),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$currentLimit → $newLimit',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Exit the whole purchase flow (success → plans → gate),
                        // then open create-post fresh with the grown limit —
                        // so backing out of the form doesn't land on the plans.
                        final navigator = Navigator.of(context);
                        navigator.popUntil((r) => r.isFirst);
                        navigator.push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => CreatePostScreen(initialType: type),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIconsBold.plus,
                                color: cBrandFill, size: 18),
                            const SizedBox(width: 7),
                            Text(
                              _qt(content, 'listing_quota.create_listing',
                                  'Elan yarat'),
                              style: TextStyle(
                                color: cBrandFill,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (receipt?.isPaid ?? false) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReceiptScreen(
                                receipt: receipt!, content: content),
                          ),
                        ),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIconsBold.receipt,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 17),
                              const SizedBox(width: 7),
                              Text(
                                _qt(content, 'listing_quota.view_receipt',
                                    'Qəbzə bax'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════ Shared little widgets ══════════════════════

class _QuotaAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const _QuotaAppBar({
    required this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cCard(isDark),
        border: Border(bottom: BorderSide(color: cLine(isDark))),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(PhosphorIconsBold.x,
                  color: onClose == null ? cMuted(isDark) : cText(isDark),
                  size: 22),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _StickyBottom extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _StickyBottom({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cCard(isDark),
        border: Border(top: BorderSide(color: cLine(isDark))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Plain filled CTA — for actions that are instant (e.g. opening a sheet), where
/// an [AsyncActionButton] loader would be wrong. Null [onTap] renders disabled.
class _FilledButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  final Widget child;

  const _FilledButton({
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _GhostButton(
      {required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: cText2(isDark),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final QuotaPlan plan;
  final bool selected;
  final Map<String, String> content;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final perLabel = plan.perListing == null
        ? _qt(content, 'listing_quota.one_time', 'bir dəfəlik · daimi limit')
        : '${_qt(content, 'listing_quota.per_listing_prefix', 'elan başına')} ${_price(plan.perListing!)}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? cBrandSoft(isDark) : cCard(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? cBrandFill
                    : (isDark ? WawatDark.border : const Color(0x140F172A)),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? cBrandFill : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? cBrandFill
                          : (isDark
                              ? WawatDark.border
                              : const Color(0xFFCBD5E1)),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(PhosphorIconsBold.check,
                          color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.packageLabel,
                        style: TextStyle(
                          color: cText(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        perLabel,
                        style: TextStyle(
                          color: plan.isBestValue
                              ? cBrandText(isDark)
                              : cMuted(isDark),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _price(plan.price),
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (plan.isBestValue)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.success : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _qt(content, 'listing_quota.badge.best_value', 'Ən sərfəli'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfirmSheet extends StatefulWidget {
  final ListingQuotaApi api;
  final QuotaPlan plan;
  final String type;
  final Map<String, String> content;

  const _ConfirmSheet({
    required this.api,
    required this.plan,
    required this.type,
    required this.content,
  });

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _creating = false;
  String? _error;

  QuotaPlan get plan => widget.plan;
  Map<String, String> get content => widget.content;

  Future<void> _pay() async {
    final navigator = Navigator.of(context);
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final idem =
          'quota-order-${widget.type}-${DateTime.now().microsecondsSinceEpoch}';
      final res = await widget.api.createOrder(
        type: widget.type,
        extraListings: plan.extraListings,
        idempotencyKey: idem,
      );
      if (!mounted) return;
      navigator.pop(res.data); // close sheet, hand the order to the caller
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = _apiError(e, content);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Block system-back while the order is being created.
    return PopScope(
      canPop: !_creating,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: cCard(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.grab : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                _qt(content, 'listing_quota.confirm_title', 'Ödənişi təsdiqlə'),
                style: TextStyle(
                  color: cText(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cFill(isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _KV(
                      label: _qt(
                          content, 'listing_quota.receipt.package', 'Paket'),
                      value: plan.packageLabel,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _KV(
                      label: _qt(content, 'listing_quota.receipt.type', 'Növ'),
                      value: _qt(content, 'listing_quota.permanent_increase',
                          'Daimi limit artımı'),
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: cLine(isDark)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _qt(content, 'listing_quota.total', 'Ümumi'),
                          style: TextStyle(
                              color: cText(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _price(plan.price),
                          style: TextStyle(
                              color: cBrandText(isDark),
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color:
                          isDark ? WawatDark.border : const Color(0x0F0F172A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(PhosphorIconsFill.shieldCheck,
                        color: cBrandText(isDark), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _qt(
                          content,
                          'listing_quota.secure_redirect',
                          'Növbəti addımda təhlükəsiz ödəniş səhifəsinə yönləndiriləcəksən. Ödənişi orada tamamla — nəticəni avtomatik alacağıq.',
                        ),
                        style: TextStyle(
                            color: cText2(isDark),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? WawatDark.danger : const Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              AsyncActionButton(
                color: cBrandFill,
                height: 52,
                borderRadius: 16,
                onPressed: _pay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.arrowRight,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 7),
                    Text(
                      '${_price(plan.price)} — ${_qt(content, 'listing_quota.go_to_payment', 'ödənişə keç')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _GhostButton(
                label: _qt(content, 'common.cancel', 'İmtina et'),
                isDark: isDark,
                onTap:
                    _creating ? () {} : () => Navigator.of(context).maybePop(),
              ),
              Center(
                child: Text(
                  _qt(content, 'listing_quota.test_mode',
                      'Test rejimi — real məbləğ tutulmur (mock)'),
                  style: TextStyle(color: cMuted(isDark), fontSize: 10.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _KV({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: cText2(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
                color: cText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
