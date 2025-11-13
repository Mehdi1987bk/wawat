import 'package:buking/screens/auth/registration/registration_bloc.dart';
import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';

class RegistrationModal extends StatefulWidget {
  final VoidCallback onLogin;

  const RegistrationModal({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<RegistrationModal> createState() => _RegistrationModalState();

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

class _RegistrationModalState extends State<RegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  String? _selectedLanguage;

  final _bloc = RegistrationBloc();
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    _bloc.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });

    _bloc.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка регистрации: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Добавляем слушатели на изменения текста для проверки валидности
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    if (value.length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }
    if (value != _passwordController.text) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  void _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласиться с условиями'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await _bloc.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
            return   HomeScreen();
          }));
        }
      } catch (e) {
        print('Registration error: $e');
      }
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
                    icon: const Icon(Icons.close),
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
                        validator: _validateName,
                        onChanged: (_) => _validateForm(),
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatInputField(
                        label: 'EMAIL',
                        placeholder: 'example@mail.com',
                        prefixIcon: Icon(Icons.email, size: WawatDimensions.iconMedium),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isModal: true,
                        validator: _validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatInputField(
                        label: 'ТЕЛЕФОН',
                        placeholder: '+7 (999) 123-45-67',
                        prefixIcon: Icon(Icons.phone, size: WawatDimensions.iconMedium),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isModal: true,
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatInputField(
                        label: 'ПАРОЛЬ',
                        placeholder: 'Минимум 6 символов',
                        prefixIcon: Icon(Icons.lock, size: WawatDimensions.iconMedium),
                        controller: _passwordController,
                        obscureText: true,
                        isModal: true,
                        validator: _validatePassword,
                        onChanged: (_) => _validateForm(),
                      ),
                      SizedBox(height: WawatDimensions.spacingMd),

                      WawatInputField(
                        label: 'ПОДТВЕРДИТЕ ПАРОЛЬ',
                        placeholder: 'Повторите пароль',
                        prefixIcon: Icon(Icons.lock, size: WawatDimensions.iconMedium),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        isModal: true,
                        validator: _validateConfirmPassword,
                        onChanged: (_) => _validateForm(),
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
                                _validateForm();
                              });
                            },
                            activeColor: WawatColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreedToTerms = !_agreedToTerms;
                                  _validateForm();
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: WawatDimensions.spacingSm),
                                child: RichText(
                                  text: TextSpan(
                                    style: WawatTextStyles.caption,
                                    children: [
                                      const TextSpan(text: 'Регистрируясь, вы соглашаетесь с '),
                                      TextSpan(
                                        text: 'Условиями использования',
                                        style: WawatTextStyles.link.copyWith(fontSize: 12),
                                      ),
                                      const TextSpan(text: ' и '),
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

                      // Register Button - СЕРАЯ, когда невалидна
                      WawatButton(
                        text: _isLoading ? 'Регистрация...' : 'Создать аккаунт',
                        onPressed: (_isLoading || !_isFormValid || !_agreedToTerms)
                            ? null
                            : _handleRegister,
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
}