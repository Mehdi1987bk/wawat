import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';
import '../../../wawat/widgets/wawat_button.dart';

/// Модальное окно "Требуется регистрация"
class AuthRequiredModal extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const AuthRequiredModal({
    Key? key,
    required this.onRegister,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: WawatDimensions.spacingLg,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: WawatDimensions.modalMaxWidth,
            ),
            padding: EdgeInsets.all(WawatDimensions.spacingLg),
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
                // Icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(WawatDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: WawatDimensions.iconXLarge,
                  ),
                ),
                SizedBox(height: WawatDimensions.spacingLg),

                // Title
                Text(
                  'Требуется регистрация',
                  style: WawatTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: WawatDimensions.spacingMd),

                // Description
                Text(
                  'Для доступа к этой функции необходимо зарегистрироваться или войти в аккаунт',
                  style: WawatTextStyles.caption.copyWith(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : WawatColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: WawatDimensions.spacingLg),

                // Register Button
                WawatButton(
                  text: 'Зарегистрироваться',
                  onPressed: onRegister,
                  width: double.infinity,
                ),
                SizedBox(height: WawatDimensions.spacingMd),

                // Login Button
                WawatOutlineButton(
                  text: 'Войти',
                  onPressed: onLogin,
                  width: double.infinity,
                ),
                SizedBox(height: WawatDimensions.spacingMd),

                // Cancel Link
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Отмена',
                    style: WawatTextStyles.body.copyWith(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : WawatColors.textSecondary,
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

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onRegister,
        required VoidCallback onLogin,
      }) {
    return showDialog(
      context: context,
      builder: (context) => AuthRequiredModal(
        onRegister: onRegister,
        onLogin: onLogin,
      ),
    );
  }
}
