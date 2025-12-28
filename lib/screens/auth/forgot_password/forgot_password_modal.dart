import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import 'forgot_password_bloc.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ForgotPasswordModal(),
    );
  }
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _bloc = ForgotPasswordBloc();

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  int _currentStep = 0; // 0 = email, 1 = otp, 2 = new password
  bool _isLoading = false;

  // Timer for OTP
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();

    _bloc.loadingStream.listen((isLoading) {
      if (!mounted) return;
      setState(() => _isLoading = isLoading);
    });

    _bloc.errorStream.listen((error) {
      if (!mounted) return;
      showTopSnackbar(error.toString(), false, context);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bloc.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _secondsRemaining = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Шаг 1: Отправить код на email
  void _handleRequestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showTopSnackbar('Введите email', false, context);
      return;
    }

    final success = await _bloc.requestOtp(email);
    if (success && mounted) {
      setState(() => _currentStep = 1);
      _startTimer(600); // 10 минут
      showTopSnackbar('Код отправлен на $email', true, context);
    }
  }

  /// Шаг 2: Проверить OTP
  void _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      showTopSnackbar('Введите 6-значный код', false, context);
      return;
    }

    final success = await _bloc.verifyOtp(otp);
    if (success && mounted) {
      setState(() => _currentStep = 2);
      _timer?.cancel();
    }
  }

  /// Шаг 3: Установить новый пароль
  void _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || password.length < 6) {
      showTopSnackbar('Пароль минимум 6 символов', false, context);
      return;
    }

    if (password != confirmPassword) {
      showTopSnackbar('Пароли не совпадают', false, context);
      return;
    }

    final success = await _bloc.resetPassword(password, confirmPassword);
    if (success && mounted) {
      showTopSnackbar('Пароль успешно изменён!', true, context);
      Navigator.of(context).pop();
    }
  }

  /// Повторно отправить код
  void _handleResendOtp() async {
    if (_secondsRemaining > 0) return;

    final success = await _bloc.requestOtp(_emailController.text.trim());
    if (success && mounted) {
      _startTimer(600);
      showTopSnackbar('Код отправлен повторно', true, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: WawatDimensions.spacingLg),
          child: Container(
            constraints: BoxConstraints(maxWidth: WawatDimensions.modalMaxWidth),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : WawatColors.backgroundWhite,
              borderRadius: BorderRadius.circular(WawatDimensions.modalBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 8),
                  _buildStepIndicator(isDark),
                  const SizedBox(height: 20),
                  if (_currentStep == 0) _buildEmailStep(isDark),
                  if (_currentStep == 1) _buildOtpStep(isDark),
                  if (_currentStep == 2) _buildPasswordStep(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final titles = ['Забыли пароль?', 'Введите код', 'Новый пароль'];

    return Row(
      children: [
        if (_currentStep > 0)
          IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => setState(() => _currentStep--),
          )
        else
          Image.asset("asset/mini_logo.png", width: 35),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titles[_currentStep],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? const Color(0xFF6366F1) : WawatColors.primary)
                  : (isDark ? Colors.white24 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Введите email, на который зарегистрирован аккаунт',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        WawatInputField(
          label: 'EMAIL',
          placeholder: 'example@mail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          isModal: true,
          isEmail: true,
        ),
        const SizedBox(height: 20),
        WawatButton(
          text: _isLoading ? 'Отправка...' : 'Отправить код',
          onPressed: _isLoading ? null : _handleRequestOtp,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildOtpStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Код отправлен на ${_emailController.text}',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // OTP Input
        _buildOtpInput(isDark),
        const SizedBox(height: 16),

        // Timer & Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_secondsRemaining > 0) ...[
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _timerText,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _isLoading ? null : _handleResendOtp,
                child: Text(
                  'Отправить повторно',
                  style: WawatTextStyles.link.copyWith(
                    color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        WawatButton(
          text: _isLoading ? 'Проверка...' : 'Подтвердить',
          onPressed: _isLoading ? null : _handleVerifyOtp,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildOtpInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
          color: isDark ? Colors.white : Colors.black,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          hintText: '000000',
          hintStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Придумайте новый пароль',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        WawatInputField(
          label: 'НОВЫЙ ПАРОЛЬ',
          placeholder: 'Минимум 6 символов',
          controller: _passwordController,
          obscureText: true,
          isModal: true,
        ),
        const SizedBox(height: 16),

        WawatInputField(
          label: 'ПОДТВЕРДИТЕ ПАРОЛЬ',
          placeholder: 'Повторите пароль',
          controller: _confirmPasswordController,
          obscureText: true,
          isModal: true,
        ),
        const SizedBox(height: 20),

        WawatButton(
          text: _isLoading ? 'Сохранение...' : 'Сохранить пароль',
          onPressed: _isLoading ? null : _handleResetPassword,
          width: double.infinity,
        ),
      ],
    );
  }
}
