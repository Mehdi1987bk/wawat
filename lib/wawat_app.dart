import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_bloc.dart';
import 'generated/l10n.dart';
import 'main.dart';
import 'presentation/bloc/bloc_provider.dart';
import 'presentation/resourses/app_colors.dart';
import 'screens/splesh/splesh_screen.dart';
import 'services/theme_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
const _appFontFamily = 'Instrument Sans';
const _appFontFallback = <String>['Noto Sans'];

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
    final bloc = BlocProvider.of<AppBloc>(context);
    return StreamBuilder<Locale?>(
        stream: bloc.locale,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              final isDark = themeManager.isDarkMode;

              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor: isDark
                      ? const Color(0xFF000000)
                      : const Color(0xFFFFFFFF),
                  systemNavigationBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
              );

              return MaterialApp(
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: child!,
                  );
                },
                color: AppColors.appBarbgColor,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                navigatorObservers: [routeObserver],
                theme: isDark ? _buildDarkTheme() : _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                // Локаль теперь всегда приходит из CacheManager (либо сохранённая, либо системная)
                locale: snapshot.data,
                localeResolutionCallback: (locale, supportedLocales) {
                  // Если есть сохранённая локаль - используем её
                  if (snapshot.hasData && snapshot.data != null) {
                    return snapshot.data;
                  }
                  // Проверяем системную локаль устройства
                  if (locale != null) {
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }
                  // Fallback на английский
                  return const Locale("en");
                },
                supportedLocales: S.delegate.supportedLocales,
                home: SpleshScreen(),
              );
            },
          );
        });
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: _appFontFamily,
      fontFamilyFallback: _appFontFallback,
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: _appFontFamily,
            fontFamilyFallback: _appFontFallback,
          ),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF5B4FFF),
        secondary: const Color(0xFF5B4FFF),
        surface: Colors.white,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: _appFontFamily,
      fontFamilyFallback: _appFontFallback,
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: _appFontFamily,
            fontFamilyFallback: _appFontFallback,
          ),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF5B4FFF),
        secondary: const Color(0xFF5B4FFF),
        surface: const Color(0xFF1E1E1E),
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}
