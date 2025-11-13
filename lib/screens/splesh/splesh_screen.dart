import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../wawat/screens/home_screen.dart';
import '../home/home_screen.dart';
import '../home/tabs/home_tab/home_tab_screen.dart';

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
      sl.get<AuthRepository>().setIsFirstOpen();
      if (value.last) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }));
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
