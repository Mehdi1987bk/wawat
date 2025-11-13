// import 'package:flutter/material.dart';
// import '../presentation/resourses/wawat_colors.dart';
// import 'screens/home_screen.dart';
// import 'screens/search_results_screen.dart';
//
// /// Главное приложение Wawat
// class WawatApp extends StatelessWidget {
//   const WawatApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Wawat',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: WawatColors.primary,
//         scaffoldBackgroundColor: WawatColors.backgroundLight,
//         fontFamily: 'System', // Использует системный шрифт
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: WawatColors.primary,
//           primary: WawatColors.primary,
//           secondary: WawatColors.secondary,
//         ),
//         useMaterial3: true,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => WawatHomeScreen(),
//         '/search-results': (context) => SearchResultsScreen(),
//       },
//     );
//   }
// }
