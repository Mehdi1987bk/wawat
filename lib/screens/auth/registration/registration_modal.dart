import 'package:buking/screens/auth/registration/registration_bloc.dart';
import 'package:buking/screens/auth/registration/widget/language_multi_select_dropdown.dart';
import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/network/response/language.dart';
import '../../../data/network/response/language_response.dart';
import '../../../data/network/response/user.dart';
import '../../../domain/entities/patterns.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreedToTerms = false;
  List<int> _selectedLanguageIds = [];
  List<Language> _languages = [];
  bool _languagesLoaded = false;

  final _bloc = RegistrationBloc();
  bool _isLoading = false;

  // Один ValueNotifier для валидации всей формы
  final ValueNotifier<bool> _isFormValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    // Слушаем изменения всех полей
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _loadLanguages();

    _bloc.loadingStream.listen((isLoading) {
      if (mounted) {
        setState(() => _isLoading = isLoading);
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
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    var isValid = Patterns.textField.hasMatch(name) &&
        Patterns.email.hasMatch(email) &&
        Patterns.textField.hasMatch(phone) &&
        Patterns.textField.hasMatch(password) &&
        password == confirmPassword &&
        _agreedToTerms &&
        _selectedLanguageIds.isNotEmpty;

    _isFormValidNotifier.value = isValid;
  }

  Future<void> _loadLanguages() async {
    try {
      final response = await _bloc.getLanguages;
      if (mounted) {
        setState(() {
          _languages = response.data;
          _languagesLoaded = true;
        });
        _validateForm(); // Валидируем после загрузки языков
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _languagesLoaded = true;
        });
      }
    }
  }

  void _handleRegister() async {
    try {
      await _bloc.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
        acceptedTerms: _agreedToTerms,
        communicationLanguageIds: _selectedLanguageIds,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      print('Registration error: $e');
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
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: WawatColors.backgroundWhite,
          borderRadius:
              BorderRadius.circular(WawatDimensions.modalBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
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
                  Icon(Icons.flight,
                      color: WawatColors.primary,
                      size: WawatDimensions.iconLarge),
                  SizedBox(width: WawatDimensions.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Регистрация', style: WawatTextStyles.h3),
                        Text('Присоединяйтесь к нам',
                            style: WawatTextStyles.caption),
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

            // FORM
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(WawatDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME
                    WawatInputField(
                      label: 'ПОЛНОЕ ИМЯ',
                      placeholder: 'Введите ваше имя',
                      prefixIcon:
                          Icon(Icons.person, size: WawatDimensions.iconMedium),
                      controller: _nameController,
                      isModal: true,
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    // EMAIL
                    WawatInputField(
                      label: 'EMAIL',
                      placeholder: 'example@mail.com',
                      prefixIcon:
                          Icon(Icons.email, size: WawatDimensions.iconMedium),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isModal: true,
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    // PHONE
                    WawatInputField(
                      label: 'ТЕЛЕФОН',
                      placeholder: '+7 (999) 123-45-67',
                      prefixIcon:
                          Icon(Icons.phone, size: WawatDimensions.iconMedium),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      isModal: true,
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    // PASSWORD
                    WawatInputField(
                      label: 'ПАРОЛЬ',
                      placeholder: 'Минимум 6 символов',
                      prefixIcon:
                          Icon(Icons.lock, size: WawatDimensions.iconMedium),
                      controller: _passwordController,
                      obscureText: true,
                      isModal: true,
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    // CONFIRM PASSWORD
                    WawatInputField(
                      label: 'ПОДТВЕРДИТЕ ПАРОЛЬ',
                      placeholder: 'Повторите пароль',
                      prefixIcon:
                          Icon(Icons.lock, size: WawatDimensions.iconMedium),
                      controller: _confirmPasswordController,
                      obscureText: true,
                      isModal: true,
                    ),
                    SizedBox(height: WawatDimensions.spacingMd),

                    // LANGUAGES
                    LanguageMultiSelectDropdown(
                      languages: _languages,
                      selectedLanguageIds: _selectedLanguageIds,
                      onSelectionChanged: (selectedIds) {
                        setState(() {
                          _selectedLanguageIds = selectedIds;
                          _validateForm();
                        });
                      },
                      isModal: true,
                    ),

                    SizedBox(height: WawatDimensions.spacingMd),

                    // TERMS CHECKBOX
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
                              padding: EdgeInsets.only(
                                  top: WawatDimensions.spacingSm),
                              child: RichText(
                                text: TextSpan(
                                  style: WawatTextStyles.caption,
                                  children: [
                                    const TextSpan(
                                        text:
                                            'Регистрируясь, вы соглашаетесь с '),
                                    TextSpan(
                                      text: 'Условиями использования',
                                      style: WawatTextStyles.link
                                          .copyWith(fontSize: 12),
                                    ),
                                    const TextSpan(text: ' и '),
                                    TextSpan(
                                      text: 'Политикой конфиденциальности',
                                      style: WawatTextStyles.link
                                          .copyWith(fontSize: 12),
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

                    // REGISTER BUTTON - отключена до валидации
                    ValueListenableBuilder<bool>(
                      valueListenable: _isFormValidNotifier,
                      builder: (_, isValid, __) {
                        return WawatButton(
                          text:
                              _isLoading ? 'Регистрация...' : 'Создать аккаунт',
                          onPressed:
                              (isValid && !_isLoading) ? _handleRegister : null,
                          width: double.infinity,
                        );
                      },
                    ),

                    SizedBox(height: WawatDimensions.spacingMd),

                    // LOGIN LINK
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
                                style:
                                    TextStyle(color: WawatColors.textSecondary),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isFormValidNotifier.dispose();
    _bloc.dispose();
    super.dispose();
  }
}
