import 'package:buking/services/home_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/scripted_network.dart';

Map<String, dynamic> _config(Object tab) => {
      'data': {'default_tab': tab},
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the server value is used and remembered for the next launch', () async {
    final network = ScriptedNetwork([ok(_config('search'))]);

    final tab = await HomeConfig(request: network.request()).refreshDefaultTab();

    expect(tab, 1);
    expect(network.requests.single.uri.path, '/api/v1/app/config');
    final nextLaunch = HomeConfig(request: ScriptedNetwork([offline()]).request());
    expect(await nextLaunch.cachedDefaultTab(), 1);
  });

  test('no network: the previous launch value is used', () async {
    SharedPreferences.setMockInitialValues({'home_default_tab': 1});
    final network = ScriptedNetwork([offline()]);

    final tab = await HomeConfig(request: network.request()).refreshDefaultTab();

    expect(tab, 1);
  });

  test('no network and nothing stored: the built-in default', () async {
    final network = ScriptedNetwork([offline()]);

    final tab = await HomeConfig(request: network.request()).refreshDefaultTab();

    expect(tab, 0);
  });

  test('a fake "504", a 429 and a broken answer keep the previous value',
      () async {
    for (final step in [
      status(504),
      status(429),
      captivePortal(),
      ok(const {'data': <String, dynamic>{}}),
    ]) {
      SharedPreferences.setMockInitialValues({'home_default_tab': 1});
      final network = ScriptedNetwork([step]);

      final tab =
          await HomeConfig(request: network.request()).refreshDefaultTab();

      expect(tab, 1);
    }
  });

  test('a 429 is not retried', () async {
    final network = ScriptedNetwork([status(429), ok(_config(1))]);

    await HomeConfig(request: network.request()).refreshDefaultTab();

    expect(network.requests, hasLength(1));
    expect(network.pauses, isEmpty);
  });

  test('one request per launch, however many callers ask', () async {
    final network = ScriptedNetwork([ok(_config(1))]);
    final config = HomeConfig(request: network.request());

    await Future.wait([config.refreshDefaultTab(), config.refreshDefaultTab()]);
    await config.refreshDefaultTab();

    expect(network.requests, hasLength(1));
  });

  test('the network came back on a retry: the fresh value wins', () async {
    SharedPreferences.setMockInitialValues({'home_default_tab': 1});
    final network = ScriptedNetwork([offline(), ok(_config(0))]);

    final tab = await HomeConfig(request: network.request()).refreshDefaultTab();

    expect(tab, 0);
    expect(network.pauses, const [Duration(seconds: 1)]);
  });
}
