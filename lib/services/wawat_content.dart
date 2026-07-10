import '../domain/repositories/auth_repository.dart';
import '../main.dart';

class WawatContent {
  WawatContent._();

  static final Map<String, Future<Map<String, String>>> _futures = {};
  static final Map<String, Map<String, String>> _cache = {};

  static Future<Map<String, String>> load({String group = 'listing'}) {
    final cached = _cache[group];
    if (cached != null) return Future.value(cached);
    return _futures[group] ??= sl
        .get<AuthRepository>()
        .getContent(group: group)
        .then((response) => _cache[group] = response.data)
        .catchError((_) => _cache[group] = const {});
  }

  static String text(
    Map<String, String> content,
    String key, [
    String? fallback,
  ]) {
    final value = content[key];
    if (value == null || value.trim().isEmpty) return fallback ?? key;
    return value;
  }
}
