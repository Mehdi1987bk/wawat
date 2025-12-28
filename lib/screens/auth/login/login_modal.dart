import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../forgot_password/forgot_password_modal.dart';
import '../login/login_bloc.dart';

class LoginModal extends StatefulWidget {
  final VoidCallback onRegister;

  const LoginModal({Key? key, required this.onRegister}) : super(key: key);

  @override
  State<LoginModal> createState() => _LoginModalState();

  static Future<void> show(BuildContext context, {required VoidCallback onRegister}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginModal(onRegister: onRegister),
    );
  }
}

class _LoginModalState extends State<LoginModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bloc = LoginBloc();
  bool _isLoading = false;

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
    _passwordController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  /// 🔥 Главное изменение: проверяем success
  void _handleLogin() async {
    final success = await _bloc.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success) return; // ⛔ Не навигируем, если ошибка

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
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
                  // Header
                  Row(
                    children: [
                      Image.asset("asset/mini_logo.png", width: 35),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Вход', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email
                  WawatInputField(
                    label: 'EMAIL',
                    placeholder: 'example@mail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isModal: true,
                    isEmail: true,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  WawatInputField(
                    label: 'ПАРОЛЬ',
                    placeholder: 'Минимум 6 символов',
                    controller: _passwordController,
                    obscureText: true,
                    isModal: true,
                  ),
                  const SizedBox(height: 12),
// Forgot password link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      ForgotPasswordModal.show(context);
                    },
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          'Забыли пароль?',
                          style: WawatTextStyles.link.copyWith(
                            color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Login button
                  WawatButton(
                    text: _isLoading ? 'Вход...' : 'Войти',
                    onPressed: _isLoading ? null : _handleLogin,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onRegister();
                    },
                    child: Text(
                      'Нет аккаунта? Зарегистрироваться',
                      style: WawatTextStyles.link.copyWith(
                        color: isDark ? const Color(0xFF6366F1) : WawatColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
