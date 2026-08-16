import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../data/network/api/promotion_api.dart';
import '../../../../../data/network/request/promotion_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/promotion_response.dart';
import '../../../../../data/network/response/receipt.dart';
import '../../../../payments/receipt_screen.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/telemetry/telemetry.dart';
import '../../../../../services/telemetry/telemetry_events.dart';
import '../../../../../services/wawat_content.dart';
import '../../profile_tab/promo/promo_api.dart';
import '../details/listing_details_screen.dart';
import '../widgets/listing_card.dart';

const _brand = Color(0xFF017BFE);
const _brand50 = Color(0xFFEAF3FE);
const _amber = Color(0xFFF5B301);
const _amber50 = Color(0xFFFEF6E7);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _screen = Color(0xFFEEF1F6);
const _emerald = Color(0xFF10B981);

// Тема-зависимые цвета. Светлая ветка = точь-в-точь как было (белый режим не
// меняется), тёмная ветка = единый графит из [WawatDark].
Color _cScreen(bool d) => d ? WawatDark.bg : _screen;
Color _cCard(bool d) => d ? WawatDark.surface : Colors.white;
Color _cFill(bool d) =>
    d ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05);
Color _cText(bool d) => d ? WawatDark.textPrimary : _ink900;
Color _cText2(bool d) => d ? WawatDark.textSecondary : _ink500;
Color _cText3(bool d) => d ? WawatDark.textSecondary : _ink600;
Color _cText4(bool d) => d ? WawatDark.textSecondary : _ink700;
Color _cMuted(bool d) => d ? WawatDark.textMuted : _ink400;
Color _cFaint(bool d) => d ? WawatDark.iconMuted : _ink300;
Color _cLine(bool d) => d ? WawatDark.divider : _ink900.withValues(alpha: 0.06);
Color _cBrandSoft(bool d) => d ? WawatDark.brandSoft : _brand50;

Future<void> openPromotionFlow(
  BuildContext context, {
  required Listing listing,
  required String type,
  Promotion? promotion,
  bool forceNew = false,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PromotionPurchaseScreen(
        listing: listing,
        initialType: type,
        initialPromotion: promotion,
        forceNew: forceNew,
      ),
    ),
  );
}

class PromotionPostCreateUpsell extends StatefulWidget {
  final Listing listing;
  final VoidCallback onSkip;

  const PromotionPostCreateUpsell({
    super.key,
    required this.listing,
    required this.onSkip,
  });

  @override
  State<PromotionPostCreateUpsell> createState() =>
      _PromotionPostCreateUpsellState();
}

class _PromotionPostCreateUpsellState extends State<PromotionPostCreateUpsell> {
  late Future<_PromotionBundle> _future = _loadPromotionBundle();

  void _retry() {
    setState(() => _future = _loadPromotionBundle());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<_PromotionBundle>(
      future: _future,
      builder: (context, snapshot) {
        final bundle = snapshot.data;
        final content = bundle?.content ?? const <String, String>{};
        final pricing = bundle?.pricing;
        return ColoredBox(
          color: _cScreen(isDark),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? WawatDark.success.withValues(alpha: 0.14)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(
                      PhosphorIconsFill.checkCircle,
                      color: isDark ? WawatDark.success : _emerald,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _tx(
                    content,
                    'promotion.created_title',
                    'Elanın yoxlamaya göndərildi',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _tx(
                    content,
                    'promotion.created_subtitle',
                    'Adətən 1–2 saat ərzində təsdiqlənir. Təsdiqdən sonra lentdə görünəcək.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cText2(isDark),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _RoutePreview(listing: widget.listing),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsFill.trendUp,
                      color: _brand,
                      size: 19,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        _tx(
                          content,
                          'promotion.upsell_title',
                          'Elanını daha çox insana çatdır',
                        ),
                        style: TextStyle(
                          color: _cText(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (snapshot.hasError) ...[
                  _ErrorBanner(
                    _tx(
                      content,
                      'promotion.pricing_unavailable',
                      'Promosyon paketlərini yükləmək alınmadı.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OutlineButton(
                    label: _tx(
                      content,
                      'common.retry',
                      'Yenidən cəhd et',
                    ),
                    icon: PhosphorIconsRegular.arrowsClockwise,
                    onTap: _retry,
                  ),
                ] else ...[
                  _UpsellCard(
                    content: content,
                    vip: true,
                    title: _tx(content, 'promotion.cta.vip', 'VİP et'),
                    subtitle: _tx(
                      content,
                      'promotion.vip_short',
                      'Ən yuxarıda, ayrıca bölmədə',
                    ),
                    price: pricing?.vip.prices.values.minOrNull,
                    onTap: pricing == null
                        ? null
                        : () => openPromotionFlow(
                              context,
                              listing: widget.listing,
                              type: 'vip',
                            ),
                  ),
                  const SizedBox(height: 12),
                  _UpsellCard(
                    content: content,
                    vip: false,
                    title: _tx(content, 'promotion.cta.boost', 'Önə çək'),
                    subtitle: _tx(
                      content,
                      'promotion.boost_short',
                      'Zəmanətli göstərişlər',
                    ),
                    price:
                        pricing?.boost.packages.map((p) => p.price).minOrNull,
                    onTap: pricing == null
                        ? null
                        : () => openPromotionFlow(
                              context,
                              listing: widget.listing,
                              type: 'featured',
                            ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    _tx(
                      content,
                      'promotion.skip',
                      'İndi yox, elanlarıma keç',
                    ),
                    style: TextStyle(
                      color: _cMuted(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PromotionPurchaseScreen extends StatefulWidget {
  final Listing listing;
  final String initialType;
  final Promotion? initialPromotion;
  final bool forceNew;

  const PromotionPurchaseScreen({
    super.key,
    required this.listing,
    required this.initialType,
    this.initialPromotion,
    this.forceNew = false,
  });

  @override
  State<PromotionPurchaseScreen> createState() =>
      _PromotionPurchaseScreenState();
}

class _PromotionPurchaseScreenState extends State<PromotionPurchaseScreen> {
  late final PromotionApi _api = PromotionApi(sl.get<Dio>());
  late Future<_PromotionBundle> _future;

  /// Boost selection — the package code (`large` | `medium` | `small`).
  String? _selectedPackage;

  /// VIP selection — the duration in days.
  int? _selectedDuration;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PromotionBundle> _load() async {
    final base = await _loadPromotionBundle();
    Promotion? existing = widget.initialPromotion;
    if (existing == null && !widget.forceNew) {
      try {
        final response = await _api.getMyPromotions(status: 'active');
        for (final item in response.data) {
          if (item.listingId == widget.listing.id &&
              item.type == widget.initialType) {
            existing = item;
            break;
          }
        }
      } catch (_) {}
    }
    final durations = base.pricing.durations;
    _selectedDuration = durations.contains(7)
        ? 7
        : (durations.isEmpty ? null : durations.first);
    if (widget.initialType == 'featured') {
      final packages = base.pricing.boost.packages;
      final existingPkg = existing?.package;
      final hasExisting =
          existingPkg != null && packages.any((p) => p.package == existingPkg);
      _selectedPackage = hasExisting
          ? existingPkg
          : (packages.isEmpty ? null : packages.first.package);
    }
    return _PromotionBundle(
      pricing: base.pricing,
      content: base.content,
      packageNamesByCode: base.packageNamesByCode,
      existingPromotion: existing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PromotionBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingPage();
        }
        if (!snapshot.hasData) {
          return _ErrorPage(onRetry: () => setState(() => _future = _load()));
        }
        final bundle = snapshot.data!;
        final existing = bundle.existingPromotion;

        // VIP — unchanged: pick 1 / 7 / 30 days, price from vip.prices.
        if (widget.initialType == 'vip') {
          final prices = bundle.pricing.vip.prices;
          return _DurationPage(
            listing: widget.listing,
            content: bundle.content,
            packageNamesByCode: bundle.packageNamesByCode,
            vip: true,
            tier: null,
            existing: existing,
            durations: bundle.pricing.durations,
            prices: prices,
            selectedDuration: _selectedDuration,
            onBack: () => Navigator.pop(context),
            onChanged: (value) => setState(() => _selectedDuration = value),
            onCheckout: _selectedDuration == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _PromotionCheckoutScreen(
                          api: _api,
                          listing: widget.listing,
                          content: bundle.content,
                          type: 'vip',
                          duration: _selectedDuration!,
                          amount: prices[_selectedDuration] ?? 0,
                          currency: bundle.pricing.currency,
                          existingPromotion: existing,
                        ),
                      ),
                    ),
          );
        }

        // Boost — guaranteed-impressions packages (no tiers, no days).
        final selected = bundle.pricing.boost.packages
            .where((p) => p.package == _selectedPackage)
            .firstOrNull;
        return _BoostPackagePage(
          listing: widget.listing,
          content: bundle.content,
          packageNamesByCode: bundle.packageNamesByCode,
          pricing: bundle.pricing,
          existing: existing,
          selectedPackage: _selectedPackage,
          onBack: () => Navigator.pop(context),
          onChanged: (value) => setState(() => _selectedPackage = value),
          onCheckout: selected == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PromotionCheckoutScreen(
                        api: _api,
                        listing: widget.listing,
                        content: bundle.content,
                        type: 'featured',
                        duration: null,
                        package: selected.package,
                        packageLabel: selected.label,
                        guaranteedMin: selected.guaranteedMin,
                        guaranteedMax: selected.guaranteedMax,
                        amount: selected.price,
                        currency: bundle.pricing.currency,
                        existingPromotion: existing,
                      ),
                    ),
                  ),
        );
      },
    );
  }
}

class _PromotionCheckoutScreen extends StatefulWidget {
  final PromotionApi api;
  final Listing listing;
  final Map<String, String> content;
  final String type;

  /// VIP duration in days — null for boost (which has no days).
  final int? duration;

  /// Boost package code + label and its guaranteed-impressions range. Null for
  /// VIP.
  final String? package;
  final String? packageLabel;
  final int? guaranteedMin;
  final int? guaranteedMax;

  final double amount;
  final String currency;
  final Promotion? existingPromotion;

  const _PromotionCheckoutScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.type,
    this.duration,
    this.package,
    this.packageLabel,
    this.guaranteedMin,
    this.guaranteedMax,
    required this.amount,
    required this.currency,
    this.existingPromotion,
  });

  @override
  State<_PromotionCheckoutScreen> createState() =>
      _PromotionCheckoutScreenState();
}

class _PromotionCheckoutScreenState extends State<_PromotionCheckoutScreen> {
  final _promoCode = TextEditingController();
  bool _loading = false;
  String? _error;

  /// The pending order — created lazily (either when the user applies a promo,
  /// so we have an id to quote against, or on "checkout"). Kept so we never
  /// create the order twice. The extend flow (`existingPromotion != null`) has
  /// no promo step and never touches this.
  Promotion? _order;
  late final String _createKey =
      'promotion-${DateTime.now().microsecondsSinceEpoch}';

  PromotionQuote? _quote; // last APPLICABLE quote (drives discount + total)
  String? _appliedCode; // the code behind _quote — forwarded to pay
  bool _quoting = false;
  String? _promoMessage; // non-applicable reason / quote error, shown in red

  bool get _isNew => widget.existingPromotion == null;
  bool get _isBoost => widget.type == 'featured';
  bool get _hasDiscount => _quote != null && _quote!.applicable;
  double get _effectiveTotal =>
      _hasDiscount ? _quote!.finalAmount : widget.amount;

  @override
  void dispose() {
    _promoCode.dispose();
    super.dispose();
  }

  /// Create the pending order once (NO promo at create — the code rides on quote
  /// + pay per the backend contract) and reuse it thereafter.
  Future<Promotion> _ensureOrder() async {
    final existing = _order;
    if (existing != null) return existing;
    final response = await widget.api.createPromotion(
      widget.listing.id,
      _isBoost
          ? PromotionRequest.boost(package: widget.package ?? '')
          : PromotionRequest.vip(durationDays: widget.duration ?? 0),
      idempotencyKey: _createKey,
    );
    _order = response.data;
    return response.data;
  }

  Future<void> _applyPromo() async {
    if (_quoting) return;
    FocusScope.of(context).unfocus();
    final code = _promoCode.text.trim();
    if (code.isEmpty) {
      setState(() {
        _quote = null;
        _appliedCode = null;
        _promoMessage = null;
      });
      return;
    }
    setState(() {
      _quoting = true;
      _promoMessage = null;
    });
    try {
      final order = await _ensureOrder();
      final quote = (await widget.api.quotePromotion(order.id, code)).data;
      if (!mounted) return;
      setState(() {
        _quoting = false;
        if (quote.applicable) {
          _quote = quote;
          _appliedCode = code;
          _promoMessage = null;
        } else {
          _quote = null;
          _appliedCode = null;
          _promoMessage = _promoReasonText(widget.content, quote.reason);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _quoting = false;
        _quote = null;
        _appliedCode = null;
        _promoMessage = _apiError(error);
      });
    }
  }

  void _clearPromo() {
    _promoCode.clear();
    setState(() {
      _quote = null;
      _appliedCode = null;
      _promoMessage = null;
    });
  }

  Future<void> _openWallet() async {
    final selected = await showAppBottomSheet<PromoCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PromoWalletSheet(content: widget.content),
    );
    if (selected == null || !mounted) return;
    _promoCode.text = selected.code;
    await _applyPromo();
  }

  Future<void> _continue() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Promotion promotion;
      if (_isNew) {
        promotion = await _ensureOrder();
      } else {
        // Boost re-buy = empty body (same package, fresh guarantee); VIP adds
        // days. Sending duration_days for boost would 422.
        final response = await widget.api.extendPromotion(
          widget.existingPromotion!.id,
          _isBoost
              ? const PromotionExtendRequest()
              : PromotionExtendRequest(durationDays: widget.duration ?? 0),
          idempotencyKey:
              'promotion-extend-${DateTime.now().microsecondsSinceEpoch}',
        );
        promotion = response.data;
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentMethodScreen(
            api: widget.api,
            listing: widget.listing,
            content: widget.content,
            promotion: promotion,
            promoCode: _isNew ? _appliedCode : null,
            quote: _isNew ? _quote : null,
          ),
        ),
      );
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _apiError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vip = widget.type == 'vip';
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      appBar: _simpleAppBar(
        context,
        _tx(widget.content, 'promotion.checkout_title', 'Sifariş yekunu'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _CheckoutSummaryCard(
            listing: widget.listing,
            vip: vip,
            boost: _isBoost,
            packageLabel: widget.packageLabel,
            guaranteedMin: widget.guaranteedMin,
            guaranteedMax: widget.guaranteedMax,
            duration: widget.duration,
            content: widget.content,
          ),
          const SizedBox(height: 14),
          if (_isNew) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _whiteCard(isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.ticket,
                        color: _cMuted(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _promoCode,
                            enabled: !_quoting,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _applyPromo(),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            style: TextStyle(
                              color: _cText(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: _tx(
                                widget.content,
                                'promotion.promo_code',
                                'Promokod (varsa)',
                              ),
                              hintStyle: TextStyle(
                                color: _cMuted(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? WawatDark.surfaceAlt
                                  : _ink900.withValues(alpha: 0.02),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? WawatDark.border
                                      : _ink900.withValues(alpha: 0.07),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: _brand),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: _cFill(isDark),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _quoting ? null : _applyPromo,
                          child: Container(
                            height: 44,
                            constraints: const BoxConstraints(minWidth: 64),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: _quoting
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _cText4(isDark),
                                    ),
                                  )
                                : Text(
                                    _tx(widget.content, 'promotion.apply',
                                        'Tətbiq et'),
                                    style: TextStyle(
                                      color: _cText4(isDark),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_hasDiscount) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.checkCircle,
                          color: isDark ? WawatDark.success : _emerald,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatContent(
                              widget.content,
                              'promotion.promo_applied',
                              'Promokod tətbiq olundu · −{amount} \$',
                              {'amount': _money(_quote!.discount)},
                            ),
                            style: TextStyle(
                              color: isDark ? WawatDark.success : _emerald,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _clearPromo,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              PhosphorIconsBold.x,
                              color: _cMuted(isDark),
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_promoMessage != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.warningCircle,
                          color: isDark
                              ? WawatDark.danger
                              : const Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _promoMessage!,
                            style: TextStyle(
                              color: isDark
                                  ? WawatDark.danger
                                  : const Color(0xFFEF4444),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openWallet,
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.wallet,
                          color: isDark ? WawatDark.brandText : _brand,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tx(
                            widget.content,
                            'promotion.choose_from_wallet',
                            'Promokodlarımdan seç',
                          ),
                          style: TextStyle(
                            color: isDark ? WawatDark.brandText : _brand,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _whiteCard(isDark),
            child: Column(
              children: [
                _CheckoutRow(
                  label: _isBoost
                      ? (widget.packageLabel ??
                          _tx(widget.content, 'promotion.cta.boost', 'Önə çək'))
                      : '${_tx(widget.content, 'enum.promotion_type.vip', 'VİP')} · ${_formatContent(widget.content, 'promotion.duration_template', '{days} gün', {
                              'days': widget.duration
                            })}',
                  value: '${widget.amount.toStringAsFixed(2)} \$',
                ),
                _CheckoutRow(
                  label: _tx(
                    widget.content,
                    'promotion.checkout.discount',
                    'Endirim',
                  ),
                  value: _hasDiscount
                      ? '−${_quote!.discount.toStringAsFixed(2)} \$'
                      : '0.00 \$',
                  valueColor: isDark ? WawatDark.success : _emerald,
                ),
                _CheckoutRow(
                  label: _tx(widget.content, 'promotion.total', 'Yekun'),
                  value: '${_effectiveTotal.toStringAsFixed(2)} \$',
                  emphasized: true,
                  topBorder: true,
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(_error!),
          ],
        ],
      ),
      bottomNavigationBar: _StickyBottom(
        child: _PrimaryButton(
          label:
              '${_tx(widget.content, 'promotion.cta.checkout', 'Ödənişə keç')} · ${_money(_effectiveTotal)} \$',
          icon: PhosphorIconsBold.arrowRight,
          iconAfter: true,
          onTap: _continue,
          loading: _loading,
        ),
      ),
    );
  }
}

/// Bottom sheet listing the user's active promo codes (GET /me/promo-codes).
/// Tapping one pops the sheet with that [PromoCode]; the checkout screen then
/// fills the field with its code and re-quotes.
class _PromoWalletSheet extends StatefulWidget {
  final Map<String, String> content;

  const _PromoWalletSheet({required this.content});

  @override
  State<_PromoWalletSheet> createState() => _PromoWalletSheetState();
}

class _PromoWalletSheetState extends State<_PromoWalletSheet> {
  late final Future<PromoCodesPage> _future = PromoApi().getPromoCodes();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: _cScreen(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: _cFaint(isDark),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 13, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _tx(widget.content, 'promotion.wallet_title',
                          'Promokodlarım'),
                      style: TextStyle(
                        color: _cText(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        PhosphorIconsBold.x,
                        color: _cText4(isDark),
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<PromoCodesPage>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _brand),
                    );
                  }
                  final codes = (snapshot.data?.data ?? const <PromoCode>[])
                      .where((code) => code.isActive)
                      .toList();
                  if (codes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _tx(widget.content, 'promotion.wallet_empty',
                              'Aktiv promokodun yoxdur.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _cText2(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: codes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _PromoWalletTile(
                      code: codes[index],
                      content: widget.content,
                      onTap: () => Navigator.pop(context, codes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoWalletTile extends StatelessWidget {
  final PromoCode code;
  final Map<String, String> content;
  final VoidCallback onTap;

  const _PromoWalletTile({
    required this.code,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = code.daysLeft;
    return Material(
      color: _cCard(isDark),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cLine(isDark)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _cBrandSoft(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIconsFill.ticket,
                  color: isDark ? WawatDark.brandText : _brand,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        color: _cText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      code.sourceLabel.isNotEmpty
                          ? code.sourceLabel
                          : code.amountLabel,
                      style: TextStyle(
                        color: _cText2(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (days != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatContent(
                          content,
                          'promotion.wallet_days_left',
                          '{days} gün qalıb',
                          {'days': days},
                        ),
                        style: TextStyle(
                          color: code.isExpiringSoon
                              ? (isDark
                                  ? WawatDark.danger
                                  : const Color(0xFFEF4444))
                              : _cMuted(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '−${code.amountLabel}',
                style: TextStyle(
                  color: isDark ? WawatDark.success : _emerald,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodScreen extends StatefulWidget {
  final PromotionApi api;
  final Listing listing;
  final Map<String, String> content;
  final Promotion promotion;

  /// Promo code applied on the checkout screen (null when none). Forwarded to
  /// the pay call so the server charges the discounted amount.
  final String? promoCode;

  /// The applicable quote behind [promoCode] — drives the discounted total shown
  /// here and on the pay button.
  final PromotionQuote? quote;

  const _PaymentMethodScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.promotion,
    this.promoCode,
    this.quote,
  });

  @override
  State<_PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<_PaymentMethodScreen> {
  String _method = 'card';
  bool _openingPayment = false;

  bool get _hasDiscount =>
      widget.quote != null &&
      widget.quote!.applicable &&
      (widget.promoCode ?? '').isNotEmpty;

  double get _payable =>
      _hasDiscount ? widget.quote!.finalAmount : widget.promotion.amount;

  Future<void> _pay() async {
    if (_openingPayment) return;
    setState(() => _openingPayment = true);
    // GA4-событие begin_checkout: вместе с purchase ниже даёт готовый отчёт
    // «сколько дошло от выбора способа оплаты до успешного платежа».
    Telemetry.instance.event(TelemetryEvents.beginCheckout, params: {
      TelemetryParams.value: _payable,
      TelemetryParams.currency: widget.promotion.currency,
      TelemetryParams.itemCategory: widget.promotion.type,
      TelemetryParams.durationDays: widget.promotion.durationDays,
      TelemetryParams.method: _method,
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PromotionProcessingScreen(
          api: widget.api,
          listing: widget.listing,
          content: widget.content,
          promotion: widget.promotion,
          method: _method,
          promoCode: widget.promoCode,
        ),
      ),
    );
    if (mounted) setState(() => _openingPayment = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      appBar: _simpleAppBar(
        context,
        _tx(widget.content, 'promotion.pay.title', 'Ödəniş'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          _PaymentIntegrationBanner(
            text: _tx(
              widget.content,
              'promotion.payment_integration_note',
              'Ödəniş sistemi inteqrasiya mərhələsindədir — bu ekran hazır, provayder qoşulan kimi işləyəcək.',
            ),
          ),
          if (_hasDiscount) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _whiteCard(isDark, radius: 18),
              child: Column(
                children: [
                  _CheckoutRow(
                    label: _tx(widget.content, 'promotion.total_before',
                        'İlkin məbləğ'),
                    value: '${widget.quote!.baseAmount.toStringAsFixed(2)} \$',
                  ),
                  _CheckoutRow(
                    label: _formatContent(
                      widget.content,
                      'promotion.promo_line',
                      'Promokod · {code}',
                      {'code': widget.promoCode},
                    ),
                    value: '−${widget.quote!.discount.toStringAsFixed(2)} \$',
                    valueColor: isDark ? WawatDark.success : _emerald,
                  ),
                  _CheckoutRow(
                    label: _tx(widget.content, 'promotion.total', 'Yekun'),
                    value: '${_payable.toStringAsFixed(2)} \$',
                    emphasized: true,
                    topBorder: true,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            _tx(widget.content, 'promotion.payment_method', 'Ödəniş üsulu'),
            style: TextStyle(
              color: _cText4(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            selected: _method == 'card',
            icon: PhosphorIconsFill.creditCard,
            title: _tx(
              widget.content,
              'enum.payment_method.card',
              'Bank kartı',
            ),
            subtitle: _tx(
              widget.content,
              'promotion.payment.card_subtitle',
              'Visa · Mastercard',
            ),
            onTap: () => setState(() => _method = 'card'),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            selected: _method == 'balance',
            icon: PhosphorIconsFill.wallet,
            iconBackground: _cBrandSoft(isDark),
            iconColor: isDark ? WawatDark.brandText : _brand,
            title: _tx(
              widget.content,
              'enum.payment_method.balance',
              'Wawatair balans',
            ),
            subtitle: _tx(
              widget.content,
              'promotion.payment.balance_subtitle',
              'Mock ödəniş · real balans inteqrasiyada',
            ),
            onTap: () => setState(() => _method = 'balance'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                PhosphorIconsFill.shieldCheck,
                color: isDark ? WawatDark.success : _emerald,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _tx(
                    widget.content,
                    'promotion.pay.secure_note',
                    'Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır',
                  ),
                  style: TextStyle(
                    color: _cMuted(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _StickyBottom(
        child: _PrimaryButton(
          label: _formatContent(
            widget.content,
            'promotion.payment.pay_template',
            'Ödə · {amount} \$',
            {'amount': _money(_payable)},
          ),
          icon: PhosphorIconsFill.lockSimple,
          onTap: _pay,
          loading: _openingPayment,
        ),
      ),
    );
  }
}

class _PromotionProcessingScreen extends StatefulWidget {
  final PromotionApi api;
  final Listing listing;
  final Map<String, String> content;
  final Promotion promotion;
  final String method;

  /// Applied promo code (null when none). The server re-validates and charges
  /// the discounted amount; a 422 `promo.not_applicable` surfaces as an error.
  final String? promoCode;

  const _PromotionProcessingScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.promotion,
    required this.method,
    this.promoCode,
  });

  @override
  State<_PromotionProcessingScreen> createState() =>
      _PromotionProcessingScreenState();
}

class _PromotionProcessingScreenState
    extends State<_PromotionProcessingScreen> {
  late final String _idempotencyKey =
      'promotion-pay-${widget.promotion.id}-${DateTime.now().microsecondsSinceEpoch}';
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _submitPayment();
  }

  Future<void> _submitPayment() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final payResponse = await widget.api.payPromotion(
        widget.promotion.id,
        PromotionPayRequest(
          method: widget.method,
          promoCode: widget.promoCode,
        ),
        idempotencyKey: _idempotencyKey,
      );
      var promotion = payResponse.data;
      Receipt? receipt = payResponse.receipt;

      final payment = promotion.payment;
      if (payment != null && !payment.isMock) {
        final checkoutUrl = payment.checkoutUrl;
        if (checkoutUrl != null && checkoutUrl.trim().isNotEmpty) {
          final uri = Uri.tryParse(checkoutUrl);
          if (uri == null ||
              !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw StateError(
              _tx(
                widget.content,
                'promotion.provider_unavailable',
                'Ödəniş səhifəsini açmaq alınmadı.',
              ),
            );
          }
          final polled = await _pollProviderResult(promotion);
          promotion = polled.data;
          receipt = polled.receipt ?? receipt;
        }
      }

      // GA4 purchase: value + currency обязательны, иначе платёж не попадёт в
      // отчёты по выручке. transaction_id даёт дедупликацию — при повторном
      // заходе на экран идемпотентный ключ тот же, и Firebase не посчитает
      // покупку дважды.
      Telemetry.instance.event(TelemetryEvents.purchase, params: {
        TelemetryParams.value: promotion.chargedAmount,
        TelemetryParams.currency: promotion.currency,
        TelemetryParams.transactionId: promotion.id,
        TelemetryParams.itemCategory: promotion.type,
        TelemetryParams.durationDays: promotion.durationDays,
        TelemetryParams.method: widget.method,
        TelemetryParams.result: promotion.status,
        TelemetryParams.listingId: widget.listing.id,
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PromotionStatusScreen(
            api: widget.api,
            listing: widget.listing,
            content: widget.content,
            initialPromotion: promotion,
            receipt: receipt,
          ),
        ),
      );
    } catch (error, stack) {
      Telemetry.instance.event(TelemetryEvents.purchaseFailed, params: {
        TelemetryParams.value: widget.promotion.amount,
        TelemetryParams.currency: widget.promotion.currency,
        TelemetryParams.transactionId: widget.promotion.id,
        TelemetryParams.method: widget.method,
        TelemetryParams.errorType: error.runtimeType.toString(),
      });
      // Сорванный платёж — всегда баг, который стоит денег: отправляем как
      // non-fatal, даже если это DioException (интерцептор о деньгах не знает).
      Telemetry.instance
          .error(error, stack, reason: 'promotion_payment_failed');
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _apiError(error);
      });
    }
  }

  Future<PromotionResponse> _pollProviderResult(Promotion promotion) async {
    PromotionResponse? last;
    var current = promotion;
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      try {
        last = await widget.api.getPromotion(current.id);
        current = last.data;
      } catch (_) {
        continue;
      }
      if (_isResolvedPromotionStatus(current.status)) break;
    }
    return last ?? PromotionResponse(data: promotion);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _error == null
                        ? _brand.withValues(alpha: 0.10)
                        : (isDark
                            ? WawatDark.danger.withValues(alpha: 0.14)
                            : const Color(0xFFEF4444).withValues(alpha: 0.10)),
                    shape: BoxShape.circle,
                  ),
                  child: _error == null
                      ? const Padding(
                          padding: EdgeInsets.all(23),
                          child: CircularProgressIndicator(
                            color: _brand,
                            strokeWidth: 4,
                          ),
                        )
                      : Icon(
                          PhosphorIconsFill.warningCircle,
                          color: isDark
                              ? WawatDark.danger
                              : const Color(0xFFEF4444),
                          size: 42,
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  _tx(
                    widget.content,
                    'promotion.pay.processing',
                    'Ödəniş emal olunur…',
                  ),
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tx(
                    widget.content,
                    'promotion.pay.processing_hint',
                    'Zəhmət olmasa gözlə. Bu ekranı bağlama.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _cText2(isDark), fontSize: 13),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 18),
                  _ErrorBanner(_error!),
                  const SizedBox(height: 12),
                  _PrimaryButton(
                    label: _tx(
                      widget.content,
                      'promotion.pay.retry',
                      'Yenidən cəhd et',
                    ),
                    icon: PhosphorIconsBold.arrowClockwise,
                    onTap: _submitPayment,
                    loading: _submitting,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      _tx(
                        widget.content,
                        'promotion.payment.change_method',
                        'Ödəniş üsulunu dəyiş',
                      ),
                      style: TextStyle(
                        color: _cText2(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PromotionStatusScreen extends StatefulWidget {
  final PromotionApi api;
  final Listing listing;
  final Map<String, String> content;
  final Promotion initialPromotion;

  /// Unified payment receipt — the "Qəbz" button shows only when it's paid.
  final Receipt? receipt;

  const PromotionStatusScreen({
    super.key,
    required this.api,
    required this.listing,
    required this.content,
    required this.initialPromotion,
    this.receipt,
  });

  @override
  State<PromotionStatusScreen> createState() => _PromotionStatusScreenState();
}

class _PromotionStatusScreenState extends State<PromotionStatusScreen> {
  late Promotion _promotion = widget.initialPromotion;
  Receipt? _receipt;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final response = await widget.api.getPromotion(_promotion.id);
      if (mounted) {
        setState(() {
          _promotion = response.data;
          if (response.receipt != null) _receipt = response.receipt;
        });
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _promotion.status;
    final active = status == 'active' || status == 'pending_activation';
    final failed = status == 'failed';
    final refunded = status == 'refunded';
    final color = active
        ? (isDark ? WawatDark.success : _emerald)
        : failed || refunded
            ? (isDark ? WawatDark.danger : const Color(0xFFEF4444))
            : (isDark ? WawatDark.warning : _amber);
    final icon = active
        ? PhosphorIconsFill.check
        : failed
            ? PhosphorIconsFill.x
            : refunded
                ? PhosphorIconsFill.arrowUDownLeft
                : PhosphorIconsFill.hourglassMedium;
    final title = active
        ? _tx(widget.content, 'promotion.activated', 'Təbriklər!')
        : failed
            ? _tx(
                widget.content,
                'promotion.payment_failed',
                'Ödəniş alınmadı',
              )
            : refunded
                ? _tx(
                    widget.content,
                    'promotion.refunded_title',
                    'Məbləğ balansa qaytarıldı',
                  )
                : _tx(
                    widget.content,
                    'promotion.payment_pending',
                    'Təsdiq gözlənilir',
                  );
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 55, 24, 24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: color, size: 54),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _statusDescription(widget.content, _promotion),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _cText2(isDark),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.surfaceAlt
                      : _ink900.withValues(alpha: 0.025),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? WawatDark.border
                        : _ink900.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    _KeyValue(
                      label: _tx(
                        widget.content,
                        'promotion.status.package',
                        'Paket',
                      ),
                      value:
                          '${_promotion.typeLabel}${(_promotion.packageLabel ?? _promotion.tierLabel) == null ? '' : ' · ${_promotion.packageLabel ?? _promotion.tierLabel}'}',
                    ),
                    const SizedBox(height: 11),
                    _KeyValue(
                      label: _tx(
                        widget.content,
                        'promotion.status.status',
                        'Status',
                      ),
                      value: _promotion.statusLabel,
                    ),
                    if (_promotion.isBoost &&
                        _promotion.impressions != null) ...[
                      const SizedBox(height: 11),
                      _KeyValue(
                        label: _tx(
                          widget.content,
                          'promotion.status.impressions',
                          'Hədəf göstərişlər',
                        ),
                        value:
                            '${_promotion.impressions!.delivered}/${_promotion.impressions!.target}',
                      ),
                    ],
                    if (_promotion.endsAt != null) ...[
                      const SizedBox(height: 11),
                      _KeyValue(
                        label: _tx(
                          widget.content,
                          'promotion.status.end',
                          'Bitmə',
                        ),
                        value: _dateTime(_promotion.endsAt),
                      ),
                    ],
                    const SizedBox(height: 11),
                    _KeyValue(
                      label: _tx(
                        widget.content,
                        'promotion.status.amount',
                        'Məbləğ',
                      ),
                      value: '${_money(_promotion.amount)} \$',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!active && !failed && !refunded)
                _OutlineButton(
                  label: _refreshing
                      ? _tx(
                          widget.content,
                          'promotion.status.refreshing',
                          'Yenilənir...',
                        )
                      : _tx(
                          widget.content,
                          'promotion.status.refresh',
                          'Statusu yenilə',
                        ),
                  icon: PhosphorIconsRegular.arrowsClockwise,
                  onTap: _refreshing ? null : _refresh,
                ),
              if (failed)
                _PrimaryButton(
                  label: _tx(
                    widget.content,
                    'common.retry',
                    'Yenidən cəhd et',
                  ),
                  icon: PhosphorIconsBold.arrowClockwise,
                  onTap: () => Navigator.pop(context),
                ),
              if (active) ...[
                _PrimaryButton(
                  label: _tx(
                    widget.content,
                    'promotion.status.view_listing',
                    'Elanıma bax',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListingDetailsScreen(
                        listingId: widget.listing.id,
                        returnToHomeOnBack: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_receipt?.isPaid ?? false) ...[
                _OutlineButton(
                  label: _tx(widget.content, 'receipt.view', 'Qəbz'),
                  icon: PhosphorIconsBold.receipt,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(
                        receipt: _receipt!,
                        content: widget.content,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
                child: Text(
                  active
                      ? _tx(
                          widget.content,
                          'promotion.status.done',
                          'Bitdi',
                        )
                      : _tx(
                          widget.content,
                          'promotion.status.check_later',
                          'Sonra profildən yoxla',
                        ),
                  style: TextStyle(
                    color: _cMuted(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPromotionsScreen extends StatefulWidget {
  const MyPromotionsScreen({super.key});

  @override
  State<MyPromotionsScreen> createState() => _MyPromotionsScreenState();
}

class _MyPromotionsScreenState extends State<MyPromotionsScreen> {
  late final PromotionApi _api = PromotionApi(sl.get<Dio>());
  Map<String, String> _content = const {};
  String _tab = 'active';
  bool _loading = true;
  List<Promotion> _items = const [];
  int _activeCount = 0;
  int _expiredCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WawatContent.loadDefault().then((value) {
      if (mounted) setState(() => _content = value);
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getMyPromotions(status: 'active'),
        _api.getMyPromotions(status: 'expired'),
      ]);
      if (!mounted) return;
      final active = results[0];
      final expired = results[1];
      setState(() {
        _activeCount = active.meta?.total ?? active.data.length;
        _expiredCount = expired.meta?.total ?? expired.data.length;
        _items = _tab == 'active' ? active.data : expired.data;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _apiError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPromotion(Promotion item) async {
    final listingId = item.listingId ?? item.listing?.id;
    if (listingId == null || listingId.isEmpty) return;
    try {
      final listing =
          (await sl.get<AuthRepository>().getListingDetails(listingId)).data;
      if (!mounted) return;
      await openPromotionFlow(
        context,
        listing: listing,
        type: item.type,
        promotion: item.isExpired ? null : item,
      );
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      appBar: _simpleAppBar(
        context,
        _tx(_content, 'promotion.my_title', 'Promosyonlarım'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: _PromotionTabs(
              content: _content,
              value: _tab,
              activeCount: _activeCount,
              expiredCount: _expiredCount,
              onChanged: (value) {
                setState(() => _tab = value);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _brand),
                  )
                : _error != null
                    ? _PromotionLoadError(
                        content: _content,
                        message: _error!,
                        onRetry: _load,
                      )
                    : _items.isEmpty
                        ? _EmptyPromotions(content: _content)
                        : RefreshIndicator(
                            color: _brand,
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return _PromotionHistoryCard(
                                  content: _content,
                                  promotion: item,
                                  onTap: () => _openPromotion(item),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// Boost = pick one of three guaranteed-impressions packages (large / medium /
/// small). No tier band, no days — the listing stays boosted until it hits its
/// target impressions. When [existing] is set (an active boost), this becomes a
/// "re-buy the same package" screen: the current progress is shown on top and
/// only that package is offered (the extend endpoint always re-buys the same
/// one). Prices and guarantee ranges are always the fresh `/pricing` values.
class _BoostPackagePage extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final Map<String, String> packageNamesByCode;
  final PromotionPricing pricing;
  final Promotion? existing;
  final String? selectedPackage;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCheckout;

  const _BoostPackagePage({
    required this.listing,
    required this.content,
    required this.packageNamesByCode,
    required this.pricing,
    required this.existing,
    required this.selectedPackage,
    required this.onBack,
    required this.onChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repurchase = existing != null;
    final all = pricing.boost.packages;
    final match = all.where((p) => p.package == existing?.package).toList();
    final packages = repurchase && match.isNotEmpty ? match : all;
    final recommendedCode = all.isEmpty ? null : all.first.package;
    final selected =
        packages.where((p) => p.package == selectedPackage).firstOrNull;

    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: Column(
        children: [
          _PromotionHero(
            vip: false,
            title: repurchase
                ? _tx(content, 'promotion.cta.extend', 'Uzat')
                : _tx(content, 'promotion.cta.boost', 'Önə çək'),
            subtitle: _tx(
              content,
              'promotion.boost.packages_description',
              'Elanına zəmanətli göstəriş sayı al. Hədəf yığılana qədər önə çəkilir — gün limiti yoxdur.',
            ),
            onBack: onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              children: [
                if (repurchase) ...[
                  _ActivePromotionPanel(content: content, promotion: existing!),
                  const SizedBox(height: 18),
                ],
                _StepTitle(
                  step: repurchase ? null : 1,
                  text: _tx(
                    content,
                    'promotion.boost.choose_package',
                    'Paket seç',
                  ),
                ),
                const SizedBox(height: 12),
                for (final package in packages) ...[
                  _BoostPackageCard(
                    package: package,
                    content: content,
                    selected: package.package == selectedPackage,
                    recommended:
                        !repurchase && package.package == recommendedCode,
                    onTap: () => onChanged(package.package),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                _InfoBanner(
                  text: _tx(
                    content,
                    'promotion.boost.guaranteed_hint',
                    'Elanın hədəf göstəriş sayına çatana qədər önə çəkilir.',
                  ),
                ),
                const SizedBox(height: 12),
                _NoRefundNote(content: content),
                const SizedBox(height: 22),
                Text(
                  _tx(
                    content,
                    'promotion.preview_title',
                    'Lentdə belə görünəcək',
                  ),
                  style: TextStyle(
                    color: _cText4(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _PromotionListingPreview(
                  listing: listing,
                  content: content,
                  packageNamesByCode: packageNamesByCode,
                  promotionType: 'featured',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _StickyBottom(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected != null) ...[
              Row(
                children: [
                  Text(
                    selected.label,
                    style: TextStyle(
                      color: _cText2(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_money(selected.price)} \$',
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _PrimaryButton(
              label: repurchase && selected != null
                  ? '${_tx(content, 'promotion.cta.extend', 'Uzat')} · ${_money(selected.price)} \$'
                  : _tx(content, 'promotion.cta.checkout', 'Ödənişə keç'),
              icon: PhosphorIconsBold.arrowRight,
              iconAfter: true,
              onTap: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}

/// One guaranteed-impressions package card: name + flat price + guaranteed
/// impression range. Radio-style single select; the recommended (largest)
/// package carries a soft brand border and a "recommended" pill.
class _BoostPackageCard extends StatelessWidget {
  final PromotionBoostPackage package;
  final Map<String, String> content;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  const _BoostPackageCard({
    required this.package,
    required this.content,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = _brand;
    final brandText = isDark ? WawatDark.brandText : _brand;
    final label = package.label.isNotEmpty
        ? package.label
        : _tx(content, 'enum.promotion_package.${package.package}',
            package.package);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? accent
                : recommended
                    ? accent.withValues(alpha: 0.45)
                    : (isDark
                        ? WawatDark.border
                        : _ink900.withValues(alpha: 0.09)),
            width: selected ? 2 : (recommended ? 1.5 : 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : _cFaint(isDark),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      PhosphorIconsBold.check,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _cText(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _tx(content, 'promotion.boost.recommended',
                                'Tövsiyə'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.eye,
                          color: _cMuted(isDark), size: 15),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _tx(content, 'promotion.boost.guaranteed_label',
                              'Zəmanətli göstərişlər'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _cText2(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _impressionRange(
                            package.guaranteedMin, package.guaranteedMax),
                        style: TextStyle(
                          color: brandText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_money(package.price)} \$',
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small "payment is non-refundable" note shown under the package list — the
/// backend copy (`promotion.boost.no_refund_note`) spells out that an unmet
/// guarantee is handled manually via support.
class _NoRefundNote extends StatelessWidget {
  final Map<String, String> content;

  const _NoRefundNote({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIconsRegular.info, color: _cMuted(isDark), size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            _tx(
              content,
              'promotion.boost.no_refund_note',
              'Ödəniş geri qaytarılmır. Zəmanət yerinə yetməzsə, dəstək vasitəsilə həll olunur.',
            ),
            style: TextStyle(
              color: _cMuted(isDark),
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationPage extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final Map<String, String> packageNamesByCode;
  final bool vip;
  final String? tier;
  final Promotion? existing;
  final List<int> durations;
  final Map<int, double> prices;
  final int? selectedDuration;
  final VoidCallback onBack;
  final ValueChanged<int> onChanged;
  final VoidCallback? onCheckout;

  const _DurationPage({
    required this.listing,
    required this.content,
    required this.packageNamesByCode,
    required this.vip,
    this.tier,
    this.existing,
    required this.durations,
    required this.prices,
    required this.selectedDuration,
    required this.onBack,
    required this.onChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = vip ? _amber : _brand;
    final selectedPrice = prices[selectedDuration] ?? 0;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: Column(
        children: [
          _PromotionHero(
            vip: vip,
            title: existing != null
                ? _tx(content, 'promotion.cta.extend', 'Uzat')
                : vip
                    ? _tx(content, 'promotion.cta.vip', 'VİP et')
                    : '${_tx(content, 'promotion.cta.boost', 'Önə çək')} · ${_tierLabel(tier, content)}',
            subtitle: vip
                ? _tx(
                    content,
                    'promotion.vip_description',
                    'Elanın lentin ən yuxarısında, ayrıca «VİP elanlar» bölməsində görünəcək.',
                  )
                : _tx(
                    content,
                    'promotion.boost_description',
                    'Elanın seçdiyin mövqe zolağında görünəcək.',
                  ),
            onBack: onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              children: [
                if (existing != null) ...[
                  _ActivePromotionPanel(
                    content: content,
                    promotion: existing!,
                  ),
                  const SizedBox(height: 18),
                ],
                _StepTitle(
                  step: vip ? null : 2,
                  text: existing != null
                      ? _tx(
                          content,
                          'promotion.step.extend_duration',
                          'Müddəti artır',
                        )
                      : _tx(
                          content,
                          'promotion.step.duration',
                          'Müddət seç',
                        ),
                  color: accent,
                ),
                const SizedBox(height: 12),
                for (final duration in durations) ...[
                  _SelectionCard(
                    selected: selectedDuration == duration,
                    accent: accent,
                    title:
                        '${existing == null ? '' : '+'}${_formatContent(content, 'promotion.duration_template', '{days} gün', {
                          'days': duration
                        })}',
                    subtitle: duration == 7
                        ? _tx(
                            content,
                            'promotion.duration.popular',
                            'Populyar seçim',
                          )
                        : duration == 1
                            ? _tx(
                                content,
                                'promotion.duration.short_trial',
                                'Qısa sınaq',
                              )
                            : _tx(
                                content,
                                'promotion.duration.best_value',
                                'Ən sərfəli paket',
                              ),
                    value: '${_money(prices[duration] ?? 0)} \$',
                    onTap: () => onChanged(duration),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                if (vip)
                  _BenefitCard(
                    title: _tx(
                      content,
                      'promotion.vip_benefits_title',
                      'VİP nə qazandırır?',
                    ),
                    color: _amber,
                    items: [
                      _tx(
                        content,
                        'promotion.vip_benefit.section',
                        'Ayrıca «VİP elanlar» bölməsində üst sıra',
                      ),
                      _tx(
                        content,
                        'promotion.vip_benefit.badge',
                        'Tac nişanı və qızılı çərçivə',
                      ),
                      _tx(
                        content,
                        'promotion.vip_benefit.views',
                        'Orta hesabla daha çox baxış',
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Text(
                  _tx(
                    content,
                    'promotion.preview_title',
                    'Lentdə belə görünəcək',
                  ),
                  style: TextStyle(
                    color: _cText4(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _PromotionListingPreview(
                  listing: listing,
                  content: content,
                  packageNamesByCode: packageNamesByCode,
                  promotionType: vip ? 'vip' : 'featured',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PromotionPurchaseBottomBar(
        content: content,
        vip: vip,
        tier: tier,
        existing: existing != null,
        selectedDuration: selectedDuration,
        selectedPrice: selectedPrice,
        onCheckout: onCheckout,
      ),
    );
  }
}

class _PromotionPurchaseBottomBar extends StatelessWidget {
  final Map<String, String> content;
  final bool vip;
  final String? tier;
  final bool existing;
  final int? selectedDuration;
  final double selectedPrice;
  final VoidCallback? onCheckout;

  const _PromotionPurchaseBottomBar({
    required this.content,
    required this.vip,
    required this.tier,
    required this.existing,
    required this.selectedDuration,
    required this.selectedPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final days = selectedDuration?.toString() ?? '-';
    final summary = vip
        ? _formatContent(
            content,
            'promotion.summary.vip_template',
            '{days} gün VİP',
            {'days': days},
          )
        : _formatContent(
            content,
            'promotion.summary.boost_template',
            '{tier} · {days} gün',
            {
              'tier': _tierLabel(tier, content),
              'days': days,
            },
          );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _StickyBottom(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${existing ? '+' : ''}$summary',
                style: TextStyle(
                  color: _cText2(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${_money(selectedPrice)} \$',
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PrimaryButton(
            label: existing
                ? '${_tx(content, 'promotion.cta.extend', 'Uzat')} · ${_money(selectedPrice)} \$'
                : _tx(
                    content,
                    'promotion.cta.checkout',
                    'Ödənişə keç',
                  ),
            icon: PhosphorIconsBold.arrowRight,
            iconAfter: true,
            amber: vip,
            onTap: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _PromotionListingPreview extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final Map<String, String> packageNamesByCode;
  final String promotionType;

  const _PromotionListingPreview({
    required this.listing,
    required this.content,
    required this.packageNamesByCode,
    required this.promotionType,
  });

  void _showFullPreview(BuildContext context, bool isDark) {
    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            decoration: BoxDecoration(
              color: _cScreen(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _cFaint(isDark),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 13, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tx(
                            content,
                            'promotion.preview_full_title',
                            'Elanın lentdə görünüşü',
                          ),
                          style: TextStyle(
                            color: _cText(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(sheetContext),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            PhosphorIconsBold.x,
                            color: _cText4(isDark),
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IgnorePointer(
                      child: ListingCard(
                        listing: listing,
                        packageNamesByCode: packageNamesByCode,
                        promotionTypeOverride: promotionType,
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        isCompact: false,
                        onFavoriteChanged: (_, __) async {},
                        onOfferTap: (_) {},
                        onMessageTap: (_) {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        IgnorePointer(
          child: ListingCard(
            listing: listing,
            packageNamesByCode: packageNamesByCode,
            promotionTypeOverride: promotionType,
            margin: EdgeInsets.zero,
            isCompact: true,
            onDetailsTap: (_) {},
            onFavoriteChanged: (_, __) async {},
            onOfferTap: (_) {},
            onMessageTap: (_) {},
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showFullPreview(context, isDark),
          ),
        ),
      ],
    );
  }
}

class _PromotionHero extends StatelessWidget {
  final bool vip;
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _PromotionHero({
    required this.vip,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        24,
      ),
      decoration: BoxDecoration(
        gradient: vip
            ? const LinearGradient(
                colors: [Color(0xFFFDE68A), Color(0xFFFBBF24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF0F7BF4), Color(0xFF0257AE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    PhosphorIconsBold.arrowLeft,
                    color: vip ? _ink900 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                vip
                    ? PhosphorIconsFill.crownSimple
                    : PhosphorIconsFill.rocketLaunch,
                color: vip ? _ink900 : Colors.white,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: vip ? _ink900 : Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            subtitle,
            style: TextStyle(
              color: vip ? _ink700 : Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpsellCard extends StatelessWidget {
  final Map<String, String> content;
  final bool vip;
  final String title;
  final String subtitle;
  final double? price;
  final VoidCallback? onTap;

  const _UpsellCard({
    required this.content,
    required this.vip,
    required this.title,
    required this.subtitle,
    this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = vip ? _amber : _brand;
    final soft = vip
        ? (isDark ? WawatDark.warning.withValues(alpha: 0.12) : _amber50)
        : _cBrandSoft(isDark);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  vip
                      ? PhosphorIconsFill.crownSimple
                      : PhosphorIconsFill.rocketLaunch,
                  color: vip ? _ink900 : Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _cText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: vip
                            ? (isDark
                                ? WawatDark.warning
                                : const Color(0xFFB45309))
                            : (isDark ? WawatDark.brandText : _brand),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _tx(
                      content,
                      'promotion.starting_from',
                      'başlanğıc',
                    ),
                    style: TextStyle(color: _cMuted(isDark), fontSize: 10),
                  ),
                  Text(
                    price == null ? '...' : '${_money(price!)} \$',
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PrimaryButton(
            label: title,
            icon: PhosphorIconsBold.arrowRight,
            amber: vip,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final bool selected;
  final Color accent;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.selected,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : _cCard(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? accent
                : (isDark ? WawatDark.border : _ink900.withValues(alpha: 0.09)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : _cFaint(isDark),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      PhosphorIconsBold.check,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: _cText2(isDark), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  final Listing listing;

  const _RoutePreview({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.06),
        ),
      ),
      child: _RouteLine(
        from: listing.cityFrom ?? '-',
        to: listing.cityTo ?? '-',
        trip: listing.isTrip,
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String from;
  final String to;
  final bool trip;

  const _RouteLine({
    required this.from,
    required this.to,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            from,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _cBrandSoft(isDark),
            shape: BoxShape.circle,
          ),
          child: Icon(
            trip ? PhosphorIconsFill.airplaneTilt : PhosphorIconsFill.package,
            color: isDark ? WawatDark.brandText : _brand,
            size: 20,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            to,
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  final Listing listing;
  final bool vip;
  final bool boost;
  final String? packageLabel;
  final int? guaranteedMin;
  final int? guaranteedMax;

  /// VIP duration in days — null for boost.
  final int? duration;
  final Map<String, String> content;

  const _CheckoutSummaryCard({
    required this.listing,
    required this.vip,
    this.boost = false,
    this.packageLabel,
    this.guaranteedMin,
    this.guaranteedMax,
    this.duration,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeLabel = listing.typeLabel ??
        (listing.isTrip
            ? WawatContent.text(
                content,
                'enum.listing_type.trip',
                'Səfər',
              )
            : WawatContent.text(
                content,
                'enum.listing_type.shipment_post',
                'Göndəriş',
              ));
    final title = vip
        ? _tx(content, 'promotion.checkout.vip_title', 'VİP promosyon')
        : _formatContent(
            content,
            'promotion.checkout.boost_title_template',
            'Önə çək · {tier}',
            {
              'tier': packageLabel ??
                  _tx(content, 'enum.promotion_type.featured', 'Önə çıxarılan')
            },
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(isDark),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: vip ? _amber : _brand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  vip
                      ? PhosphorIconsFill.crownSimple
                      : PhosphorIconsFill.rocketLaunch,
                  color: vip ? _ink900 : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _cText(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${listing.cityFrom ?? '-'} → ${listing.cityTo ?? '-'} · $typeLabel',
                      style: TextStyle(
                        color: _cText2(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _cLine(isDark),
                ),
              ),
            ),
            child: Column(
              children: [
                _CheckoutRow(
                  label: _tx(
                    content,
                    'promotion.checkout.package',
                    'Paket',
                  ),
                  value: boost
                      ? (packageLabel ??
                          _tx(content, 'enum.promotion_type.featured',
                              'Önə çıxarılan'))
                      : _tx(content, 'enum.promotion_type.vip', 'VİP'),
                ),
                // Boost = guaranteed impressions, no days/start/end. VIP keeps
                // the duration + start + end summary.
                if (boost)
                  _CheckoutRow(
                    label: _tx(
                      content,
                      'promotion.boost.guaranteed_label',
                      'Zəmanətli göstərişlər',
                    ),
                    value: _impressionRange(guaranteedMin, guaranteedMax),
                  )
                else ...[
                  _CheckoutRow(
                    label: _tx(
                      content,
                      'promotion.checkout.duration',
                      'Müddət',
                    ),
                    value: _formatContent(
                      content,
                      'promotion.duration_template',
                      '{days} gün',
                      {'days': duration ?? 0},
                    ),
                  ),
                  _CheckoutRow(
                    label: _tx(
                      content,
                      'promotion.checkout.start',
                      'Başlama',
                    ),
                    value: _tx(
                      content,
                      'promotion.checkout.starts_after_approval',
                      'Təsdiqdən dərhal sonra',
                    ),
                  ),
                  _CheckoutRow(
                    label: _tx(
                      content,
                      'promotion.checkout.end',
                      'Bitmə',
                    ),
                    value: MaterialLocalizations.of(context).formatMediumDate(
                      DateTime.now().add(Duration(days: duration ?? 0)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  const _PaymentOption({
    required this.selected,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBackground,
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = iconBackground ?? (isDark ? WawatDark.elevated : _ink900);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _brand
                : (isDark ? WawatDark.border : _ink900.withValues(alpha: 0.07)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _brand.withValues(alpha: 0.15),
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: _cMuted(isDark),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? _brand : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _brand : _cFaint(isDark),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      PhosphorIconsBold.check,
                      color: Colors.white,
                      size: 11,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentIntegrationBanner extends StatelessWidget {
  final String text;

  const _PaymentIntegrationBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.warning.withValues(alpha: 0.12) : _amber50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIconsFill.wrench,
            color: isDark ? WawatDark.warning : const Color(0xFFB67C00),
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? WawatDark.warning : const Color(0xFF8A5D00),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final bool topBorder;
  final Color? valueColor;

  const _CheckoutRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.topBorder = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        top: topBorder ? 10 : 8,
        bottom: 8,
      ),
      decoration: topBorder
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _cLine(isDark),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasized ? _cText(isDark) : _cText2(isDark),
                fontSize: 14,
                fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? _cText(isDark),
              fontSize: emphasized ? 18 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionHistoryCard extends StatelessWidget {
  final Map<String, String> content;
  final Promotion promotion;
  final VoidCallback onTap;

  const _PromotionHistoryCard({
    required this.content,
    required this.promotion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vip = promotion.isVip;
    final accent = vip ? _amber : _brand;
    final route = promotion.listing == null
        ? _formatContent(
            content,
            'promotion.listing_template',
            'Elan #{id}',
            {'id': promotion.listingId?.substring(0, 6) ?? '-'},
          )
        : '${promotion.listing?.cityFrom ?? '-'} → ${promotion.listing?.cityTo ?? '-'}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCard(isDark, radius: 18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  vip
                      ? PhosphorIconsFill.crownSimple
                      : PhosphorIconsFill.rocketLaunch,
                  color: vip ? _ink900 : Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vip ? _tx(content, 'enum.promotion_type.vip', 'VİP') : promotion.packageLabel ?? promotion.tierLabel ?? promotion.typeLabel} · $route',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _cText(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_promotionMetaLabel(promotion, content)} · ${_money(promotion.amount)} \$',
                      style: TextStyle(color: _cMuted(isDark), fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                // Extra transparent margin around the chip → a comfortable,
                // reliable tap target (the bare chip was easy to miss).
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 68, minHeight: 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      promotion.isExpired
                          ? _tx(
                              content,
                              'promotion.action.renew',
                              'Yenilə',
                            )
                          : _tx(
                              content,
                              'promotion.action.extend',
                              'Uzat',
                            ),
                      style: TextStyle(
                        color: vip ? _ink900 : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!promotion.isExpired) ...[
            const SizedBox(height: 11),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: _progressValue(promotion),
                color: accent,
                backgroundColor: isDark
                    ? WawatDark.surfaceAlt
                    : _ink900.withValues(alpha: 0.06),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromotionTabs extends StatelessWidget {
  final Map<String, String> content;
  final String value;
  final int activeCount;
  final int expiredCount;
  final ValueChanged<String> onChanged;

  const _PromotionTabs({
    required this.content,
    required this.value,
    required this.activeCount,
    required this.expiredCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cFill(isDark),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tab(
            isDark,
            'active',
            _formatContent(
              content,
              'promotion.tabs.active_template',
              'Aktiv ({count})',
              {'count': activeCount},
            ),
          ),
          _tab(
            isDark,
            'expired',
            _formatContent(
              content,
              'promotion.tabs.expired_template',
              'Bitmiş ({count})',
              {'count': expiredCount},
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(bool isDark, String itemValue, String label) {
    final selected = value == itemValue;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(itemValue),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? WawatDark.elevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected && !isDark
                ? [
                    BoxShadow(
                      color: _ink900.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? (isDark ? WawatDark.brandText : _brand)
                  : _cText2(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPromotions extends StatelessWidget {
  final Map<String, String> content;

  const _EmptyPromotions({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: _cBrandSoft(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsFill.rocketLaunch,
                color: isDark ? WawatDark.brandText : _brand,
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _tx(
                content,
                'promotion.empty',
                'Bu bölmədə promosyon yoxdur.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cText2(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionLoadError extends StatelessWidget {
  final Map<String, String> content;
  final String message;
  final VoidCallback onRetry;

  const _PromotionLoadError({
    required this.content,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ErrorBanner(message),
            const SizedBox(height: 12),
            _OutlineButton(
              label: _tx(content, 'common.retry', 'Yenidən cəhd et'),
              icon: PhosphorIconsRegular.arrowsClockwise,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivePromotionPanel extends StatelessWidget {
  final Map<String, String> content;
  final Promotion promotion;

  const _ActivePromotionPanel({
    required this.content,
    required this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vip = promotion.isVip;
    final color = vip ? _amber : _brand;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: vip
            ? (isDark ? WawatDark.warning.withValues(alpha: 0.12) : _amber50)
            : _cBrandSoft(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(
              vip
                  ? PhosphorIconsFill.crownSimple
                  : PhosphorIconsFill.rocketLaunch,
              color: vip ? _ink900 : Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            _formatContent(
              content,
              'promotion.active_template',
              '{type} artıq aktivdir',
              {'type': promotion.typeLabel},
            ),
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _promotionMetaLabel(promotion, content),
            style: TextStyle(color: _cText3(isDark), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: _progressValue(promotion),
              color: color,
              backgroundColor: isDark ? WawatDark.elevated : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;

  const _BenefitCard({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    color: color,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: _cText3(isDark),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final int? step;
  final String text;
  final Color color;

  const _StepTitle({
    this.step,
    required this.text,
    this.color = _brand,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Кружок-номер остаётся бренд/amber ЗАЛИВКОЙ; подпись как ТЕКСТ должна быть
    // читаемой на тёмном (brandText / warning), light-ветку не трогаем.
    final Color labelColor = isDark
        ? (color == _amber ? WawatDark.warning : WawatDark.brandText)
        : color;
    return Row(
      children: [
        if (step != null) ...[
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandText = isDark ? WawatDark.brandText : _brand;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _cBrandSoft(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _brand.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.info, color: brandText, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: brandText,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;

  const _ErrorBanner(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark
            ? WawatDark.danger.withValues(alpha: 0.14)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsFill.warningCircle,
            color: isDark ? WawatDark.danger : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? WawatDark.danger : const Color(0xFFDC2626),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _cText2(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: _cText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool amber;
  final bool iconAfter;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.amber = false,
    this.iconAfter = false,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = amber ? _ink900 : Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Opacity(
        opacity: onTap == null && !loading ? 0.5 : 1,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: amber ? _amber : _brand,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (amber ? const Color(0xFFE8A400) : _brand)
                    .withValues(alpha: 0.34),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: loading
              ? SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null && !iconAfter) ...[
                      Icon(icon, color: foreground, size: 19),
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (icon != null && iconAfter) ...[
                      const SizedBox(width: 7),
                      Icon(icon, color: foreground, size: 19),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _OutlineButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: _cText4(isDark), size: 19),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                color: _cText4(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyBottom extends StatelessWidget {
  final Widget child;

  const _StickyBottom({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          border: Border(
            top: BorderSide(color: _cLine(isDark)),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: const Center(child: CircularProgressIndicator(color: _brand)),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorPage({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsFill.warningCircle,
                  color: isDark ? WawatDark.danger : const Color(0xFFEF4444),
                  size: 56,
                ),
                const SizedBox(height: 14),
                Text(
                  WawatContent.text(
                    const {},
                    'promotion.error.load',
                    'Məlumatları yükləmək alınmadı.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _PrimaryButton(
                  label: WawatContent.text(
                    const {},
                    'common.retry',
                    'Yenidən cəhd et',
                  ),
                  onTap: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<_PromotionBundle> _loadPromotionBundle() async {
  final api = PromotionApi(sl.get<Dio>());
  final results = await Future.wait([
    api.getPricing(),
    WawatContent.loadDefault(),
    _loadPackageNames(),
  ]);
  return _PromotionBundle(
    pricing: (results[0] as PromotionPricingResponse).data,
    content: results[1] as Map<String, String>,
    packageNamesByCode: results[2] as Map<String, String>,
  );
}

Future<Map<String, String>> _loadPackageNames() async {
  try {
    final response = await sl.get<AuthRepository>().getListingPackageTypes();
    return {
      for (final item in response.data) item.code: item.name,
    };
  } catch (_) {
    return const {};
  }
}

class _PromotionBundle {
  final PromotionPricing pricing;
  final Map<String, String> content;
  final Map<String, String> packageNamesByCode;
  final Promotion? existingPromotion;

  const _PromotionBundle({
    required this.pricing,
    required this.content,
    this.packageNamesByCode = const {},
    this.existingPromotion,
  });
}

PreferredSizeWidget _simpleAppBar(BuildContext context, String title) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    backgroundColor: _cCard(isDark),
    elevation: 0,
    surfaceTintColor: _cCard(isDark),
    leading: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Icon(
        PhosphorIconsBold.arrowLeft,
        color: _cText4(isDark),
        size: 20,
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: _cText(isDark),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

BoxDecoration _whiteCard(bool isDark, {double radius = 24}) {
  return BoxDecoration(
    color: _cCard(isDark),
    borderRadius: BorderRadius.circular(radius),
    border: isDark
        ? Border.all(color: WawatDark.border)
        : Border.all(color: _ink900.withValues(alpha: 0.06)),
    boxShadow: isDark
        ? null
        : [
            BoxShadow(
              color: _ink900.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
  );
}

String _tx(Map<String, String> content, String key, String fallback) {
  return WawatContent.text(content, key, fallback);
}

String _formatContent(
  Map<String, String> content,
  String key,
  String fallback,
  Map<String, Object?> values,
) {
  var text = _tx(content, key, fallback);
  for (final entry in values.entries) {
    text = text.replaceAll('{${entry.key}}', entry.value?.toString() ?? '');
  }
  return text;
}

String _tierLabel(
  String? tier, [
  Map<String, String> content = const {},
]) {
  return switch (tier) {
    'top10' => _tx(content, 'promotion.tier.top10', 'İlk 10'),
    'top50' => _tx(content, 'promotion.tier.top50', 'İlk 50'),
    'top100' => _tx(content, 'promotion.tier.top100', 'İlk 100'),
    _ => _tx(
        content,
        'enum.promotion_type.featured',
        'Önə çıxarılan',
      ),
  };
}

String _money(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(
        RegExp(r'\.$'),
        '',
      );
}

/// Guaranteed-impressions range shown on package cards / checkout, e.g.
/// `410–510`. Collapses to a single number if min == max.
String _impressionRange(int? min, int? max) {
  final lo = min ?? 0;
  final hi = max ?? 0;
  if (hi <= 0 && lo <= 0) return '—';
  if (hi <= lo) return '$lo';
  return '$lo–$hi';
}

/// Progress fraction (0..1) for a promotion's progress bar. Boost uses the
/// server impression percent; VIP falls back to elapsed-time progress.
double _progressValue(Promotion promotion) {
  final impressions = promotion.impressions;
  if (promotion.isBoost && impressions != null) {
    return (impressions.percent / 100).clamp(0.0, 1.0);
  }
  return _promotionProgress(promotion);
}

/// Meta line under a promotion's route on the "My promotions" card / active
/// panel. Boost shows delivered-of-target impressions; VIP shows time left.
String _promotionMetaLabel(Promotion promotion, Map<String, String> content) {
  final impressions = promotion.impressions;
  if (promotion.isBoost && impressions != null) {
    return '${_tx(content, 'promotion.boost.progress_label', 'Göstərilib')} '
        '${impressions.delivered}/${impressions.target}';
  }
  return _remainingLabel(promotion, content);
}

String _dateTime(String? raw) {
  final date = DateTime.tryParse(raw ?? '')?.toLocal();
  if (date == null) return '-';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day.$month.${date.year} · $hour:$minute';
}

String _remainingLabel(
  Promotion promotion,
  Map<String, String> content,
) {
  if (promotion.isExpired) {
    return _tx(
      content,
      'promotion.remaining.expired',
      'Müddəti bitib',
    );
  }
  var seconds = promotion.remainingSeconds;
  if (seconds <= 0 && promotion.endsAt != null) {
    final end = DateTime.tryParse(promotion.endsAt!)?.toLocal();
    if (end != null) seconds = end.difference(DateTime.now()).inSeconds;
  }
  if (seconds <= 0) return promotion.statusLabel;
  final days = seconds ~/ 86400;
  final hours = (seconds % 86400) ~/ 3600;
  if (days > 0) {
    return _formatContent(
      content,
      'promotion.remaining.days_template',
      '{days} gün {hours} saat qalıb',
      {'days': days, 'hours': hours},
    );
  }
  return _formatContent(
    content,
    'promotion.remaining.hours_template',
    '{hours} saat qalıb',
    {'hours': hours},
  );
}

double _promotionProgress(Promotion promotion) {
  if (promotion.startsAt == null || promotion.endsAt == null) return 0.5;
  final start = DateTime.tryParse(promotion.startsAt!)?.toLocal();
  final end = DateTime.tryParse(promotion.endsAt!)?.toLocal();
  if (start == null || end == null) return 0.5;
  final total = end.difference(start).inSeconds;
  if (total <= 0) return 1;
  final elapsed = DateTime.now().difference(start).inSeconds;
  return (elapsed / total).clamp(0.0, 1.0);
}

String _statusDescription(
  Map<String, String> content,
  Promotion promotion,
) {
  return switch (promotion.status) {
    'active' => promotion.isVip
        ? _tx(
            content,
            'promotion.status.active_vip',
            'Elanın indi VİP-dir və lentin ən yuxarısında görünəcək.',
          )
        : _tx(
            content,
            'promotion.status.active_boost',
            'Elanın indi önə çəkilir və zəmanətli göstərişlər toplayır.',
          ),
    'pending_activation' => _tx(
        content,
        'promotion.pending_activation_note',
        'Elan təsdiqlənən kimi promosyon avtomatik aktivləşəcək.',
      ),
    'failed' => _tx(
        content,
        'promotion.status.failed',
        'Kartından məbləğ tutulmadı. Yenidən cəhd edə bilərsən.',
      ),
    'refunded' => _tx(
        content,
        'promotion.refunded_to_balance',
        'Məbləğ Wawatair balansına qaytarıldı.',
      ),
    _ => _tx(
        content,
        'promotion.status.pending',
        'Bankın və ya ödəniş provayderinin təsdiqini gözləyirik. Nəticə hazır olanda bildiriş alacaqsan.',
      ),
  };
}

String _apiError(Object error) {
  if (error is StateError) {
    final message = error.message.toString();
    if (message.trim().isNotEmpty) return message;
  }
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }
  }
  return WawatContent.text(
    const {},
    'promotion.error.generic',
    'Əməliyyat alınmadı. Yenidən cəhd et.',
  );
}

/// Human message for a quote's `applicable:false` reason code. Falls back to the
/// generic "not applied" text for unknown/`null` reasons so a code never silently
/// looks accepted.
String _promoReasonText(Map<String, String> content, String? reason) {
  switch (reason) {
    case 'invalid':
      return _tx(content, 'promo.reason.invalid',
          'Promokod yanlışdır, artıq istifadə olunub və ya vaxtı keçib.');
    case 'below_min_order':
      return _tx(content, 'promo.reason.below_min_order',
          'Sifariş məbləği bu promokod üçün minimuma çatmır.');
    case 'currency_mismatch':
      return _tx(content, 'promo.reason.currency_mismatch',
          'Promokod başqa valyutadadır.');
    case 'feature_disabled':
      return _tx(content, 'promo.reason.feature_disabled',
          'Promokodlar müvəqqəti olaraq deaktivdir.');
    case 'listing_not_active':
      return _tx(content, 'promo.reason.listing_not_active',
          'Elan aktiv olmadığı üçün promokod tətbiq olunmur.');
    case 'no_promo_code':
      return _tx(content, 'promo.reason.no_promo_code', 'Promokod daxil edin.');
    default:
      return _tx(content, 'promo.reason.generic', 'Promokod tətbiq olunmadı.');
  }
}

bool _isResolvedPromotionStatus(String status) {
  return status == 'active' ||
      status == 'pending_activation' ||
      status == 'failed' ||
      status == 'refunded' ||
      status == 'canceled' ||
      status == 'expired';
}

extension _IterableMin on Iterable<double> {
  double? get minOrNull {
    if (isEmpty) return null;
    return reduce((a, b) => a < b ? a : b);
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
