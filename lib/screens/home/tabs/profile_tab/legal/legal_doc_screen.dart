import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:buking/services/localization_service.dart';

import 'legal_api.dart';

// ── palette ──────────────────────────────────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dElevated = Color(0xFF1C2740);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dText2 = Color(0xFF9FB0C7);
const _dMuted = Color(0xFF6B7B93);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cScreen(bool d) => d ? _dBg : Colors.white;
Color _cBar(bool d) => d ? _dBar : Colors.white;
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText2 : _ink700;
Color _cBody(bool d) => d ? _dText2 : _ink600;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cChipBg(bool d) =>
    d ? Colors.white.withValues(alpha: 0.06) : _ink900.withValues(alpha: 0.04);
Color _cShimmer(bool d, bool hi) => d
    ? (hi ? _dElevated : _dSurface)
    : (hi ? const Color(0xFFF4F6F9) : const Color(0xFFE7EBF1));

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
String _fmtDate(DateTime d) => '${d.day} ${_azMonths[d.month - 1]} ${d.year}';

class LegalDocScreen extends StatefulWidget {
  final String slug; // terms | privacy
  final String title;

  const LegalDocScreen({super.key, required this.slug, required this.title});

  @override
  State<LegalDocScreen> createState() => _LegalDocScreenState();
}

class _LegalDocScreenState extends State<LegalDocScreen> {
  final LegalApi _api = LegalApi();
  PageDoc? _doc;
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
      final doc = await _api.getPage(widget.slug);
      if (mounted) setState(() => _doc = doc);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _share() {
    final title = _doc?.title ?? widget.title;
    Share.share('$title\nhttps://wawatair.com/${widget.slug}');
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
        appBar: AppBar(
          backgroundColor: _cBar(d),
          surfaceTintColor: _cBar(d),
          elevation: 0,
          centerTitle: false,
          titleSpacing: 4,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon:
                Icon(PhosphorIconsBold.arrowLeft, color: _cText2(d), size: 21),
          ),
          title: Text(
              _doc?.title.isNotEmpty == true ? _doc!.title : widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
              onPressed: _share,
              icon: Icon(PhosphorIconsRegular.shareNetwork,
                  color: _cMuted(d), size: 20),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _cLine(d)),
          ),
        ),
        body: _loading
            ? _Skeleton(isDark: d)
            : _error != null
                ? _ErrorView(onRetry: _load)
                : _content(d),
      ),
    );
  }

  Widget _content(bool d) {
    final doc = _doc!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (doc.updatedAt != null) ...[
          _updatedChip(d, doc.updatedAt!),
          const SizedBox(height: 6),
        ],
        ..._Markdown.render(doc.body, d),
      ],
    );
  }

  Widget _updatedChip(bool d, DateTime date) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: _cChipBg(d), borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                widget.slug == 'privacy'
                    ? PhosphorIconsRegular.shieldCheck
                    : PhosphorIconsRegular.clockCounterClockwise,
                size: 13,
                color: _cMuted(d)),
            const SizedBox(width: 6),
            Text(
                tr('legal.updated_at', 'Yenilənib: {date}',
                    {'date': _fmtDate(date)}),
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Minimal markdown → widgets: `#`/`##`/`###` headings, `-`/`*` bullets,
/// blank-line-separated paragraphs, inline `**bold**`. Enough for CMS legal copy.
class _Markdown {
  static List<Widget> render(String body, bool d) {
    final widgets = <Widget>[];
    final lines = body.replaceAll('\r\n', '\n').split('\n');
    final paragraph = <String>[];

    void flush() {
      if (paragraph.isEmpty) return;
      final text = paragraph.join(' ').trim();
      paragraph.clear();
      if (text.isEmpty) return;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text.rich(
          _spans(
              text,
              TextStyle(
                  color: _cBody(d),
                  fontSize: 12.7,
                  height: 1.7,
                  fontWeight: FontWeight.w500)),
        ),
      ));
    }

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        flush();
        continue;
      }
      if (line.startsWith('### ')) {
        flush();
        widgets.add(_heading(line.substring(4), d, 13.5));
      } else if (line.startsWith('## ')) {
        flush();
        widgets.add(_heading(line.substring(3), d, 14));
      } else if (line.startsWith('# ')) {
        flush();
        widgets.add(_heading(line.substring(2), d, 15.5));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        flush();
        widgets.add(_bullet(line.substring(2), d));
      } else {
        paragraph.add(line);
      }
    }
    flush();
    return widgets;
  }

  static Widget _heading(String text, bool d, double size) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text.rich(
          _spans(
              text,
              TextStyle(
                  color: _cText(d),
                  fontSize: size,
                  fontWeight: FontWeight.w800)),
        ),
      );

  static Widget _bullet(String text, bool d) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 8),
              child: Container(
                width: 4,
                height: 4,
                decoration:
                    BoxDecoration(color: _cMuted(d), shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Text.rich(
                _spans(
                    text,
                    TextStyle(
                        color: _cBody(d),
                        fontSize: 12.7,
                        height: 1.6,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      );

  /// Splits on `**` toggling bold.
  static TextSpan _spans(String text, TextStyle base) {
    final parts = text.split('**');
    if (parts.length == 1) return TextSpan(text: text, style: base);
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final bold = i.isOdd;
      spans.add(TextSpan(
        text: parts[i],
        style: bold
            ? base.copyWith(
                fontWeight: FontWeight.w800,
                color: base.color == null ? null : base.color)
            : base,
      ));
    }
    return TextSpan(style: base, children: spans);
  }
}

class _Skeleton extends StatelessWidget {
  final bool isDark;

  const _Skeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    Widget bar(double w, {double h = 12}) => Container(
          width: w,
          height: h,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: _cShimmer(d, false),
              borderRadius: BorderRadius.circular(6)),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        bar(120, h: 22),
        const SizedBox(height: 12),
        bar(180, h: 16),
        bar(double.infinity),
        bar(double.infinity),
        bar(260),
        const SizedBox(height: 16),
        bar(200, h: 16),
        bar(double.infinity),
        bar(double.infinity),
        bar(230),
      ],
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
                tr('legal.load_failed_body',
                    'Səhifəni yükləyə bilmədik. İnternet bağlantını yoxla.'),
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
