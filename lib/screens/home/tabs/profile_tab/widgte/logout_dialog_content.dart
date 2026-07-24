import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../presentation/resourses/app_colors.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/theme_manager.dart';

class LogoutDialogContent extends StatelessWidget {
  final String? title;
  final String? description;
  final String? yes;
  final String? no;
  final VoidCallback onConfirmLogout;

  const LogoutDialogContent({
    super.key,
    required this.onConfirmLogout,
    this.title,
    this.description,
    this.yes,
    this.no,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 40,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.grab : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDark ? cText(isDark) : Colors.black,
                ),
                child: Text(title ?? ""),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: isDark ? cLine(isDark) : Colors.grey[300],
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? cText2(isDark) : Colors.grey,
                ),
                child: Text(
                  description ?? "",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? cMuted(isDark) : AppColors.appColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        no ?? "",
                        style: TextStyle(
                          color: isDark ? cMuted(isDark) : AppColors.appColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirmLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? WawatDark.danger : AppColors.appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        yes ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
