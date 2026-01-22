import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../services/theme_manager.dart';
import '../home/home_screen.dart';
import 'Intro_page.dart';

bool cartNumberFocus = false;
bool finKodNumberFocus = false;

class SpleshScreen extends StatefulWidget {
  @override
  _SpleshScreenState createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  @override
  void initState() {
    super.initState();
    Future.wait([
      Future.delayed(
        const Duration(seconds: 4),
      ),
      sl.get<AuthRepository>().firstOpen(),
    ]).then((value) {
      if (!mounted) return; // Проверяем, смонтирован ли еще виджет

      final isFirstOpen = value.last as bool;

      if (isFirstOpen) {
        sl.get<AuthRepository>().setIsFirstOpen();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return IntroPage();
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return HomeScreen();
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Center(
              child: Image.asset(
                'asset/icon.jpeg',
                fit: BoxFit.fitWidth,
                width: 200,
              ),
            ),
          ),
        );
      },
    );
  }
}
