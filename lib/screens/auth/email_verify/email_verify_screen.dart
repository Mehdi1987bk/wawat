import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../presentation/common/async_button.dart';
import '../../../presentation/resourses/wawat_dark.dart';
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
    final titleColor = isDark ? WawatDark.textPrimary : const Color(0xFF111827);
    final bodyColor =
        isDark ? WawatDark.textSecondary : const Color(0xFF4B5563);
    final mutedColor = isDark ? WawatDark.textMuted : const Color(0xFF9CA3AF);

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
                      color: isDark
                          ? WawatDark.brandChip
                          : _brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      color: isDark ? WawatDark.brandText : _brand,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Email-ini təsdiqlə',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
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
                    text: 'Linki yenidən göndər',
                    onPressed: _resend,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Davam et',
                      style: TextStyle(
                        color: isDark ? WawatDark.brandText : _brand,
                        fontWeight: FontWeight.w600,
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
  final Future<void> Function()? onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncActionButton(
      height: 48,
      borderRadius: 14,
      color: _EmailVerifyScreenState._brand,
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
