/// Снимок главной страницы приложения — то, что видит пользователь на старте.
///
/// Запуск (Flutter из `.fvmrc`, см. KNOWN_ISSUES):
///   flutter test tool/screenshots/home_tab_screenshot.dart
///
/// Файл лежит вне `test/` намеренно: `flutter test` без аргументов его не
/// подхватывает. Он ходит в боевой API (api.wawatair.com), ждёт сеть и пишет
/// PNG на диск — такому «тесту» не место в обычном прогоне и в CI.
///
/// Почему снимок делается тестовым биндингом, а не сборкой приложения:
/// на машине агента нет Android SDK и эмулятора, а web-сборка невозможна —
/// два десятка файлов приложения импортируют `dart:io`. Виджет-тест остаётся
/// единственным способом отрисовать настоящий экран настоящими данными.
///
// Файл живёт вне `test/`, поэтому анализатор не считает его тестом и ругается
// на тестовые хелперы плагинов. Здесь они по назначению.
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

/// Куда складывать кадры. Каталог показывается оператору в чате.
const _shotsDir = '.project-ai/shots';

/// Префикс имени файла задаёт запускающий: `SHOT_PREFIX=... flutter test …`.
final String _shotPrefix = Platform.environment['SHOT_PREFIX'] ?? 'home-tab';

/// Логический размер кадра — обычный современный телефон.
const Size _screen = Size(390, 844);
const double _pixelRatio = 2;

final GlobalKey _captureKey = GlobalKey();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // flutter_test подменяет HttpClient заглушкой, которая на любой запрос
    // отвечает 400. Экрану нужен живой API — снимаем подмену.
    HttpOverrides.global = null;

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final cacheDir = Directory.systemTemp.createTempSync('wawat_shot_');
    _stubPathProvider(cacheDir.path);

    await _loadRealFonts();

    Hive.init(cacheDir.path);
    _registerDependencies();

    app.themeManager = await ThemeManager.create();
    // Тексты главной приходят из CMS (`GET /content`), а не из ARB.
    await LocalizationService.instance.load('az');
  });

  testWidgets('главная страница', (tester) async {
    await _pumpHome(tester);

    // Лента, словари пакетов и CMS-тексты грузятся тремя независимыми
    // запросами; ждём их реальным временем, а не pumpAndSettle (на экране
    // живут бесконечные анимации скелетона).
    await _waitForNetwork(tester, const Duration(seconds: 12));
    await _capture(tester, '$_shotPrefix-1.png');

    await _scroll(tester, -520);
    await _waitForNetwork(tester, const Duration(seconds: 3));
    await _capture(tester, '$_shotPrefix-2.png');

    await _scroll(tester, -900);
    await _waitForNetwork(tester, const Duration(seconds: 4));
    await _capture(tester, '$_shotPrefix-3.png');

    // Тёмная тема — та же верхушка главной, чтобы было с чем сравнивать.
    // Возврат наверх неизбежно задевает pull-to-refresh, поэтому после него
    // ждём дольше: пока обновление не закончится, спиннер висит поверх шапки.
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
            // Вырезы телефона: без них шапка прилипает к верхней грани кадра.
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

/// Приложение собирает тёмную тему приватным методом в `wawat_app.dart`.
/// Экранам оттуда нужна только яркость — конкретные цвета они берут из
/// `wawat_dark.dart`, поэтому для снимка хватает минимальной копии.
final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Instrument Sans',
  fontFamilyFallback: const ['Noto Sans'],
);

/// Крутит ленту на [dy] логических пикселей (отрицательное — вниз по списку).
Future<void> _scroll(WidgetTester tester, double dy) async {
  await tester.drag(
    find.byType(CustomScrollView).first,
    Offset(0, dy),
    warnIfMissed: false,
  );
  await tester.pump();
}

/// Даёт запросам реальное время: `runAsync` пускает настоящие таймеры и
/// сокеты, `pump` после него отрисовывает то, что успело приехать.
Future<void> _waitForNetwork(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 250);
  for (var spent = Duration.zero; spent < total; spent += step) {
    await tester.runAsync(() => Future<void>.delayed(step));
    await tester.pump(step);
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  // Картинки декодируются только в реальном времени — иначе в кадр попадут
  // пустые места вместо логотипа и фотографий объявлений.
  await tester.runAsync(() async {
    for (final element in tester.elementList(find.byType(Image))) {
      final image = element.widget as Image;
      try {
        await precacheImage(image.image, element);
      } catch (_) {
        // Недоступная картинка не должна ронять съёмку.
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

/// Открытые сокеты и таймауты dio переживают тест, и биндинг валит его на
/// «A Timer is still pending even after the widget tree was disposed».
/// Закрываем клиент и прокручиваем время, чтобы таймеры успели отработать.
Future<void> _closeNetwork(WidgetTester tester) async {
  app.sl.get<Dio>().close(force: true);
  await _waitForNetwork(tester, const Duration(seconds: 2));
  await tester.pump(const Duration(minutes: 2));
}

/// Тот же граф зависимостей, что собирает `main._registerDependency()`,
/// но без Firebase, пушей и сокетов — экрану нужны только API и кэш.
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

/// В виджет-тестах весь текст рисуется заглушкой Ahem — прямоугольниками.
/// Подкладываем настоящие шрифты приложения, шрифт иконок Phosphor и
/// Material Icons, иначе кадр невозможно смотреть.
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
      // Иконки объявлены с `fontPackage`, поэтому движок ищет их семейство
      // под именем `packages/<пакет>/<семейство>` — под ним и регистрируем.
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

/// Плагина path_provider в тестовом окружении нет, а кэш картинок без него
/// не стартует. Отдаём ему временный каталог.
void _stubPathProvider(String path) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => path,
  );
}
