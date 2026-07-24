import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../presentation/bloc/base_screen.dart';
import '../../../services/theme_manager.dart';
import '../../home/home_screen.dart';
import '../forgot_password/forgot_password_modal.dart';
import '../registration/registration_screen.dart';
import 'login_bloc.dart';

class LoginScreen extends BaseScreen<LoginBloc> {
  final VoidCallback? onRegister;

  LoginScreen({
    Key? key,
    this.onRegister,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen, LoginBloc> {
  static const _brand = Color(0xFF0271EB);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _remember = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _message;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    bloc.loadingStream.listen((value) {
      if (mounted) setState(() => _isLoading = value);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _message = null;
      _fieldErrors = {};
    });

    final result = await bloc.login(
      _emailController.text.trim(),
      _passwordController.text,
      remember: _remember,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  bool get _isSuspendedMessage {
    final value = (_message ?? '').toLowerCase();
    return value.contains('məhdud') || value.contains('suspended');
  }

  Future<void> _contactSupport() async {
    final uri = Uri(scheme: 'mailto', path: 'support@wawatair.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openRegister() {
    if (widget.onRegister != null) {
      widget.onRegister!();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RegistrationScreen()),
    );
  }

  @override
  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final bodyColor =
        isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4B5563);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Icon(Icons.arrow_back, color: titleColor),
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  _LogoMark(size: 56),
                  const SizedBox(height: 14),
                  Text(
                    'Xoş gəldin',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hesabına daxil ol',
                    style: TextStyle(
                      fontSize: 14,
                      color: bodyColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 22),
              _AlertBox(
                message: _message!,
                isWarning: _message!.toLowerCase().contains('cəhd'),
              ),
            ],
            const SizedBox(height: 22),
            _AuthField(
              label: 'Email',
              hint: 'ad@nümunə.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              error: _fieldErrors['email'],
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: 'Şifrə',
              hint: '••••••••',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              error: _fieldErrors['password'],
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark ? const Color(0xFF9CA3AF) : null,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  activeColor: _brand,
                  onChanged: (value) {
                    setState(() => _remember = value ?? true);
                  },
                ),
                Expanded(
                  child: Text(
                    'Məni xatırla',
                    style: TextStyle(color: bodyColor),
                  ),
                ),
                TextButton(
                  onPressed: () => ForgotPasswordModal.show(context),
                  child: const Text(
                    'Şifrənizi unutmusunuz?',
                    style: TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PrimaryButton(
              text: _isLoading ? 'Daxil olunur...' : 'Daxil ol',
              onPressed: _isLoading ? null : _login,
            ),
            if (_isSuspendedMessage) ...[
              const SizedBox(height: 12),
              _OutlineButton(
                text: 'Dəstək ilə əlaqə',
                icon: Icons.support_agent_outlined,
                onPressed: _contactSupport,
              ),
            ],
            const SizedBox(height: 24),
            _DividerLabel(text: 'və ya'),
            const SizedBox(height: 18),
            _OutlineButton(
              text: 'Google ilə davam et',
              icon: Icons.g_mobiledata,
              onPressed: null,
            ),
            const SizedBox(height: 10),
            _OutlineButton(
              text: 'Apple ilə davam et',
              icon: Icons.apple,
              onPressed: null,
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Hesabın yoxdur? ',
                    style: TextStyle(color: bodyColor),
                  ),
                  GestureDetector(
                    onTap: _openRegister,
                    child: const Text(
                      'Qeydiyyatdan keç',
                      style: TextStyle(
                        color: _brand,
                        fontWeight: FontWeight.w700,
                      ),
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
  LoginBloc provideBloc() => LoginBloc();
}

class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 3.5,
      height: size,
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.28,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset(
        'asset/wawatair_primary.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? error;
  final bool isDark;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.error,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final labelColor =
        isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151);
    final inputColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final hintColor =
        isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          cursorColor: _LoginScreenState._brand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: hintColor),
            suffixIcon: suffix,
            filled: true,
            fillColor: inputColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red : _LoginScreenState._brand,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
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
          backgroundColor: _LoginScreenState._brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              _LoginScreenState._brand.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const _OutlineButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF111827),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  final String message;
  final bool isWarning;

  const _AlertBox({
    required this.message,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.amber : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.timer_outlined : Icons.error_outline,
            color: color.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
