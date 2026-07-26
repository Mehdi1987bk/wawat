import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../legal/legal_doc_screen.dart';
import '../promo/rate_app_screen.dart';

// ── palette ──────────────────────────────────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
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
Color _cText2(bool d) => d ? _dText : _ink700;
Color _cMuted(bool d) => d ? _dMuted : _ink400;
Color _cFaint(bool d) => d ? _dFaint : _ink300;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.05);
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);
Color _cSocialBg(bool d) =>
    d ? Colors.white.withValues(alpha: 0.06) : _ink900.withValues(alpha: 0.05);

const _website = 'https://wawatair.com';
const _instagram = 'https://instagram.com/wawatair';
const _facebook = 'https://facebook.com/wawatair';
const _tiktok = 'https://www.tiktok.com/@wawatair';
const _telegram = 'https://t.me/wawatair';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.0';
  String _build = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() {
          _version = info.version;
          _build = info.buildNumber;
        });
      }
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

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
          title: Text('Tətbiq haqqında',
              style: TextStyle(
                  color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _cLine(d)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 28),
            _header(d),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _cSurface(d),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cLine(d)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _row(d, PhosphorIconsFill.star, 'Tətbiqi qiymətləndir',
                      onTap: () => _push(const RateAppScreen())),
                  _row(d, PhosphorIconsFill.globe, 'Veb sayt',
                      trailing: 'wawatair.com', onTap: () => _open(_website)),
                  _row(d, PhosphorIconsFill.fileText, 'İstifadə şərtləri',
                      onTap: () => _push(const LegalDocScreen(
                          slug: 'terms', title: 'İstifadə şərtləri'))),
                  _row(d, PhosphorIconsFill.shieldCheck, 'Məxfilik siyasəti',
                      onTap: () => _push(const LegalDocScreen(
                          slug: 'privacy', title: 'Məxfilik siyasəti'))),
                  _row(d, PhosphorIconsFill.scroll, 'Lisenziyalar',
                      last: true,
                      onTap: () => showLicensePage(
                            context: context,
                            applicationName: 'Wawatair',
                            applicationVersion: _version,
                          )),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text('Bizi izlə',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _social(d, PhosphorIconsFill.instagramLogo, _instagram),
                const SizedBox(width: 12),
                _social(d, PhosphorIconsFill.facebookLogo, _facebook),
                const SizedBox(width: 12),
                _social(d, PhosphorIconsFill.tiktokLogo, _tiktok),
                const SizedBox(width: 12),
                _social(d, PhosphorIconsFill.telegramLogo, _telegram),
              ],
            ),
            const SizedBox(height: 24),
            Text('© 2026 Wawatair · Bütün hüquqlar qorunur',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _header(bool d) {
    final buildLabel = _build.isEmpty ? '' : ' (build $_build)';
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: _brand.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: const Text('W',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        Text('Wawatair',
            style: TextStyle(
                color: _cText(d), fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text('Versiya $_version$buildLabel',
            style: TextStyle(
                color: _cMuted(d), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: d ? const Color(0x2910B981) : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsFill.checkCircle,
                  size: 14,
                  color: d ? const Color(0xFF4FD6A0) : const Color(0xFF059669)),
              const SizedBox(width: 6),
              Text('Ən son versiyadasan',
                  style: TextStyle(
                      color:
                          d ? const Color(0xFF4FD6A0) : const Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(bool d, IconData icon, String label,
      {String? trailing, VoidCallback? onTap, bool last = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: _cLine(d), width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _cBrandSoft(d),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: d ? _dBrandText : _brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: _cText(d),
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            if (trailing != null) ...[
              Text(trailing,
                  style: TextStyle(
                      color: _cMuted(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
            ],
            Icon(PhosphorIconsRegular.caretRight, size: 15, color: _cFaint(d)),
          ],
        ),
      ),
    );
  }

  Widget _social(bool d, IconData icon, String url) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(url),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _cSocialBg(d), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: d ? _dText2 : _ink700),
      ),
    );
  }
}
