import 'package:buking/screens/home/home_screen.dart';
import 'package:buking/services/theme_aware_screen.dart';
import 'package:buking/services/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          body: ThemeAwareScreen(
            isDark: isDark,
            child: SafeArea(
              child: Column(
                children: [
                  // Центральный контент
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _buildHeroSection(isDark),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildSearchButton(context),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A5FFF), Color(0xFFB74CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334A5FFF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Продолжить',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.asset(
            "asset/home_back.png",
            color: isDark ? Colors.white.withOpacity(0.9) : null,
            colorBlendMode: isDark ? BlendMode.modulate : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : WawatColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            child: const Text(
              'Ищи тех, кто летит — и передавай посылки надёжно и быстро',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color:
              isDark ? const Color(0xFFB0B0B0) : WawatColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            child: const Text(
              'Быстрая и безопасная доставка посылок по всему миру',
            ),
          ),
        ),
      ],
    );
  }
}

// Класс с цветами (если у вас еще нет)
class WawatColors {
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
}