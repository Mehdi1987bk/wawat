import 'dart:async';

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
import '../../../services/localization_service.dart';
import '../../../wawat_app.dart';
import '../../home/tabs/profile_tab/promo/promo_api.dart';
import '../../home/tabs/profile_tab/referral/referral_api.dart';
import '../login/login_screen.dart';
import 'registration_bloc.dart';

class RegistrationScreen extends BaseScreen<RegistrationBloc> {
  final VoidCallback? onLogin;

  /// Optional friend's invite code to prefill (e.g. resolved from an invite
  /// deep link). Left null for a normal registration.
  final String? initialReferralCode;

  RegistrationScreen({
    Key? key,
    this.onLogin,
    this.initialReferralCode,
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
  final _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = false;
  String? _message;
  Map<String, String> _fieldErrors = {};
  List<Language> _languages = const [];
  final Set<String> _selectedLanguages = {};
  ReferralInviter? _inviter;
  Timer? _inviteDebounce;
  String? _resolvedCode;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
    // Manual entry: resolve "who invited" as the user types the code (debounced).
    _referralController.addListener(_onReferralChanged);
    final code = widget.initialReferralCode?.trim();
    if (code != null && code.isNotEmpty) {
      _referralController.text = code;
      _resolveInviter(code);
    }
  }

  void _onReferralChanged() {
    final code = _referralController.text.trim();
    if (code == _resolvedCode) return;
    _inviteDebounce?.cancel();
    if (code.length < 4) {
      _resolvedCode = null;
      if (_inviter != null) setState(() => _inviter = null);
      return;
    }
    _inviteDebounce = Timer(const Duration(milliseconds: 600), () {
      _resolvedCode = code;
      _resolveInviter(code);
    });
  }

  /// Resolve who invited (public GET /referral/{code}) to show a friendly
  /// banner and confirm the code. Best-effort: an unknown code (404) clears the
  /// banner and never blocks registration.
  Future<void> _resolveInviter(String code) async {
    try {
      final inviter = await ReferralApi().getInviter(code);
      if (!mounted) return;
      // Ignore a stale response if the field has moved on to another code.
      if (_referralController.text.trim() != code) return;
      final show = inviter != null && inviter.referrerName.isNotEmpty;
      setState(() => _inviter = show ? inviter : null);
    } catch (_) {
      if (mounted && _inviter != null) setState(() => _inviter = null);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteDebounce?.cancel();
    _referralController.dispose();
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
    final referral = _referralController.text.trim();
    final result = await bloc.registerWithResult(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      termsAccepted: _termsAccepted,
      communicationLanguageCodes: _selectedLanguages.toList(),
      preferredLocale: preferredLocale,
      referralCode: referral.length > 40 ? referral.substring(0, 40) : referral,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
      // The reward promo is granted server-side the instant registration
      // succeeds — surface it once we've landed on Home.
      if (referral.isNotEmpty) _showReferralPromoToast();
      return;
    }

    setState(() {
      _message = result.message;
      _fieldErrors = result.fieldErrors;
    });
  }

  /// After a referral registration the new user already owns a promo code.
  /// Fetch the wallet and toast the referral reward. Best-effort, never blocks.
  Future<void> _showReferralPromoToast() async {
    try {
      final page = await PromoApi().getPromoCodes(status: 'active');
      PromoCode? promo;
      for (final p in page.data) {
        if (p.source == 'referral') {
          promo = p;
          break;
        }
      }
      if (promo == null) return;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            t('auth.referral_promo_received', {'amount': promo.amountLabel}),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    } catch (_) {}
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
                    tr('auth.create_account_title', 'Hesab yarat'),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('auth.register_subtitle', 'Bir neçə addımda qoşul'),
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
            if (_inviter != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.brandChip : const Color(0xFFEAF3FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard,
                        color: isDark ? WawatDark.brandText : _brand, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('auth.referral_invited_by', {
                          'name': _inviter!.referrerName,
                          'reward': '${_inviter!.rewardAmount.round()} ₼',
                        }),
                        style: TextStyle(
                          color: isDark ? WawatDark.brandText : _brand,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _AuthField(
                    label: tr('auth.first_name_label', 'Ad'),
                    hint: tr('auth.first_name_hint', 'Tahir'),
                    controller: _firstNameController,
                    error: _fieldErrors['first_name'],
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AuthField(
                    label: tr('auth.last_name_label', 'Soyad'),
                    hint: tr('auth.last_name_hint', 'Quliyev'),
                    controller: _lastNameController,
                    error: _fieldErrors['last_name'],
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: tr('auth.email_label', 'Email'),
              hint: tr('auth.email_hint', 'ad@nümunə.com'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              error: _fieldErrors['email'],
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: tr('auth.password_label', 'Şifrə'),
              hint: tr('auth.password_min8_hint', 'Minimum 8 simvol'),
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
              label: tr('auth.confirm_password_label', 'Şifrəni təsdiqlə'),
              hint: tr('auth.repeat_hint', 'Təkrar yaz'),
              controller: _confirmPasswordController,
              obscureText: true,
              error: _fieldErrors['password_confirmation'],
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _AuthField(
              label: t('auth.referral_code_label'),
              hint: t('auth.referral_code_hint'),
              controller: _referralController,
              error: _fieldErrors['referral_code'],
              isDark: isDark,
            ),
            const SizedBox(height: 18),
            Text(
              tr('auth.spoken_languages', 'Danışdığın dillər'),
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
                          TextSpan(
                              text: tr('auth.terms_prefix',
                                  'İstifadə qaydaları və ')),
                          TextSpan(
                            text: tr('auth.privacy_policy_link',
                                'Məxfilik siyasəti'),
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
                          TextSpan(
                              text:
                                  tr('auth.terms_suffix', ' ilə tanış oldum.')),
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
              text: tr('auth.register', 'Qeydiyyatdan keç'),
              onPressed: _register,
            ),
            const SizedBox(height: 24),
            _DividerLabel(text: tr('common.or', 'və ya'), isDark: isDark),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    text: tr('auth.google', 'Google'),
                    icon: Icons.g_mobiledata,
                    onPressed: null,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutlineButton(
                    text: tr('auth.apple', 'Apple'),
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
                    tr('auth.have_account', 'Hesabın var? '),
                    style: TextStyle(color: bodyColor),
                  ),
                  GestureDetector(
                    onTap: _openLogin,
                    child: Text(
                      tr('auth.login', 'Daxil ol'),
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
