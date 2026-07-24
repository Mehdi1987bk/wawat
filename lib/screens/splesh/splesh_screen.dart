import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/resourses/wawat_dark.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : Colors.white,
      body: Center(
        child: isDark
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  'asset/wawatair_primary.png',
                  fit: BoxFit.contain,
                  width: 260,
                ),
              )
            : Image.asset(
                'asset/wawatair_primary.png',
                fit: BoxFit.contain,
                width: 260,
              ),
      ),
    );
  }
}
