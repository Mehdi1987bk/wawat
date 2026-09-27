import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:buking/services/localization_service.dart';

import 'app_review.dart';

// ── palette (light from mock + navy dark) ────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _amber = Color(0xFFFBBF24);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dMuted = Color(0xFF6B7B93);
const _dBrandText = Color(0xFF7FB6FF);

// success (toast + check)
const _okGreen = Color(0xFF10B981);
const _dOkGreen = Color(0xFF4FD6A0);

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

/// "Rate app" page. Pure rating: encourages the user, opens the Store listing,
/// then thanks them. The promo-code reward is intentionally NOT shown or granted
/// here — that whole feature is parked (see kPromoFeatureEnabled).
class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  bool _rated = false;
  bool _busy = false;

  /// Opens the Store listing (no reward, no backend call), then shows a thanks
  /// state on return.
  Future<void> _rate() async {
    if (_rated || _busy) return;
    setState(() => _busy = true);
    await AppReviewFlow.openStoreListing(context);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _rated = true;
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
        title: Text(tr('promo.earn_rate', 'Tətbiqi qiymətləndir'),
            style: TextStyle(
                color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _cLine(d)),
        ),
      );

  // ── intro: informational + one button ───────────────────────────────────────
  Widget _introPage(bool d) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 36),
        Center(child: _starBadge(d)),
        const SizedBox(height: 20),
        Text(tr('app_review.like_title', 'Wawatair-i bəyənirsən?'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            tr('app_review.like_subtitle_plain',
                'Bir dəqiqəni ayır və bizi Store-da qiymətləndir. Dəstəyin bizə çox kömək edir.'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PrimaryButton(
            label: tr('app_review.rate_in_store', 'Store-da qiymətləndir'),
            icon: PhosphorIconsFill.star,
            busy: _busy,
            onTap: _rate,
          ),
        ),
        const SizedBox(height: 8),
        Text(tr('app_review.less_than_minute', 'Bir dəqiqədən az çəkir'),
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
              _step(
                  d,
                  '1',
                  tr('app_review.step_open_plain',
                      'Düyməyə bas — Store səhifəsi açılır')),
              const SizedBox(height: 12),
              _step(d, '2',
                  tr('app_review.step_stars_plain', 'Ulduz ver və rəyini yaz')),
              const SizedBox(height: 12),
              _step(
                  d,
                  '3',
                  tr('app_review.step_done_plain',
                      'Tətbiqə qayıt — hamısı budur')),
            ],
          ),
        ),
      ],
    );
  }

  // ── rated: thanks only ───────────────────────────────────────────────────────
  Widget _ratedPage(bool d) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 36),
        Center(child: _checkBadge(d)),
        const SizedBox(height: 20),
        Text(tr('app_review.thanks_title', 'Təşəkkür edirik! ⭐️'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            tr('app_review.thanks_body_short', 'Dəstəyin bizə çox kömək edir.'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
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
