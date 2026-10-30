/// Разбор JSON модуля рейсов.
///
/// Сервер выбрасывает пустые ключи целиком (§7.2), поэтому везде проверяется
/// наличие ключа, а не только значение.
library;

Map<String, dynamic>? jMap(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>> jMapList(Object? v) => v is List
    ? v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
    : const [];

List<String> jStringList(Object? v) => v is List
    ? v
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false)
    : const [];

String? jString(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? jInt(Object? v) {
  if (v is bool) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString().trim() ?? '');
}

double? jDouble(Object? v) {
  if (v is bool) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString().trim() ?? '');
}

bool jBool(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().trim().toLowerCase();
  return s == 'true' || s == '1';
}

/// `null`, когда ключа нет: отличается от `false` там, где отсутствие значит
/// «неизвестно» (`departure_confirmed` у стороны без живого потока).
bool? jBoolOrNull(Object? v) {
  if (v == null) return null;
  return jBool(v);
}

DateTime? jUtc(Object? v) {
  final s = jString(v);
  if (s == null) return null;
  return DateTime.tryParse(s)?.toUtc();
}
