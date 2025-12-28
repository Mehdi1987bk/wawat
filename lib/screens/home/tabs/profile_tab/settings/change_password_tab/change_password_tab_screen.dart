import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../presentation/bloc/error_dispatcher.dart';
import '../../../../../../services/theme_aware_screen.dart';
import '../../../../../../services/theme_manager.dart';
import '../experience_tab/experience_tab_screen.dart';
import 'change_password_tab_bloc.dart';

class ChangePasswordTab extends BaseScreen {
  ChangePasswordTab({Key? key}) : super(key: key);

  @override
  State<ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState
    extends BaseState<ChangePasswordTab, ChangePasswordTabBloc> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);
  bool _isLoading = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _currentPasswordController.addListener(_validateForm);
    _newPasswordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    bloc.loadingStream.listen((isLoading) {
      if (mounted) setState(() => _isLoading = isLoading);
    });

    bloc.errorStream.listen((error) {
      if (!mounted) return;
      showTopSnackbar(error.toString(), false, context);
    });
  }

  void _validateForm() {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final isValid = currentPassword.length >= 6 &&
        newPassword.length >= 6 &&
        confirmPassword.length >= 6 &&
        newPassword == confirmPassword &&
        currentPassword != newPassword;

    _isFormValid.value = isValid;
  }

  Future<void> _handleChangePassword() async {
    final success = await bloc.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (success && mounted) {
      showIOSStyleMessage(context, 'Пароль успешно изменён');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _validateForm();
    }
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B4FFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF5B4FFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                child: const Text('Изменить пароль'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Введите текущий и новый пароль',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Current password
                    _buildPasswordField(
                      label: 'Текущий пароль',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    // New password
                    _buildPasswordField(
                      label: 'Новый пароль',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      isDark: isDark,
                      hint: 'Минимум 6 символов',
                    ),

                    const SizedBox(height: 16),

                    // Confirm password
                    _buildPasswordField(
                      label: 'Подтвердите новый пароль',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      isDark: isDark,
                      hint: 'Повторите новый пароль',
                    ),

                    // Password hints

                    const SizedBox(height: 24),

                    // Submit button
                    ValueListenableBuilder<bool>(
                      valueListenable: _isFormValid,
                      builder: (_, isValid, __) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor:
                              const Color(0xFF5B4FFF).withOpacity(0.3),
                              backgroundColor: const Color(0xFF5B4FFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (isValid && !_isLoading)
                                ? _handleChangePassword
                                : null,
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,

                            )
                                : const Text(
                              'Сохранить новый пароль',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required bool isDark,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint ?? '••••••••',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF4A4A4A)
                    : const Color(0xFFE5E5EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF4A4A4A)
                    : const Color(0xFFE5E5EA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5B4FFF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.white54 : Colors.grey,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
      ],
    );
  }



  @override
  ChangePasswordTabBloc provideBloc() {
    return ChangePasswordTabBloc();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }
}
