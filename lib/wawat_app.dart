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
import 'presentation/resourses/wawat_dark.dart';
import 'screens/splesh/splesh_screen.dart';
import 'services/localization_service.dart';
import 'services/network_status_service.dart';
import 'services/notification_router.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider.value(value: LocalizationService.instance),
        ChangeNotifierProvider.value(value: NetworkStatusService.instance),
      ],
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
              // Пересобрать всё дерево, когда CMS-контент/язык загрузился/сменился.
              context.watch<LocalizationService>();
              final isDark = themeManager.isDarkMode;

              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor:
                      isDark ? WawatDark.bar : const Color(0xFFFFFFFF),
                  systemNavigationBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
              );

              return MaterialApp(
                builder: (context, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    flushPendingNotificationNavigation();
                  });
                  final isOffline =
                      context.watch<NetworkStatusService>().isOffline;
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: Stack(
                      children: [
                        child!,
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          right: 16,
                          child: IgnorePointer(
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              offset:
                                  isOffline ? Offset.zero : const Offset(0, -2),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isOffline ? 1 : 0,
                                child: _OfflineBanner(
                                  message: S.of(context).noInternetConnection,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                // az, en, ru, tr, ua(uk), es — es новый; фреймворк-строки берёт
                // из GlobalMaterialLocalizations, UI-строки — из CMS через t().
                supportedLocales: const [
                  Locale('az'),
                  Locale('en'),
                  Locale('ru'),
                  Locale('tr'),
                  Locale('uk'),
                  Locale('es'),
                ],
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
      scaffoldBackgroundColor: WawatDark.bg,
      canvasColor: WawatDark.bg,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: _appFontFamily,
            fontFamilyFallback: _appFontFallback,
            color: WawatDark.textPrimary,
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: WawatDark.brand,
        onPrimary: Colors.white,
        secondary: WawatDark.brand,
        onSecondary: Colors.white,
        surface: WawatDark.surface,
        onSurface: WawatDark.textPrimary,
        surfaceContainerHighest: WawatDark.elevated,
        outline: WawatDark.border,
        error: WawatDark.danger,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: WawatDark.bar,
        foregroundColor: WawatDark.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: WawatDark.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: _appFontFamily,
          fontFamilyFallback: _appFontFallback,
          color: WawatDark.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardColor: WawatDark.surface,
      cardTheme: const CardThemeData(
        color: WawatDark.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: WawatDark.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: _appFontFamily,
          fontFamilyFallback: _appFontFallback,
          color: WawatDark.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _appFontFamily,
          fontFamilyFallback: _appFontFallback,
          color: WawatDark.textSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: WawatDark.surface,
        modalBackgroundColor: WawatDark.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: WawatDark.grab,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: WawatDark.surfaceAlt,
        contentTextStyle: TextStyle(color: WawatDark.textPrimary),
        actionTextColor: WawatDark.brandText,
        behavior: SnackBarBehavior.floating,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: WawatDark.brand,
        inactiveTrackColor: WawatDark.border,
        thumbColor: WawatDark.brand,
        overlayColor: WawatDark.focusGlow,
      ),
      dividerTheme: const DividerThemeData(
        color: WawatDark.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: WawatDark.icon),
      listTileTheme: const ListTileThemeData(
        iconColor: WawatDark.icon,
        textColor: WawatDark.textPrimary,
      ),
      textTheme: Typography.whiteMountainView.apply(
        fontFamily: _appFontFamily,
        fontFamilyFallback: _appFontFallback,
        bodyColor: WawatDark.textPrimary,
        displayColor: WawatDark.textPrimary,
      ),
      hintColor: WawatDark.placeholder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WawatDark.surfaceAlt,
        hintStyle: const TextStyle(color: WawatDark.placeholder),
        labelStyle: const TextStyle(color: WawatDark.textSecondary),
        prefixIconColor: WawatDark.iconMuted,
        suffixIconColor: WawatDark.iconMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WawatDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WawatDark.focusRing, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? WawatDark.brand
              : const Color(0xFF9CA3AF),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? WawatDark.brand.withValues(alpha: 0.45)
              : const Color(0xFF3A3A3A),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: WawatDark.bar,
        selectedItemColor: WawatDark.brandText,
        unselectedItemColor: WawatDark.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: WawatDark.surfaceAlt,
        labelStyle: const TextStyle(color: WawatDark.textPrimary),
        side: const BorderSide(color: WawatDark.border),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String message;

  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A2024) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 21,
              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFFECACA)
                      : const Color(0xFF991B1B),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
