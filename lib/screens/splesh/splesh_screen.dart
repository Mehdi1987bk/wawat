import 'package:buking/presentation/resourses/app_colors.dart';
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
      final isFirstOpen = value.last as bool;

      if (isFirstOpen) {
        // Первый запуск - показать IntroPage
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
        // Повторный запуск - перейти на HomeScreen
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
