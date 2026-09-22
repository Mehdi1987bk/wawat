import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class HomeStats {
  const HomeStats({
    required this.deliveriesThisMonth,
    required this.verifiedTravelers,
  });

  final int deliveriesThisMonth;
  final int verifiedTravelers;

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final data = nested is Map
        ? nested.map((key, value) => MapEntry(key.toString(), value))
        : json;

    int readCount(String key) {
      final value = data[key];
      final parsed =
          value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
      if (parsed == null || parsed < 0) {
        throw const FormatException('Invalid home stats response');
      }
      return parsed;
    }

    return HomeStats(
      deliveriesThisMonth: readCount('deliveries_this_month'),
      verifiedTravelers: readCount('verified_travelers'),
    );
  }

  Map<String, int> toJson() => {
        'deliveries_this_month': deliveriesThisMonth,
        'verified_travelers': verifiedTravelers,
      };
}

/// Loads the public home counters with stale-while-revalidate semantics.
///
/// The screen reads [loadCached] first and never waits for [refresh] before it
/// renders. A successful network response replaces the last-known value on
/// disk; an invalid/error response leaves that cached value untouched.
class HomeStatsService {
  HomeStatsService({Dio? dio, SharedPreferences? preferences})
      : _dio = dio ?? sl.get<Dio>(),
        _preferences = preferences;

  static const _endpoint = '$baseUrl/home/stats';
  static const _cacheKey = 'home.stats.last_known';

  final Dio _dio;
  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<HomeStats?> loadCached() async {
    try {
      final raw = (await _prefs).getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return HomeStats.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<HomeStats> refresh() async {
    final response = await _dio
        .get<Map<String, dynamic>>(
          _endpoint,
          options: Options(
            headers: const {'Accept': 'application/json'},
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        )
        .timeout(const Duration(seconds: 12));
    final raw = response.data;
    if (raw == null) {
      throw const FormatException('Empty home stats response');
    }

    final stats = HomeStats.fromJson(raw);
    await (await _prefs).setString(_cacheKey, jsonEncode(stats.toJson()));
    return stats;
  }
}
