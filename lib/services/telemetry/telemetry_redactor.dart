/// Вычищает персональные данные из всего, что уходит с устройства.
///
/// Это не «на всякий случай», а обязательное условие для сторов: в App Privacy
/// и Data safety мы заявляем, что диагностика **не содержит** контактных данных
/// и содержимого сообщений. Сообщения об ошибках Dio охотно тащат в себе тело
/// запроса — там и телефон, и e-mail, и Bearer-токен. Поэтому любая строка,
/// которая попадает в Analytics, Crashlytics или в панель бэкенда, проходит
/// через [redact].
///
/// Правило простое: чистим **до** отправки, а не полагаемся на то, что бэкенд
/// или Firebase что-то отфильтруют.
class TelemetryRedactor {
  TelemetryRedactor._();

  // Bearer-токены и JWT.
  static final _bearer =
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false);
  static final _jwt = RegExp(r'\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9._-]{10,}\b');

  // E-mail.
  static final _email =
      RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]{2,}\b', caseSensitive: false);

  // Телефоны: +994 XX XXX XX XX и любые последовательности от 9 цифр
  // с разделителями.
  static final _phone =
      RegExp(r'(?<!\d)\+?\d[\d\s().-]{7,}\d(?!\d)', multiLine: true);

  // Явные секреты в JSON/квери: "password":"...", token=..., otp=1234.
  static final _secretField = RegExp(
    r'''("?\b(?:password|password_confirmation|token|access_token|refresh_token|api_key|secret|otp|code|pin|card|cvv|iban)\b"?\s*[:=]\s*)("[^"]*"|[^\s,&}]+)''',
    caseSensitive: false,
  );

  // Числовые id в путях: /listings/12345 → /listings/{id}. Нужно, чтобы
  // эндпоинты группировались в панели, а не размазывались по тысяче строк.
  static final _pathId = RegExp(r'/\d+(?=/|$)');
  static final _pathUuid = RegExp(
    r'/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?=/|$)',
    caseSensitive: false,
  );

  /// Полная чистка произвольной строки (сообщение об ошибке, тело ответа).
  ///
  /// [collapseWhitespace] схлопывает пробелы и переносы в один пробел — это
  /// правильно для однострочных сообщений, но **не** для стек-трейсов: там
  /// перенос строки и есть граница кадра, без него трейс превращается в
  /// нечитаемую простыню. Для трейсов передавайте `false`.
  static String redact(
    String? input, {
    int maxLength = 512,
    bool collapseWhitespace = true,
  }) {
    if (input == null || input.isEmpty) return '';
    var s = input;
    s = s.replaceAll(_bearer, 'Bearer ***');
    s = s.replaceAll(_jwt, '***jwt***');
    s = s.replaceAllMapped(_secretField, (m) => '${m.group(1)}"***"');
    s = s.replaceAll(_email, '***@***');
    s = s.replaceAll(_phone, '***');
    s = collapseWhitespace
        ? s.replaceAll(RegExp(r'\s+'), ' ').trim()
        : s.trimRight();
    return s.length <= maxLength ? s : '${s.substring(0, maxLength - 1)}…';
  }

  /// `/api/v1/listings/8123/proposals` → `/listings/{id}/proposals`.
  ///
  /// Схлопывание id — то, что превращает сырой лог запросов в осмысленную
  /// таблицу «эндпоинт → доля ошибок» в панели.
  static String endpoint(String? path) {
    if (path == null || path.isEmpty) return 'unknown';
    var p = path;
    final qIndex = p.indexOf('?');
    if (qIndex >= 0) p = p.substring(0, qIndex);
    // Отрезаем схему и хост.
    final schemeIndex = p.indexOf('://');
    if (schemeIndex >= 0) {
      final slash = p.indexOf('/', schemeIndex + 3);
      p = slash >= 0 ? p.substring(slash) : '/';
    }
    p = p.replaceFirst(RegExp(r'^/api/v\d+'), '');
    p = p.replaceAll(_pathUuid, '/{id}');
    p = p.replaceAll(_pathId, '/{id}');
    if (p.isEmpty) p = '/';
    return p.length <= 120 ? p : p.substring(0, 120);
  }

  /// Рекурсивная чистка структуры (query-параметры, контекст события).
  static Object? value(Object? v, {int depth = 0}) {
    if (depth > 4) return '…';
    if (v == null || v is num || v is bool) return v;
    if (v is String) return redact(v, maxLength: 200);
    if (v is Iterable) {
      return v.take(20).map((e) => value(e, depth: depth + 1)).toList();
    }
    if (v is Map) {
      final out = <String, Object?>{};
      var i = 0;
      for (final e in v.entries) {
        if (i++ >= 30) break;
        final key = e.key.toString();
        if (_isSensitiveKey(key)) {
          out[key] = '***';
        } else {
          out[key] = value(e.value, depth: depth + 1);
        }
      }
      return out;
    }
    return redact(v.toString(), maxLength: 200);
  }

  static const _sensitiveKeys = {
    'password',
    'password_confirmation',
    'old_password',
    'new_password',
    'token',
    'access_token',
    'refresh_token',
    'fcm_token',
    'api_key',
    'secret',
    'otp',
    'otp_code',
    'code',
    'pin',
    'authorization',
    'phone',
    'email',
    'card',
    'cvv',
    'iban',
    'body', // тело сообщения в чате
    'message',
    'text',
    'avatar',
    'about',
  };

  static bool _isSensitiveKey(String key) =>
      _sensitiveKeys.contains(key.toLowerCase());
}
