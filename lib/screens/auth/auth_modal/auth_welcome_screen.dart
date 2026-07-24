import 'package:flutter/material.dart';

import '../../../presentation/bloc/base_screen.dart';
import 'auth_welcome_bloc.dart';

class AuthWelcomeScreen extends BaseScreen<AuthWelcomeBloc> {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  AuthWelcomeScreen({
    Key? key,
    required this.onRegister,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<AuthWelcomeScreen> createState() => _AuthWelcomeScreenState();
}

class _AuthWelcomeScreenState
    extends BaseState<AuthWelcomeScreen, AuthWelcomeBloc> {
  static const _brand = Color(0xFF0271EB);
  static const _brandDark = Color(0xFF023E80);

  @override
  Widget body() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_brand, _brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Qonaq',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 238,
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Image.asset(
                        'asset/wawatair_primary.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Səyahət et, bağlama daşı, qazan. Etibarlı crowdshipping icması.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _WhiteButton(
                text: 'Qeydiyyatdan keç',
                onPressed: widget.onRegister,
              ),
              const SizedBox(height: 12),
              _GlassButton(
                text: 'Daxil ol',
                onPressed: widget.onLogin,
              ),
              const SizedBox(height: 16),
              const _DividerLabel(text: 'və ya'),
              const SizedBox(height: 16),
              const _OAuthButton(
                text: 'Google ilə davam et',
                icon: Icons.g_mobiledata,
              ),
              const SizedBox(height: 10),
              const _OAuthButton(
                text: 'Apple ilə davam et',
                icon: Icons.apple,
                isDark: true,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Qonaq kimi davam et',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  AuthWelcomeBloc provideBloc() => AuthWelcomeBloc();
}

class _WhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _WhiteButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: _AuthWelcomeScreenState._brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GlassButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;

  const _OAuthButton({
    required this.text,
    required this.icon,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDark ? Colors.black : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF111827);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: null,
        icon: Icon(icon, size: 24),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          disabledBackgroundColor: background.withValues(alpha: 0.65),
          disabledForegroundColor: foreground.withValues(alpha: 0.65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final String text;

  const _DividerLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.25))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.25))),
      ],
    );
  }
}
