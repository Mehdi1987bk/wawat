import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'support_api.dart';

// ── palette (light from mock + navy dark) ────────────────────────────────────
const _brand = Color(0xFF017BFE);
const _brand700 = Color(0xFF024FA3);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);

const _dBg = Color(0xFF0A0F1A);
const _dElevated = Color(0xFF1C2740);
const _dBar = Color(0xFF0F1728);
const _dLine = Color(0x14FFFFFF);
const _dText = Color(0xFFEAF0FA);
const _dMuted = Color(0xFF6B7B93);
const _dBrandText = Color(0xFF7FB6FF);

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _cScreen(bool d) => d ? _dBg : Colors.white;
Color _cBar(bool d) => d ? _dBar : Colors.white;
Color _cText(bool d) => d ? _dText : _ink900;
Color _cText2(bool d) => d ? _dText : _ink700;
Color _cMuted(bool d) => d ? _dMuted : _ink500;
Color _cLine(bool d) => d ? _dLine : _ink900.withValues(alpha: 0.07);
Color _cField(bool d) => d ? _dElevated : _ink900.withValues(alpha: 0.02);
Color _cBrandText(bool d) => d ? _dBrandText : _brand;
Color _cBrandSoft(bool d) =>
    d ? _brand.withValues(alpha: 0.14) : const Color(0xFFEAF3FE);

class _Topic {
  final String label;
  final String code;
  const _Topic(this.label, this.code);
}

const _topics = [
  _Topic('Ümumi', 'general'),
  _Topic('Ödəniş', 'payment'),
  _Topic('Hesab', 'account'),
  _Topic('Texniki', 'technical'),
  _Topic('Təklif', 'suggestion'),
];

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportApi _api = SupportApi();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String _topic = 'general';
  bool _submitting = false;
  bool _sent = false;
  String _ticket = '';

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _toast(String m) {
    final d = _dark(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: d ? _dElevated : _ink900,
      content: Text(m,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700)),
    ));
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final subject = _subject.text.trim();
    final body = _body.text.trim();
    if (subject.isEmpty || body.isEmpty) {
      _toast('Başlıq və mesajı doldur.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final ticket =
          await _api.submit(category: _topic, subject: subject, body: body);
      if (ticket == null) {
        // Endpoint not live yet → open a mail draft so nothing is lost.
        await _api.mailtoDraft(subject: subject, body: body);
      }
      if (!mounted) return;
      setState(() {
        _sent = true;
        _ticket = ticket ?? _localTicket();
      });
    } catch (_) {
      if (mounted) _toast('Göndərilmədi. Yenidən yoxla.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _localTicket() =>
      'SP-${DateTime.now().millisecondsSinceEpoch % 100000}';

  @override
  Widget build(BuildContext context) {
    final d = _dark(context);
    return Scaffold(
      backgroundColor: _cScreen(d),
      appBar: AppBar(
        backgroundColor: _cBar(d),
        surfaceTintColor: _cBar(d),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(PhosphorIconsBold.arrowLeft, color: _cText2(d), size: 21),
        ),
        title: Text('Dəstəyə yaz',
            style: TextStyle(
                color: _cText(d), fontSize: 17, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _cLine(d)),
        ),
      ),
      body: _sent ? _successView(d) : _form(d),
    );
  }

  // ── form ────────────────────────────────────────────────────────────────────
  Widget _form(bool d) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _cBrandSoft(d), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: d ? _dElevated : Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(PhosphorIconsFill.headset,
                    size: 20, color: _cBrandText(d)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Adətən '),
                    TextSpan(
                        text: '24 saat',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: d ? _dBrandText : _brand700)),
                    const TextSpan(
                        text: ' ərzində cavablayırıq. Sorğunu ətraflı yaz.'),
                  ]),
                  style: TextStyle(
                      color: d ? _dBrandText : _brand700,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _label(d, 'Mövzu'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _topics.map((t) => _pill(d, t)).toList(),
        ),
        const SizedBox(height: 16),
        _label(d, 'Başlıq'),
        const SizedBox(height: 8),
        _field(d, _subject, 'Qısa başlıq'),
        const SizedBox(height: 16),
        _label(d, 'Mesaj'),
        const SizedBox(height: 8),
        _field(d, _body, 'Problemi və ya sualını ətraflı yaz…', lines: 5),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toast('Şəkil əlavə etmə tezliklə'),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _cField(d),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: d
                      ? Colors.white.withValues(alpha: 0.14)
                      : _ink900.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.paperclip,
                    size: 16, color: _cMuted(d)),
                const SizedBox(width: 8),
                Text('Şəkil əlavə et (ops.)',
                    style: TextStyle(
                        color: _cMuted(d),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _primaryButton(
          label: 'Göndər',
          icon: PhosphorIconsBold.paperPlaneTilt,
          busy: _submitting,
          onTap: _submit,
        ),
      ],
    );
  }

  Widget _label(bool d, String t) => Text(t,
      style: TextStyle(
          color: _cText2(d), fontSize: 12.5, fontWeight: FontWeight.w700));

  Widget _pill(bool d, _Topic t) {
    final on = _topic == t.code;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _topic = t.code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? _cBrandSoft(d) : (d ? _dElevated : Colors.white),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
              color:
                  on ? (d ? _brand : _brand.withValues(alpha: 0.5)) : _cLine(d),
              width: on ? 1.4 : 1),
        ),
        child: Text(t.label,
            style: TextStyle(
                color: on ? _cBrandText(d) : _cText2(d),
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _field(bool d, TextEditingController c, String hint, {int lines = 1}) {
    return TextField(
      controller: c,
      maxLines: lines,
      minLines: lines,
      style: TextStyle(
          color: _cText(d), fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _cMuted(d), fontWeight: FontWeight.w500),
        filled: true,
        fillColor: _cField(d),
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
    );
  }

  // ── success ─────────────────────────────────────────────────────────────────
  Widget _successView(bool d) {
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
                color: d ? const Color(0x2910B981) : const Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIconsFill.checkCircle,
                  size: 48,
                  color: d ? const Color(0xFF4FD6A0) : const Color(0xFF10B981)),
            ),
            const SizedBox(height: 16),
            Text('Mesajın göndərildi',
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Müraciət nömrən '),
                TextSpan(
                    text: '#$_ticket',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: _cText2(d))),
                const TextSpan(
                    text: '. Cavabı e-poçt və bildirişlə alacaqsan.'),
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: _primaryButton(
                label: 'Bağla',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    IconData? icon,
    bool busy = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.6 : 1,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _brand.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
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
                    if (icon != null) ...[
                      Icon(icon, size: 17, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
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
