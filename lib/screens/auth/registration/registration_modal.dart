import 'package:buking/screens/auth/registration/registration_bloc.dart';
import 'package:buking/screens/auth/registration/widget/country_code_selector.dart';
import 'package:buking/screens/auth/registration/widget/language_selector.dart';
 import 'package:buking/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../../../data/network/response/country.dart';
import '../../../data/network/response/language.dart';
import '../../../domain/entities/patterns.dart';
import '../../../generated/l10n.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat/widgets/wawat_button.dart';
import '../../../wawat/widgets/wawat_input_field.dart';
import '../../home/tabs/profile_tab/privacy_policy/privacy_policy_screen.dart';

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
  Set<String> _selectedLanguageCodes = {};
  List<Language> _allLanguages = [];
  bool _isLoadingLanguages = false;

  // Countries
  List<Country> _allCountries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = false;

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
    _loadCountries();

    _bloc.loadingStream.listen((isLoading) {
      if (mounted) setState(() => _isLoading = isLoading);
    });

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
            _selectedLanguageCodes.isNotEmpty &&
            _selectedCountry != null;

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

  Future<void> _loadCountries() async {
    try {
      setState(() => _isLoadingCountries = true);
      final response = await _bloc.getCountries();
      if (mounted) {
        setState(() {
          _allCountries = response.data;
          // По умолчанию выбираем Азербайджан (AZ)
          _selectedCountry = _allCountries.firstWhere(
                (c) => c.code == 'AZ',
            orElse: () => _allCountries.first,
          );
          _isLoadingCountries = false;
        });
        _validateForm();
      }
    } catch (_) {
      setState(() => _isLoadingCountries = false);
    }
  }

  void _handleRegister() async {
    final success = await _bloc.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirmation: _confirmPasswordController.text.trim(),
      acceptedTerms: _agreedToTerms,
      communicationLanguageCodes: _selectedLanguageCodes.toList(),
      callingCode: _selectedCountry?.callingCode,
    );

    if (!success) return;

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
    );

  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>   PrivacyPolicyScreen(),
      ),
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
                      Image.asset("asset/mini_logo.png", width: 35),

                      SizedBox(width: WawatDimensions.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).nyt7,
                              style: WawatTextStyles.h3.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              S.of(context).nty3,
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
                          color: isDark ? Colors.white : Colors.black,
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
                          label: S.of(context).btr3,
                          placeholder: S.of(context).nbgf3,
                          controller: _nameController,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: S.of(context).emailbgf,
                          placeholder: 'example@mail.com',
                          controller: _emailController,
                          isModal: true,
                          isEmail: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),

                        Text(
                          S.of(context).bgf34,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CountryCodeSelector(
                              selectedCountry: _selectedCountry,
                              countries: _allCountries,
                              isLoading: _isLoadingCountries,
                              onChanged: (country) {
                                setState(() => _selectedCountry = country);
                                _validateForm();
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '123 45 67',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: S.of(context).bgf35,
                          placeholder: S.of(context).bgfbvgfd3,
                          controller: _passwordController,
                          obscureText: true,
                          isModal: true,
                        ),
                        SizedBox(height: WawatDimensions.spacingMd),
                        WawatInputField(
                          label: S.of(context).bg334,
                          placeholder: S.of(context).vbrgf2,
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

                        SizedBox(height: WawatDimensions.spacingMd),

                        // Privacy Policy Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                  _validateForm();
                                },
                                activeColor: isDark
                                    ? const Color(0xFF6366F1)
                                    : WawatColors.primary,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(width: WawatDimensions.spacingSm),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: RichText(
                                  text: TextSpan(
                                    style: WawatTextStyles.caption.copyWith(
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : WawatColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                        TextSpan(text:S.of(context).betb4b3retb3r),
                                      TextSpan(
                                        text:  " "+  S.of(context).privacyPolicy,
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF6366F1)
                                              : WawatColors.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _openPrivacyPolicy,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: WawatDimensions.spacingLg),

                        ValueListenableBuilder<bool>(
                          valueListenable: _isFormValidNotifier,
                          builder: (_, isValid, __) {
                            return WawatButton(
                              text: _isLoading
                                  ? S.of(context).bgfd3
                                  : S.of(context).bgd2,
                              onPressed: (isValid && !_isLoading)
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
                                    text: S.of(context).muj56,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : WawatColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: S.of(context).ujt4,
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
