import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_bloc.dart';
import 'app_theme.dart';
import 'generated/l10n.dart';
import 'main.dart';
import 'presentation/bloc/bloc_provider.dart';
import 'presentation/resourses/app_colors.dart';
import 'screens/splesh/splesh_screen.dart';
import 'services/theme_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class WawatApp extends StatefulWidget {
  @override
  _WawatAppState createState() => _WawatAppState();
}

class _WawatAppState extends State<WawatApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeManager, // Используем уже загруженный themeManager из main.dart
      child: BlocProvider<AppBloc>(bloc: AppBloc(), child: App()),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        // Устанавливаем глобальные системные цвета для клавиатуры
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            // ← ИСПРАВЛЕНО: инвертирована логика для клавиатуры (iOS)
            // Brightness.light = темная клавиатура, Brightness.dark = светлая клавиатура
            statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? const Color(0xFF121212) : Colors.white,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          color: AppColors.appBarbgColor,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5B4FFF),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: [
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: SpleshScreen(),
        );
      },
    );
  }
}
