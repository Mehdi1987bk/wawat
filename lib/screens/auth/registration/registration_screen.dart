import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/network/response/language.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/common/async_button.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/theme_manager.dart';
import '../../home/home_screen.dart';
import '../../home/tabs/profile_tab/privacy_policy/privacy_policy_screen.dart';
import '../login/login_screen.dart';
import 'registration_bloc.dart';

class RegistrationScreen extends BaseScreen<RegistrationBloc> {
  final VoidCallback? onLogin;

  RegistrationScreen({
    Key? key,
    this.onLogin,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState
    extends BaseState<RegistrationScreen, RegistrationBloc> {
  static const _brand = Color(0xFF0271EB);

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = false;
  String? _message;
  Map<String, String> _fieldErrors = {};
  List<Language> _languages = const [];
  final Set<String> _selectedLanguages = {};

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguages() async {
    try {
      final response = await bloc.getLanguages;
      if (mounted) {
        setState(() => _languages = response.data);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _languages = [
            Language(code: 'az', name: 'Azərbaycanca'),
            Language(code: 'en', name: 'English'),
            Language(code: 'ru', name: 'Русский'),
            Language(code: 'tr', name: 'Türkçe'),
            Language(code: 'ua', name: 'Українська'),
          ];
        });
      }
    }
  }

  Future<void> _register() async {
    setState(() {
      _message = null;
      _fieldErrors = {};
    });

    final locale = Localizations.localeOf(context).languageCode;
    final preferredLocale = locale == 'uk' ? 'ua' : locale;
    final result = await bloc.registerWithResult(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      termsAccepted: _termsAccepted,
      communicationLanguageCodes: _selectedLanguages.toList(),
      preferredLocale: preferredLocale,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  void _openLogin() {
    if (widget.onLogin != null) {
      widget.onLogin!();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget body() {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    final titleColor = isDark ? WawatDark.textPrimary : const Color(0xFF111827);
    final bodyColor =
        isDark ? WawatDark.textSecondary : const Color(0xFF4B5563);
    final labelColor =
        isDark ? WawatDark.textSecondary : const Color(0xFF374151);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Icon(Icons.arrow_back, color: titleColor),
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(
                    'Hesab yarat',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bir neçə addımda qoşul',
                    style: TextStyle(
                      fontSize: 14,
                      color: bodyColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              _AlertBox(message: _message!, isDark: isDark),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _AuthField(
                    label: 'Ad',
                    hint: 'Tahir',
                    controller: _firstNameController,
                    error: _fieldErrors['first_name'],
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AuthField(
                    label: 'Soyad',
                    hint: 'Quliyev',
                    controller: _lastNameController,
                    error: _fieldErrors['last_name'],
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: 'Email',
              hint: 'ad@nümunə.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              error: _fieldErrors['email'],
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: 'Şifrə',
              hint: 'Minimum 8 simvol',
              controller: _passwordController,
              obscureText: _obscurePassword,
              error: _fieldErrors['password'],
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark ? WawatDark.iconMuted : null,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: 'Şifrəni təsdiqlə',
              hint: 'Təkrar yaz',
              controller: _confirmPasswordController,
              obscureText: true,
              error: _fieldErrors['password_confirmation'],
              isDark: isDark,
            ),
            const SizedBox(height: 18),
            Text(
              'Danışdığın dillər',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((language) {
                final isSelected = _selectedLanguages.contains(language.code);
                return FilterChip(
                  selected: isSelected,
                  label: Text(language.name ?? language.code),
                  selectedColor: _brand,
                  backgroundColor: isDark ? WawatDark.surfaceAlt : Colors.white,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : bodyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? _brand
                        : (isDark ? WawatDark.border : Colors.black12),
                  ),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedLanguages.add(language.code);
                      } else {
                        _selectedLanguages.remove(language.code);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: _brand,
                  onChanged: (value) {
                    setState(() => _termsAccepted = value ?? false);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bodyColor,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(text: 'İstifadə qaydaları və '),
                          TextSpan(
                            text: 'Məxfilik siyasəti',
                            style: TextStyle(
                              color: isDark ? WawatDark.brandText : _brand,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: ' ilə tanış oldum.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_fieldErrors['terms_accepted'] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  _fieldErrors['terms_accepted']!,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            _PrimaryButton(
              text: 'Qeydiyyatdan keç',
              onPressed: _register,
            ),
            const SizedBox(height: 24),
            _DividerLabel(text: 'və ya', isDark: isDark),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    text: 'Google',
                    icon: Icons.g_mobiledata,
                    onPressed: null,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutlineButton(
                    text: 'Apple',
                    icon: Icons.apple,
                    onPressed: null,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Hesabın var? ',
                    style: TextStyle(color: bodyColor),
                  ),
                  GestureDetector(
                    onTap: _openLogin,
                    child: Text(
                      'Daxil ol',
                      style: TextStyle(
                        color: isDark ? WawatDark.brandText : _brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  RegistrationBloc provideBloc() => RegistrationBloc();
}

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? error;
  final bool isDark;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.error,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final labelColor =
        isDark ? WawatDark.textSecondary : const Color(0xFF374151);
    final inputColor = isDark ? WawatDark.surfaceAlt : Colors.white;
    final textColor = isDark ? WawatDark.textPrimary : const Color(0xFF111827);
    final hintColor = isDark ? WawatDark.placeholder : const Color(0xFF9CA3AF);
    final borderColor = isDark ? WawatDark.border : Colors.black12;
    final focusColor =
        isDark ? WawatDark.focusRing : _RegistrationScreenState._brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          cursorColor: _RegistrationScreenState._brand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            suffixIcon: suffix,
            filled: true,
            fillColor: inputColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red : focusColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncActionButton(
      height: 48,
      borderRadius: 14,
      color: _RegistrationScreenState._brand,
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const _OutlineButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? WawatDark.textPrimary : const Color(0xFF111827),
          disabledForegroundColor:
              isDark ? WawatDark.textSecondary : const Color(0xFF9CA3AF),
          side: BorderSide(
            color: isDark ? WawatDark.border : Colors.black12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  final String message;
  final bool isDark;

  const _AlertBox({required this.message, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.dangerSoftBg : Colors.red.shade50,
        border: Border.all(
          color: isDark ? WawatDark.dangerSoftBorder : Colors.red.shade200,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: isDark ? WawatDark.dangerText : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? WawatDark.dangerText : Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _DividerLabel({required this.text, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? WawatDark.divider : null)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? WawatDark.textMuted : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: isDark ? WawatDark.divider : null)),
      ],
    );
  }
}
