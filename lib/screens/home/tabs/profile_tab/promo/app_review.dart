import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'promo_api.dart';

// ── Wawatair navy palette (shared spec) ──────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _brand700 = Color(0xFF024FA3);
const _accent = Color(0xFFF2FC2A);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink500 = Color(0xFF64748B);
const _ink300 = Color(0xFFCBD5E1);
const _amber = Color(0xFFFBBF24);

const _dSurface = Color(0xFF141D2E);
const _dElevated = Color(0xFF1C2740);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dText2 = Color(0xFF9FB0C7);
const _dMuted = Color(0xFF6B7B93);
const _dBrandText = Color(0xFF7FB6FF);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cSurface(bool d) => d ? _dSurface : Colors.white;
Color _cElevated(bool d) => d ? _dElevated : const Color(0xFFF8FAFC);
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText2 : _ink800;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);

/// Orchestrates the store-review reward flow. Timing/frequency is 100% backend
/// driven (see [PromoApi.getReviewPrompt]) — this only renders and reports back.
class AppReviewFlow {
  AppReviewFlow._();

  /// Fetches the prompt and, if the backend says `should_show`, shows the alert.
  /// Safe to call on app start — silently no-ops when disabled / not due.
  static Future<void> maybePrompt(BuildContext context, {PromoApi? api}) async {
    if (!kPromoFeatureEnabled) return;
    final prompt = await (api ?? PromoApi()).getReviewPrompt();
    if (prompt == null || !prompt.shouldShow) return;
    if (!context.mounted) return;
    await show(context, prompt: prompt, api: api);
  }

  /// Shows the alert immediately (used by the "Tətbiqi qiymətləndir" earn card).
  static Future<void> show(
    BuildContext context, {
    AppReviewPrompt? prompt,
    PromoApi? api,
  }) async {
    final resolved = api ?? PromoApi();
    final data = prompt ?? await resolved.getReviewPrompt();
    if (data == null || !context.mounted) return;
    resolved.markReviewShown(promptToken: data.promptToken);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => _ReviewDialog(prompt: data, api: resolved),
    );
  }

  /// Runs the native store-review flow (in_app_review, falling back to the
  /// store URL) then reports `rated` to the backend. Reusable by the standalone
  /// rate page.
  static Future<String?> requestStoreReview(
    BuildContext context, {
    AppReviewPrompt? prompt,
    int? rating,
    PromoApi? api,
  }) async {
    final resolved = api ?? PromoApi();
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else if (context.mounted) {
        await _openStore(context, prompt);
      }
    } catch (_) {
      if (context.mounted) await _openStore(context, prompt);
    }
    return resolved.markReviewRated(
        promptToken: prompt?.promptToken, rating: rating);
  }

  static Future<void> _openStore(
      BuildContext context, AppReviewPrompt? prompt) async {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final url = (isIos ? prompt?.storeUrlIos : prompt?.storeUrlAndroid) ??
        prompt?.storeUrlAndroid ??
        prompt?.storeUrlIos;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ReviewDialog extends StatefulWidget {
  final AppReviewPrompt prompt;
  final PromoApi api;

  const _ReviewDialog({required this.prompt, required this.api});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

enum _Stage { intro, highPicked, redirecting, thanks, lowRating }

class _ReviewDialogState extends State<_ReviewDialog> {
  _Stage _stage = _Stage.intro;
  int _rating = 0;
  final TextEditingController _feedback = TextEditingController();

  String _t(String key, String fallback) =>
      widget.prompt.content[key] ?? fallback;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  void _onStar(int value) {
    setState(() {
      _rating = value;
      _stage = value >= 4 ? _Stage.highPicked : _Stage.lowRating;
    });
  }

  Future<void> _goStore() async {
    setState(() => _stage = _Stage.redirecting);
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await _openStoreUrl();
      }
    } catch (_) {
      await _openStoreUrl();
    }
    widget.api.markReviewRated(
        promptToken: widget.prompt.promptToken, rating: _rating);
    if (mounted) setState(() => _stage = _Stage.thanks);
  }

  Future<void> _openStoreUrl() async {
    final url = (Theme.of(context).platform == TargetPlatform.iOS
            ? widget.prompt.storeUrlIos
            : widget.prompt.storeUrlAndroid) ??
        widget.prompt.storeUrlAndroid ??
        widget.prompt.storeUrlIos;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendFeedback() async {
    widget.api.markReviewRated(
        promptToken: widget.prompt.promptToken, rating: _rating);
    if (mounted) Navigator.of(context).maybePop();
  }

  void _later() {
    widget.api.markReviewDismissed(promptToken: widget.prompt.promptToken);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return Dialog(
      backgroundColor: _cSurface(d),
      surfaceTintColor: _cSurface(d),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _body(d),
        ),
      ),
    );
  }

  List<Widget> _body(bool d) {
    switch (_stage) {
      case _Stage.redirecting:
        return _redirecting(d);
      case _Stage.thanks:
        return _thanks(d);
      case _Stage.lowRating:
        return _low(d);
      case _Stage.highPicked:
        return _high(d);
      case _Stage.intro:
        return _intro(d);
    }
  }

  Widget _closeButton(bool d) => Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _later,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: d ? _dElevated : _ink900.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIconsBold.x, size: 15, color: _cMuted(d)),
          ),
        ),
      );

  Widget _starIconBadge(bool d, {Color? bg, Color? fg}) => Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg ?? _cBrandSoft(d),
          borderRadius: BorderRadius.circular(26),
        ),
        child:
            Icon(PhosphorIconsFill.star, size: 38, color: fg ?? _cBrandText(d)),
      );

  Widget _stars(bool d, {required bool goldAll}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final active = goldAll || i < _rating;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onStar(i + 1),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                active ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                size: 26,
                color: active ? _amber : (d ? _dMuted : _ink300),
              ),
            ),
          );
        }),
      );

  List<Widget> _intro(bool d) => [
        _closeButton(d),
        _starIconBadge(d),
        const SizedBox(height: 16),
        Text(_t('title', 'Wawatair-i bəyənirsən?'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          _t('subtitle',
              '1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _cMuted(d),
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _stars(d, goldAll: false),
        const SizedBox(height: 16),
        _rewardChip(d),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: _t('cta', 'Store-da qiymətləndir'),
          icon: PhosphorIconsFill.star,
          onTap: () => _onStar(5),
        ),
        const SizedBox(height: 4),
        _GhostButton(label: _t('later', 'Sonra'), onTap: _later),
        const SizedBox(height: 4),
        Text('Bir dəqiqədən az çəkir',
            style: TextStyle(
                color: _cMuted(d), fontSize: 11, fontWeight: FontWeight.w500)),
      ];

  List<Widget> _high(bool d) => [
        _closeButton(d),
        _starIconBadge(d,
            bg: d ? const Color(0x29F5B40A) : const Color(0xFFFFFBEB),
            fg: _amber),
        const SizedBox(height: 16),
        Text('Çox sağ ol! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Rəyini App Store-da paylaş — sənə '),
              TextSpan(
                  text: '${widget.prompt.rewardLabel()} promokod',
                  style: TextStyle(
                      color: _cText2(d), fontWeight: FontWeight.w800)),
              const TextSpan(text: ' göndərək.'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _cMuted(d),
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _stars(d, goldAll: true),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'App Store-da rəy yaz',
          icon: PhosphorIconsFill.appleLogo,
          onTap: _goStore,
        ),
        const SizedBox(height: 4),
        _GhostButton(label: _t('later', 'Sonra'), onTap: _later),
      ];

  List<Widget> _redirecting(bool d) => [
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: _cBrandSoft(d), shape: BoxShape.circle),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: _cBrandText(d)),
          ),
        ),
        const SizedBox(height: 16),
        Text('App Store açılır…',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Rəyini orada paylaş, sonra tətbiqə qayıt.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
      ];

  List<Widget> _thanks(bool d) => [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: d ? const Color(0x2910B981) : const Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: Icon(PhosphorIconsFill.checkCircle,
              size: 48,
              color: d ? const Color(0xFF4FD6A0) : const Color(0xFF10B981)),
        ),
        const SizedBox(height: 16),
        Text(_t('thanks_title', 'Təşəkkür edirik! ⭐️'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          _t('thanks_body', 'Dəstəyin bizə çox kömək edir. Budur hədiyyən:'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _cMuted(d),
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _RewardCoupon(prompt: widget.prompt, isDark: d),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: 'Kodu köçür',
          icon: PhosphorIconsFill.copy,
          onTap: () {
            Clipboard.setData(const ClipboardData(text: 'WAWA5'));
            Navigator.of(context).maybePop();
          },
        ),
        const SizedBox(height: 4),
        _GhostButton(
            label: 'Bağla', onTap: () => Navigator.of(context).maybePop()),
      ];

  List<Widget> _low(bool d) => [
        _closeButton(d),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _cBrandSoft(d), borderRadius: BorderRadius.circular(22)),
          child: Icon(PhosphorIconsFill.chatTeardropText,
              size: 30, color: _cBrandText(d)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                i < _rating
                    ? PhosphorIconsFill.star
                    : PhosphorIconsRegular.star,
                size: 20,
                color: i < _rating ? _amber : (d ? _dMuted : _ink300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Bizə kömək et — nəyi dəyişək?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Fikrin birbaşa komandamıza gedir. Promokod yenə də səninlədir.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        TextField(
          controller: _feedback,
          maxLines: 3,
          style: TextStyle(
              color: _cText(d), fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Təcrübən barədə bir neçə söz yaz…',
            hintStyle:
                TextStyle(color: _cMuted(d), fontWeight: FontWeight.w500),
            filled: true,
            fillColor: _cElevated(d),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _cLine(d)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brand, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PrimaryButton(
          label: 'Rəy göndər',
          icon: PhosphorIconsFill.paperPlaneTilt,
          onTap: _sendFeedback,
        ),
        const SizedBox(height: 4),
        _GhostButton(label: 'Keç', onTap: _later),
      ];

  Widget _rewardChip(bool d) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: d
              ? _accent.withValues(alpha: 0.16)
              : _accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsFill.gift, size: 16, color: _cBrandText(d)),
            const SizedBox(width: 6),
            Text('${widget.prompt.rewardLabel()} promokod hədiyyə',
                style: TextStyle(
                    color: d ? _dText : _ink800,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _RewardCoupon extends StatelessWidget {
  final AppReviewPrompt prompt;
  final bool isDark;

  const _RewardCoupon({required this.prompt, required this.isDark});

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
              border: Border.all(
                  color: _brand.withValues(alpha: 0.4),
                  width: 2,
                  style: BorderStyle.solid),
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
                      Text('WAWA5',
                          style: TextStyle(
                              color: d ? _dBrandText : _brand700,
                              fontSize: 19,
                              letterSpacing: 3,
                              fontFeatures: const [],
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _cSurface(d),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(PhosphorIconsFill.gift,
                      size: 20, color: _cBrandText(d)),
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
                Text('${prompt.rewardLabel()} endirim · növbəti sifarişə',
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
  final VoidCallback onTap;

  const _PrimaryButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
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
        child: Row(
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
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                color: _cMuted(d), fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
