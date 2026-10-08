import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/network/api/email_otp_api.dart';
import '../../../presentation/common/async_button.dart';
import '../../../presentation/common/otp_code_input.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/localization_service.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat_app.dart';
import 'email_otp_state.dart';

/// Opens the e-mail OTP screen when the backend flag is on and the account is
/// not yet verified. A single funnel for every trigger (register, login,
/// cold-start, a global 403, the profile banner) so the `busy` guard can stop
/// the screen from being stacked when two triggers fire at once.
///
/// It is a no-op while the flag is off (`required == false`) — exactly today's
/// behaviour — so wiring it in is safe before the flag is ever flipped.
Future<void> presentEmailOtpIfRequired({
  required bool autoSend,
  int initialCooldownSeconds = 0,
  bool forceRefresh = true,
}) async {
  final state = EmailOtpState.instance;
  if (state.busy) return;
  state.busy = true;
  try {
    if (forceRefresh) {
      try {
        await state.refresh();
      } catch (_) {
        return; // offline / not authed → never block the user.
      }
    }
    if (!state.required || state.verified) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    await nav.push(
      MaterialPageRoute(
        builder: (_) => EmailOtpScreen(
          email: state.email,
          autoSend: autoSend,
          initialCooldownSeconds: initialCooldownSeconds,
        ),
      ),
    );
  } finally {
    state.busy = false;
  }
}

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({
    super.key,
    required this.email,
    this.autoSend = false,
    this.initialCooldownSeconds = 0,
  });

  final String email;

  /// Request a code as the screen opens (login / 403 — no fresh code yet). On
  /// register this is false: the server already sent the first code.
  final bool autoSend;

  /// Seconds the resend button stays locked when the screen opens (60 right
  /// after register, where the server just sent a code).
  final int initialCooldownSeconds;

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  static const _brand = Color(0xFF0271EB);

  late final EmailOtpApi _api = EmailOtpApi();

  String _code = '';
  String? _error;
  int _cooldown = 0;
  int _resetToken = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialCooldownSeconds > 0) {
      _startCooldown(widget.initialCooldownSeconds);
    }
    if (widget.autoSend && !EmailOtpState.instance.codeSentThisSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    if (seconds <= 0) {
      setState(() => _cooldown = 0);
      return;
    }
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  /// CMS key `auth.otp_resend_wait` ships a `:seconds` token (colon style),
  /// which `tr()` does not substitute — handle both `{seconds}` and `:seconds`.
  String _resendWaitText() {
    final secs = '$_cooldown';
    var s = tr('auth.otp_resend_wait', '{seconds} saniyə gözləyin',
        {'seconds': secs});
    return s.replaceAll(':seconds', secs);
  }

  void _toast(String message, {bool error = false}) {
    if (message.trim().isEmpty) return;
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Colors.red.shade600 : null,
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  Future<void> _send() async {
    try {
      final res = await _api.sendCode();
      EmailOtpState.instance.codeSentThisSession = true;
      if (!mounted) return;
      setState(() => _error = null);
      _startCooldown(res.resendAvailableInSeconds);
      _toast(tr('auth.email_otp_sent', 'Kod e-poçtunuza göndərildi.'));
    } on EmailOtpException catch (e) {
      if (!mounted) return;
      if (e.isConflict) {
        _finishVerified(
            tr('auth.email_already_verified', 'E-poçt artıq təsdiqlənib.'));
        return;
      }
      // Rate-limited or send-limit: show the server text, keep the timer honest
      // (never unlock the button early), honour a server-sent cooldown.
      if (_cooldown == 0 &&
          (e.resendAvailableInSeconds ?? 0) > 0) {
        _startCooldown(e.resendAvailableInSeconds!);
      }
      _toast(
        e.message ?? tr('auth.otp_send_limit', 'Göndərmə limiti bitib.'),
        error: true,
      );
    } catch (_) {
      if (!mounted) return;
      _toast(tr('error.request_failed', 'Sorğu alınmadı'), error: true);
    }
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;
    try {
      final ok = await _api.verify(_code);
      if (!mounted) return;
      if (ok) {
        _finishVerified(tr('auth.email_verified', 'E-poçt təsdiqləndi.'));
        return;
      }
      _showInlineError(tr('auth.otp_invalid', 'Kod yanlışdır.'));
    } on EmailOtpException catch (e) {
      if (!mounted) return;
      if (e.isConflict) {
        _finishVerified(
            tr('auth.email_already_verified', 'E-poçt artıq təsdiqlənib.'));
        return;
      }
      _showInlineError(e.message ?? tr('auth.otp_invalid', 'Kod yanlışdır.'));
      // "Code not requested" recovery: if nothing was sent this run and resend
      // is free, request a fresh code automatically (spec endpoint-2 fallback).
      if (!EmailOtpState.instance.codeSentThisSession && _cooldown == 0) {
        _send();
      }
    } catch (_) {
      if (!mounted) return;
      _showInlineError(tr('error.request_failed', 'Sorğu alınmadı'));
    }
  }

  void _showInlineError(String message) {
    setState(() {
      _error = message;
      _code = '';
      _resetToken++;
    });
  }

  void _finishVerified(String toast) {
    EmailOtpState.instance.markVerified();
    _toast(toast);
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final titleColor = isDark ? WawatDark.textPrimary : const Color(0xFF111827);
    final bodyColor =
        isDark ? WawatDark.textSecondary : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor:
          isDark ? WawatDark.bg : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Icon(Icons.arrow_back, color: titleColor),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        WawatDark.brandSoft,
                                        WawatDark.brandSoft,
                                      ]
                                    : const [
                                        Color(0xFFEAF3FE),
                                        Color(0xFFDCEBFD),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color:
                                            _brand.withValues(alpha: 0.22),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              color: isDark ? WawatDark.brandText : _brand,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          tr('auth.email_otp_title', 'E-poçtu təsdiqlə'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSubtitle(isDark, bodyColor),
                        const SizedBox(height: 32),
                        OtpCodeInput(
                          hasError: _error != null,
                          resetToken: _resetToken,
                          onChanged: (code) {
                            final wasReady = _code.length == 6;
                            final isReady = code.length == 6;
                            _code = code;
                            if (wasReady != isReady) setState(() {});
                          },
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          child: _error == null
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: _ErrorPill(message: _error!, isDark: isDark),
                                ),
                        ),
                        const SizedBox(height: 28),
                        AsyncActionButton(
                          height: 54,
                          borderRadius: 16,
                          color: _brand,
                          disabled: _code.length != 6,
                          boxShadow: (_code.length == 6 && !isDark)
                              ? [
                                  BoxShadow(
                                    color: _brand.withValues(alpha: 0.34),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : null,
                          onPressed: _verify,
                          child: Text(
                            tr('common.confirm', 'Təsdiqlə'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildResend(isDark, bodyColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Subtitle with the e-mail address highlighted in brand colour. The CMS
  /// string carries the address via a `{email}` placeholder, so we resolve it,
  /// then split on the address to colour just that span.
  Widget _buildSubtitle(bool isDark, Color bodyColor) {
    final resolved = tr(
      'auth.email_otp_subtitle',
      '{email} ünvanına göndərdiyimiz 6 rəqəmli kodu daxil et.',
      {'email': widget.email},
    );
    final base = TextStyle(color: bodyColor, fontSize: 14.5, height: 1.45);
    final brandStyle = base.copyWith(
      color: isDark ? WawatDark.brandText : _brand,
      fontWeight: FontWeight.w700,
    );

    final email = widget.email;
    final idx = email.isEmpty ? -1 : resolved.indexOf(email);
    final List<InlineSpan> spans;
    if (idx < 0) {
      spans = [TextSpan(text: resolved)];
    } else {
      spans = [
        if (idx > 0) TextSpan(text: resolved.substring(0, idx)),
        TextSpan(text: email, style: brandStyle),
        if (idx + email.length < resolved.length)
          TextSpan(text: resolved.substring(idx + email.length)),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(style: base, children: spans),
      ),
    );
  }

  /// Resend row: a muted countdown while locked, a tappable brand link once the
  /// cooldown clears. Each carries a small leading icon.
  Widget _buildResend(bool isDark, Color bodyColor) {
    final brandColor = isDark ? WawatDark.brandText : _brand;
    if (_cooldown > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: bodyColor),
          const SizedBox(width: 6),
          Text(
            _resendWaitText(),
            style: TextStyle(
              color: bodyColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _send,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, size: 18, color: brandColor),
            const SizedBox(width: 6),
            Text(
              tr('auth.code_not_received_resend',
                  'Kod gəlmədi? Yenidən göndər'),
              style: TextStyle(
                color: brandColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft red pill that holds the inline verify error (wrong / expired code).
class _ErrorPill extends StatelessWidget {
  const _ErrorPill({required this.message, required this.isDark});

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color fg = isDark ? const Color(0xFFFFB4B4) : const Color(0xFFD92D20);
    final Color bg =
        isDark ? const Color(0x33F04438) : const Color(0xFFFEF3F2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0x55F04438) : const Color(0xFFFEE4E2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: fg),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
