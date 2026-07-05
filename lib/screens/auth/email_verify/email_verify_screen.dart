import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../services/theme_manager.dart';
import '../../home/home_screen.dart';
import 'email_verify_bloc.dart';

class EmailVerifyScreen extends BaseScreen<EmailVerifyBloc> {
  final String email;

  EmailVerifyScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState
    extends BaseState<EmailVerifyScreen, EmailVerifyBloc> {
  static const _brand = Color(0xFF0271EB);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    bloc.loadingStream.listen((value) {
      if (mounted) setState(() => _isLoading = value);
    });
  }

  Future<void> _resend() async {
    final result = await bloc.resendVerificationLink();
    if (!mounted) return;
    showTopSnackbar(
      result.message ?? 'Təsdiq linki email-inizə göndərildi.',
      result.isSuccess,
      context,
    );
  }

  @override
  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final bodyColor =
        isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4B5563);
    final mutedColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Icon(
                  Icons.arrow_back,
                  color: titleColor,
                ),
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: _brand,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Email-ini təsdiqlə',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.email} ünvanına təsdiq linki göndərdik. Linkə klikləyib hesabını aktivləşdir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: bodyColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PrimaryButton(
                    text: _isLoading ? 'Göndərilir...' : 'Linki yenidən göndər',
                    onPressed: _isLoading ? null : _resend,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Davam et',
                      style: TextStyle(
                        color: _brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Məktub gəlmədi? Spam qovluğunu yoxla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  EmailVerifyBloc provideBloc() => EmailVerifyBloc();
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _EmailVerifyScreenState._brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              _EmailVerifyScreenState._brand.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
