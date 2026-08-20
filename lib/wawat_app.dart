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
import 'services/telemetry/telemetry.dart';
import 'services/telemetry/telemetry_events.dart';
import 'services/theme_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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
                  // Cold-start push routing is flushed from HomeScreen.initState,
                  // NOT here: at frame 1 the top route is SpleshScreen, and the
                  // splash replaces the top route on its way to Home — which would
                  // destroy any target pushed now. See notification_router.dart.
                  final isOffline =
                      context.watch<NetworkStatusService>().isOffline;
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: Stack(
                      children: [
                        child!,
                        // Full-screen offline gate: covers the app while there's
                        // no connection and disappears the moment it's restored,
                        // so the user resumes exactly where they left off — the
                        // Navigator underneath is never touched.
                        if (isOffline)
                          const Positioned.fill(child: _OfflineScreen()),
                      ],
                    ),
                  );
                },
                color: AppColors.appBarbgColor,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                scaffoldMessengerKey: scaffoldMessengerKey,
                navigatorObservers: [routeObserver, telemetryRouteObserver],
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

/// Full-screen "no internet" gate. Rendered as an overlay above the app's
/// Navigator while offline; restoring the connection simply removes it and the
/// user continues from wherever they were. The retry button actively re-probes
/// the network (not just the OS interface flag), so it also recovers from a
/// Wi‑Fi that reports "connected" but has no real internet.
class _OfflineScreen extends StatefulWidget {
  const _OfflineScreen();

  @override
  State<_OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<_OfflineScreen> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Сколько пользователей упирается в эту заглушку и как часто — один из
    // главных вопросов к качеству: всплеск здесь обычно означает не «плохой
    // интернет у людей», а проблему с доступностью API.
    Telemetry.instance.event(TelemetryEvents.offlineGateShown);
  }

  Future<void> _retry() async {
    if (_checking) return;
    setState(() => _checking = true);
    Telemetry.instance.breadcrumb('offline gate: retry tapped');
    final online = await NetworkStatusService.instance.recheck();
    if (online) {
      Telemetry.instance.event(TelemetryEvents.backOnline,
          params: {TelemetryParams.source: 'manual_retry'});
    }
    if (!mounted) return;
    setState(() => _checking = false);
    // If online, the app root rebuilds (isOffline=false) and this overlay is
    // removed automatically — the user stays exactly where they were. If still
    // offline, nudge them so the tap doesn't feel unresponsive.
    if (!online) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(S.of(context).noInternetConnection),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? WawatDark.bg : Colors.white;
    final titleColor = isDark ? WawatDark.textPrimary : const Color(0xFF0F172A);
    final subColor = isDark ? WawatDark.textSecondary : const Color(0xFF64748B);
    final iconBg = isDark ? const Color(0xFF3A2024) : const Color(0xFFFEF2F2);
    final iconColor =
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);

    return Material(
      color: bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration:
                    BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(Icons.wifi_off_rounded, size: 44, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).noInternetConnection,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'İnternet bağlantını yoxla və yenidən cəhd et.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subColor,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _checking ? null : _retry,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF017BFE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(
                            S.of(context).retry,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
