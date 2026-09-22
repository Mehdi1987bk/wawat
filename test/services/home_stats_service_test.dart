import 'package:buking/services/home_stats_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('parses the wrapped public API response', () {
    final stats = HomeStats.fromJson({
      'data': {
        'deliveries_this_month': 1240,
        'verified_travelers': 3512,
      },
    });

    expect(stats.deliveriesThisMonth, 1240);
    expect(stats.verifiedTravelers, 3512);
  });

  test('rejects missing or negative counters', () {
    expect(
      () => HomeStats.fromJson({
        'data': {'deliveries_this_month': -1},
      }),
      throwsFormatException,
    );
  });

  test('refresh persists values for the next offline launch', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': {
                'deliveries_this_month': 27,
                'verified_travelers': 314,
              },
            },
          ),
        ),
      ),
    );
    final preferences = await SharedPreferences.getInstance();
    final service = HomeStatsService(dio: dio, preferences: preferences);

    final fresh = await service.refresh();
    final cached = await service.loadCached();

    expect(fresh.deliveriesThisMonth, 27);
    expect(cached?.verifiedTravelers, 314);
  });

  test('returns null when no valid cached value exists', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('home.stats.last_known', '{broken');

    final cached = await HomeStatsService(
      dio: Dio(),
      preferences: preferences,
    ).loadCached();

    expect(cached, isNull);
  });
}
