import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/api/listing_quota_api.dart';
import '../../../../../data/network/response/listing_quota_response.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/receipt.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/common/async_button.dart';
import '../../../../../presentation/common/app_bottom_sheet.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/telemetry/telemetry.dart';
import '../../../../../services/telemetry/telemetry_events.dart';
import '../../../../../services/wawat_content.dart';
import '../../../../payments/card_checkout_screen.dart';
import '../../../../payments/iap/iap_catalog.dart';
import '../../../../payments/iap/iap_service.dart';
import '../../../../payments/receipt_screen.dart';
import '../create_post_screen.dart';

const _kCurrency = r'$';

String _money(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _price(double v) => '${_money(v)} $_kCurrency';

enum _QuotaPayMethod { store, card }

class _QuotaCheckout {
  final _QuotaPayMethod method;
  final QuotaOrder order;
  final bool storePaid;
  final int? serverLimit;
  final Receipt? receipt;

  const _QuotaCheckout.card(this.order)
    : method = _QuotaPayMethod.card,
      storePaid = false,
      serverLimit = null,
      receipt = null;

  const _QuotaCheckout.storePaid(this.order, {this.serverLimit, this.receipt})
    : method = _QuotaPayMethod.store,
      storePaid = true;
}

Future<int?> _refreshQuotaLimit(String type) async {
  try {
    final me = await sl.get<AuthRepository>().customersMe();
    return me.listingQuota?.forType(type)?.limit;
  } catch (e, st) {
    Telemetry.instance.error(e, st, reason: 'quota_me_refetch_failed');
    return null;
  }
}

String _quotaFailedText() => tr(
  'listing_quota.payment_failed_sub',
  'Məbləğ tutulmadı və limit dəyişmədi. Yenidən cəhd et.',
);

String _quotaIapErrorText(String? raw, [String? code]) {
  final text = (raw ?? '').trim();
  if (code != null && code.trim().isNotEmpty && text.isNotEmpty) {
    return text;
  }
  final msg = text.toLowerCase();
  if (msg.contains('previous transaction still pending') ||
      msg.contains('duplicate') ||
      msg.contains('pending transaction')) {
    return tr(
      'listing_quota.iap.pending',
      'Əvvəlki ödəniş hələ tamamlanır. Bir azdan yenidən cəhd et.',
    );
  }
  return _quotaFailedText();
}

String _apiError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      final m = (data['message'] as String).trim();
      if (m.isNotEmpty) return m;
    }
  }
  return tr('common.error', 'Xəta baş verdi. Yenidən cəhd edin.');
}

String _qt(Map<String, String> content, String key, String fallback) =>
    WawatContent.text(content, key, fallback);

class _QuotaBundle {
  final List<QuotaPlan> plans;
  final String typeLabel;
  final Map<int, ProductDetails> storeByExtra;
  final Map<int, IapCatalogProduct> catalogByExtra;

  const _QuotaBundle({
    required this.plans,
    required this.typeLabel,
    this.storeByExtra = const {},
    this.catalogByExtra = const {},
  });

  ProductDetails? storeFor(QuotaPlan plan) => storeByExtra[plan.extraListings];
  IapCatalogProduct? catalogFor(QuotaPlan plan) =>
      catalogByExtra[plan.extraListings];

  String priceFor(QuotaPlan plan) {
    final store = storeFor(plan);
    if (store != null && store.price.isNotEmpty) return store.price;
    return _price(plan.price);
  }
}

Future<void> openListingQuotaFlow(
  BuildContext context, {
  required String type,
  required int currentLimit,
  Listing? repostListing,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => QuotaPlansScreen(
        type: type,
        currentLimit: currentLimit,
        repostListing: repostListing,
      ),
    ),
  );
}

class QuotaPlansScreen extends StatefulWidget {
  final String type;
  final int currentLimit;
  final Listing? repostListing;

  const QuotaPlansScreen({
    super.key,
    required this.type,
    required this.currentLimit,
    this.repostListing,
  });

  @override
  State<QuotaPlansScreen> createState() => _QuotaPlansScreenState();
}

class _QuotaPlansScreenState extends State<QuotaPlansScreen> {
  final ListingQuotaApi _api = ListingQuotaApi(sl.get<Dio>());
  late Future<_QuotaBundle> _future;
  Map<String, String> _content = const {};
  int? _selectedExtra;

  bool get _isTrip => widget.type == 'trip';

  @override
  void initState() {
    super.initState();
    _future = _loadBundle();
    WawatContent.loadGroups(const ['listing_quota', 'common', 'limit']).then((
      c,
    ) {
      if (mounted) setState(() => _content = c);
    });
  }

  Future<_QuotaBundle> _loadBundle() async {
    final results = await Future.wait<dynamic>([
      _api.getPricing(),
      kIapEnabled
          ? IapService.instance
                .loadProducts(
                  forceCatalog: true,
                  kinds: const {IapProductKind.quota},
                )
                .catchError((_) => const <ProductDetails>[])
          : Future<List<ProductDetails>>.value(const []),
    ]);
    final pricing = results[0] as QuotaPricingResponse;
    final storeProducts = results[1] as List<ProductDetails>;

    final typePricing = pricing.data.forType(widget.type);
    final plans = typePricing?.plans ?? const <QuotaPlan>[];
    final typeLabel =
        typePricing?.label ??
        (_isTrip
            ? tr('listing_quota.type_trip', 'səfər')
            : tr('listing_quota.type_shipment', 'göndəriş'));

    final storeById = <String, ProductDetails>{
      for (final product in storeProducts) product.id: product,
    };
    final catalogByExtra = <int, IapCatalogProduct>{};
    final storeByExtra = <int, ProductDetails>{};
    for (final item in IapService.instance.catalogProducts.value) {
      if (item.kind != IapProductKind.quota) continue;
      final extra = item.extraListings;
      if (extra == null) continue;
      if (item.listingType != null && item.listingType != widget.type) {
        continue;
      }
      catalogByExtra[extra] = item;
      final store = storeById[item.productId];
      if (store != null) storeByExtra[extra] = store;
    }

    return _QuotaBundle(
      plans: plans,
      typeLabel: typeLabel,
      storeByExtra: storeByExtra,
      catalogByExtra: catalogByExtra,
    );
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
        child: FutureBuilder<_QuotaBundle>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _loading(isDark);
            }
            final bundle = snapshot.data;
            final plans = bundle?.plans ?? const <QuotaPlan>[];
            if (snapshot.hasError || bundle == null || plans.isEmpty) {
              return _error(isDark);
            }
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
            final typeLabel = bundle.typeLabel;

            return Column(
              children: [
                _QuotaAppBar(
                  title: tr('listing_quota.title', 'Limiti artır'),
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
                        tr(
                          'listing_quota.limit_full_title.${widget.type}',
                          'Aktiv {type} limitin dolub',
                          {'type': typeLabel},
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
                          Icon(
                            PhosphorIconsFill.rocketLaunch,
                            color: cBrandText(isDark),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr(
                              'listing_quota.plans_header',
                              'Limiti artır',
                            ).toUpperCase(),
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
                          priceText: bundle.priceFor(plan),
                          selected: plan.extraListings == _selectedExtra,
                          content: _content,
                          onTap: () => setState(
                            () => _selectedExtra = plan.extraListings,
                          ),
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
                    _FilledButton(
                      color: cBrandFill,
                      onTap: selected == null
                          ? null
                          : () => _confirm(bundle, selected),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            PhosphorIconsFill.lightning,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            selected == null
                                ? tr('listing_quota.pay_cta_empty', 'Plan seç')
                                : '${bundle.priceFor(selected)} ${tr('listing_quota.pay_cta', 'ödə və limiti artır')}',
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
                            Icon(
                              PhosphorIconsBold.pause,
                              color: cText2(isDark),
                              size: 17,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              tr(
                                'listing_quota.pause_instead',
                                'və ya bir elanı dayandır',
                              ),
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
        title: tr('listing_quota.title', 'Limiti artır'),
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
        title: tr('listing_quota.title', 'Limiti artır'),
        onClose: () => Navigator.of(context).maybePop(),
      ),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsFill.warningCircle,
                  color: isDark ? WawatDark.danger : const Color(0xFFEF4444),
                  size: 34,
                ),
                const SizedBox(height: 12),
                Text(
                  tr(
                    'listing_quota.load_error',
                    'Planlar yüklənmədi. Yenidən cəhd et.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cText2(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                AsyncActionButton(
                  color: cBrandFill,
                  width: 200,
                  height: 46,
                  onPressed: () async =>
                      setState(() => _future = _loadBundle()),
                  child: Text(
                    tr('common.retry', 'Yenidən'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Future<void> _confirm(_QuotaBundle bundle, QuotaPlan plan) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeProduct = bundle.storeFor(plan);
    final catalogProduct = bundle.catalogFor(plan);
    final storeAvailable =
        kIapEnabled &&
        storeProduct != null &&
        catalogProduct != null &&
        (Platform.isIOS || Platform.isAndroid);
    final checkout = await showAppBottomSheet<_QuotaCheckout>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: isDark
          ? WawatDark.scrim
          : Colors.black.withValues(alpha: 0.45),
      builder: (_) => _ConfirmSheet(
        api: _api,
        plan: plan,
        priceText: bundle.priceFor(plan),
        type: widget.type,
        content: _content,
        storeAvailable: storeAvailable,
        storeProduct: storeProduct,
        catalogProduct: catalogProduct,
      ),
    );
    if (!mounted || checkout == null) return;
    if (checkout.storePaid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuotaSuccessScreen(
            order: checkout.order,
            type: widget.type,
            currentLimit: widget.currentLimit,
            repostListing: widget.repostListing,
            serverLimit: checkout.serverLimit,
            receipt: checkout.receipt,
            content: _content,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QuotaProcessingScreen(
          api: _api,
          order: checkout.order,
          method: checkout.method,
          type: widget.type,
          currentLimit: widget.currentLimit,
          repostListing: widget.repostListing,
          content: _content,
        ),
      ),
    );
  }
}

class _QuotaProcessingScreen extends StatefulWidget {
  final ListingQuotaApi api;
  final QuotaOrder order;
  final _QuotaPayMethod method;
  final String type;
  final int currentLimit;
  final Listing? repostListing;
  final Map<String, String> content;

  const _QuotaProcessingScreen({
    required this.api,
    required this.order,
    required this.method,
    required this.type,
    required this.currentLimit,
    this.repostListing,
    required this.content,
  });

  @override
  State<_QuotaProcessingScreen> createState() => _QuotaProcessingScreenState();
}

class _QuotaProcessingScreenState extends State<_QuotaProcessingScreen> {
  late final String _idempotencyKey =
      'quota-pay-${widget.order.id}-${DateTime.now().microsecondsSinceEpoch}';
  bool _paying = true;
  String? _error;
  late QuotaOrder _order = widget.order;

  Map<String, String> get _content => widget.content;

  @override
  void initState() {
    super.initState();
    _submitCardPayment();
  }

  Future<void> _submitCardPayment() async {
    setState(() {
      _paying = true;
      _error = null;
    });
    Telemetry.instance.event(
      TelemetryEvents.beginCheckout,
      params: {
        TelemetryParams.value: _order.amount,
        TelemetryParams.currency: _order.currency,
        TelemetryParams.transactionId: _order.id,
        TelemetryParams.itemCategory: 'listing_quota',
        TelemetryParams.listingType: _order.type,
        TelemetryParams.method: 'card',
        'extra_listings': _order.extraListings,
      },
    );
    try {
      final pay = await widget.api.payOrder(
        _order.id,
        method: 'card',
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      final payData = pay.data;
      if (payData.isPaid) {
        await _onCardPaid(payData, pay.receipt);
        return;
      }
      final url = payData.checkoutUrl;
      if (url == null || url.isEmpty) {
        throw StateError(_failedText());
      }
      final outcome = await Navigator.of(context).push<CardCheckoutResult>(
        MaterialPageRoute(
          builder: (_) => CardCheckoutScreen(
            checkoutUrl: url,
            title: tr('listing_quota.pay.card_title', 'Kart ilə ödəniş'),
          ),
        ),
      );
      if (!mounted) return;
      if (outcome == null || outcome == CardCheckoutResult.abandoned) {
        setState(() {
          _paying = false;
          _error = tr(
            'listing_quota.payment_canceled',
            'Ödəniş ləğv edildi. Yenidən cəhd edə bilərsən.',
          );
        });
        return;
      }
      final res = await _pollOrder();
      if (!mounted) return;
      final o = res.data;
      if (o.isPaid) {
        await _onCardPaid(o, res.receipt);
      } else {
        Telemetry.instance.event(
          TelemetryEvents.purchaseFailed,
          params: {
            TelemetryParams.transactionId: o.id,
            TelemetryParams.itemCategory: 'listing_quota',
            TelemetryParams.method: 'card',
            TelemetryParams.result: o.status,
          },
        );
        setState(() {
          _order = o;
          _paying = false;
          _error = o.isPending ? null : (res.message ?? _failedText());
        });
      }
    } catch (e, st) {
      Telemetry.instance.event(
        TelemetryEvents.purchaseFailed,
        params: {
          TelemetryParams.transactionId: _order.id,
          TelemetryParams.itemCategory: 'listing_quota',
          TelemetryParams.method: 'card',
          TelemetryParams.errorType: e.runtimeType.toString(),
        },
      );
      Telemetry.instance.error(e, st, reason: 'quota_payment_failed');
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = _apiError(e);
      });
    }
  }

  Future<void> _onCardPaid(QuotaOrder o, Receipt? receipt) async {
    Telemetry.instance.event(
      TelemetryEvents.purchase,
      params: {
        TelemetryParams.value: o.amount,
        TelemetryParams.currency: o.currency,
        TelemetryParams.transactionId: o.id,
        TelemetryParams.itemCategory: 'listing_quota',
        TelemetryParams.listingType: o.type,
        TelemetryParams.method: 'card',
        'extra_listings': o.extraListings,
      },
    );
    await _goToSuccess(o, receipt);
  }

  Future<QuotaOrderResponse> _pollOrder() async {
    QuotaOrderResponse? last;
    var current = _order;
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      try {
        last = await widget.api.getOrder(current.id);
        current = last.data;
      } catch (_) {
        continue;
      }
      if (current.isPaid || current.isFailed) break;
    }
    return last ?? await widget.api.getOrder(_order.id);
  }

  Future<void> _goToSuccess(QuotaOrder o, Receipt? receipt) async {
    final serverLimit = await _refreshQuotaLimit(widget.type);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuotaSuccessScreen(
          order: o,
          type: widget.type,
          currentLimit: widget.currentLimit,
          repostListing: widget.repostListing,
          serverLimit: serverLimit,
          receipt: receipt,
          content: _content,
        ),
      ),
    );
  }

  String _failedText() => tr(
    'listing_quota.payment_failed_sub',
    'Məbləğ tutulmadı və limit dəyişmədi. Yenidən cəhd et.',
  );

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
        _error = _apiError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final failed = _error != null;
    return PopScope(
      canPop: !_paying,
      child: Scaffold(
        backgroundColor: cCard(isDark),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _QuotaAppBar(
                title: tr('listing_quota.title', 'Limiti artır'),
                onClose: _paying
                    ? null
                    : () => Navigator.of(context).maybePop(),
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
                            tr(
                              'listing_quota.payment_pending',
                              'Ödəniş gözlənilir…',
                            ),
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
                              fontWeight: FontWeight.w500,
                            ),
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
                            child: Icon(
                              PhosphorIconsFill.xCircle,
                              color: isDark
                                  ? WawatDark.danger
                                  : const Color(0xFFEF4444),
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            tr(
                              'listing_quota.payment_failed',
                              'Ödəniş keçmədi',
                            ),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
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
                            tr(
                              'listing_quota.payment_pending',
                              'Ödəniş gözlənilir…',
                            ),
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
                            onPressed: _submitCardPayment,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  PhosphorIconsBold.arrowClockwise,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  tr('listing_quota.retry', 'Yenidən cəhd et'),
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
                          _GhostButton(
                            label: tr('common.close', 'Bağla'),
                            isDark: isDark,
                            onTap: () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
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
                                Icon(
                                  PhosphorIconsBold.arrowsClockwise,
                                  color: cBrandText(isDark),
                                  size: 18,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  tr(
                                    'listing_quota.refresh_status',
                                    'Statusu yenilə',
                                  ),
                                  style: TextStyle(
                                    color: cBrandText(isDark),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _GhostButton(
                            label: tr(
                              'listing_quota.cancel_payment',
                              'Ödənişi ləğv et',
                            ),
                            isDark: isDark,
                            onTap: () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
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

class QuotaSuccessScreen extends StatelessWidget {
  final QuotaOrder order;
  final String type;
  final int currentLimit;

  final Listing? repostListing;

  final int? serverLimit;

  final Receipt? receipt;
  final Map<String, String> content;

  const QuotaSuccessScreen({
    super.key,
    required this.order,
    required this.type,
    required this.currentLimit,
    this.repostListing,
    this.serverLimit,
    this.receipt,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final int? newLimit = serverLimit;
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
                child: const Icon(
                  PhosphorIconsFill.checkCircle,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                tr('listing_quota.success_title', 'Limitin artdı!'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  tr('listing_quota.success_sub_prefix', 'İndi daha'),
                  '${order.extraListings}',
                  order.typeLabel,
                  tr(
                    'listing_quota.success_sub_suffix',
                    'aktiv elan yarada bilərsən.',
                  ),
                ].where((s) => s.trim().isNotEmpty).join(' '),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (newLimit != null) ...[
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('listing_quota.new_limit', 'Yeni limit'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$currentLimit → $newLimit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final navigator = Navigator.of(context);
                        final repost = repostListing;
                        navigator.popUntil((r) => r.isFirst);
                        navigator.push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => repost != null
                                ? CreatePostScreen(repostListing: repost)
                                : CreatePostScreen(initialType: type),
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
                            Icon(
                              PhosphorIconsBold.plus,
                              color: cBrandFill,
                              size: 18,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              tr('listing_quota.create_listing', 'Elan yarat'),
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
                    _QuotaReceiptLink(
                      order: order,
                      receipt: receipt,
                      content: content,
                    ),
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

class _QuotaReceiptLink extends StatefulWidget {
  final QuotaOrder order;
  final Receipt? receipt;
  final Map<String, String> content;

  const _QuotaReceiptLink({
    required this.order,
    required this.receipt,
    required this.content,
  });

  @override
  State<_QuotaReceiptLink> createState() => _QuotaReceiptLinkState();
}

class _QuotaReceiptLinkState extends State<_QuotaReceiptLink> {
  late Receipt? _receipt = widget.receipt;

  @override
  void initState() {
    super.initState();
    if (!(_receipt?.isPaid ?? false)) _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      final res = await ListingQuotaApi(
        sl.get<Dio>(),
      ).getOrder(widget.order.id);
      if (!mounted || !(res.receipt?.isPaid ?? false)) return;
      setState(() => _receipt = res.receipt);
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    if (receipt == null || !receipt.isPaid) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ReceiptScreen(receipt: receipt, content: widget.content),
            ),
          ),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsBold.receipt,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  tr('listing_quota.view_receipt', 'Qəbzə bax'),
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
    );
  }
}

class _QuotaAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const _QuotaAppBar({required this.title, this.onClose});

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
              child: Icon(
                PhosphorIconsBold.x,
                color: onClose == null ? cMuted(isDark) : cText(isDark),
                size: 22,
              ),
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

  const _GhostButton({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

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
  final String priceText;
  final bool selected;
  final Map<String, String> content;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.priceText,
    required this.selected,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final perLabel = plan.perListing == null
        ? tr('listing_quota.one_time', 'bir dəfəlik · daimi limit')
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
                      ? const Icon(
                          PhosphorIconsBold.check,
                          color: Colors.white,
                          size: 12,
                        )
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
                  priceText,
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
                  tr('listing_quota.badge.best_value', 'Ən sərfəli'),
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

  final String priceText;
  final String type;
  final Map<String, String> content;

  final bool storeAvailable;

  final ProductDetails? storeProduct;
  final IapCatalogProduct? catalogProduct;

  const _ConfirmSheet({
    required this.api,
    required this.plan,
    required this.priceText,
    required this.type,
    required this.content,
    required this.storeAvailable,
    this.storeProduct,
    this.catalogProduct,
  });

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _creating = false;
  bool _paying = false;
  String? _error;

  String? _notice;

  late final String _idem =
      'quota-order-${widget.type}-${widget.plan.extraListings}-${DateTime.now().microsecondsSinceEpoch}';

  QuotaPlan get plan => widget.plan;
  Map<String, String> get content => widget.content;

  bool get _busy => _creating || _paying;

  String get _storeMethod => Platform.isIOS ? 'app_store' : 'google_play';

  bool get _showCard => true;

  Future<void> _pay(_QuotaPayMethod method) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _creating = true;
      _error = null;
      _notice = null;
    });
    final QuotaOrder order;
    try {
      final res = await widget.api.createOrder(
        type: widget.type,
        extraListings: plan.extraListings,
        idempotencyKey: _idem,
      );
      if (!mounted) return;
      order = res.data;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = _apiError(e);
      });
      return;
    }
    if (method == _QuotaPayMethod.card) {
      navigator.pop(_QuotaCheckout.card(order));
      return;
    }
    await _payWithStore(order);
  }

  Future<void> _payWithStore(QuotaOrder order) async {
    setState(() {
      _creating = false;
      _paying = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    if (order.isPaid) {
      final serverLimit = await _refreshQuotaLimit(widget.type);
      if (!mounted) return;
      navigator.pop(
        _QuotaCheckout.storePaid(
          order,
          serverLimit: serverLimit,
          receipt: null,
        ),
      );
      return;
    }
    Telemetry.instance.event(
      TelemetryEvents.beginCheckout,
      params: {
        TelemetryParams.value: widget.storeProduct?.rawPrice ?? order.amount,
        TelemetryParams.currency:
            widget.storeProduct?.currencyCode ?? order.currency,
        TelemetryParams.transactionId: order.id,
        TelemetryParams.itemCategory: 'listing_quota',
        TelemetryParams.listingType: order.type,
        TelemetryParams.method: _storeMethod,
        'extra_listings': order.extraListings,
      },
    );
    try {
      final result = await IapService.instance.purchase(
        widget.catalogProduct!.productId,
        orderId: order.id,
      );
      if (!mounted) return;
      if (result.outcome == IapOutcome.canceled) {
        setState(() {
          _paying = false;
          _error = null;
        });
        return;
      }
      if (result.outcome == IapOutcome.pending) {
        setState(() {
          _paying = false;
          _error = null;
          _notice = tr(
            'common.payment_processing',
            'Ödəniş emal olunur. Təsdiqlənən kimi avtomatik aktivləşəcək.',
          );
        });
        return;
      }
      if (result.outcome == IapOutcome.error) {
        Telemetry.instance.event(
          TelemetryEvents.purchaseFailed,
          params: {
            TelemetryParams.transactionId: order.id,
            TelemetryParams.itemCategory: 'listing_quota',
            TelemetryParams.method: _storeMethod,
            TelemetryParams.errorType: 'iap_${result.message ?? 'error'}',
          },
        );
        setState(() {
          _paying = false;
          _error = _quotaIapErrorText(result.message, result.code);
        });
        return;
      }
      QuotaOrder paid = order;
      Receipt? receipt;
      try {
        final res = await widget.api.getOrder(order.id);
        if (mounted && res.data.isPaid) {
          paid = res.data;
          receipt = res.receipt;
        }
      } catch (_) {
      }
      if (!mounted) return;
      Telemetry.instance.event(
        TelemetryEvents.purchase,
        params: {
          TelemetryParams.value: widget.storeProduct?.rawPrice ?? paid.amount,
          TelemetryParams.currency:
              widget.storeProduct?.currencyCode ?? paid.currency,
          TelemetryParams.transactionId: paid.id,
          TelemetryParams.itemCategory: 'listing_quota',
          TelemetryParams.listingType: paid.type,
          TelemetryParams.method: _storeMethod,
          TelemetryParams.result: paid.status,
          'extra_listings': paid.extraListings,
        },
      );
      final serverLimit = await _refreshQuotaLimit(widget.type);
      if (!mounted) return;
      navigator.pop(
        _QuotaCheckout.storePaid(
          paid,
          serverLimit: serverLimit,
          receipt: receipt,
        ),
      );
    } catch (e, st) {
      Telemetry.instance.event(
        TelemetryEvents.purchaseFailed,
        params: {
          TelemetryParams.transactionId: order.id,
          TelemetryParams.itemCategory: 'listing_quota',
          TelemetryParams.method: _storeMethod,
          TelemetryParams.errorType: e.runtimeType.toString(),
        },
      );
      Telemetry.instance.error(e, st, reason: 'quota_store_payment_failed');
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = _apiError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !_busy,
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
                tr('listing_quota.confirm_title', 'Ödənişi təsdiqlə'),
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
                        content,
                        'listing_quota.receipt.package',
                        'Paket',
                      ),
                      value: plan.packageLabel,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _KV(
                      label: tr('listing_quota.receipt.type', 'Növ'),
                      value: tr(
                        'listing_quota.permanent_increase',
                        'Daimi limit artımı',
                      ),
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
                          tr('listing_quota.total', 'Ümumi'),
                          style: TextStyle(
                            color: cText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.priceText,
                          style: TextStyle(
                            color: cBrandText(isDark),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_busy) ...[
                SizedBox(
                  height: 132,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: cBrandText(isDark)),
                        const SizedBox(height: 14),
                        Text(
                          _paying
                              ? tr(
                                  'listing_quota.awaiting_store',
                                  'Mağaza ödənişi gözlənilir…',
                                )
                              : tr(
                                  'listing_quota.creating_order',
                                  'Sifariş hazırlanır…',
                                ),
                          style: TextStyle(
                            color: cText2(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tr('listing_quota.pay.method_title', 'Ödəniş üsulu'),
                    style: TextStyle(
                      color: cText(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.storeAvailable) ...[
                  _QuotaMethodTile(
                    isDark: isDark,
                    icon: PhosphorIconsBold.storefront,
                    title: Platform.isIOS
                        ? tr('listing_quota.pay.store_apple', 'App Store')
                        : tr('listing_quota.pay.store_google', 'Google Play'),
                    subtitle: tr(
                      'listing_quota.pay.store_sub',
                      'Mağaza vasitəsilə',
                    ),
                    trailing: widget.priceText,
                    onTap: () => _pay(_QuotaPayMethod.store),
                  ),
                  if (_showCard) const SizedBox(height: 8),
                ],
                if (_showCard)
                  _QuotaMethodTile(
                    isDark: isDark,
                    icon: PhosphorIconsBold.creditCard,
                    title: tr('listing_quota.pay.card', 'Bank kartı'),
                    subtitle: tr(
                      'listing_quota.pay.card_sub',
                      'AZN ilə ödəniş',
                    ),
                    trailing: widget.storeAvailable ? null : widget.priceText,
                    onTap: () => _pay(_QuotaPayMethod.card),
                  ),
                if (!widget.storeAvailable && !_showCard)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cFill(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.warningCircle,
                          color: isDark
                              ? WawatDark.warning
                              : const Color(0xFFE8A400),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tr(
                              'listing_quota.pay.store_unavailable',
                              'Ödəniş üsulu hazırda əlçatan deyil. Bir azdan yenidən cəhd et.',
                            ),
                            style: TextStyle(
                              color: cText2(isDark),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
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
                      color: isDark
                          ? WawatDark.danger
                          : const Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (_notice != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _notice!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cBrandText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                _GhostButton(
                  label: tr('common.cancel', 'İmtina et'),
                  isDark: isDark,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaMethodTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _QuotaMethodTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cFill(isDark),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cBrandSoft(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cBrandText(isDark), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: cText2(isDark), fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailing!,
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Icon(
                PhosphorIconsBold.caretRight,
                color: cMuted(isDark),
                size: 18,
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
        Text(
          label,
          style: TextStyle(
            color: cText2(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: cText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
