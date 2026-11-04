// ignore_for_file: invalid_use_of_visible_for_testing_member
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:buking/app_theme.dart';
import 'package:buking/call_interceptor.dart';
import 'package:buking/data/cache/cache_manager.dart';
import 'package:buking/data/cache/data_cache_manager.dart';
import 'package:buking/data/network/api/auth_api.dart';
import 'package:buking/data/network/api/chat_api.dart';
import 'package:buking/data/repositories/data_auth_repository.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/generated/l10n.dart';
import 'package:buking/main.dart' as app;
import 'package:buking/screens/home/tabs/home_tab/home_tab_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/notification/unread_notif_bloc.dart';
import 'package:buking/services/localization_service.dart';
import 'package:buking/services/network_status_service.dart';
import 'package:buking/services/theme_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _shotsDir = '.project-ai/shots';

final String _shotPrefix = Platform.environment['SHOT_PREFIX'] ?? 'home-tab';

const Size _screen = Size(390, 844);
const double _pixelRatio = 2;

final GlobalKey _captureKey = GlobalKey();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = null;

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final cacheDir = Directory.systemTemp.createTempSync('wawat_shot_');
    _stubPathProvider(cacheDir.path);

    await _loadRealFonts();

    Hive.init(cacheDir.path);
    _registerDependencies();

    app.themeManager = await ThemeManager.create();
    await LocalizationService.instance.load('az');
  });

  testWidgets('главная страница', (tester) async {
    await _pumpHome(tester);

    await _waitForNetwork(tester, const Duration(seconds: 12));
    await _capture(tester, '$_shotPrefix-1.png');

    await _scroll(tester, -520);
    await _waitForNetwork(tester, const Duration(seconds: 3));
    await _capture(tester, '$_shotPrefix-2.png');

    await _scroll(tester, -900);
    await _waitForNetwork(tester, const Duration(seconds: 4));
    await _capture(tester, '$_shotPrefix-3.png');

    await app.themeManager.toggleTheme();
    await _scroll(tester, 760);
    await _scroll(tester, 760);
    await _waitForNetwork(tester, const Duration(seconds: 8));
    await _capture(tester, '$_shotPrefix-4.png');

    await _closeNetwork(tester);
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> _pumpHome(WidgetTester tester) async {
  tester.view.devicePixelRatio = _pixelRatio;
  tester.view.physicalSize = _screen * _pixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app.themeManager),
          ChangeNotifierProvider.value(value: LocalizationService.instance),
          ChangeNotifierProvider.value(value: NetworkStatusService.instance),
        ],
        child: Consumer<ThemeManager>(
          builder: (context, manager, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: manager.isDarkMode ? _darkTheme : appTheme,
            locale: const Locale('az'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('az'),
              Locale('en'),
              Locale('ru'),
              Locale('tr'),
              Locale('uk'),
              Locale('es'),
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 47, bottom: 34),
                textScaler: TextScaler.noScaling,
              ),
              child: child!,
            ),
            home: HomeTabScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Instrument Sans',
  fontFamilyFallback: const ['Noto Sans'],
);

Future<void> _scroll(WidgetTester tester, double dy) async {
  await tester.drag(
    find.byType(CustomScrollView).first,
    Offset(0, dy),
    warnIfMissed: false,
  );
  await tester.pump();
}

Future<void> _waitForNetwork(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 250);
  for (var spent = Duration.zero; spent < total; spent += step) {
    await tester.runAsync(() => Future<void>.delayed(step));
    await tester.pump(step);
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    for (final element in tester.elementList(find.byType(Image))) {
      final image = element.widget as Image;
      try {
        await precacheImage(image.image, element);
      } catch (_) {
      }
    }
  });
  await tester.pump();

  final boundary =
      _captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  late Uint8List bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = data!.buffer.asUint8List();
    image.dispose();
  });

  final file = File('$_shotsDir/$name')..createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  // ignore: avoid_print
  print('screenshot: ${file.path} (${bytes.length ~/ 1024} KB)');
}

Future<void> _closeNetwork(WidgetTester tester) async {
  app.sl.get<Dio>().close(force: true);
  await _waitForNetwork(tester, const Duration(seconds: 2));
  await tester.pump(const Duration(minutes: 2));
}

void _registerDependencies() {
  final dio = Dio()
    ..options.headers['content-type'] = 'application/json'
    ..options.headers['accept'] = 'application/json'
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30)
    ..interceptors.add(CallInterceptor());

  app.sl.registerLazySingleton<Dio>(() => dio);
  app.sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  app.sl.registerLazySingleton<ChatApi>(() => ChatApi(dio));
  app.sl.registerLazySingleton<CacheManager>(() => DataCacheManager());
  app.sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());
  app.sl.registerLazySingleton<UnreadNotificationBloc>(
    () => UnreadNotificationBloc()..init(),
  );
}

Future<void> _loadRealFonts() async {
  await _loadFamily('Instrument Sans', [
    'assets/fonts/InstrumentSans-Regular.ttf',
    'assets/fonts/InstrumentSans-Medium.ttf',
    'assets/fonts/InstrumentSans-SemiBold.ttf',
    'assets/fonts/InstrumentSans-Bold.ttf',
  ]);
  await _loadFamily('Noto Sans', [
    'assets/fonts/NotoSans-Regular.ttf',
    'assets/fonts/NotoSans-Medium.ttf',
    'assets/fonts/NotoSans-SemiBold.ttf',
    'assets/fonts/NotoSans-Bold.ttf',
  ]);

  final phosphor = _packageRoot('phosphor_flutter');
  if (phosphor != null) {
    const families = {
      'PhosphorRegular': 'Phosphor.ttf',
      'PhosphorBold': 'Phosphor-Bold.ttf',
      'PhosphorFill': 'Phosphor-Fill.ttf',
      'PhosphorLight': 'Phosphor-Light.ttf',
      'PhosphorThin': 'Phosphor-Thin.ttf',
      'PhosphorDuotone': 'Phosphor-Duotone.ttf',
    };
    for (final entry in families.entries) {
      await _loadFamily(
        'packages/phosphor_flutter/${entry.key}',
        ['$phosphor/lib/fonts/${entry.value}'],
      );
    }
  }

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _loadFamily('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
}

Future<void> _loadFamily(String family, List<String> paths) async {
  final loader = FontLoader(family);
  var added = 0;
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    added++;
    loader.addFont(
      file.readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  }
  if (added > 0) await loader.load();
}

String? _packageRoot(String package) {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return null;
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  for (final entry in (json['packages'] as List).cast<Map<String, dynamic>>()) {
    if (entry['name'] != package) continue;
    final root = Uri.parse(entry['rootUri'] as String);
    return root.isScheme('file')
        ? root.toFilePath()
        : Directory.current.uri.resolveUri(root).toFilePath();
  }
  return null;
}

void _stubPathProvider(String path) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => path,
  );
}
