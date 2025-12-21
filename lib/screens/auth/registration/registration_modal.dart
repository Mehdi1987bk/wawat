import 'package:buking/screens/auth/registration/registration_bloc.dart';
import 'package:buking/screens/auth/registration/widget/language_selector.dart';
import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/network/response/language.dart';
import '../../../domain/entities/patterns.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../services/theme_manager.dart';
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

  bool _agreedToTerms = true;
  Set<String> _selectedLanguageCodes = {};
  List<Language> _allLanguages = [];
  bool _isLoadingLanguages = false;

  final _bloc = RegistrationBloc();
  bool _isLoading = false;

  final ValueNotifier<bool> _isFormValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _loadLanguages();

    _bloc.loadingStream.listen((isLoading) {
      if (mounted) setState(() => _isLoading = isLoading);
    });

    // 🔥 ИСПРАВЛЕНИЕ: добавлена обработка ошибок
    _bloc.errorStream.listen((error) {
      if (!mounted) return;
      showTopSnackbar(error.toString(), false, context);
    });
  }

  void _validateForm() {
    final isValid =
        Patterns.textField.hasMatch(_nameController.text.trim()) &&
            Patterns.email.hasMatch(_emailController.text.trim()) &&
            Patterns.textField.hasMatch(_phoneController.text.trim()) &&
            Patterns.textField.hasMatch(_passwordController.text.trim()) &&
            _agreedToTerms &&
            _selectedLanguageCodes.isNotEmpty;

    _isFormValidNotifier.value = isValid;
  }

  Future<void> _loadLanguages() async {
    try {
      setState(() => _isLoadingLanguages = true);
      final response = await _bloc.getLanguages;
      if (mounted) {
        setState(() {
          _allLanguages = response.data;
          _isLoadingLanguages = false;
        });
        _validateForm();
      }
    } catch (_) {
      setState(() => _isLoadingLanguages = false);
    }
  }

  /// 🔥 Обработка регистрации с блокировкой навигации при ошибке
  void _handleRegister() async {
    final success = await _bloc.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirmation: _confirmPasswordController.text.trim(),
      acceptedTerms: _agreedToTerms,
      communicationLanguageCodes: _selectedLanguageCodes.toList(),
    );

    if (!success) return; // ⛔ НЕ НАВИГИРУЕМ

    if (!mounted) return;

    Navigator.push(
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
          insetPadding:
          EdgeInsets.symmetric(horizontal: WawatDimensions.spacingLg),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: WawatDimensions.modalMaxWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.95,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : WawatColors.backgroundWhite,
              borderRadius:
              BorderRadius.circular(WawatDimensions.modalBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.all(WawatDimensions.spacingMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flight,
                        color: isDark
                            ? const Color(0xFF6366F1)
                            : WawatColors.primary,
                        size: WawatDimensions.iconLarge,
                      ),
                      SizedBox(width: WawatDimensions.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Регистрация',
                              style: WawatTextStyles.h3.copyWith(
                                color:
                                isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              'Присоединяйтесь к нам',
                              style: WawatTextStyles.caption.copyWith(
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : WawatColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color:
                          isDark ? Colors.white : Colors.black,
                        ),
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
                        WawatInputField(
                          label: 'ПОЛНОЕ ИМЯ',
                          placeholder: 'Введите ваше имя',
                          controller: _nameController,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: 'EMAIL',
                          placeholder: 'example@mail.com',
                          controller: _emailController,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: 'ТЕЛЕФОН',
                          placeholder: '+7 (999) 123-45-67',
                          controller: _phoneController,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: 'ПАРОЛЬ',
                          placeholder: 'Минимум 6 символов',
                          controller: _passwordController,
                          obscureText: true,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: 'ПОДТВЕРДИТЕ ПАРОЛЬ',
                          placeholder: 'Повторите пароль',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          isModal: true,
                        ),

                        SizedBox(height: WawatDimensions.spacingMd),

                        // 🔹 Языки
                        if (_allLanguages.isNotEmpty)
                          LanguageSelector(
                            languages: _allLanguages,
                            selectedLanguageCodes: _selectedLanguageCodes,
                            onSelectionChanged: (selected) {
                              setState(() {
                                _selectedLanguageCodes = selected;
                              });
                              _validateForm();
                            },
                          ),

                        SizedBox(height: WawatDimensions.spacingLg),

                        ValueListenableBuilder<bool>(
                          valueListenable: _isFormValidNotifier,
                          builder: (_, isValid, __) {
                            return WawatButton(
                              text: _isLoading
                                  ? 'Регистрация...'
                                  : 'Создать аккаунт',
                              onPressed:
                              (isValid && !_isLoading)
                                  ? _handleRegister
                                  : null,
                              width: double.infinity,
                            );
                          },
                        ),

                        SizedBox(height: WawatDimensions.spacingMd),

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
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : WawatColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Войти',
                                    style: WawatTextStyles.link.copyWith(
                                      color: isDark
                                          ? const Color(0xFF6366F1)
                                          : WawatColors.primary,
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