import 'package:flutter/material.dart';

import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement login logic
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Вход выполнен!'),
        ),
      );
    }
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка для восстановления отправлена на email'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                 Image.asset("asset/mini_logo.png",width: 35,),
                  SizedBox(width: WawatDimensions.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Вход',
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: WawatColors.primary,
                            height: 1.4,
                          )
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
              padding: EdgeInsets.only(left: 20,right: 20,bottom: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WawatInputField(
                      label: 'EMAIL',
                      placeholder: 'example@mail.com',
                      prefixIcon: Icon(Icons.email, size: WawatDimensions.iconMedium),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isModal: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Некорректный email';
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

                    // Login Button
                    WawatButton(
                      text: 'Войти',
                      onPressed: _handleLogin,
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
}
