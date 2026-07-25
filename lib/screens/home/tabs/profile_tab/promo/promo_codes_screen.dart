import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../services/wawat_content.dart';
import '../../listings/promotion/promotion_screens.dart';
import 'app_review.dart';
import 'promo_api.dart';
import 'promo_codes_bloc.dart';

// ── Wawatair palette (light from mock + navy dark from spec) ─────────────────
const _brand = Color(0xFF017BFE);
const _brand50 = Color(0xFFEAF3FE);
const _brand700 = Color(0xFF024FA3);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _screenLight = Color(0xFFEEF1F6);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dElevated = Color(0xFF1C2740);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dText2 = Color(0xFF9FB0C7);
const _dMuted = Color(0xFF6B7B93);
const _dFaint = Color(0xFF55637A);
const _dBrandText = Color(0xFF7FB6FF);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cScreen(bool d) => d ? _dBg : _screenLight;
Color _cSurface(bool d) => d ? _dSurface : Colors.white;
Color _cBar(bool d) => d ? _dBar : Colors.white;
Color _cElevated(bool d) => d ? _dElevated : _ink900.withValues(alpha: 0.05);
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText2 : _ink700;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cFaint(bool d) => d ? _dFaint : _ink300;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) => d ? _brand.withValues(alpha: 0.14) : _brand50;
Color _cBrandBadge(bool d) => d ? _brand.withValues(alpha: 0.2) : _brand50;
Color _cAmberBg(bool d) =>
    d ? const Color(0x29F5B40A) : const Color(0xFFFFFBEB);
Color _cAmberText(bool d) =>
    d ? const Color(0xFFF4C64D) : const Color(0xFFD97706);
Color _cAmberIcon(bool d) =>
    d ? const Color(0xFFF4C64D) : const Color(0xFFF59E0B);
Color _cEmeraldBg(bool d) =>
    d ? const Color(0x2910B981) : const Color(0xFFECFDF5);
Color _cEmeraldText(bool d) =>
    d ? const Color(0xFF4FD6A0) : const Color(0xFF059669);
Color _cEmeraldIcon(bool d) =>
    d ? const Color(0xFF4FD6A0) : const Color(0xFF10B981);

const _azMonths = [
  'Yanvar',
  'Fevral',
  'Mart',
  'Aprel',
  'May',
  'İyun',
  'İyul',
  'Avqust',
  'Sentyabr',
  'Oktyabr',
  'Noyabr',
  'Dekabr',
];
String _fmtDate(DateTime d) => '${d.day} ${_azMonths[d.month - 1]}';

class PromoCodesScreen extends BaseScreen<PromoCodesBloc> {
  PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState
    extends BaseState<PromoCodesScreen, PromoCodesBloc> {
  @override
  PromoCodesBloc provideBloc() => PromoCodesBloc();

  @override
  bool get showProgressIndicator => false;

  @override
  Color? backgroundColor() => _cScreen(_dark(context));

  String _t(Map<String, String> c, String k, String f) =>
      WawatContent.text(c, k, f);

  void _toast(String message) {
    final d = _dark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: d ? _dElevated : _ink900,
        content: Text(message,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _copy(String code, Map<String, String> content) {
    Clipboard.setData(ClipboardData(text: code));
    _toast(_t(content, 'promo.copied', 'Kod kopyalandı'));
  }

  void _useCode(String code, Map<String, String> content) {
    Clipboard.setData(ClipboardData(text: code));
    _toast(_t(content, 'promo.copied', 'Kod kopyalandı'));
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MyPromotionsScreen()));
  }

  void _openRate() => AppReviewFlow.show(context);

  void _openReferral(Map<String, String> content) =>
      _toast(_t(content, 'common.coming_soon', 'Tezliklə aktiv olacaq.'));

  @override
  PreferredSizeWidget appBar() {
    final d = _dark(context);
    return AppBar(
      backgroundColor: _cBar(d),
      surfaceTintColor: _cBar(d),
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: StreamBuilder<PromoState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final content = snapshot.data?.content ?? const {};
          return Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: 34,
                  height: 40,
                  child: Icon(PhosphorIconsBold.arrowLeft,
                      color: _cText2(d), size: 21),
                ),
              ),
              Expanded(
                child: Text(
                  _t(content, 'promo.title', 'Promokodlarım'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _cText(d),
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toast(_t(content, 'promo.hint',
                    'Kodu elanı VİP edərkən və ya önə çəkərkən ödənişdə tətbiq et.')),
                child: SizedBox(
                  width: 34,
                  height: 40,
                  child: Icon(PhosphorIconsRegular.question,
                      color: _cMuted(d), size: 21),
                ),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cLine(d)),
      ),
    );
  }

  @override
  Widget body() {
    final d = _dark(context);
    return ColoredBox(
      color: _cScreen(d),
      child: StreamBuilder<PromoState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const PromoState.initial();
          if (state.loading && state.items.isEmpty) {
            return const _PromoSkeleton();
          }
          if (state.error != null && state.items.isEmpty) {
            return _LoadError(
                content: state.content, onRetry: bloc.loadInitial);
          }
          final onboarding = state.tab == 'active' &&
              state.items.isEmpty &&
              state.activeCount == 0;
          if (onboarding) {
            return _EmptyState(
              content: state.content,
              onRate: _openRate,
              onInvite: () => _openReferral(state.content),
            );
          }
          return Column(
            children: [
              _InfoHint(content: state.content),
              _Segment(state: state, onTab: bloc.setTab),
              Expanded(child: _list(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _list(PromoState state) {
    final d = _dark(context);
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            _t(state.content, 'promo.tab_empty', 'Bu bölmədə promokod yoxdur.'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cMuted(d), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: _brand,
      backgroundColor: _cSurface(d),
      onRefresh: bloc.loadInitial,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final promo = state.items[i];
          return _PromoTicket(
            promo: promo,
            notchColor: _cScreen(d),
            onCopy: () => _copy(promo.code, state.content),
            onUse: () => _useCode(promo.code, state.content),
            onTap: () => _showDetail(promo, state.content),
          );
        },
      ),
    );
  }

  void _showDetail(PromoCode promo, Map<String, String> content) {
    final d = _dark(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      isScrollControlled: true,
      builder: (_) => _DetailSheet(
        promo: promo,
        content: content,
        isDark: d,
        onCopy: () {
          _copy(promo.code, content);
        },
        onPromote: () {
          Navigator.of(context).maybePop();
          _useCode(promo.code, content);
        },
      ),
    );
  }
}

// ── Info hint ────────────────────────────────────────────────────────────────
class _InfoHint extends StatelessWidget {
  final Map<String, String> content;

  const _InfoHint({required this.content});

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cBrandSoft(d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.info, size: 17, color: _cBrandText(d)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              WawatContent.text(content, 'promo.hint',
                  'Kodu elanı VİP edərkən və ya önə çəkərkən ödənişdə tətbiq et.'),
              style: TextStyle(
                  color: d ? _dBrandText : _brand700,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segment (Aktiv / İstifadə olunmuş / Vaxtı keçmiş) ─────────────────────────
class _Segment extends StatelessWidget {
  final PromoState state;
  final ValueChanged<String> onTab;

  const _Segment({required this.state, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _cElevated(d),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _tab(context, d, 'active',
                WawatContent.text(state.content, 'promo.tab_active', 'Aktiv'),
                count: state.activeCount),
            _tab(
                context,
                d,
                'used',
                WawatContent.text(
                    state.content, 'promo.tab_used', 'İstifadə olunmuş')),
            _tab(
                context,
                d,
                'expired',
                WawatContent.text(
                    state.content, 'promo.tab_expired', 'Vaxtı keçmiş')),
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, bool d, String key, String label,
      {int count = 0}) {
    final on = state.tab == key;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTab(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: on ? _cSurface(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: on && !d
                ? [
                    BoxShadow(
                        color: _ink900.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: on ? _cBrandText(d) : _cMuted(d),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (key == 'active' && count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _cBrandBadge(d),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('$count',
                      style: TextStyle(
                          color: _cBrandText(d),
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ticket (coupon) ──────────────────────────────────────────────────────────
class _PromoTicket extends StatelessWidget {
  final PromoCode promo;
  final Color notchColor;
  final VoidCallback onCopy;
  final VoidCallback onUse;
  final VoidCallback onTap;

  const _PromoTicket({
    required this.promo,
    required this.notchColor,
    required this.onCopy,
    required this.onUse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    final muted = !promo.isActive;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _cSurface(d),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cLine(d)),
              boxShadow: d
                  ? null
                  : [
                      BoxShadow(
                          color: _ink900.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8))
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _stub(d, muted),
                    Expanded(child: _content(context, d, muted)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 82,
            top: 8,
            bottom: 8,
            child: _DashedVLine(
              color: muted
                  ? (d
                      ? Colors.white.withValues(alpha: 0.14)
                      : _ink400.withValues(alpha: 0.3))
                  : (d
                      ? Colors.white.withValues(alpha: 0.14)
                      : _brand700.withValues(alpha: 0.22)),
            ),
          ),
          Positioned(left: 82, top: -8, child: _notch()),
          Positioned(left: 82, bottom: -8, child: _notch()),
          if (muted)
            Positioned(
              right: 12,
              top: 12,
              child: _stamp(d),
            ),
        ],
      ),
    );
  }

  Widget _notch() => Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: notchColor, shape: BoxShape.circle),
      );

  Widget _stub(bool d, bool muted) {
    final bg = muted
        ? (d ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9))
        : _cBrandSoft(d);
    final fg = muted ? _cMuted(d) : (d ? _dBrandText : _brand700);
    return Container(
      width: 90,
      color: bg,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(promo.amountLabel,
              style: TextStyle(
                  color: fg,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('ENDİRİM',
              style: TextStyle(
                  color: fg.withValues(alpha: 0.7),
                  fontSize: 9,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, bool d, bool muted) {
    if (muted) return _mutedContent(d);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_sourceIcon(promo.source), size: 13, color: _cBrandText(d)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_sourceLabel(promo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _cBrandText(d),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(promo.code,
                  style: TextStyle(
                      color: _cText(d),
                      fontSize: 16,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCopy,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _cBrandSoft(d),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(PhosphorIconsBold.copy,
                      size: 13, color: _cBrandText(d)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _expiry(d)),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onUse,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: _brand.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: const Text('İstifadə et',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expiry(bool d) {
    if (promo.isExpiringSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: _cAmberBg(d), borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsFill.clock, size: 11, color: _cAmberText(d)),
            const SizedBox(width: 4),
            Text('${promo.daysLeft} gün qalıb',
                style: TextStyle(
                    color: _cAmberText(d),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIconsRegular.clock, size: 12, color: _cMuted(d)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            promo.expiresAt == null
                ? 'Müddətsiz'
                : '${_fmtDate(promo.expiresAt!)}-a qədər',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _cMuted(d), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _mutedContent(bool d) {
    final used = promo.isUsed;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_sourceLabel(promo),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(promo.code,
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 15,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.lineThrough)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: used
                  ? _cEmeraldBg(d)
                  : (d
                      ? Colors.white.withValues(alpha: 0.06)
                      : _ink900.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    used
                        ? PhosphorIconsFill.check
                        : PhosphorIconsFill.clockCountdown,
                    size: 11,
                    color: used ? _cEmeraldText(d) : (d ? _dText2 : _ink400)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _historyLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                            used ? _cEmeraldText(d) : (d ? _dText2 : _ink400),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stamp(bool d) {
    final used = promo.isUsed;
    final color = used ? _cEmeraldIcon(d).withValues(alpha: 0.6) : _cMuted(d);
    final border = used
        ? _cEmeraldIcon(d).withValues(alpha: 0.3)
        : (d ? Colors.white.withValues(alpha: 0.18) : _ink300);
    return Transform.rotate(
      angle: -0.14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(used ? 'İŞLƏNİB' : 'BİTİB',
            style: TextStyle(
                color: color,
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w800)),
      ),
    );
  }

  String _historyLabel() {
    if (promo.isUsed) {
      final date = promo.usedAt == null ? '' : ' · ${_fmtDate(promo.usedAt!)}';
      final ctx =
          (promo.usedContext ?? '').isEmpty ? '' : ' · ${promo.usedContext}';
      return 'İstifadə olunub$date$ctx';
    }
    final date =
        promo.expiresAt == null ? '' : ' · ${_fmtDate(promo.expiresAt!)}';
    return 'Vaxtı bitib$date';
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'rate_review':
        return PhosphorIconsFill.star;
      case 'referral':
        return PhosphorIconsFill.gift;
      case 'welcome':
        return PhosphorIconsFill.handHeart;
      default:
        return PhosphorIconsFill.tag;
    }
  }

  String _sourceLabel(PromoCode p) {
    if (p.sourceLabel.isNotEmpty) return p.sourceLabel;
    switch (p.source) {
      case 'rate_review':
        return 'Tətbiqi qiymətləndirdiyin üçün';
      case 'referral':
        return 'Dostunu dəvət etdiyin üçün';
      case 'welcome':
        return 'Xoş gəlmisən bonusu';
      default:
        return 'Promokod';
    }
  }
}

class _DashedVLine extends StatelessWidget {
  final Color color;

  const _DashedVLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      child: CustomPaint(painter: _DashPainter(color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;

  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(1, y), Offset(1, (y + dash).clamp(0, size.height)), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

// ── Empty (onboarding) ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRate;
  final VoidCallback onInvite;

  const _EmptyState(
      {required this.content, required this.onRate, required this.onInvite});

  String _t(String k, String f) => WawatContent.text(content, k, f);

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _cBrandSoft(d), borderRadius: BorderRadius.circular(26)),
            child:
                Icon(PhosphorIconsFill.ticket, size: 34, color: _cBrandText(d)),
          ),
        ),
        const SizedBox(height: 16),
        Text(_t('promo.empty_title', 'Hələ promokodun yoxdur'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cText(d), fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          _t('promo.empty_subtitle',
              'Promokod qazan və sifarişlərində endirim əldə et.'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _cMuted(d),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 26),
        _EarnCard(
          icon: PhosphorIconsFill.star,
          iconBg: _cAmberBg(d),
          iconColor: _cAmberIcon(d),
          title: _t('promo.earn_rate', 'Tətbiqi qiymətləndir'),
          subtitle: _t('promo.earn_rate_sub', 'Store-da ulduz ver'),
          onTap: onRate,
        ),
        const SizedBox(height: 10),
        _EarnCard(
          icon: PhosphorIconsFill.gift,
          iconBg: _cBrandSoft(d),
          iconColor: _cBrandText(d),
          title: _t('promo.earn_invite', 'Dostunu dəvət et'),
          subtitle:
              _t('promo.earn_invite_sub', 'Hər qeydiyyatdan olan dost üçün'),
          onTap: onInvite,
        ),
      ],
    );
  }
}

class _EarnCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EarnCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cSurface(d),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cLine(d)),
          boxShadow: d
              ? null
              : [
                  BoxShadow(
                      color: _ink900.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: _cText(d),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: TextStyle(
                          color: _cMuted(d),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _cBrandSoft(d),
                  borderRadius: BorderRadius.circular(99)),
              child: Text('+5 ₼',
                  style: TextStyle(
                      color: _cBrandText(d),
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 4),
            Icon(PhosphorIconsRegular.caretRight, size: 15, color: _cFaint(d)),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom-sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final PromoCode promo;
  final Map<String, String> content;
  final bool isDark;
  final VoidCallback onCopy;
  final VoidCallback onPromote;

  const _DetailSheet({
    required this.promo,
    required this.content,
    required this.isDark,
    required this.onCopy,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: _cSurface(d),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: d
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            _PromoTicket(
              promo: promo,
              notchColor: _cSurface(d),
              onCopy: onCopy,
              onUse: onPromote,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _condition(d, 'Minimum ödəniş: ${_minLabel()}'),
            const SizedBox(height: 10),
            _condition(d, 'Bir dəfə istifadə olunur'),
            const SizedBox(height: 10),
            _condition(d, 'VİP və önə çəkmə üçün keçərli'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: _sheetButton(
                    d,
                    label: 'Kodu köçür',
                    icon: PhosphorIconsBold.copy,
                    primary: false,
                    onTap: onCopy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 14,
                  child: _sheetButton(
                    d,
                    label: 'Elanı önə çıxar',
                    icon: PhosphorIconsBold.rocketLaunch,
                    primary: true,
                    onTap: onPromote,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _minLabel() {
    final m = promo.minOrderAmount;
    if (m == null) return '—';
    final symbol = promo.currency == 'AZN' ? '₼' : promo.currency;
    final rounded = m == m.roundToDouble() ? m.round().toString() : '$m';
    return '$rounded $symbol';
  }

  Widget _condition(bool d, String text) {
    return Row(
      children: [
        Icon(PhosphorIconsFill.checkCircle, size: 18, color: _cEmeraldIcon(d)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: _cText2(d),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _sheetButton(bool d,
      {required String label,
      required IconData icon,
      required bool primary,
      required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? _brand : _cBrandSoft(d),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: primary ? Colors.white : _cBrandText(d)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: primary ? Colors.white : _cBrandText(d),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────
class _PromoSkeleton extends StatelessWidget {
  const _PromoSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _Shimmer(height: 44, radius: 16),
        SizedBox(height: 16),
        _Shimmer(height: 92, radius: 20),
        SizedBox(height: 12),
        _Shimmer(height: 92, radius: 20),
        SizedBox(height: 12),
        _Shimmer(height: 92, radius: 20),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double height;
  final double radius;

  const _Shimmer({required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
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
    final d = _dark(context);
    final base = d ? _dSurface : const Color(0xFFE7EBF1);
    final hi = d ? _dElevated : const Color(0xFFF4F6F9);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _c.value, 0),
              end: Alignment(1 + 2 * _c.value, 0),
              colors: [base, hi, base],
              stops: const [0.3, 0.5, 0.7],
            ),
          ),
        );
      },
    );
  }
}

// ── Network error ────────────────────────────────────────────────────────────
class _LoadError extends StatelessWidget {
  final Map<String, String> content;
  final Future<void> Function() onRetry;

  const _LoadError({required this.content, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: d ? const Color(0x1FEF4444) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(PhosphorIconsRegular.wifiSlash,
                  size: 40,
                  color: d ? const Color(0xFFFF9A9A) : const Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(
              WawatContent.text(
                  content, 'promo.error_title', 'Bağlantı yoxdur'),
              style: TextStyle(
                  color: _cText(d), fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(content, 'promo.error_body',
                  'Promokodları yükləyə bilmədik. İnternet bağlantını yoxla.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _cMuted(d), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                    color: _brand, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(PhosphorIconsBold.arrowClockwise,
                        size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Yenidən cəhd et',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
