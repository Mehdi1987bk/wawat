  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
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
      final isNotFirstOpen = value.last; // true = уже был запуск, false = первый раз

      if (isNotFirstOpen) {
        // Повторный вход - сразу на главный экран
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
        );
      } else {
        // Первый вход - показываем IntroPage и сохраняем флаг
        sl.get<AuthRepository>().setIsFirstOpen();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => IntroPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2662EA),
              Color(0xFF9333EA),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Image.asset(
            'asset/logo.png',
            fit: BoxFit.fitWidth,
            color: Colors.white,
            width: 200,
          ),
        ),
      ),
    );
  }
}