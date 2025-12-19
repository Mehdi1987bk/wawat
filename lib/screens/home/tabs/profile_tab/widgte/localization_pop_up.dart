import 'package:buking/screens/home/tabs/profile_tab/widgte/supported_locale.dart';
import 'package:buking/services/theme_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../presentation/resourses/app_colors.dart';
import '/../generated/l10n.dart';

class LocalizationPopUp extends StatefulWidget {
  final ValueChanged<Locale> onChanged;
  final Locale? currentLocale;

  const LocalizationPopUp({
    super.key,
    required this.onChanged,
    required this.currentLocale,
  });

  @override
  State<LocalizationPopUp> createState() => _LocalizationPopUpState();
}

class _LocalizationPopUpState extends State<LocalizationPopUp> {
  late Locale? _currentLocale = widget.currentLocale;

  @override
  Widget build(BuildContext context) {
    final currentSupportedLocale = supportedLocales
        .firstWhereOrNull((element) => element.locale == _currentLocale);

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 320,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Индикатор свайпа
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),

                // Заголовок
                Container(
                  margin: const EdgeInsets.only(top: 25, bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                              const Color(0xFF10B981).withOpacity(0.2),
                              const Color(0xFF059669).withOpacity(0.1),
                            ]
                                : [
                              const Color(0xFFDCFCE7),
                              const Color(0xFFA7F3D0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.language,
                          color: isDark
                              ? const Color(0xFF10B981)
                              : const Color(0xFF059669),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                        child: const Text("Выбери язык"),
                      ),
                    ],
                  ),
                ),

                // Список языков
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: supportedLocales.map((e) {
                      final isSelected = e == currentSupportedLocale;
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => onChanged(e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFFDCFCE7))
                                : (isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF9FAFB)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF059669))
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: (isDark
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF059669))
                                    .withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // Флаг
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  e.image,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Название языка
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isDark
                                        ? (isSelected
                                        ? Colors.white
                                        : const Color(0xFFB0B0B0))
                                        : (isSelected
                                        ? const Color(0xFF000000)
                                        : const Color(0xFF6B7280)),
                                  ),
                                  child: Text(e.name),
                                ),
                              ),

                              // Чекбокс/индикатор
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (isDark
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF059669))
                                      : (isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : const Color(0xFFE5E7EB)),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF059669))
                                        : (isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFD1D5DB)),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onChanged(SupportedLocale? e) {
    if (e != null) {
      setState(() {
        _currentLocale = e.locale;
        widget.onChanged(e.locale);
      });
      Navigator.pop(context);
    }
  }
}