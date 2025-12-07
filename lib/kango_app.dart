import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_bloc.dart';
import 'app_theme.dart';
import 'generated/l10n.dart';
import 'main.dart';
import 'presentation/bloc/bloc_provider.dart';
import 'presentation/resourses/app_colors.dart';
import 'presentation/resourses/theme_provider.dart';
import 'screens/splesh/splesh_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class WawatApp extends StatefulWidget {
  @override
  _WawatAppState createState() => _WawatAppState();
}

class _WawatAppState extends State<WawatApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: BlocProvider<AppBloc>(bloc: AppBloc(), child: App()),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return MaterialApp(
      color: AppColors.getAppBarBgColor(isDark),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.getBgColor(isDark),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      localizationsDelegates: [
        S.delegate,
        // GlobalMaterialLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: SpleshScreen(),
      // home: isviewed != 0 ? OnBoarding() : SpleshScreen(),
    );
  }
}
