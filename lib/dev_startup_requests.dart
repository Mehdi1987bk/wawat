import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'screens/forced_update/forced_update_screen.dart';
import 'services/app_update_service.dart';
import 'services/guarded_request.dart';
import 'services/network_failure.dart';
import 'services/retry_gate.dart';
import 'wawat_app.dart' show navigatorKey;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Wawat startup requests dev',
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    theme: ThemeData(
      fontFamily: 'Instrument Sans',
      fontFamilyFallback: const ['Noto Sans'],
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(primary: Color(0xFF017BFE)),
      useMaterial3: true,
    ),
    home: const _DevStartupScreen(),
  ));
}

const _answer = {
  'data': {
    'platform': 'ios',
    'latest_version': '2.0.4',
    'update_available': true,
    'force_update': false,
    'title': 'Yeniləmə tələb olunur',
    'message': 'Davam etmək üçün tətbiqi yeniləyin.',
    'store_url': 'https://apps.apple.com/app/id6755226789',
  },
};

Map<String, dynamic> _forced() => {
      'data': {...?_answer['data'], 'force_update': true},
    };

typedef _Reply = Future<ResponseBody> Function(RequestOptions options);

ResponseBody _json(Map<String, dynamic> body, [int code = 200]) =>
    ResponseBody.fromString(jsonEncode(body), code, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });

ResponseBody _html(int code, {Map<String, List<String>> headers = const {}}) =>
    ResponseBody.fromString('<html>$code</html>', code, headers: {
      Headers.contentTypeHeader: ['text/html'],
      ...headers,
    });

class _Scenario {
  const _Scenario(
    this.title,
    this.hint,
    this.reply, {
    this.splashWindow,
    this.screenRepeats,
  });

  final String title;
  final String hint;
  final _Reply reply;

  final Duration? splashWindow;

  final int? screenRepeats;
}

const _feedUrl = 'https://api.wawatair.com/api/v1/listings?page=2';

final _scenarios = <_Scenario>[
  _Scenario(
    'Нет сети',
    'Авиарежим: соединение не устанавливается',
    (o) async => throw DioException.connectionError(
        requestOptions: o, reason: 'Failed host lookup'),
  ),
  _Scenario(
    '«504» за 300 мс',
    'Гостевой Wi‑Fi или VPN отвечает вместо сервера',
    (o) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return _html(504);
    },
  ),
  _Scenario(
    '429 + Retry-After: 30',
    'Сервер просит сбавить темп',
    (o) async => _html(429, headers: {
      'retry-after': ['30'],
    }),
  ),
  _Scenario(
    'Сервер молчит',
    'Соединение висит до таймаута',
    (o) async {
      await Future<void>.delayed(o.connectTimeout!);
      throw DioException.connectionTimeout(
          timeout: o.connectTimeout!, requestOptions: o);
    },
  ),
  _Scenario(
    'Сервер: обновление обязательно',
    'Успешный ответ с force_update: true',
    (o) async => _json(_forced()),
  ),
  _Scenario(
    'Ответ опоздал на 3 секунды',
    'Заставка ждёт 1 с и пускает дальше; force_update приходит позже',
    (o) async {
      await Future<void>.delayed(const Duration(seconds: 3));
      return _json(_forced());
    },
    splashWindow: const Duration(seconds: 1),
  ),
  _Scenario(
    'Экран повторяет запрос подряд',
    'Сервер отвечает 500, экран тут же пробует снова — 4 раза',
    (o) async => _json(const {'message': 'Server Error'}, 500),
    screenRepeats: 4,
  ),
  _Scenario(
    'Лента после 429',
    'Сервер просит подождать 30 с, лента продолжает просить страницу',
    (o) async => ResponseBody.fromString(
      jsonEncode(const {'message': 'Too Many Attempts.'}),
      429,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'retry-after': ['30'],
      },
    ),
    screenRepeats: 200,
  ),
];

class _FakeNetwork implements HttpClientAdapter {
  _FakeNetwork(this.reply, this.onRequest);

  final _Reply reply;
  final void Function(RequestOptions options) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    onRequest(options);
    return reply(options);
  }

  @override
  void close({bool force = false}) {}
}

class _DevStartupScreen extends StatefulWidget {
  const _DevStartupScreen();

  @override
  State<_DevStartupScreen> createState() => _DevStartupScreenState();
}

class _DevStartupScreenState extends State<_DevStartupScreen> {
  final _log = <String>[];
  final _watch = Stopwatch();
  String? _running;

  String get _at => '${(_watch.elapsedMilliseconds / 1000).toStringAsFixed(1)} с';

  void _say(String line) {
    if (!mounted) return;
    setState(() => _log.add('$_at  $line'));
  }

  Future<void> _play(_Scenario scenario) async {
    if (_running != null) return;
    setState(() {
      _running = scenario.title;
      _log
        ..clear()
        ..add('▶ ${scenario.title} — ${scenario.hint}');
    });
    _watch
      ..reset()
      ..start();

    var sent = 0;
    final dio = Dio()
      ..httpClientAdapter = _FakeNetwork(scenario.reply, (options) {
        sent++;
        _say('запрос №$sent ушёл');
      })
      ..interceptors.add(RetryGate())
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra[NetworkFailure.startedAtKey] = DateTime.now();
          handler.next(options);
        },
        onError: (err, handler) {
          final failure = NetworkFailure.of(err);
          final code = failure.statusCode == 0 ? 'нет ответа' : 'код ${failure.statusCode}';
          _say('  ↳ $code → телеметрия: '
              '${failure.isRealFailure ? 'error' : 'warning'}, '
              'is_offline: ${failure.isOffline}');
          handler.next(err);
        },
      ));

    final repeats = scenario.screenRepeats;
    if (repeats != null) {
      for (var i = 0; i < repeats; i++) {
        try {
          await dio.get<dynamic>(_feedUrl);
        } on DioException catch (_) {
        }
      }
      _say('✅ Итог: экран просил $repeats раз подряд — в сеть ушло $sent '
          'за $_at');
      if (mounted) setState(() => _running = null);
      return;
    }

    final request = GuardedRequest(dio: () => dio);
    final service = AppUpdateService(
      request: request,
      build: () async => const AppBuild(
        platform: 'ios',
        version: '2.0.3',
        buildNumber: '62',
        packageName: 'com.wawat.app',
      ),
      lang: () => 'az',
    )..attach(onForcedUpdate: (info) {
        _say('⛔ force_update пришёл после заставки — экран обновления');
        return showForcedUpdateScreen(info);
      });

    final window = scenario.splashWindow;
    final info = window == null
        ? await service.check()
        : await service.startupCheck(window: window);

    final blocked = request.blockedUntil;
    if (blocked != null) {
      final wait = blocked.difference(DateTime.now()).inSeconds + 1;
      _say('сервер просил подождать: следующий запрос не раньше чем через $wait с');
      final again = await request.get('https://api.wawatair.com/api/v1/app/config');
      _say('повторная попытка сейчас: запросов в сеть — ${again.attempts}');
    }

    if (info?.forceUpdate == true) {
      _say('⛔ Итог: сервер требует обновление — блокирующий экран');
      setState(() => _running = null);
      showForcedUpdateScreen(info!);
      return;
    }
    _say(info == null
        ? '✅ Итог: ответа нет — пользователь проходит в приложение'
        : '✅ Итог: обновление не обязательно — пользователь проходит');
    if (mounted) setState(() => _running = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Стартовая проверка версии'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final scenario in _scenarios)
                    FilledButton.tonal(
                      onPressed:
                          _running == null ? () => _play(scenario) : null,
                      child: Text(scenario.title),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final line in _log)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: line.contains('Итог') || line.startsWith('▶')
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  if (_running != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
