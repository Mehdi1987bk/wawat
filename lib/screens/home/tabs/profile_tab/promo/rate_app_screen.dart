import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_review.dart';
import 'promo_api.dart';
import 'promo_codes_screen.dart';

// ── palette (light from mock + navy dark) ────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _brand700 = Color(0xFF024FA3);
const _accent = Color(0xFFF2FC2A);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink300 = Color(0xFFCBD5E1);
const _amber = Color(0xFFFBBF24);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dElevated = Color(0xFF1C2740);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dMuted = Color(0xFF6B7B93);
const _dFaint = Color(0xFF55637A);
const _dBrandText = Color(0xFF7FB6FF);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cScreen(bool d) => d ? _dBg : Colors.white;
Color _cBar(bool d) => d ? _dBar : Colors.white;
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText : _ink800;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);
Color _cStepBg(bool d) => d ? _dSurface : _ink900.withValues(alpha: 0.02);

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  AppReviewPrompt _prompt = const AppReviewPrompt.fallback();
  bool _rated = false;
  bool _busy = false;
  String? _awardedCode;

  bool get _hasCoupon => (_awardedCode ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    PromoApi().getReviewPrompt().then((p) {
      if (p != null && mounted) {
        setState(() {
          _prompt = p;
          _rated = p.alreadyRated;
          _awardedCode = p.rewardCode;
        });
      }
    });
  }

  Future<void> _rate(int stars) async {
    if (_busy || _rated) return;
    if (stars <= 3) {
      AppReviewFlow.show(context, prompt: _prompt);
      return;
    }
    setState(() => _busy = true);
    final code = await AppReviewFlow.requestStoreReview(context,
        prompt: _prompt, rating: stars);
    // Reward code (if the backend granted one) is revealed inline below.
    if (mounted)
      setState(() {
        _busy = false;
        _rated = true;
        _awardedCode = code ?? _prompt.rewardCode;
      });
  }

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: d ? Brightness.light : Brightness.dark,
        statusBarBrightness: d ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _cScreen(d),
        appBar: _appBar(d),
        body: SafeArea(top: false, child: _page(d)),
      ),
    );
  }

  PreferredSizeWidget _appBar(bool d) => AppBar(
        backgroundColor: _cBar(d),
        surfaceTintColor: _cBar(d),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(PhosphorIconsBold.arrowLeft, color: _cText2(d), size: 21),
        ),
        title: Text('Tətbiqi qiymətləndir',
            style: TextStyle(
                color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _cLine(d)),
        ),
      );

  Widget _page(bool d) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 36),
        Center(child: _rated ? _checkBadge(d) : _starBadge(d)),
        const SizedBox(height: 20),
        Text(_rated ? 'Təşəkkür edirik! ⭐️' : 'Wawatair-i bəyənirsən?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            !_rated
                ? '1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.'
                : _hasCoupon
                    ? 'Dəstəyin bizə çox kömək edir. Budur hədiyyə promokodun:'
                    : 'Bu tətbiqi artıq qiymətləndirmisən. Dəstəyin bizə çox kömək edir.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
        _stars(d),
        const SizedBox(height: 20),
        if (!_rated) ..._introTail(d) else ..._rewardTail(d),
      ],
    );
  }

  // ── not rated yet ──────────────────────────────────────────────────────────
  List<Widget> _introTail(bool d) => [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: d
                  ? _accent.withValues(alpha: 0.16)
                  : _accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsFill.gift, size: 15, color: _cBrandText(d)),
                const SizedBox(width: 6),
                Text('${_prompt.rewardLabel()} promokod hədiyyə',
                    style: TextStyle(
                        color: _cText2(d),
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PrimaryButton(
            label: 'Store-da qiymətləndir',
            icon: PhosphorIconsFill.star,
            busy: _busy,
            onTap: () => _rate(5),
          ),
        ),
        const SizedBox(height: 8),
        Text('Bir dəqiqədən az çəkir',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cStepBg(d),
            borderRadius: BorderRadius.circular(16),
            border: d ? Border.all(color: _cLine(d)) : null,
          ),
          child: Column(
            children: [
              _step(d, '1', 'Store-da ulduz ver'),
              const SizedBox(height: 12),
              _step(d, '2',
                  '${_prompt.rewardLabel()} promokod avtomatik hesabına gəlir'),
              const SizedBox(height: 12),
              _step(d, '3', 'Elanı VİP/önə çəkərkən tətbiq et'),
            ],
          ),
        ),
      ];

  // ── rated → coupon inline, same page ─────────────────────────────────────────
  List<Widget> _rewardTail(bool d) {
    // 13b — already rated but the reward code is spent/absent: thanks only,
    // no coupon and no "Promokodlarıma bax".
    if (!_hasCoupon) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _Coupon(code: _awardedCode!, prompt: _prompt, isDark: d),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _PrimaryButton(
          label: 'Promokodlarıma bax',
          icon: PhosphorIconsFill.ticket,
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => PromoCodesScreen()),
          ),
        ),
      ),
    ];
  }

  Widget _stars(bool d) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _rated ? null : () => _rate(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              _rated ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
              size: 34,
              color: _rated ? _amber : (d ? _dFaint : _ink300),
            ),
          ),
        );
      }),
    );
  }

  Widget _starBadge(bool d) => SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _cBrandSoft(d),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child:
                  Icon(PhosphorIconsFill.star, size: 50, color: _cBrandText(d)),
            ),
            const Positioned(
                top: -4,
                right: 8,
                child:
                    Icon(PhosphorIconsFill.sparkle, size: 18, color: _amber)),
            const Positioned(
                bottom: 8,
                left: -4,
                child:
                    Icon(PhosphorIconsFill.sparkle, size: 12, color: _amber)),
          ],
        ),
      );

  Widget _checkBadge(bool d) => Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: d ? const Color(0x2910B981) : const Color(0xFFECFDF5),
          shape: BoxShape.circle,
        ),
        child: Icon(PhosphorIconsFill.checkCircle,
            size: 46,
            color: d ? const Color(0xFF4FD6A0) : const Color(0xFF10B981)),
      );

  Widget _step(bool d, String n, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: _cBrandSoft(d), shape: BoxShape.circle),
          child: Text(n,
              style: TextStyle(
                  color: _cBrandText(d),
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: d ? _dText : _ink700,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _Coupon extends StatelessWidget {
  final String code;
  final AppReviewPrompt prompt;
  final bool isDark;

  const _Coupon(
      {required this.code, required this.prompt, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _cBrandSoft(d),
              border:
                  Border.all(color: _brand.withValues(alpha: 0.4), width: 2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROMOKODUN',
                          style: TextStyle(
                              color: (d ? _dBrandText : _brand700)
                                  .withValues(alpha: 0.7),
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(code,
                          style: TextStyle(
                              color: d ? _dBrandText : _brand700,
                              fontSize: 19,
                              letterSpacing: 3,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: d ? _dElevated : _ink900,
                      content: const Text('Kod kopyalandı',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ));
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: d ? _dElevated : Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(PhosphorIconsBold.copy,
                        size: 18, color: _cBrandText(d)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: _brand,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(PhosphorIconsFill.tag,
                    size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Text('${prompt.rewardLabel()} endirim · VİP/önə çəkmə',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: 0.5),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 17, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}
