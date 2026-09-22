import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/resourses/wawat_dark.dart';
import '../../services/home_config.dart';
import '../../services/app_update_service.dart';
import '../forced_update/forced_update_screen.dart';
import '../home/home_screen.dart';
import 'Intro_page.dart';

bool cartNumberFocus = false;
bool finKodNumberFocus = false;

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
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
      // Backend decides the landing tab. Hidden inside the splash window and
      // bounded so a slow/offline backend can never stall startup — it then
      // falls back to the previous launch's cached tab (0 on a fresh install).
      HomeConfig.instance.refreshDefaultTab().timeout(
            const Duration(milliseconds: 3000),
            onTimeout: () => HomeConfig.instance.cachedDefaultTab(),
          ),
      AppUpdateService.instance.check().timeout(
            const Duration(seconds: 4),
            onTimeout: () => null,
          ),
    ]).then((value) {
      if (!mounted) return; // Проверяем, смонтирован ли еще виджет

      final isFirstOpen = value[1] as bool;
      final defaultTab = value[2] as int;
      final updateInfo = value[3] as AppUpdateInfo?;

      if (updateInfo?.forceUpdate == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ForcedUpdateScreen(info: updateInfo!),
          ),
        );
        return;
      }

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
              return HomeScreen(initialTabIndex: defaultTab);
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
        // Dark: blue+white check with white wordmark (reads on the dark bg) — no
        // white chip. Light: the standard dark wordmark.
        child: Image.asset(
          isDark
              ? 'asset/wawatair_logo_dark.png'
              : 'asset/wawatair_primary.png',
          fit: BoxFit.contain,
          width: 260,
        ),
      ),
    );
  }
}
