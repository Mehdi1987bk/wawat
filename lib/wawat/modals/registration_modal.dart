import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';
import '../widgets/wawat_button.dart';
import '../widgets/wawat_input_field.dart';

/// Модальное окно регистрации
class RegistrationModal extends StatefulWidget {
  final VoidCallback onLogin;

  const RegistrationModal({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<RegistrationModal> createState() => _RegistrationModalState();
}

class _RegistrationModalState extends State<RegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  String? _selectedLanguage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Необходимо согласиться с условиями'),
          ),
        );
        return;
      }
      // TODO: Implement registration logic
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Регистрация успешна!'),
        ),
      );
    }
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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: WawatColors.inputBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flight,
                    color: WawatColors.primary,
                    size: WawatDimensions.iconLarge,
                  ),
                  SizedBox(width: WawatDimensions.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Регистрация',
                          style: WawatTextStyles.h3,
                        ),
                        Text(
                          'Присоединяйтесь к нам',
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
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(WawatDimensions.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WawatInputField(
                        label: 'ПОЛНОЕ ИМЯ',
                        placeholder: 'Введите ваше имя',
                        prefixIcon: Icon(Icons.person, size: WawatDimensions.iconMedium),
                        controller: _nameController,
                        isModal: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите имя';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

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
                        label: 'ТЕЛЕФОН',
                        placeholder: '+7 (999) 123-45-67',
                        prefixIcon: Icon(Icons.phone, size: WawatDimensions.iconMedium),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isModal: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите телефон';
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
                            return 'Минимум 6 символов';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatInputField(
                        label: 'ПОДТВЕРДИТЕ ПАРОЛЬ',
                        placeholder: 'Повторите пароль',
                        prefixIcon: Icon(Icons.lock, size: WawatDimensions.iconMedium),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        isModal: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Подтвердите пароль';
                          }
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatDropdownField(
                        label: 'ЯЗЫКИ ОБЩЕНИЯ',
                        placeholder: 'Выбор',
                        prefixIcon: Icon(Icons.language, size: WawatDimensions.iconMedium),
                        value: _selectedLanguage,
                        isModal: true,
                        onTap: () {
                          // TODO: Show language picker
                        },
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            activeColor: WawatColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreedToTerms = !_agreedToTerms;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: WawatDimensions.spacingSm),
                                child: RichText(
                                  text: TextSpan(
                                    style: WawatTextStyles.caption,
                                    children: [
                                      TextSpan(text: 'Регистрируясь, вы соглашаетесь с '),
                                      TextSpan(
                                        text: 'Условиями использования',
                                        style: WawatTextStyles.link.copyWith(fontSize: 12),
                                      ),
                                      TextSpan(text: ' и '),
                                      TextSpan(
                                        text: 'Политикой конфиденциальности',
                                        style: WawatTextStyles.link.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: WawatDimensions.spacingLg),

                      // Register Button
                      WawatButton(
                        text: 'Создать аккаунт',
                        onPressed: _handleRegister,
                        width: double.infinity,
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onLogin();
                          },
                          child: RichText(
                            text: TextSpan(
                              style: WawatTextStyles.body,
                              children: [
                                TextSpan(
                                  text: 'Уже есть аккаунт? ',
                                  style: TextStyle(color: WawatColors.textSecondary),
                                ),
                                TextSpan(
                                  text: 'Войти',
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
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogin,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RegistrationModal(
        onLogin: onLogin,
      ),
    );
  }
}
