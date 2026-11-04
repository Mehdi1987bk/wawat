import 'dart:async';

import 'package:buking/services/app_update_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/scripted_network.dart';

const _ios = AppBuild(
  platform: 'ios',
  version: '2.0.3',
  buildNumber: '62',
  packageName: 'com.wawat.app',
);

Map<String, dynamic> _answer({bool force = false, bool available = false}) => {
      'data': {
        'platform': 'ios',
        'latest_version': '2.0.4',
        'latest_build': 63,
        'update_available': available,
        'force_update': force,
        'title': 'Yeniləmə',
        'message': 'Yeni versiyanı quraşdırın',
        'store_url': 'https://apps.apple.com/app/id1',
      },
    };

AppUpdateService _service(ScriptedNetwork network, {AppBuild? build = _ios}) =>
    AppUpdateService(
      request: network.request(),
      build: () async => build,
      lang: () => 'az',
      clock: network.clock,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUpdateInfo.fromJson', () {
    test('parses the wrapped backend contract', () {
      final info = AppUpdateInfo.fromJson({
        'data': {
          'force_update': true,
          'latest_version': '1.2.0',
          'title': 'Update',
          'message': 'Install the latest version',
          'store_url': 'https://example.com/store',
        },
      });

      expect(info.forceUpdate, isTrue);
      expect(info.latestVersion, '1.2.0');
      expect(info.title, 'Update');
      expect(info.message, 'Install the latest version');
      expect(info.storeUrl, 'https://example.com/store');
    });

    test('accepts the flat Namazov response and string booleans', () {
      final info = AppUpdateInfo.fromJson({
        'force_update': 'true',
        'latest_version': '2.0.0',
      });

      expect(info.forceUpdate, isTrue);
      expect(info.latestVersion, '2.0.0');
    });

    test('defaults to no forced update for incomplete responses', () {
      final info = AppUpdateInfo.fromJson(const {});

      expect(info.forceUpdate, isFalse);
      expect(info.updateAvailable, isFalse);
      expect(info.storeUrl, isNull);
    });

    test('reads the soft-update flag separately from the forced one', () {
      final info = AppUpdateInfo.fromJson(_answer(available: true));

      expect(info.updateAvailable, isTrue);
      expect(info.forceUpdate, isFalse);
    });
  });

  group('request contract', () {
    test('sends platform, numeric build number and language', () async {
      final network = ScriptedNetwork([ok(_answer())]);

      await _service(network).check();

      final sent = network.requests.single;
      expect(sent.method, 'GET');
      expect(sent.uri.path, '/api/v1/app/version-check');
      expect(sent.uri.queryParameters['platform'], 'ios');
      expect(sent.uri.queryParameters['build_number'], '62');
      expect(sent.uri.queryParameters['lang'], 'az');
    });

    test('a version string instead of a build number is never sent', () async {
      final network = ScriptedNetwork([ok(_answer(force: true))]);
      const broken = AppBuild(
        platform: 'ios',
        version: '2.0.3',
        buildNumber: '2.0.3',
        packageName: 'com.wawat.app',
      );

      final info = await _service(network, build: broken).check();

      expect(info, isNull);
      expect(network.requests, isEmpty);
    });

    test('an unsupported platform makes no request', () async {
      final network = ScriptedNetwork([ok(_answer(force: true))]);

      expect(await _service(network, build: null).check(), isNull);
      expect(network.requests, isEmpty);
    });

    test('a forced update without a store link still gets one', () async {
      final answer = _answer(force: true);
      (answer['data'] as Map).remove('store_url');
      final network = ScriptedNetwork([ok(answer)]);

      final info = await _service(network).check();

      expect(info!.forceUpdate, isTrue);
      expect(info.storeUrl, startsWith('https://apps.apple.com/'));
    });
  });

  group('fail-open: no answer never blocks the user', () {
    test('no network', () async {
      final network = ScriptedNetwork([offline()]);

      final info = await _service(network).check();

      expect(info, isNull);
    });

    test('a timeout', () async {
      final network = ScriptedNetwork([
        (options) => throw DioException.receiveTimeout(
              timeout: const Duration(seconds: 10),
              requestOptions: options,
            ),
      ]);

      expect(await _service(network).check(), isNull);
    });

    test('a fake "504" from a captive portal, a 429 and a 4xx', () async {
      for (final step in [status(504), status(429), status(422)]) {
        final network = ScriptedNetwork([step]);

        expect(await _service(network).check(), isNull);
      }
    });

    test('a failed first attempt followed by force_update still blocks',
        () async {
      final network = ScriptedNetwork([offline(), ok(_answer(force: true))]);

      final info = await _service(network).check();

      expect(info!.forceUpdate, isTrue);
      expect(network.requests, hasLength(2));
    });
  });

  group('one request per launch', () {
    test('later callers get the answer from memory', () async {
      final network = ScriptedNetwork([ok(_answer(available: true))]);
      final service = _service(network);

      final first = await service.check();
      final second = await service.check();

      expect(network.requests, hasLength(1));
      expect(second, same(first));
    });

    test('concurrent callers share one request', () async {
      final network = ScriptedNetwork([ok(_answer())]);
      final service = _service(network);

      await Future.wait([service.check(), service.check(), service.check()]);

      expect(network.requests, hasLength(1));
    });

    test('a failed check is not repeated right away either', () async {
      final network = ScriptedNetwork([status(429), ok(_answer(force: true))]);
      final service = _service(network);

      expect(await service.check(), isNull);
      expect(await service.check(), isNull);

      expect(network.requests, hasLength(1));
    });
  });

  group('return from the background', () {
    test('within 15 minutes makes no network request', () async {
      final network = ScriptedNetwork([ok(_answer())]);
      final service = _service(network)..attach(onForcedUpdate: (_) => true);
      await service.check();

      network.advance(const Duration(minutes: 14, seconds: 59));
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(network.requests, hasLength(1));
    });

    test('after 15 minutes asks again, and a forced update blocks the app',
        () async {
      final network =
          ScriptedNetwork([ok(_answer()), ok(_answer(force: true))]);
      final shown = <AppUpdateInfo>[];
      final service = _service(network)
        ..attach(onForcedUpdate: (info) {
          shown.add(info);
          return true;
        });
      await service.check();

      network.advance(const Duration(minutes: 15));
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(network.requests, hasLength(2));
      expect(shown.single.forceUpdate, isTrue);

      network.advance(const Duration(minutes: 16));
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();
      expect(shown, hasLength(1));
    });

    test('going to the background itself asks nothing', () async {
      final network = ScriptedNetwork([ok(_answer())]);
      final service = _service(network)..attach(onForcedUpdate: (_) => true);
      await service.check();

      network.advance(const Duration(hours: 1));
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      await pumpEventQueue();

      expect(network.requests, hasLength(1));
    });

    test('before the first check there is nothing to repeat', () async {
      final network = ScriptedNetwork([ok(_answer())]);
      final service = _service(network)..attach(onForcedUpdate: (_) => true);

      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(network.requests, isEmpty);
    });
  });

  group('startup', () {
    test('an answer inside the splash window goes to the splash', () async {
      final network = ScriptedNetwork([ok(_answer(force: true))]);
      final shown = <AppUpdateInfo>[];
      final service = _service(network)
        ..attach(onForcedUpdate: (info) {
          shown.add(info);
          return true;
        });

      final info = await service.startupCheck();

      expect(info!.forceUpdate, isTrue);
      await pumpEventQueue();
      expect(shown, isEmpty);
    });

    test('the splash never waits longer than its window', () async {
      final hang = Completer<ResponseBody>();
      final network = ScriptedNetwork([(_) => hang.future]);
      final service = _service(network)..attach(onForcedUpdate: (_) => true);

      final watch = Stopwatch()..start();
      final info = await service.startupCheck(
        window: const Duration(milliseconds: 50),
      );

      expect(info, isNull, reason: 'no answer means the user gets in');
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      hang.complete(ok(_answer())(RequestOptions()));
      await pumpEventQueue();
    });

    test('force_update that arrives after the splash still blocks', () async {
      final late = Completer<ResponseBody>();
      final network = ScriptedNetwork([(_) => late.future]);
      final shown = <AppUpdateInfo>[];
      final service = _service(network)
        ..attach(onForcedUpdate: (info) {
          shown.add(info);
          return true;
        });

      final atSplash = await service.startupCheck(
        window: const Duration(milliseconds: 50),
      );
      expect(atSplash, isNull);
      expect(shown, isEmpty);

      late.complete(ok(_answer(force: true))(RequestOptions()));
      await pumpEventQueue();

      expect(shown.single.forceUpdate, isTrue);
    });

    test('a late answer without force_update changes nothing', () async {
      final late = Completer<ResponseBody>();
      final network = ScriptedNetwork([(_) => late.future]);
      final shown = <AppUpdateInfo>[];
      final service = _service(network)
        ..attach(onForcedUpdate: (info) {
          shown.add(info);
          return true;
        });

      await service.startupCheck(window: const Duration(milliseconds: 50));
      late.complete(ok(_answer(available: true))(RequestOptions()));
      await pumpEventQueue();

      expect(shown, isEmpty);
    });
  });
}
