import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'referral_api.dart';

// ── palette ──────────────────────────────────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _brand700 = Color(0xFF024FA3);
const _accent = Color(0xFFF2FC2A);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink400 = Color(0xFF94A3B8);
const _screenLight = Color(0xFFEEF1F6);

const _dBg = Color(0xFF0A0F1A);
const _dSurface = Color(0xFF141D2E);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dText2 = Color(0xFF9FB0C7);
const _dMuted = Color(0xFF6B7B93);
const _dBrandText = Color(0xFF7FB6FF);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cScreen(bool d) => d ? _dBg : _screenLight;
Color _cSurface(bool d) => d ? _dSurface : Colors.white;
Color _cBar(bool d) => d ? _dBar : Colors.white;
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText2 : _ink700;
Color _cMuted(bool d) => d ? _dMuted : _ink400;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.06);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);
Color _cAmberBg(bool d) =>
    d ? const Color(0x29F5B40A) : const Color(0xFFFFFBEB);
Color _cAmberText(bool d) =>
    d ? const Color(0xFFF4C64D) : const Color(0xFFD97706);
Color _cEmeraldBg(bool d) =>
    d ? const Color(0x2910B981) : const Color(0xFFECFDF5);
Color _cEmeraldText(bool d) =>
    d ? const Color(0xFF4FD6A0) : const Color(0xFF059669);

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

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralApi _api = ReferralApi();
  ReferralInfo _info = const ReferralInfo.empty();
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
      final info = await _api.getInfo();
      if (mounted) setState(() => _info = info);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _shareText {
    final code = _info.code.isEmpty ? '' : ' Kod: ${_info.code}.';
    final link =
        _info.shareLink.isEmpty ? 'https://wawatair.com' : _info.shareLink;
    return 'Wawatair-ə qoşul, hər ikimiz ${_info.rewardAmount.round()} ${_info.currencySymbol} qazanaq!$code $link';
  }

  void _toast(String m) {
    final d = _dark(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: d ? const Color(0xFF1C2740) : _ink900,
      content: Text(m,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700)),
    ));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _info.code));
    _toast('Kod kopyalandı');
  }

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlay(d),
      child: Scaffold(
        backgroundColor: _cScreen(d),
        appBar: _appBar(context, d, 'Dostunu dəvət et'),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: _cBrandText(d)))
            : _error != null
                ? _ErrorView(onRetry: _load)
                : _content(d),
      ),
    );
  }

  Widget _content(bool d) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _hero(),
        const SizedBox(height: 20),
        _step(d, 1, 'Linki paylaş', 'dostuna dəvət linkini göndər.'),
        const SizedBox(height: 12),
        _step(d, 2, 'Dostun qoşulur', 'link ilə qeydiyyatdan keçir.'),
        const SizedBox(height: 12),
        _step(d, 3, 'İkiniz də qazanırsınız',
            'ilk sifarişdən sonra ${_info.rewardAmount.round()} ${_info.currencySymbol} promokod.'),
        const SizedBox(height: 20),
        _codeCard(d),
        const SizedBox(height: 16),
        _shareRow(d),
        const SizedBox(height: 20),
        _stats(d),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  ReferralInvitesScreen(rewardAmount: _info.rewardAmount))),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dəvət etdiklərim',
                    style: TextStyle(
                        color: _cBrandText(d),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(PhosphorIconsBold.arrowRight,
                    size: 14, color: _cBrandText(d)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F7BF4), Color(0xFF0257AE)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -12,
              top: -12,
              child: Icon(PhosphorIconsFill.gift,
                  size: 110, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(PhosphorIconsFill.gift,
                      size: 30, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Dostunu dəvət et,\nhər ikiniz '),
                      TextSpan(
                          text:
                              '${_info.rewardAmount.round()} ${_info.currencySymbol}',
                          style: const TextStyle(color: _accent)),
                      const TextSpan(text: ' qazanın'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dostun ilk sifarişini tamamlayanda promokod hər ikinizə gedir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(bool d, int n, String title, String rest) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: _cBrandSoft(d), shape: BoxShape.circle),
          child: Text('$n',
              style: TextStyle(
                  color: _cBrandText(d),
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '$title ',
                    style: TextStyle(
                        color: _cText(d), fontWeight: FontWeight.w800)),
                TextSpan(text: '— $rest'),
              ]),
              style: TextStyle(
                  color: _cText2(d), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _codeCard(bool d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cBrandSoft(d),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _brand.withValues(alpha: d ? 0.4 : 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DƏVƏT KODUN',
              style: TextStyle(
                  color: (d ? _dBrandText : _brand700).withValues(alpha: 0.7),
                  fontSize: 10.5,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(_info.code.isEmpty ? '—' : _info.code,
                    style: TextStyle(
                        color: d ? _dBrandText : _brand700,
                        fontSize: 19,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _info.code.isEmpty ? null : _copy,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: d ? _dSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(PhosphorIconsBold.copy,
                      size: 16, color: _cBrandText(d)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shareRow(bool d) {
    final link =
        _info.shareLink.isEmpty ? 'https://wawatair.com' : _info.shareLink;
    return Row(
      children: [
        _shareItem(
            d,
            PhosphorIconsFill.whatsappLogo,
            const Color(0xFF25D366),
            'WhatsApp',
            () => _openUrl(
                'https://wa.me/?text=${Uri.encodeComponent(_shareText)}')),
        _shareItem(
            d,
            PhosphorIconsFill.telegramLogo,
            const Color(0xFF229ED9),
            'Telegram',
            () => _openUrl(
                'https://t.me/share/url?url=${Uri.encodeComponent(link)}&text=${Uri.encodeComponent(_shareText)}')),
        _shareItem(d, PhosphorIconsBold.linkSimple, _brand, 'Kopyala', () {
          Clipboard.setData(ClipboardData(text: _shareText));
          _toast('Link kopyalandı');
        }, softBrand: true),
        _shareItem(d, PhosphorIconsBold.dotsThree, _cText2(d), 'Digər',
            () => Share.share(_shareText),
            neutral: true),
      ],
    );
  }

  Widget _shareItem(
      bool d, IconData icon, Color color, String label, VoidCallback onTap,
      {bool softBrand = false, bool neutral = false}) {
    final bg = softBrand
        ? _cBrandSoft(d)
        : neutral
            ? (d
                ? Colors.white.withValues(alpha: 0.06)
                : _ink900.withValues(alpha: 0.05))
            : color.withValues(alpha: 0.1);
    final fg = softBrand ? _cBrandText(d) : color;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, size: 22, color: fg),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: _cText2(d),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _stats(bool d) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
          _statCell(d, '${_info.invited}', 'Dəvət'),
          _statDivider(d),
          _statCell(d, '${_info.joined}', 'Qoşulan'),
          _statDivider(d),
          _statCell(
              d, '${_info.earned.round()} ${_info.currencySymbol}', 'Qazanılan',
              brand: true),
        ],
      ),
    );
  }

  Widget _statCell(bool d, String value, String label, {bool brand = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: brand ? _cBrandText(d) : _cText(d),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statDivider(bool d) =>
      Container(width: 1, height: 32, color: _cLine(d));
}

// ── Invited list ─────────────────────────────────────────────────────────────
class ReferralInvitesScreen extends StatefulWidget {
  final num rewardAmount;

  const ReferralInvitesScreen({super.key, this.rewardAmount = 5});

  @override
  State<ReferralInvitesScreen> createState() => _ReferralInvitesScreenState();
}

class _ReferralInvitesScreenState extends State<ReferralInvitesScreen> {
  final ReferralApi _api = ReferralApi();
  List<ReferralInvite> _items = const [];
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
      final items = await _api.getInvites();
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
        appBar: _appBar(context, d, 'Dəvət etdiklərim'),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: _cBrandText(d)))
            : _error != null
                ? _ErrorView(onRetry: _load)
                : _items.isEmpty
                    ? _empty(d)
                    : _list(d),
      ),
    );
  }

  Widget _list(bool d) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: _cLine(d), indent: 60),
      itemBuilder: (context, i) {
        final it = _items[i];
        return Container(
          color: _cSurface(d),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: it.isRewarded
                        ? _cBrandSoft(d)
                        : (d
                            ? Colors.white.withValues(alpha: 0.06)
                            : _ink900.withValues(alpha: 0.06)),
                    shape: BoxShape.circle),
                child: Text(it.isRewarded ? it.initials : '?',
                    style: TextStyle(
                        color: it.isRewarded ? _cBrandText(d) : _cMuted(d),
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        it.isRewarded && it.name.isNotEmpty
                            ? it.name
                            : 'Dəvət olunub',
                        style: TextStyle(
                            color: _cText(d),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700)),
                    Text(
                        it.isRewarded
                            ? 'Qoşulub${it.displayDate == null ? '' : ' · ${_fmtDate(it.displayDate!)}'}'
                            : 'İlk sifariş gözlənilir',
                        style: TextStyle(
                            color: _cMuted(d),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (it.isRewarded)
                _chip(
                    d,
                    it.statusLabel.isNotEmpty
                        ? it.statusLabel
                        : '+${widget.rewardAmount.round()} \$',
                    _cEmeraldBg(d),
                    _cEmeraldText(d))
              else
                _chip(
                    d,
                    it.statusLabel.isNotEmpty ? it.statusLabel : 'Gözləyir',
                    _cAmberBg(d),
                    _cAmberText(d),
                    icon: PhosphorIconsFill.clock),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(bool d, String label, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _empty(bool d) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _cBrandSoft(d),
                  borderRadius: BorderRadius.circular(22)),
              child: Icon(PhosphorIconsFill.userPlus,
                  size: 30, color: _cBrandText(d)),
            ),
            const SizedBox(height: 14),
            Text('Hələ heç kimi dəvət etməmisən',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cText2(d),
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Linki paylaş — dostların burada görünəcək.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: _brand, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(PhosphorIconsFill.shareFat,
                        size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Dəvət linkini paylaş',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
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

// ── Shared error view ────────────────────────────────────────────────────────
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
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: d ? const Color(0x1FEF4444) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(PhosphorIconsRegular.wifiSlash,
                  size: 34,
                  color: d ? const Color(0xFFFF9A9A) : const Color(0xFFEF4444)),
            ),
            const SizedBox(height: 14),
            Text('Bağlantı yoxdur',
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: _brand, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(PhosphorIconsBold.arrowClockwise,
                        size: 15, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Yenidən cəhd et',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
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
