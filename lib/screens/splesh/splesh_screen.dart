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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Запускаем параллельно задержку и проверку первого открытия
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 4)),
        sl.get<AuthRepository>().firstOpen(),
      ]);

      if (!mounted) return;

      final isFirstOpen = results[1] as bool;
      print('🔍 isFirstOpen: $isFirstOpen'); // Для отладки

      if (isFirstOpen) {
        await sl.get<AuthRepository>().setIsFirstOpen();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => IntroPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      print('❌ Error in splash: $e');
      // При ошибке переходим на HomeScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
        );
      }
    }
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
              Colors.white,
              Colors.white,
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
  }
}
