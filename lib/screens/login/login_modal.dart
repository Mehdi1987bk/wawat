import 'package:flutter/material.dart';

import '../../presentation/bloc/base_screen.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';
import '../../wawat/widgets/wawat_button.dart';
import '../../wawat/widgets/wawat_input_field.dart';
import 'login_bloc.dart';

/// Модальное окно входа
class LoginModal extends BaseScreen {
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
      builder: (context) => LoginModal(
        onRegister: onRegister,
      ),
    );
  }
}

class _LoginModalState extends BaseState<LoginModal, LoginBloc> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Подписываемся на состояние загрузки
    bloc.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });

    // Подписываемся на ошибки
    bloc.errorStream.listen((error) {
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await bloc.login(
          _phoneController.text,
          _passwordController.text,
        );

        // Успешный вход - закрываем модал
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Вход выполнен успешно!'),
              backgroundColor: Colors.green,
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
    // TODO: Implement forgot password logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка для восстановления отправлена на телефон'),
      ),
    );
  }

  @override
  Widget body() {
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
          color: WawatColors.backgroundWhite,
          borderRadius: BorderRadius.circular(WawatDimensions.modalBorderRadius),
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
                        Text(
                          'Вход',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: WawatColors.primary,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          'Добро пожаловать обратно',
                          style: WawatTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
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
                      label: 'ТЕЛЕФОН',
                      placeholder: '+998901234567',
                      prefixIcon: Icon(Icons.phone, size: WawatDimensions.iconMedium),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      isModal: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите номер телефона';
                        }
                        if (value.length < 9) {
                          return 'Некорректный номер телефона';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    WawatInputField(
                      label: 'ПАРОЛЬ',
                      placeholder: 'Минимум 6 символов',
                      prefixIcon: Icon(Icons.lock, size: WawatDimensions.iconMedium),
                      controller: _passwordController,
                      obscureText: true,
                      isModal: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен быть минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: WawatDimensions.spacingSm),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _handleForgotPassword,
                        child: Text(
                          'Забыли пароль?',
                          style: WawatTextStyles.link,
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

                    // Loading indicator
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: WawatDimensions.spacingSm),
                          child: CircularProgressIndicator(),
                        ),
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
                            style: WawatTextStyles.body,
                            children: [
                              TextSpan(
                                text: 'Нет аккаунта? ',
                                style: TextStyle(color: WawatColors.textSecondary),
                              ),
                              TextSpan(
                                text: 'Зарегистрироваться',
                                style: WawatTextStyles.link,
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
  }

  @override
  LoginBloc provideBloc() {
    return LoginBloc();
  }
}
