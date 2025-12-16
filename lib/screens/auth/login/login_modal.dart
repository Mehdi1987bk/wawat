import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_aware_screen.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';

import 'login_bloc.dart';

/// Модальное окно входа
class LoginModal extends StatefulWidget {
  final VoidCallback onRegister;

  const LoginModal({
    Key? key,
    required this.onRegister,
  }) : super(key: key);

  @override
  State<LoginModal> createState() => _LoginModalState();

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onRegister,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginModal(
        onRegister: onRegister,
      ),
    );
  }
}

class _LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bloc = LoginBloc();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Подписываемся на состояние загрузки
    _bloc.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });

    // Подписываемся на ошибки
    _bloc.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _bloc.login(
          _emailController.text,
          _passwordController.text,
        );

        // Успешный вход - закрываем модал
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomeScreen();
              },
            ),
          );
        }
      } catch (e) {
        // Ошибка уже обработана через errorStream
        print('Login error: $e');
      }
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка для восстановления отправлена на email'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: WawatDimensions.spacingLg,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: WawatDimensions.modalMaxWidth,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : WawatColors.backgroundWhite,
              borderRadius:
              BorderRadius.circular(WawatDimensions.modalBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(WawatDimensions.spacingMd),
                  child: Row(
                    children: [
                      Image.asset("asset/mini_logo.png", width: 35),
                      SizedBox(width: WawatDimensions.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF6366F1)
                                    : WawatColors.primary,
                                height: 1.4,
                              ),
                              child: const Text('Вход'),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: WawatTextStyles.caption.copyWith(
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : WawatColors.textSecondary,
                              ),
                              child: const Text('Добро пожаловать обратно'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WawatInputField(
                          label: 'EMAIL',
                          placeholder: 'example@mail.com',
                          prefixIcon: Icon(
                            Icons.email,
                            size: WawatDimensions.iconMedium,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : WawatColors.textSecondary,
                          ),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),

                        WawatInputField(
                          label: 'ПАРОЛЬ',
                          placeholder: 'Минимум 6 символов',
                          prefixIcon: Icon(
                            Icons.lock,
                            size: WawatDimensions.iconMedium,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : WawatColors.textSecondary,
                          ),
                          controller: _passwordController,
                          obscureText: true,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingSm),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: WawatTextStyles.link.copyWith(
                                color: isDark
                                    ? const Color(0xFF6366F1)
                                    : WawatColors.primary,
                              ),
                              child: const Text('Забыли пароль?'),
                            ),
                          ),
                        ),
                        SizedBox(height: WawatDimensions.spacingLg),

                        // Login Button with loading state
                        WawatButton(
                          text: _isLoading ? 'Вход...' : 'Войти',
                          onPressed: _isLoading ? null : _handleLogin,
                          width: double.infinity,
                        ),

                        SizedBox(height: WawatDimensions.spacingMd),

                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onRegister();
                            },
                            child: RichText(
                              text: TextSpan(
                                style: WawatTextStyles.body.copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Нет аккаунта? ',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : WawatColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Зарегистрироваться',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF6366F1)
                                          : WawatColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}