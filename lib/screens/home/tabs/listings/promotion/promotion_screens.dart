import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../data/network/api/promotion_api.dart';
import '../../../../../data/network/request/promotion_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/promotion_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
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
                      'İlk 10 / 50 / 100 mövqe',
                    ),
                    price: pricing?.boost.tiers
                        .expand((tier) => tier.prices.values)
                        .minOrNull,
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
  String? _selectedTier;
  int? _selectedDuration;
  int _step = 0;

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
    if (widget.initialType == 'featured' &&
        base.pricing.boost.tiers.isNotEmpty) {
      _selectedTier = existing?.tier ?? base.pricing.boost.tiers.first.tier;
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
        final isVip = widget.initialType == 'vip';
        final existing = bundle.existingPromotion;
        final isExtension = existing != null;
        if (!isVip && _step == 0 && !isExtension) {
          return _BoostTierPage(
            listing: widget.listing,
            content: bundle.content,
            pricing: bundle.pricing,
            selectedTier: _selectedTier,
            onBack: () => Navigator.pop(context),
            onChanged: (value) => setState(() => _selectedTier = value),
            onContinue:
                _selectedTier == null ? null : () => setState(() => _step = 1),
          );
        }
        final prices = isVip
            ? bundle.pricing.vip.prices
            : bundle.pricing.boost.tiers
                    .where((item) => item.tier == _selectedTier)
                    .firstOrNull
                    ?.prices ??
                const <int, double>{};
        return _DurationPage(
          listing: widget.listing,
          content: bundle.content,
          packageNamesByCode: bundle.packageNamesByCode,
          vip: isVip,
          tier: _selectedTier,
          existing: existing,
          durations: bundle.pricing.durations,
          prices: prices,
          selectedDuration: _selectedDuration,
          onBack: () {
            if (!isVip && !isExtension && _step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.pop(context);
            }
          },
          onChanged: (value) => setState(() => _selectedDuration = value),
          onCheckout: _selectedDuration == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PromotionCheckoutScreen(
                        api: _api,
                        listing: widget.listing,
                        content: bundle.content,
                        type: widget.initialType,
                        tier: _selectedTier,
                        duration: _selectedDuration!,
                        amount: prices[_selectedDuration] ?? 0,
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
  final String? tier;
  final int duration;
  final double amount;
  final String currency;
  final Promotion? existingPromotion;

  const _PromotionCheckoutScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.type,
    this.tier,
    required this.duration,
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

  @override
  void dispose() {
    _promoCode.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = widget.existingPromotion == null
          ? await widget.api.createPromotion(
              widget.listing.id,
              PromotionRequest(
                type: widget.type,
                tier: widget.type == 'featured' ? widget.tier : null,
                durationDays: widget.duration,
                promoCode: _promoCode.text,
              ),
              idempotencyKey:
                  'promotion-${DateTime.now().microsecondsSinceEpoch}',
            )
          : await widget.api.extendPromotion(
              widget.existingPromotion!.id,
              PromotionExtendRequest(durationDays: widget.duration),
              idempotencyKey:
                  'promotion-extend-${DateTime.now().microsecondsSinceEpoch}',
            );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentMethodScreen(
            api: widget.api,
            listing: widget.listing,
            content: widget.content,
            promotion: response.data,
          ),
        ),
      );
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
            tier: widget.tier,
            duration: widget.duration,
            content: widget.content,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _whiteCard(isDark),
            child: Row(
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
                Container(
                  height: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _cFill(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _tx(widget.content, 'promotion.apply', 'Tətbiq et'),
                    style: TextStyle(
                      color: _cText4(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _whiteCard(isDark),
            child: Column(
              children: [
                _CheckoutRow(
                  label:
                      '${vip ? _tx(widget.content, 'enum.promotion_type.vip', 'VİP') : _tierLabel(widget.tier, widget.content)} · ${_formatContent(widget.content, 'promotion.duration_template', '{days} gün', {
                        'days': widget.duration
                      })}',
                  value: '${widget.amount.toStringAsFixed(2)} ₼',
                ),
                _CheckoutRow(
                  label: _tx(
                    widget.content,
                    'promotion.checkout.discount',
                    'Endirim',
                  ),
                  value: '0.00 ₼',
                  valueColor: isDark ? WawatDark.success : _emerald,
                ),
                _CheckoutRow(
                  label: _tx(widget.content, 'promotion.total', 'Yekun'),
                  value: '${widget.amount.toStringAsFixed(2)} ₼',
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
          label: _loading
              ? _tx(widget.content, 'common.wait', 'Gözləyin...')
              : '${_tx(widget.content, 'promotion.cta.checkout', 'Ödənişə keç')} · ${_money(widget.amount)} ₼',
          icon: PhosphorIconsBold.arrowRight,
          iconAfter: true,
          onTap: _loading ? null : _continue,
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

  const _PaymentMethodScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.promotion,
  });

  @override
  State<_PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<_PaymentMethodScreen> {
  String _method = 'card';
  bool _openingPayment = false;

  Future<void> _pay() async {
    if (_openingPayment) return;
    setState(() => _openingPayment = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PromotionProcessingScreen(
          api: widget.api,
          listing: widget.listing,
          content: widget.content,
          promotion: widget.promotion,
          method: _method,
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
            'Ödə · {amount} ₼',
            {'amount': _money(widget.promotion.amount)},
          ),
          icon: PhosphorIconsFill.lockSimple,
          onTap: _openingPayment ? null : _pay,
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

  const _PromotionProcessingScreen({
    required this.api,
    required this.listing,
    required this.content,
    required this.promotion,
    required this.method,
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
      var promotion = (await widget.api.payPromotion(
        widget.promotion.id,
        PromotionPayRequest(method: widget.method),
        idempotencyKey: _idempotencyKey,
      ))
          .data;

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
          promotion = await _pollProviderResult(promotion);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PromotionStatusScreen(
            api: widget.api,
            listing: widget.listing,
            content: widget.content,
            initialPromotion: promotion,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _apiError(error);
      });
    }
  }

  Future<Promotion> _pollProviderResult(Promotion promotion) async {
    var current = promotion;
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      try {
        current = (await widget.api.getPromotion(current.id)).data;
      } catch (_) {
        continue;
      }
      if (_isResolvedPromotionStatus(current.status)) break;
    }
    return current;
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
                    onTap: _submitting ? null : _submitPayment,
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

  const PromotionStatusScreen({
    super.key,
    required this.api,
    required this.listing,
    required this.content,
    required this.initialPromotion,
  });

  @override
  State<PromotionStatusScreen> createState() => _PromotionStatusScreenState();
}

class _PromotionStatusScreenState extends State<PromotionStatusScreen> {
  late Promotion _promotion = widget.initialPromotion;
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final response = await widget.api.getPromotion(_promotion.id);
      if (mounted) setState(() => _promotion = response.data);
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
                          '${_promotion.typeLabel}${_promotion.tierLabel == null ? '' : ' · ${_promotion.tierLabel}'}',
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
                      value: '${_money(_promotion.amount)} ₼',
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

class _BoostTierPage extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final PromotionPricing pricing;
  final String? selectedTier;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback? onContinue;

  const _BoostTierPage({
    required this.listing,
    required this.content,
    required this.pricing,
    required this.selectedTier,
    required this.onBack,
    required this.onChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultDuration =
        pricing.durations.contains(7) ? 7 : pricing.durations.firstOrNull;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: Column(
        children: [
          _PromotionHero(
            vip: false,
            title: _tx(content, 'promotion.cta.boost', 'Önə çək'),
            subtitle: _tx(
              content,
              'promotion.boost_description',
              'Elanın axtarış və lentdə seçdiyin mövqe zolağında görünəcək.',
            ),
            onBack: onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 105),
              children: [
                _StepTitle(
                  step: 1,
                  text: _tx(
                    content,
                    'promotion.step.position',
                    'Mövqe zolağını seç',
                  ),
                ),
                const SizedBox(height: 12),
                for (final tier in pricing.boost.tiers) ...[
                  _SelectionCard(
                    selected: tier.tier == selectedTier,
                    accent: _brand,
                    title: tier.label,
                    subtitle: _formatContent(
                      content,
                      'promotion.position_description_template',
                      'Nəticələrin ilk {count}-liyində daha çox baxış',
                      {'count': tier.positionLimit},
                    ),
                    value: defaultDuration == null
                        ? ''
                        : '${_money(tier.prices[defaultDuration] ?? 0)} ₼',
                    onTap: () => onChanged(tier.tier),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                _InfoBanner(
                  text: _tx(
                    content,
                    'promotion.tier_note',
                    'VİP elanlar həmişə önə çəkilmiş elanların da üstündədir.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _StickyBottom(
        child: _PrimaryButton(
          label: _tx(
            content,
            'promotion.cta.continue_duration',
            'Davam et — müddət seç',
          ),
          icon: PhosphorIconsBold.arrowRight,
          iconAfter: true,
          onTap: onContinue,
        ),
      ),
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
                    value: '${_money(prices[duration] ?? 0)} ₼',
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
                '${_money(selectedPrice)} ₼',
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
                ? '${_tx(content, 'promotion.cta.extend', 'Uzat')} · ${_money(selectedPrice)} ₼'
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
    showModalBottomSheet<void>(
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
                    price == null ? '...' : '${_money(price!)} ₼',
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
  final String? tier;
  final int duration;
  final Map<String, String> content;

  const _CheckoutSummaryCard({
    required this.listing,
    required this.vip,
    this.tier,
    required this.duration,
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
    final endDate = MaterialLocalizations.of(context).formatMediumDate(
      DateTime.now().add(Duration(days: duration)),
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
                      vip
                          ? _tx(
                              content,
                              'promotion.checkout.vip_title',
                              'VİP promosyon',
                            )
                          : _formatContent(
                              content,
                              'promotion.checkout.boost_title_template',
                              'Önə çək · {tier}',
                              {'tier': _tierLabel(tier, content)},
                            ),
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
                  value: vip
                      ? _tx(content, 'enum.promotion_type.vip', 'VİP')
                      : _tierLabel(tier, content),
                ),
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
                    {'days': duration},
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
                  value: endDate,
                ),
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
                      '${vip ? _tx(content, 'enum.promotion_type.vip', 'VİP') : promotion.tierLabel ?? promotion.typeLabel} · $route',
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
                      '${_remainingLabel(promotion, content)} · ${_money(promotion.amount)} ₼',
                      style: TextStyle(color: _cMuted(isDark), fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
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
            ],
          ),
          if (!promotion.isExpired) ...[
            const SizedBox(height: 11),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: _promotionProgress(promotion),
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
            _remainingLabel(promotion, content),
            style: TextStyle(color: _cText3(isDark), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: _promotionProgress(promotion),
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

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.amber = false,
    this.iconAfter = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !iconAfter) ...[
                Icon(
                  icon,
                  color: amber ? _ink900 : Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: amber ? _ink900 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null && iconAfter) ...[
                const SizedBox(width: 7),
                Icon(
                  icon,
                  color: amber ? _ink900 : Colors.white,
                  size: 19,
                ),
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
            'Elanın indi seçilmiş mövqe zolağında önə çıxarılır.',
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
