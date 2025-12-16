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
      value: themeManager,
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

        // ВАЖНО для Android: устанавливаем цвета навигационной панели
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
            // ← КЛЮЧЕВОЕ для Android клавиатуры
            systemNavigationBarColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );

        return MaterialApp(
          color: AppColors.appBarbgColor,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          // ← КЛЮЧЕВОЕ: тема с правильным brightness
          theme: isDark ? _buildDarkTheme() : _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: [
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: SpleshScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF5B4FFF),
        secondary: const Color(0xFF5B4FFF),
        surface: Colors.white,
        background: Colors.white,
      ),
      useMaterial3: true,
      // Эти настройки могут помочь
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF5B4FFF),
        secondary: const Color(0xFF5B4FFF),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),
      useMaterial3: true,
      // Эти настройки могут помочь
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}
