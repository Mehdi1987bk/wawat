import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/tier_status_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import '../new_profile/profile_api.dart';
import '../verification/verification_screen.dart';

/// "Statusum" — data-driven tier / level page backed by `GET /me/tier-status`.
/// Nothing about thresholds, progress or the ladder is computed client-side —
/// every value (labels, requirements, ranges, met-flags) comes from the API.
class TierStatusScreen extends StatefulWidget {
  const TierStatusScreen({super.key});

  @override
  State<TierStatusScreen> createState() => _TierStatusScreenState();
}

class _TierStatusScreenState extends State<TierStatusScreen> {
  final WawatProfileApi _api = WawatProfileApi();

  late Future<TierStatusResponse> _future;
  Map<String, String> _content = const {};

  @override
  void initState() {
    super.initState();
    _future = _api.tierStatus();
    WawatContent.loadGroups(['tier', 'common']).then((c) {
      if (mounted) setState(() => _content = c);
    });
  }

  void _reload() => setState(() => _future = _api.tierStatus());

  String _t(String key, String fallback) =>
      WawatContent.text(_content, key, fallback);

  Future<void> _openVerification() async {
    try {
      final user = await sl.get<AuthRepository>().userDetails.first;
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(user: user)),
      );
      if (mounted) _reload();
    } catch (_) {
      /* verification unavailable — silently ignore */
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          _t('tier.title', 'Statusum'),
          style: TextStyle(
            color: cText(isDark),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: FutureBuilder<TierStatusResponse>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _TierSkeleton(d: isDark);
          }
          if (snap.hasError || snap.data == null) {
            return _TierError(
              d: isDark,
              title: _t('tier.error_title', 'Yüklənmədi'),
              body: _t(
                'tier.error_body',
                'Statusunu yükləyə bilmədik. İnternet bağlantını yoxla və yenidən cəhd et.',
              ),
              retry: _t('common.retry', 'Yenidən cəhd et'),
              onRetry: _reload,
            );
          }
          // text() returns AZ fallbacks even before the CMS map resolves, so
          // there is no need to block rendering on _content.
          return _body(isDark, snap.data!.data);
        },
      ),
    );
  }

  Widget _body(bool d, TierStatus data) {
    return ListView(
      // Reserve the Android system-nav inset so the last row (and the footnote)
      // clears the gesture bar instead of being cut off at the screen bottom.
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, 28 + MediaQuery.of(context).viewPadding.bottom),
      children: [
        _HeroCard(d: d, data: data, t: _t),
        const SizedBox(height: 16),
        if (data.isDemoted)
          _DemotionSection(d: d, data: data, t: _t, onVerify: _openVerification)
        else if (!data.isMax)
          _ProgressSection(
              d: d, data: data, t: _t, onVerify: _openVerification),
        if (data.isDemoted || !data.isMax) const SizedBox(height: 20),
        _LadderSection(d: d, data: data, t: _t),
        const SizedBox(height: 16),
        _InfoNote(
          d: d,
          text: _t(
            'tier.note',
            'Səviyyə reytinqindən asılıdır — reytinqin düşsə səviyyə dəyişə '
                'bilər, qalxsa geri qayıdır.',
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  HERO
// ════════════════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.d, required this.data, required this.t});

  final bool d;
  final TierStatus data;
  final String Function(String, String) t;

  @override
  Widget build(BuildContext context) {
    final tier = data.currentTier;
    final m = data.metrics;
    final subtitle = tier.key == 'new'
        ? t('tier.hero_sub_new', 'Səyahətinə yenicə başladın 👋')
        : t('tier.hero_sub_template', 'Sən {tier} səviyyədəsən')
            .replaceAll('{tier}', tier.label);

    return _Card(
      d: d,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _Medal(
            tierKey: tier.key,
            size: 96,
            radius: 26,
            iconSize: 46,
            elevated: true,
          ),
          const SizedBox(height: 16),
          Text(
            tier.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cText(d),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (data.isMax) ...[
            const SizedBox(height: 8),
            _Pill(
              d: d,
              icon: PhosphorIconsFill.trophy,
              text: t('tier.max_badge', 'Ən yüksək səviyyədəsən 🏆'),
              fg: cBrandText(d),
              bg: cBrandSoft(d),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cText2(d),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsFill.package, size: 15, color: cBrandText(d)),
              const SizedBox(width: 5),
              Text(
                t('tier.metric_deliveries_template', '{count} çatdırılma')
                    .replaceAll('{count}', '${m.completedDeliveries}'),
                style: TextStyle(
                  color: cText2(d),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 1,
                height: 12,
                color: cLine(d),
              ),
              Icon(
                m.hasRating
                    ? PhosphorIconsFill.star
                    : PhosphorIconsRegular.star,
                size: 15,
                color: m.hasRating ? _kStar : cFaint(d),
              ),
              const SizedBox(width: 5),
              Text(
                m.hasRating
                    ? t('tier.metric_rating_template', '{rating} reytinq')
                        .replaceAll('{rating}', _rating(m.ratingAvg!))
                    : t('tier.metric_no_rating', 'reytinq yoxdur'),
                style: TextStyle(
                  color: m.hasRating ? cText2(d) : cMuted(d),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  PROGRESS (to next tier) — brand / amber / ready / only-KYC variants
// ════════════════════════════════════════════════════════════════════════

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.d,
    required this.data,
    required this.t,
    required this.onVerify,
  });

  final bool d;
  final TierStatus data;
  final String Function(String, String) t;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final next = data.nextTier!;
    final reqs = data.nextTierRequirements;
    final numeric = reqs.where((r) => !r.isVerification).toList();
    final kyc = _kycOf(reqs);

    // Degenerate: a next tier with no requirements at all (only reachable via a
    // malformed/partial payload). Showing a "keçmək üçün" card with "0 şərt
    // qalıb" would be misleading — render nothing instead.
    if (numeric.isEmpty && kyc == null) return const SizedBox.shrink();

    final numericAllMet = numeric.every((r) => r.met);
    final deliveriesAllMet =
        numeric.where((r) => r.isDeliveries).every((r) => r.met);
    final ratingLow =
        numeric.any((r) => r.isRating && !r.met && r.currentNum != null);

    if (data.isReadyForPromotion) {
      return _readyCard(next, numeric, kyc);
    }
    // Only KYC left: EVERY numeric requirement (deliveries AND rating) is met,
    // and the only blocker is an unmet verification requirement.
    if (numericAllMet && kyc != null && !kyc.met) {
      return _onlyKycCard(next, numeric, kyc);
    }
    final amber = deliveriesAllMet && ratingLow;
    return _standardCard(next, numeric, kyc, amber: amber);
  }

  // ── default (brand-tinted) / amber (rating blocker) ──
  Widget _standardCard(
    TierRef next,
    List<TierRequirement> numeric,
    TierRequirement? kyc, {
    required bool amber,
  }) {
    final bg = amber
        ? _warnBg(d)
        : (d ? WawatDark.brandChip : const Color(0xFFF3F8FE));
    final border = amber
        ? _warnBorder(d)
        : (d ? WawatDark.border : cBrandFill.withValues(alpha: 0.18));

    return _Card(
      d: d,
      bg: bg,
      border: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _progressHeader(next),
          const SizedBox(height: 14),
          for (int i = 0; i < numeric.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _ReqBar(d: d, req: numeric[i], t: t),
          ],
          if (kyc != null) ...[
            const SizedBox(height: 12),
            _KycBox(d: d, met: kyc.met, t: t, onVerify: onVerify),
          ],
          const SizedBox(height: 14),
          _footer(numeric, kyc),
        ],
      ),
    );
  }

  // ── all requirements met → positive emerald banner ──
  Widget _readyCard(
    TierRef next,
    List<TierRequirement> numeric,
    TierRequirement? kyc,
  ) {
    return _StripCard(
      d: d,
      stripColor: _kEmeraldStrip(d),
      icon: PhosphorIconsFill.confetti,
      title: t('tier.ready_title_template', '{tier} səviyyəsinə hazırsan!')
          .replaceAll('{tier}', next.label),
      subtitle: t(
        'tier.ready_sub',
        'Növbəti çatdırılmadan sonra yüksələcəksən.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < numeric.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _ReqBar(d: d, req: numeric[i], t: t),
          ],
          if (kyc != null) ...[
            const SizedBox(height: 12),
            _KycBox(d: d, met: kyc.met, t: t, onVerify: onVerify),
          ],
        ],
      ),
    );
  }

  // ── only KYC left → prominent last-step card with big CTA ──
  Widget _onlyKycCard(
    TierRef next,
    List<TierRequirement> numeric,
    TierRequirement kyc,
  ) {
    return _StripCard(
      d: d,
      stripColor: cBrandFill,
      icon: PhosphorIconsFill.sealCheck,
      title: t('tier.laststep_title_template', '{tier} səviyyəsinə son addım!')
          .replaceAll('{tier}', next.label),
      subtitle: t(
        'tier.laststep_sub',
        'Çatdırılma və reytinqin hazırdır — yalnız hesab təsdiqi qalıb.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in numeric) ...[
            _MiniReqRow(d: d, req: r, t: t),
            const SizedBox(height: 8),
          ],
          _MiniReqRow(d: d, kyc: kyc, t: t),
          const SizedBox(height: 14),
          _BrandButton(
            label: t('tier.kyc_button_big', 'Hesabı təsdiqlə'),
            icon: PhosphorIconsFill.sealCheck,
            onTap: onVerify,
          ),
          const SizedBox(height: 8),
          Text(
            t('tier.laststep_caption', 'Təsdiqdən dərhal sonra yüksələcəksən'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cMuted(d),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressHeader(TierRef next) {
    return Row(
      children: [
        _Medal(tierKey: next.key, size: 32, radius: 11, iconSize: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t('tier.progress_title_template', '{tier} səviyyəsinə keçmək üçün')
                .replaceAll('{tier}', next.label),
            style: TextStyle(
              color: cText(d),
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _footer(List<TierRequirement> numeric, TierRequirement? kyc) {
    IconData icon;
    String text;
    Color color;

    final unmet = <TierRequirement>[
      ...numeric.where((r) => !r.met),
      if (kyc != null && !kyc.met) kyc,
    ];
    final onlyRatingNoValue = unmet.length == 1 &&
        unmet.first.isRating &&
        unmet.first.currentNum == null;
    final firstDelivery = unmet.length == 1 &&
        unmet.first.isDeliveries &&
        (unmet.first.requiredNum ?? 0) <= 1 &&
        (unmet.first.currentNum ?? 0) == 0;
    final onlyRatingLow = unmet.length == 1 &&
        unmet.first.isRating &&
        unmet.first.currentNum != null;

    if (onlyRatingNoValue) {
      icon = PhosphorIconsFill.handWaving;
      text = t('tier.footer_first_review',
          'İlk rəyini al — yüksəlmək üçün reytinq lazımdır');
      color = cBrandText(d);
    } else if (firstDelivery) {
      icon = PhosphorIconsFill.rocketLaunch;
      text = t('tier.footer_first', 'İlk sifarişini tamamla və yüksəl!');
      color = cBrandText(d);
    } else if (onlyRatingLow) {
      icon = PhosphorIconsFill.star;
      text = t('tier.footer_rating', 'Reytinqini yüksəlt');
      color = _warnText(d);
    } else {
      icon = PhosphorIconsFill.target;
      text = t('tier.footer_count_template', '{count} şərt qalıb')
          .replaceAll('{count}', '${unmet.length}');
      color = cBrandText(d);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cCard(d),
        borderRadius: BorderRadius.circular(16),
        border: cCardBorder(d),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: cText3(d),
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

// ════════════════════════════════════════════════════════════════════════
//  DEMOTION
// ════════════════════════════════════════════════════════════════════════

class _DemotionSection extends StatelessWidget {
  const _DemotionSection({
    required this.d,
    required this.data,
    required this.t,
    required this.onVerify,
  });

  final bool d;
  final TierStatus data;
  final String Function(String, String) t;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final numeric =
        data.nextTierRequirements.where((r) => !r.isVerification).toList();
    final kyc = _kycOf(data.nextTierRequirements);
    final from = data.demotedFrom?.label ?? '';
    final to = data.currentTier.label;

    return _Card(
      d: d,
      bg: _warnBg(d),
      border: _warnBorder(d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: d
                      ? WawatDark.warning.withValues(alpha: 0.16)
                      : const Color(0xFFFDECC8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(PhosphorIconsFill.trendDown,
                    size: 16, color: _warnIcon(d)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('tier.demoted_title', 'Səviyyən dəyişdi'),
                      style: TextStyle(
                        color: cText(d),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t(
                        'tier.demoted_body_template',
                        'Reytinqin dəyişdiyi üçün səviyyən {from} → {to} oldu. '
                            'Tələbləri tamamlayaraq geri qayıda bilərsən.',
                      ).replaceAll('{from}', from).replaceAll('{to}', to),
                      style: TextStyle(
                        color: cText3(d),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cCard(d),
              borderRadius: BorderRadius.circular(16),
              border: cCardBorder(d),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < numeric.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _ReqBar(d: d, req: numeric[i], t: t),
                ],
                if (kyc != null) ...[
                  const SizedBox(height: 12),
                  _KycBox(d: d, met: kyc.met, t: t, onVerify: onVerify),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  REQUIREMENT BAR
// ════════════════════════════════════════════════════════════════════════

class _ReqBar extends StatelessWidget {
  const _ReqBar({required this.d, required this.req, required this.t});

  final bool d;
  final TierRequirement req;
  final String Function(String, String) t;

  @override
  Widget build(BuildContext context) {
    if (req.isDeliveries) return _deliveries();
    return _ratingRow();
  }

  Widget _deliveries() {
    final cur = (req.currentNum ?? 0).toInt();
    final need = (req.requiredNum ?? 0).toInt();
    final gap = (req.remaining ?? 0).toInt();
    final caption = req.met
        ? t('tier.deliveries_done', 'Çatdırılma kifayətdir ✓')
        : (need <= 1 && cur == 0
            ? t('tier.deliveries_first', 'İlk çatdırılmanı tamamla')
            : t('tier.deliveries_remaining_template',
                    '{count} çatdırılma qalıb')
                .replaceAll('{count}', '$gap'));

    return _row(
      icon: PhosphorIconsFill.package,
      iconColor: req.met ? _okText(d) : cBrandText(d),
      label: t('tier.req_deliveries', 'Çatdırılma'),
      valueText: '$cur / $need',
      valueColor: req.met ? _okText(d) : cText(d),
      showCheck: req.met,
      barValue: req.progress,
      barColor: req.met ? _okBar(d) : cBrandFill,
      caption: caption,
      captionColor: req.met ? _okText(d) : cBrandText(d),
    );
  }

  Widget _ratingRow() {
    final hasVal = req.currentNum != null;
    final need = req.requiredNum;
    final label = t('tier.req_rating_template', 'Reytinq (min {min})')
        .replaceAll('{min}', need != null ? _rating(need) : '');
    final String caption;
    final Color captionColor;
    if (req.met) {
      caption = t('tier.rating_done', 'Reytinq kifayətdir ✓');
      captionColor = _okText(d);
    } else if (hasVal) {
      caption = t(
        'tier.rating_remaining_template',
        'min {min} lazımdır — hazırda {cur} · {gap} qalıb',
      )
          .replaceAll('{min}', need != null ? _rating(need) : '')
          .replaceAll('{cur}', _rating(req.currentNum!))
          .replaceAll('{gap}', _rating(req.remaining ?? 0));
      captionColor = _warnText(d);
    } else {
      caption = t('tier.rating_none', 'Hələ reytinqin yoxdur');
      captionColor = cMuted(d);
    }

    return _row(
      icon: hasVal ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
      iconColor: hasVal ? _kStar : cFaint(d),
      label: label,
      valueText: hasVal ? _rating(req.currentNum!) : '—',
      valueColor: req.met
          ? _okText(d)
          : hasVal
              ? _warnText(d)
              : cMuted(d),
      showCheck: req.met,
      // Below-threshold rating stays a plain amber number (no ✗) — matching the
      // deliveries row and 3 of the design's 4 low-rating states. The amber
      // value + amber caption already signal the unmet state.
      barValue: req.met
          ? 1
          : hasVal
              ? req.progress
              : 0,
      barColor: req.met
          ? _okBar(d)
          : hasVal
              ? _warnBar(d)
              : cBrandFill,
      caption: caption,
      captionColor: captionColor,
    );
  }

  Widget _row({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String valueText,
    required Color valueColor,
    required double barValue,
    required Color barColor,
    required String caption,
    required Color captionColor,
    bool showCheck = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cText3(d),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                color: valueColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showCheck) ...[
              const SizedBox(width: 4),
              Icon(PhosphorIconsFill.checkCircle, size: 14, color: valueColor),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _Bar(value: barValue, fill: barColor, track: _barTrack(d)),
        const SizedBox(height: 4),
        Text(
          caption,
          style: TextStyle(
            color: captionColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Compact single-line requirement row (used inside the only-KYC card).
class _MiniReqRow extends StatelessWidget {
  const _MiniReqRow({
    required this.d,
    this.req,
    this.kyc,
    required this.t,
  }) : assert(req != null || kyc != null);

  final bool d;
  final TierRequirement? req;
  final TierRequirement? kyc;
  final String Function(String, String) t;

  @override
  Widget build(BuildContext context) {
    if (kyc != null) {
      return _line(
        icon: PhosphorIconsFill.sealCheck,
        iconColor: kyc!.met ? _okText(d) : _warnIcon(d),
        label: t('tier.kyc_label', 'Hesab təsdiqi (KYC)'),
        value: kyc!.met
            ? t('tier.kyc_verified', 'Təsdiqlənib')
            : t('tier.kyc_unverified', 'Təsdiqlənməyib'),
        valueColor: kyc!.met ? _okText(d) : _warnText(d),
        met: kyc!.met,
      );
    }
    final r = req!;
    if (r.isDeliveries) {
      final cur = (r.currentNum ?? 0).toInt();
      final need = (r.requiredNum ?? 0).toInt();
      return _line(
        icon: PhosphorIconsFill.package,
        iconColor: r.met ? _okText(d) : cBrandText(d),
        label: t('tier.req_deliveries', 'Çatdırılma'),
        value: '$cur / $need',
        valueColor: r.met ? _okText(d) : cText(d),
        met: r.met,
      );
    }
    final hasVal = r.currentNum != null;
    return _line(
      icon: hasVal ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
      iconColor: hasVal ? _kStar : cFaint(d),
      label: t('tier.req_rating_template', 'Reytinq (min {min})').replaceAll(
          '{min}', r.requiredNum != null ? _rating(r.requiredNum!) : ''),
      value: hasVal ? _rating(r.currentNum!) : '—',
      valueColor: r.met
          ? _okText(d)
          : hasVal
              ? _warnText(d)
              : cMuted(d),
      met: r.met,
    );
  }

  Widget _line({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool met,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: cText3(d),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          met ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.xCircle,
          size: 14,
          color: valueColor,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  KYC BOX
// ════════════════════════════════════════════════════════════════════════

class _KycBox extends StatelessWidget {
  const _KycBox({
    required this.d,
    required this.met,
    required this.t,
    required this.onVerify,
  });

  final bool d;
  final bool met;
  final String Function(String, String) t;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final label = t('tier.kyc_label', 'Hesab təsdiqi (KYC)');
    if (met) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _okBg(d),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsFill.sealCheck, size: 15, color: _okText(d)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cText3(d),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              t('tier.kyc_verified', 'Təsdiqlənib'),
              style: TextStyle(
                color: _okText(d),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(PhosphorIconsFill.checkCircle, size: 14, color: _okText(d)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _warnBg(d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.sealCheck, size: 15, color: _warnIcon(d)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: cText3(d),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                t('tier.kyc_unverified', 'Təsdiqlənməyib'),
                style: TextStyle(
                  color: _warnText(d),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(PhosphorIconsFill.xCircle, size: 14, color: _warnText(d)),
            ],
          ),
          const SizedBox(height: 8),
          _SmallBrandButton(
            label: t('tier.kyc_button', 'Hesabını təsdiqlə'),
            onTap: onVerify,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  LADDER (all tiers)
// ════════════════════════════════════════════════════════════════════════

class _LadderSection extends StatelessWidget {
  const _LadderSection({required this.d, required this.data, required this.t});

  final bool d;
  final TierStatus data;
  final String Function(String, String) t;

  @override
  Widget build(BuildContext context) {
    final all = data.allTiers;
    if (all.isEmpty) return const SizedBox.shrink();
    final curKey = data.currentTier.key;
    final curIdx = all.indexWhere((e) => e.key == curKey);
    final anyKyc = all.any((e) => e.requiresVerification);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsFill.steps, size: 15, color: cBrandText(d)),
            const SizedBox(width: 6),
            Text(
              t('tier.ladder_title', 'Bütün səviyyələr').toUpperCase(),
              style: TextStyle(
                color: cText2(d),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        if (anyKyc) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(PhosphorIconsFill.sealCheck, size: 13, color: cBrandText(d)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  t(
                    'tier.ladder_kyc_legend',
                    'Yuxarı səviyyələr üçün hesab təsdiqi (KYC) tələb olunur',
                  ),
                  style: TextStyle(
                    color: cMuted(d),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        for (int i = 0; i < all.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _LadderRow(
            d: d,
            item: all[i],
            t: t,
            state: _stateFor(i, curIdx, all[i]),
          ),
        ],
      ],
    );
  }

  _LadderRowState _stateFor(int i, int curIdx, TierLadderItem item) {
    if (item.key == data.currentTier.key) return _LadderRowState.current;
    if (data.demotedFrom != null && item.key == data.demotedFrom!.key) {
      return _LadderRowState.comeback;
    }
    if (data.isReadyForPromotion &&
        data.nextTier != null &&
        item.key == data.nextTier!.key) {
      return _LadderRowState.ready;
    }
    if (curIdx >= 0 && i < curIdx) return _LadderRowState.done;
    return _LadderRowState.locked;
  }
}

enum _LadderRowState { done, current, locked, comeback, ready }

class _LadderRow extends StatelessWidget {
  const _LadderRow({
    required this.d,
    required this.item,
    required this.t,
    required this.state,
  });

  final bool d;
  final TierLadderItem item;
  final String Function(String, String) t;
  final _LadderRowState state;

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _LadderRowState.current;
    final isComeback = state == _LadderRowState.comeback;
    final isReady = state == _LadderRowState.ready;
    final isDone = state == _LadderRowState.done;

    Color bg = cCard(d);
    BoxBorder? border = cCardBorder(d) ?? Border.all(color: cLine(d));
    if (isCurrent) {
      bg = cBrandSoft(d);
      border = Border.all(color: cBrandFill.withValues(alpha: 0.9), width: 1.5);
    } else if (isComeback) {
      bg = _warnBg(d);
      border = Border.all(color: _warnBorder(d));
    } else if (isReady) {
      bg = _okBg(d);
      border = Border.all(color: _okBorder(d));
    }

    return Opacity(
      opacity: isDone ? 0.72 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          children: [
            _Medal(tierKey: item.key, size: 40, radius: 12, iconSize: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cText(d),
                            fontSize: 13.5,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (item.requiresVerification) ...[
                        const SizedBox(width: 4),
                        Icon(PhosphorIconsFill.sealCheck,
                            size: 12, color: cBrandText(d)),
                      ],
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        _Badge(
                          text: t('tier.badge_current', 'Cari'),
                          bg: cBrandFill,
                          fg: Colors.white,
                        ),
                      ] else if (isComeback) ...[
                        const SizedBox(width: 6),
                        _Badge(
                          text: t('tier.badge_comeback', 'Geri qayıt'),
                          bg: _warnIcon(d),
                          fg: Colors.white,
                        ),
                      ] else if (isReady) ...[
                        const SizedBox(width: 6),
                        _Badge(
                          text: t('tier.badge_ready', 'Hazır'),
                          bg: _okBar(d),
                          fg: Colors.white,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _rangeText(),
                    style: TextStyle(
                      color: isCurrent ? cText2(d) : cMuted(d),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _trailing(),
          ],
        ),
      ),
    );
  }

  Widget _trailing() {
    switch (state) {
      case _LadderRowState.current:
        return const SizedBox.shrink();
      case _LadderRowState.comeback:
        return Icon(PhosphorIconsRegular.arrowUUpLeft,
            size: 18, color: _warnIcon(d));
      case _LadderRowState.ready:
      case _LadderRowState.done:
        return Icon(PhosphorIconsFill.checkCircle, size: 18, color: _okText(d));
      case _LadderRowState.locked:
        return Icon(PhosphorIconsRegular.lockSimple,
            size: 18, color: cFaint(d));
    }
  }

  String _rangeText() {
    final min = item.minDeliveries;
    final max = item.maxDeliveries;
    if (min <= 0 && (max == null || max <= 0)) {
      return t('tier.tier_start', 'Başlanğıc');
    }
    String out;
    if (max == null) {
      out = t('tier.range_open_template', '{min}+ çatdırılma')
          .replaceAll('{min}', '$min');
    } else if (min == max) {
      out = t('tier.range_single_template', '{n} çatdırılma')
          .replaceAll('{n}', '$min');
    } else {
      out = t('tier.range_span_template', '{min}-{max} çatdırılma')
          .replaceAll('{min}', '$min')
          .replaceAll('{max}', '$max');
    }
    if (item.minRating > 0) {
      out += t('tier.range_rating_template', ' · reytinq {min}+')
          .replaceAll('{min}', _rating(item.minRating));
    }
    return out;
  }
}

// ════════════════════════════════════════════════════════════════════════
//  SHARED PRIMITIVES
// ════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({
    required this.d,
    required this.child,
    this.bg,
    this.border,
    this.padding = const EdgeInsets.all(16),
  });

  final bool d;
  final Widget child;
  final Color? bg;
  final Color? border;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? cCard(d),
        borderRadius: BorderRadius.circular(24),
        border: border != null ? Border.all(color: border!) : cCardBorder(d),
        boxShadow: cCardShadow(d, _kLightCardShadow),
      ),
      child: child,
    );
  }
}

/// Card with a solid coloured header strip (ready / only-KYC variants).
class _StripCard extends StatelessWidget {
  const _StripCard({
    required this.d,
    required this.stripColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final bool d;
  final Color stripColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cCard(d),
        borderRadius: BorderRadius.circular(24),
        border: cCardBorder(d),
        boxShadow: cCardShadow(d, _kLightCardShadow),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: stripColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: body,
          ),
        ],
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  const _Medal({
    required this.tierKey,
    required this.size,
    required this.radius,
    required this.iconSize,
    this.elevated = false,
  });

  final String tierKey;
  final double size;
  final double radius;
  final double iconSize;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _tierGradient(tierKey),
          stops: const [0.0, 0.53, 1.0],
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.45],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              _tierIcon(tierKey),
              size: iconSize,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x470F172A),
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.fill, required this.track});

  final double value;
  final Color fill;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 10,
        color: track,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.d,
    required this.icon,
    required this.text,
    required this.fg,
    required this.bg,
  });

  final bool d;
  final IconData icon;
  final String text;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  const _BrandButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cBrandFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBrandButton extends StatelessWidget {
  const _SmallBrandButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cBrandFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(PhosphorIconsBold.arrowRight,
                  size: 11, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.d, required this.text});

  final bool d;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cFill(d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.info, size: 15, color: cMuted(d)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: cText2(d),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  SKELETON / ERROR
// ════════════════════════════════════════════════════════════════════════

class _TierSkeleton extends StatefulWidget {
  const _TierSkeleton({required this.d});

  final bool d;

  @override
  State<_TierSkeleton> createState() => _TierSkeletonState();
}

class _TierSkeletonState extends State<_TierSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final p = _c.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Card(
              d: d,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _sk(d, p, 96, 96, 26),
                  const SizedBox(height: 16),
                  _sk(d, p, 120, 22, 8),
                  const SizedBox(height: 8),
                  _sk(d, p, 180, 12, 6),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              d: d,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sk(d, p, 160, 16, 6),
                  const SizedBox(height: 14),
                  _sk(d, p, double.infinity, 10, 9999),
                  const SizedBox(height: 14),
                  _sk(d, p, double.infinity, 10, 9999),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _sk(d, p, double.infinity, 64, 16),
            ],
          ],
        );
      },
    );
  }

  Widget _sk(bool d, double phase, double w, double h, double r) {
    final base = d ? WawatDark.skeletonBase : const Color(0xFFE7EBF1);
    final hi = d ? WawatDark.skeletonHi : const Color(0xFFF4F6F9);
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [base, hi, base],
          stops: const [0.1, 0.5, 0.9],
          // Sweep the highlight band across the block (design: sk 1.3s loop).
          transform: _SlideGradient(-1.0 + 2.0 * phase),
        ),
      ),
    );
  }
}

/// Slides a gradient horizontally by [slide] × width (used for the shimmer).
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

class _TierError extends StatelessWidget {
  const _TierError({
    required this.d,
    required this.title,
    required this.body,
    required this.retry,
    required this.onRetry,
  });

  final bool d;
  final String title;
  final String body;
  final String retry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cFill(d),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(PhosphorIconsRegular.cloudWarning,
                  size: 36, color: cFaint(d)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: cText(d),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cText2(d),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: _BrandButton(
                label: retry,
                icon: PhosphorIconsBold.arrowClockwise,
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  helpers
// ════════════════════════════════════════════════════════════════════════

const Color _kStar = Color(0xFFF5A524);
const Color _kEmeraldBar = Color(0xFF10B981);
const Color _kAmberBar = Color(0xFFE8A400);

const List<BoxShadow> _kLightCardShadow = [
  BoxShadow(
    color: Color(0x0A0F172A),
    blurRadius: 2,
    offset: Offset(0, 1),
  ),
  BoxShadow(
    color: Color(0x140F172A),
    blurRadius: 24,
    offset: Offset(0, 12),
    spreadRadius: -14,
  ),
];

Color _okText(bool d) => d ? WawatDark.success : const Color(0xFF059669);
Color _okBg(bool d) => d ? WawatDark.successBg : const Color(0xFFECFDF5);
Color _okBorder(bool d) =>
    d ? WawatDark.success.withValues(alpha: 0.35) : const Color(0xFFA7F3D0);
Color _okBar(bool d) => d ? WawatDark.success : _kEmeraldBar;

Color _warnText(bool d) => d ? WawatDark.warning : const Color(0xFFB67C00);
Color _warnIcon(bool d) => d ? WawatDark.warning : _kAmberBar;
Color _warnBg(bool d) => d ? WawatDark.warningBg : const Color(0xFFFEF6E7);
Color _warnBorder(bool d) =>
    d ? WawatDark.warning.withValues(alpha: 0.35) : const Color(0xFFFDE4B0);
Color _warnBar(bool d) => d ? WawatDark.warning : _kAmberBar;

Color _kEmeraldStrip(bool d) =>
    d ? const Color(0xFF0E9F6E) : const Color(0xFF10B981);

Color _barTrack(bool d) =>
    d ? Colors.white.withValues(alpha: 0.09) : const Color(0x120F172A);

TierRequirement? _kycOf(List<TierRequirement> reqs) {
  for (final r in reqs) {
    if (r.isVerification) return r;
  }
  return null;
}

String _rating(double v) => v.toStringAsFixed(1);

IconData _tierIcon(String key) {
  switch (key) {
    case 'new':
      return PhosphorIconsFill.sparkle;
    case 'standard':
      return PhosphorIconsFill.shield;
    case 'bronze':
      return PhosphorIconsFill.medal;
    case 'silver':
      return PhosphorIconsFill.medal;
    case 'gold':
      return PhosphorIconsFill.trophy;
    case 'platinum':
      return PhosphorIconsFill.crownSimple;
    default:
      return PhosphorIconsFill.medal;
  }
}

List<Color> _tierGradient(String key) {
  switch (key) {
    case 'new':
      return const [Color(0xFFEEF2F6), Color(0xFFCBD5E1), Color(0xFF94A3B8)];
    case 'standard':
      return const [Color(0xFFDCE3EC), Color(0xFFAEB9C8), Color(0xFF7E8CA1)];
    case 'bronze':
      return const [Color(0xFFF3CFA6), Color(0xFFCB8A4C), Color(0xFF96552A)];
    case 'silver':
      return const [Color(0xFFF5F8FB), Color(0xFFC3CDD9), Color(0xFF8F9BAC)];
    case 'gold':
      return const [Color(0xFFFDEAA6), Color(0xFFF0C04C), Color(0xFFC4922B)];
    case 'platinum':
      return const [Color(0xFFECF1FF), Color(0xFFC2CDEA), Color(0xFF8C9BC6)];
    default:
      return const [Color(0xFFEEF2F6), Color(0xFFCBD5E1), Color(0xFF94A3B8)];
  }
}
