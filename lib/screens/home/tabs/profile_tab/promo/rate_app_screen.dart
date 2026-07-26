import 'dart:async';

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
const _amber = Color(0xFFFBBF24);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dElevated = Color(0xFF1C2740);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dMuted = Color(0xFF6B7B93);
const _dBrandText = Color(0xFF7FB6FF);

// success (toast + 13b check)
const _okGreen = Color(0xFF10B981);
const _dOkGreen = Color(0xFF4FD6A0);

const _azMonths = [
  'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'İyun',
  'İyul', 'Avqust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr' //
];
String _azDate(DateTime d) => '${d.day} ${_azMonths[d.month - 1]} ${d.year}';

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
  ReviewReward? _reward;

  bool get _hasCoupon => _reward?.hasCode == true;

  @override
  void initState() {
    super.initState();
    PromoApi().getReviewPrompt().then((p) {
      if (p != null && mounted) {
        setState(() {
          _prompt = p;
          _rated = p.alreadyRated;
          _reward = p.existingReward;
        });
      }
    });
  }

  /// Single entry point: opens the native Store review sheet, reports back to
  /// the backend, then reveals the granted coupon inline + a 5-second toast.
  Future<void> _rate() async {
    if (_busy || _rated) return;
    setState(() => _busy = true);
    final reward =
        await AppReviewFlow.requestStoreReview(context, prompt: _prompt);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _rated = true;
      _reward = reward ?? _prompt.existingReward;
    });
    _showThanksToast(context, dark: _dark(context));
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
        body:
            SafeArea(top: false, child: _rated ? _ratedPage(d) : _introPage(d)),
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

  // ── intro: informational + one button (no in-app rating) ────────────────────
  Widget _introPage(bool d) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 36),
        Center(child: _starBadge(d)),
        const SizedBox(height: 20),
        Text('Wawatair-i bəyənirsən?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            '1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),
        Center(child: _rewardChip(d)),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PrimaryButton(
            label: 'Store-da qiymətləndir',
            icon: PhosphorIconsFill.star,
            busy: _busy,
            onTap: _rate,
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
              _step(d, '1',
                  'Düyməyə bas — Store-un qiymətləndirmə pəncərəsi açılır'),
              const SizedBox(height: 12),
              _step(d, '2',
                  '${_prompt.rewardLabel()} promokod avtomatik hesabına gəlir'),
              const SizedBox(height: 12),
              _step(d, '3', 'Elanı VİP/önə çəkərkən tətbiq et'),
            ],
          ),
        ),
      ],
    );
  }

  // ── rated: coupon inline (with validity), or thanks-only when spent ──────────
  Widget _ratedPage(bool d) {
    final hasCoupon = _hasCoupon;
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 36),
        Center(child: hasCoupon ? _giftBadge(d) : _checkBadge(d)),
        const SizedBox(height: 20),
        Text(
            hasCoupon
                ? 'Hədiyyə promokodun hazırdır 🎁'
                : 'Təşəkkür edirik! ⭐️',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            hasCoupon
                ? 'Rəyin üçün təşəkkür! Bu promokodu VİP/önə çəkərkən tətbiq et:'
                : 'Bu tətbiqi artıq qiymətləndirmisən. Dəstəyin bizə çox kömək edir.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500),
          ),
        ),
        if (hasCoupon) ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Coupon(reward: _reward!, isDark: d),
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
        ],
      ],
    );
  }

  Widget _rewardChip(bool d) => Container(
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
      );

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

  Widget _giftBadge(bool d) => SizedBox(
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
                  Icon(PhosphorIconsFill.gift, size: 46, color: _cBrandText(d)),
            ),
            const Positioned(
                top: -4,
                right: 8,
                child:
                    Icon(PhosphorIconsFill.sparkle, size: 18, color: _amber)),
            const Positioned(
                bottom: 8,
                left: -2,
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
            size: 46, color: d ? _dOkGreen : _okGreen),
      );

  Widget _step(bool d, String n, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text,
                style: TextStyle(
                    color: d ? _dText : _ink700,
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

/// Slides a green "thanks" banner in from the top; auto-dismisses after 5s.
/// Replaces the old full-page thanks screen the user asked to remove.
void _showThanksToast(BuildContext context, {required bool dark}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ThanksToast(
      isDark: dark,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _ThanksToast extends StatefulWidget {
  final bool isDark;
  final VoidCallback onDismiss;

  const _ThanksToast({required this.isDark, required this.onDismiss});

  @override
  State<_ThanksToast> createState() => _ThanksToastState();
}

class _ThanksToastState extends State<_ThanksToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(const Duration(seconds: 5), _close);
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (mounted) await _c.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, -0.5), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
            child: FadeTransition(
              opacity: _c,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color:
                        d ? const Color(0xFF13251C) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            (d ? _dOkGreen : _okGreen).withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: d ? 0.4 : 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (d ? _dOkGreen : _okGreen)
                              .withValues(alpha: d ? 0.18 : 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIconsFill.checkCircle,
                            size: 24, color: d ? _dOkGreen : _okGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Təşəkkür edirik! ⭐️',
                                style: TextStyle(
                                    color: _cText(d),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Rəyin bizə çox kömək edir.',
                                style: TextStyle(
                                    color: _cMuted(d),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The granted coupon rendered inline on the rate page, with its validity
/// window (days left + expiry date) so the user knows how long they have.
class _Coupon extends StatelessWidget {
  final ReviewReward reward;
  final bool isDark;

  const _Coupon({required this.reward, required this.isDark});

  String? _validity() {
    final days = reward.daysLeft;
    if (reward.expiresAt == null || days == null) return null;
    if (days < 0) return 'Müddəti bitib';
    final date = _azDate(reward.expiresAt!);
    if (days == 0) return 'Bu gün bitir · $date';
    return '$days gün qalıb · son tarix $date';
  }

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    final validity = _validity();
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
            child: Column(
              children: [
                Row(
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
                          Text(reward.code,
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
                        Clipboard.setData(ClipboardData(text: reward.code));
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
                if (validity != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(PhosphorIconsFill.clock,
                          size: 14, color: _cBrandText(d)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(validity,
                            style: TextStyle(
                                color: _cBrandText(d),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
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
                Text('${reward.amountLabel()} endirim · VİP/önə çəkmə',
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
