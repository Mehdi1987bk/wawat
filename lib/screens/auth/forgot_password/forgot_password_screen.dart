import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../presentation/bloc/base_screen.dart';
import '../../../services/theme_manager.dart';
import '../login/login_screen.dart';
import 'forgot_password_bloc.dart';

class ForgotPasswordScreen extends BaseScreen<ForgotPasswordBloc> {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends BaseState<ForgotPasswordScreen, ForgotPasswordBloc> {
  static const _brand = Color(0xFF0271EB);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _step = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _secondsRemaining = 0;
  Timer? _timer;
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
    _confirmPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _message = null;
      _fieldErrors = {};
    });
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() => _secondsRemaining = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _otp =>
      _otpControllers.map((controller) => controller.text).join();

  Future<void> _requestOtp({bool isResend = false}) async {
    _clearErrors();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _fieldErrors = {'email': 'Email mütləqdir.'});
      return;
    }

    final result = await bloc.requestOtp(email);
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _step = 1);
      _startTimer(bloc.expiresInSeconds);
      if (isResend) {
        _clearOtp();
      }
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  Future<void> _verifyOtp() async {
    _clearErrors();
    if (_otp.length != 6) {
      setState(() => _fieldErrors = {'otp': '6 rəqəmli kodu daxil edin.'});
      return;
    }

    final result = await bloc.verifyOtp(_otp);
    if (!mounted) return;

    if (result.isSuccess) {
      _timer?.cancel();
      setState(() => _step = 2);
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  Future<void> _resetPassword() async {
    _clearErrors();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    if (password.length < 8) {
      setState(
          () => _fieldErrors = {'password': 'Minimum 8 simvol olmalıdır.'});
      return;
    }
    if (password != confirmation) {
      setState(() => _fieldErrors = {
            'password_confirmation': 'Şifrələr uyğun gəlmir.',
          });
      return;
    }

    final result = await bloc.resetPassword(password, confirmation);
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _step = 3);
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  void _clearOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes.first.requestFocus();
  }

  void _goBack() {
    if (_step == 0 || _step == 3) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _message = null;
      _fieldErrors = {};
      _step--;
    });
  }

  @override
  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final bodyColor =
        isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4B5563);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
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
                onTap: _goBack,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildStep(isDark, titleColor, bodyColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(bool isDark, Color titleColor, Color bodyColor) {
    if (_step == 3) {
      return _buildSuccessStep(titleColor, bodyColor);
    }

    return Center(
      key: ValueKey(_step),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIndicator(currentStep: _step),
            const SizedBox(height: 28),
            Text(
              _step == 0
                  ? 'Şifrəni bərpa et'
                  : _step == 1
                      ? 'Kodu yaz'
                      : 'Yeni şifrə',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 0
                  ? 'Email-ini yaz - təsdiq kodu göndərək.'
                  : _step == 1
                      ? '${_emailController.text.trim()} ünvanına gələn 6 rəqəmli kod.'
                      : 'Yeni şifrəni təyin et.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bodyColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 18),
              _AlertBox(message: _message!, isDark: isDark),
            ],
            const SizedBox(height: 28),
            if (_step == 0) _buildEmailStep(isDark),
            if (_step == 1) _buildOtpStep(isDark, bodyColor),
            if (_step == 2) _buildPasswordStep(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthField(
          label: 'Email',
          hint: 'ad@nümunə.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          error: _fieldErrors['email'],
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          text: _isLoading ? 'Göndərilir...' : 'Kod göndər',
          onPressed: _isLoading ? null : _requestOtp,
        ),
      ],
    );
  }

  Widget _buildOtpStep(bool isDark, Color bodyColor) {
    final otpError = _fieldErrors['otp'];
    final isExpired = _secondsRemaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
              child: _OtpBox(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                isDark: isDark,
                hasError: otpError != null,
                enabled: !isExpired,
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        if (otpError != null) ...[
          const SizedBox(height: 12),
          Text(
            otpError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (isExpired)
          _PrimaryButton(
            text: 'Yeni kod göndər',
            onPressed: _isLoading ? null : () => _requestOtp(isResend: true),
          )
        else
          _PrimaryButton(
            text: _isLoading ? 'Yoxlanılır...' : 'Təsdiqlə',
            onPressed: _isLoading ? null : _verifyOtp,
          ),
        const SizedBox(height: 18),
        Text(
          isExpired ? 'Kodun vaxtı bitib.' : 'Kodun vaxtı: $_timerText',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isExpired ? Colors.orange.shade600 : bodyColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!isExpired) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isLoading ? null : () => _requestOtp(isResend: true),
            child: const Text(
              'Kod gəlmədi? Yenidən göndər',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _brand,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthField(
          label: 'Yeni şifrə',
          hint: 'Minimum 8 simvol',
          controller: _passwordController,
          obscureText: _obscurePassword,
          error: _fieldErrors['password'],
          isDark: isDark,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? const Color(0xFF9CA3AF) : null,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Təsdiqlə',
          hint: 'Təkrar yaz',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          error: _fieldErrors['password_confirmation'],
          isDark: isDark,
          suffix: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? const Color(0xFF9CA3AF) : null,
            ),
            onPressed: () {
              setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          text: _isLoading ? 'Yenilənir...' : 'Şifrəni yenilə',
          onPressed: _isLoading ? null : _resetPassword,
        ),
      ],
    );
  }

  Widget _buildSuccessStep(Color titleColor, Color bodyColor) {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 84,
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 120),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 52,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Şifrə yeniləndi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Şifrəniz uğurla dəyişdirildi. Artıq yeni şifrəniz ilə daxil ola bilərsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bodyColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(
            text: 'Daxil ol',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  ForgotPasswordBloc provideBloc() => ForgotPasswordBloc();
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= currentStep;
        return Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isActive
                    ? _ForgotPasswordScreenState._brand
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: index < currentStep
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:
                            isActive ? Colors.white : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
            ),
            if (index < 2)
              Container(
                width: 26,
                height: 2,
                color: index < currentStep
                    ? _ForgotPasswordScreenState._brand
                    : Colors.black.withValues(alpha: 0.08),
              ),
          ],
        );
      }),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? error;
  final bool isDark;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.error,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final labelColor =
        isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
    final inputColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final hintColor =
        isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          cursorColor: _ForgotPasswordScreenState._brand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            suffixIcon: suffix,
            filled: true,
            fillColor: inputColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color:
                    hasError ? Colors.red : _ForgotPasswordScreenState._brand,
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        enabled: enabled,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red.shade300 : Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : _ForgotPasswordScreenState._brand,
              width: 1.5,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
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
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor:
              _ForgotPasswordScreenState._brand.withValues(alpha: 0.5),
          backgroundColor: _ForgotPasswordScreenState._brand,
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

class _AlertBox extends StatelessWidget {
  final String message;
  final bool isDark;

  const _AlertBox({
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A1E1E) : Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.red.shade100 : Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
