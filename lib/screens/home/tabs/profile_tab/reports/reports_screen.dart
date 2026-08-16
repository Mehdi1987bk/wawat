import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:buking/services/localization_service.dart';

import 'reports_api.dart';

// ── palette ──────────────────────────────────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink200 = Color(0xFFE2E8F0);
const _screenLight = Color(0xFFEEF1F6);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
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
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText2 : _ink700;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cFaint(bool d) => d ? _dFaint : _ink400;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);
Color _cInset(bool d) =>
    d ? Colors.white.withValues(alpha: 0.04) : _ink900.withValues(alpha: 0.03);
Color _cAmberBg(bool d) =>
    d ? const Color(0x29F5B40A) : const Color(0xFFFFFBEB);
Color _cAmberText(bool d) =>
    d ? const Color(0xFFF4C64D) : const Color(0xFFD97706);
Color _cEmeraldBg(bool d) =>
    d ? const Color(0x2910B981) : const Color(0xFFECFDF5);
Color _cEmeraldText(bool d) =>
    d ? const Color(0xFF4FD6A0) : const Color(0xFF059669);
Color _cGrayBg(bool d) =>
    d ? Colors.white.withValues(alpha: 0.06) : _ink900.withValues(alpha: 0.05);

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
String _fmtDateTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${_fmtDate(d)} $hh:$mm';
}

IconData _typeIcon(String t) {
  switch (t) {
    case 'user':
      return PhosphorIconsFill.user;
    case 'message':
      return PhosphorIconsFill.chatCircle;
    default:
      return PhosphorIconsFill.note;
  }
}

Color _typeIconBg(bool d, String t) {
  switch (t) {
    case 'user':
      return _cBrandSoft(d);
    case 'message':
      return _cGrayBg(d);
    default:
      return _cAmberBg(d);
  }
}

Color _typeIconColor(bool d, String t) {
  switch (t) {
    case 'user':
      return _cBrandText(d);
    case 'message':
      return _cMuted(d);
    default:
      return _cAmberText(d);
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  const _StatusStyle(this.label, this.icon, this.bg, this.fg);
}

_StatusStyle _statusStyle(bool d, Report r) {
  switch (r.status) {
    case 'resolved':
      return _StatusStyle(tr('reports.status_resolved', 'Həll olundu'),
          PhosphorIconsFill.checkCircle, _cEmeraldBg(d), _cEmeraldText(d));
    case 'rejected':
      return _StatusStyle(tr('reports.status_rejected', 'Rədd edildi'),
          PhosphorIconsFill.xCircle, _cGrayBg(d), _cMuted(d));
    case 'pending':
      return _StatusStyle(tr('reports.status_pending', 'Gözləyir'),
          PhosphorIconsFill.clock, _cAmberBg(d), _cAmberText(d));
    default:
      return _StatusStyle(tr('reports.status_reviewing', 'Baxılır'),
          PhosphorIconsFill.clock, _cAmberBg(d), _cAmberText(d));
  }
}

PreferredSizeWidget _appBar(BuildContext context, bool d, String title) =>
    AppBar(
      backgroundColor: _cBar(d),
      surfaceTintColor: _cBar(d),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 4,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(PhosphorIconsBold.arrowLeft, color: _cText2(d), size: 21),
      ),
      title: Text(title,
          style: TextStyle(
              color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cLine(d)),
      ),
    );

SystemUiOverlayStyle _overlay(bool d) => SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: d ? Brightness.light : Brightness.dark,
      statusBarBrightness: d ? Brightness.dark : Brightness.light,
    );

Widget _statusChip(bool d, _StatusStyle s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.fg),
          const SizedBox(width: 5),
          Text(s.label,
              style: TextStyle(
                  color: s.fg, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsApi _api = ReportsApi();
  List<Report> _items = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.getReports();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlay(d),
      child: Scaffold(
        backgroundColor: _cScreen(d),
        appBar: _appBar(context, d, tr('reports.title', 'Şikayətlərim')),
        body: _loading
            ? const _Skeleton()
            : _error != null
                ? _ErrorView(onRetry: _load)
                : _items.isEmpty
                    ? _empty(d)
                    : _list(d),
      ),
    );
  }

  Widget _list(bool d) {
    return RefreshIndicator(
      color: _brand,
      backgroundColor: _cSurface(d),
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _card(d, _items[i]),
      ),
    );
  }

  Widget _card(bool d, Report r) {
    final s = _statusStyle(d, r);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailScreen(report: r))),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _typeIconBg(d, r.targetType),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(_typeIcon(r.targetType),
                      size: 16, color: _typeIconColor(d, r.targetType)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_reportTitle(r.targetType),
                          style: TextStyle(
                              color: _cText(d),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700)),
                      if (r.note.isNotEmpty)
                        Text(r.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _cFaint(d),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusChip(d, s),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(PhosphorIconsRegular.flag, size: 13, color: _cFaint(d)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      if (r.reasonLabel.isNotEmpty) r.reasonLabel,
                      if (r.createdAt != null) _fmtDate(r.createdAt!),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _cMuted(d),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(bool d) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _cBrandSoft(d),
                  borderRadius: BorderRadius.circular(26)),
              child: Icon(PhosphorIconsFill.flagBanner,
                  size: 34, color: _cBrandText(d)),
            ),
            const SizedBox(height: 16),
            Text(tr('reports.empty_title', 'Şikayətin yoxdur'),
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              tr('reports.empty_subtitle',
                  'Elan, istifadəçi və ya mesaj barədə şikayət etsən, burada görünəcək.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

String _reportTitle(String type) {
  switch (type) {
    case 'user':
      return tr('reports.subject_user', 'İstifadəçi barədə şikayət');
    case 'message':
      return tr('reports.subject_message', 'Mesaj barədə şikayət');
    default:
      return tr('reports.subject_listing', 'Elan barədə şikayət');
  }
}

// ── Detail ───────────────────────────────────────────────────────────────────
class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    final r = widget.report;
    final s = _statusStyle(d, r);
    final idLabel = r.id.length > 6 ? r.id.substring(0, 6).toUpperCase() : r.id;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlay(d),
      child: Scaffold(
        backgroundColor: _cScreen(d),
        appBar: _appBar(context, d,
            tr('reports.id_template', 'Şikayət #{id}', {'id': idLabel})),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cSurface(d),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cLine(d)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusChip(d, s),
                      if (r.createdAt != null)
                        Text(_fmtDateTime(r.createdAt!),
                            style: TextStyle(
                                color: _cFaint(d),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: _cInset(d),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: _typeIconBg(d, r.targetType),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(_typeIcon(r.targetType),
                              size: 18, color: _typeIconColor(d, r.targetType)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_reportTitle(r.targetType),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _cText(d),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              if (r.hasEvidence)
                                Text(
                                    tr('reports.evidence_attached',
                                        'Sübut əlavə edilib'),
                                    style: TextStyle(
                                        color: _cFaint(d),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label(d, tr('reports.reason_label', 'Səbəb')),
                  const SizedBox(height: 4),
                  Text(r.reasonLabel.isEmpty ? '—' : r.reasonLabel,
                      style: TextStyle(
                          color: _cText(d),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  if (r.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _label(d, tr('reports.explanation_label', 'İzah')),
                    const SizedBox(height: 4),
                    Text(r.note,
                        style: TextStyle(
                            color: _cText2(d),
                            fontSize: 12.7,
                            height: 1.5,
                            fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _label(d, tr('reports.status_label', 'Vəziyyət')),
            const SizedBox(height: 12),
            _Timeline(steps: _steps(r), isDark: d),
            if (r.resolutionNote.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cBrandSoft(d),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIconsFill.shieldCheck,
                            size: 15, color: _cBrandText(d)),
                        const SizedBox(width: 6),
                        Text(
                            tr('reports.moderation_response',
                                'Moderasiya cavabı'),
                            style: TextStyle(
                                color: _cBrandText(d),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r.resolutionNote,
                        style: TextStyle(
                            color: _cText2(d),
                            fontSize: 12.7,
                            height: 1.5,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(bool d, String t) => Text(t,
      style: TextStyle(
          color: _cText2(d), fontSize: 12, fontWeight: FontWeight.w700));

  List<_Step> _steps(Report r) {
    final resolved = r.status == 'resolved';
    final done = resolved || r.status == 'rejected';
    return [
      _Step(tr('reports.step_sent', 'Göndərildi'),
          r.createdAt == null ? null : _fmtDateTime(r.createdAt!), 'done'),
      _Step(
          tr('reports.status_reviewing', 'Baxılır'),
          tr('reports.step_reviewing_hint', 'Moderasiya komandası yoxlayır'),
          done ? 'done' : 'active'),
      _Step(
        tr('reports.step_result', 'Nəticə'),
        done
            ? (resolved
                ? tr('reports.status_resolved', 'Həll olundu')
                : tr('reports.status_rejected', 'Rədd edildi'))
            : tr('reports.result_pending', 'Gözlənilir'),
        done ? 'done' : 'future',
      ),
    ];
  }
}

class _Step {
  final String title;
  final String? subtitle;
  final String state; // done | active | future
  const _Step(this.title, this.subtitle, this.state);
}

class _Timeline extends StatelessWidget {
  final List<_Step> steps;
  final bool isDark;

  const _Timeline({required this.steps, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final last = i == steps.length - 1;
        final done = s.state == 'done';
        final active = s.state == 'active';
        final dotColor = done
            ? (d ? const Color(0xFF4FD6A0) : const Color(0xFF10B981))
            : active
                ? (d ? const Color(0xFF4F9DFF) : _brand)
                : (d ? _dFaint : _ink200);
        final titleColor = s.state == 'future' ? _cFaint(d) : _cText(d);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    child: Icon(
                        done || active
                            ? PhosphorIconsBold.check
                            : PhosphorIconsFill.circle,
                        size: done || active ? 9 : 6,
                        color: Colors.white),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color:
                            d ? Colors.white.withValues(alpha: 0.1) : _ink200,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 16, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        style: TextStyle(
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    if ((s.subtitle ?? '').isNotEmpty)
                      Text(s.subtitle!,
                          style: TextStyle(
                              color:
                                  s.state == 'future' ? _cFaint(d) : _cMuted(d),
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Skeleton + error ─────────────────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _Shimmer(height: 78),
        SizedBox(height: 12),
        _Shimmer(height: 78),
        SizedBox(height: 12),
        _Shimmer(height: 78),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double height;

  const _Shimmer({required this.height});

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
    final hi = d ? const Color(0xFF1C2740) : const Color(0xFFF4F6F9);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(-1 + 2 * _c.value, 0),
            end: Alignment(1 + 2 * _c.value, 0),
            colors: [base, hi, base],
            stops: const [0.3, 0.5, 0.7],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorView({required this.onRetry});

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
                  size: 38,
                  color: d ? const Color(0xFFFF9A9A) : const Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(tr('common.no_connection', 'Bağlantı yoxdur'),
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
                tr('common.load_failed_generic',
                    'Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
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
                  children: [
                    const Icon(PhosphorIconsBold.arrowClockwise,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(tr('common.retry', 'Yenidən cəhd et'),
                        style: const TextStyle(
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
