import '../../services/localization_service.dart';
import 'data/flight_envelope.dart';

/// Текст раздела рейсов.
///
/// Все подписи идут через CMS: ключ `flight.<...>`, в коде — азербайджанский
/// запас на случай, если бэкенд ключ ещё не завёл. Список ключей для бэкенда
/// собирается из этих вызовов в `docs/i18n-new-keys.json`.
String ft(String key, String fallback, [Map<String, String>? params]) =>
    tr('flight.$key', fallback, params);

/// Текст полоски «данные на …» (§4.2) или `null`, если данные свежие.
///
/// Время переводится в часовой пояс телефона: у `fetched_at` есть зона, а
/// города в скобках — того аэропорта, чей экран открыт, если он известен.
String? fStaleLineText(FlightMeta meta, {String? place}) {
  if (!meta.stale) return null;
  final at = meta.fetchedAt?.toLocal();
  if (at == null) {
    return ft('stale_unknown', 'Məlumat ən son məlum vəziyyətə görədir');
  }
  final clock = '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
  if (place == null || place.isEmpty) {
    return ft('stale_line', 'Məlumat {time} vəziyyətinə görədir', {
      'time': clock,
    });
  }
  return ft('stale_line_place', 'Məlumat {time} ({place}) vəziyyətinə görədir', {
    'time': clock,
    'place': place,
  });
}

/// Разряды числа неразрывным пробелом: `1 892`. Так в прототипе.
String fNum(num value) {
  final negative = value < 0;
  final whole = value.abs().round().toString();
  final out = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i != 0 && (whole.length - i) % 3 == 0) out.write(' ');
    out.write(whole[i]);
  }
  return negative ? '−${out.toString()}' : out.toString();
}

/// `1 892 km`
String fKm(num? km) => km == null ? '—' : '${fNum(km)} ${ft('unit_km', 'km')}';

/// `11 277 m`
String fMeters(num? m) =>
    m == null ? '—' : '${fNum(m)} ${ft('unit_m', 'm')}';

/// `842 km/s`
String fSpeed(num? kmh) =>
    kmh == null ? '—' : '${fNum(kmh)} ${ft('unit_kmh', 'km/s')}';

/// `3 saat 25 dəqiqə` — полная форма для строк «ключ → значение».
String fMinutesLong(int? minutes) {
  if (minutes == null) return '—';
  final m = minutes.abs();
  final h = m ~/ 60;
  final rest = m % 60;
  final parts = <String>[];
  if (h > 0) parts.add('$h ${ft('unit_hour', 'saat')}');
  if (rest > 0 || h == 0) parts.add('$rest ${ft('unit_minute', 'dəqiqə')}');
  return parts.join(' ');
}

/// `3 s 25 dəq` — короткая форма для тесных мест.
String fMinutesShort(int? minutes) {
  if (minutes == null) return '—';
  final m = minutes.abs();
  final h = m ~/ 60;
  final rest = m % 60;
  if (h == 0) return '$rest ${ft('unit_min_short', 'dəq')}';
  if (rest == 0) return '$h ${ft('unit_hour_short', 's')}';
  return '$h ${ft('unit_hour_short', 's')} $rest ${ft('unit_min_short', 'dəq')}';
}

/// `+12 dəq` / `−4 dəq` — отклонение от расписания.
String fDeltaMinutes(int? minutes) {
  if (minutes == null) return '—';
  final sign = minutes > 0 ? '+' : (minutes < 0 ? '−' : '');
  return '$sign${minutes.abs()} ${ft('unit_min_short', 'dəq')}';
}

const _monthKeys = [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
];

const _monthFallbacks = [
  'Yanvar',
  'Fevral',
  'Mart',
  'Aprel',
  'May',
  'İyun',
  'İyul',
  'Avqust',
  'Sentyabr',
  'Oktyabr',
  'Noyabr',
  'Dekabr',
];

String fMonth(int month) {
  final i = (month - 1).clamp(0, 11);
  return tr('month.${_monthKeys[i]}', _monthFallbacks[i]);
}

/// Строчная форма месяца. `toLowerCase` для «İ» в Dart даёт «i» с отдельной
/// точкой, поэтому она заменяется явно.
String fMonthLower(int month) =>
    fMonth(month).replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

const _weekdayKeys = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

const _weekdayFallbacks = [
  'bazar ertəsi',
  'çərşənbə axşamı',
  'çərşənbə',
  'cümə axşamı',
  'cümə',
  'şənbə',
  'bazar',
];

/// `bazar` — подпись под выбранной датой. В приложении названий дней недели
/// до этого не было, поэтому ключи новые.
String fWeekday(DateTime? date) {
  if (date == null) return '';
  final i = (date.weekday - 1).clamp(0, 6);
  return tr('weekday.${_weekdayKeys[i]}', _weekdayFallbacks[i]);
}

const _weekdayShortFallbacks = ['B.e', 'Ç.a', 'Ç', 'C.a', 'C', 'Ş', 'B'];

/// `B.e` — шапка столбца в календаре и подпись дня в истории рейса.
String fWeekdayShort(int weekday) {
  final i = (weekday - 1).clamp(0, 6);
  return tr('weekday.short_${_weekdayKeys[i]}', _weekdayShortFallbacks[i]);
}

/// `21 oktyabr 2026`
String fDateLong(DateTime? date) => date == null
    ? '—'
    : '${date.day} ${fMonthLower(date.month)} ${date.year}';

/// `21 oktyabr`
String fDateShort(DateTime? date) =>
    date == null ? '—' : '${date.day} ${fMonthLower(date.month)}';

/// `2026-10-21` → `21 oktyabr 2026`. Строка даты рейса приходит именно так.
String fDateStringLong(String? isoDate) {
  final parsed = isoDate == null ? null : DateTime.tryParse(isoDate);
  return fDateLong(parsed);
}

String fDateStringShort(String? isoDate) {
  final parsed = isoDate == null ? null : DateTime.tryParse(isoDate);
  return fDateShort(parsed);
}

/// `22:40` + 45 минут → `23:25`. Табло даёт расписание и задержку отдельно,
/// фактическое время считается здесь.
String? fClockPlus(String? clock, int? minutes) {
  if (clock == null) return null;
  if (minutes == null || minutes == 0) return clock;
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(clock);
  if (match == null) return clock;
  final total = int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  final shifted = (total + minutes) % (24 * 60);
  final safe = shifted < 0 ? shifted + 24 * 60 : shifted;
  return '${(safe ~/ 60).toString().padLeft(2, '0')}:'
      '${(safe % 60).toString().padLeft(2, '0')}';
}

/// Минуты от начала суток для строки `HH:MM` — нужно для сортировки табло.
int fClockMinutes(String? clock) {
  if (clock == null) return 0;
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(clock);
  if (match == null) return 0;
  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

/// `bu gün` · `sabah` · `dünən` — иначе короткая дата. Нужно там, где рейс
/// стоит в списке и дата сама по себе ничего не говорит.
String fDayWord(String? isoDate) {
  final parsed = isoDate == null ? null : DateTime.tryParse(isoDate);
  if (parsed == null) return '—';
  final now = DateTime.now();
  final days = DateTime(parsed.year, parsed.month, parsed.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  return switch (days) {
    0 => ft('day_today', 'bu gün'),
    1 => ft('day_tomorrow', 'sabah'),
    -1 => ft('day_yesterday', 'dünən'),
    _ => fDateShort(parsed),
  };
}

/// `YYYY-MM-DD` — формат, который принимают эндпоинты.
String fApiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// `2026-11-01T06:00` — формат окна табло: местное время аэропорта, без
/// секунд и без зоны.
String fApiLocalWindow(DateTime local) =>
    '${fApiDate(local)}T${local.hour.toString().padLeft(2, '0')}:'
    '${local.minute.toString().padLeft(2, '0')}';

/// `09:12` — часы и минуты по времени телефона. В ответах рядом с местным
/// временем аэропорта всегда есть UTC: когда показывать нужно не аэропортное
/// время, а «когда это случилось у меня», берётся эта форма.
String fClock(DateTime? moment) {
  if (moment == null) return '—';
  final at = moment.toLocal();
  return '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
}

/// `12 saniyə əvvəl` · `3 dəqiqə əvvəl` · `2 saat əvvəl`.
String fAgo(DateTime? moment, {DateTime? now}) {
  if (moment == null) return '—';
  final diff = (now ?? DateTime.now().toUtc()).difference(moment.toUtc());
  final s = diff.inSeconds;
  if (s < 0) return ft('just_now', 'indi');
  if (s < 60) {
    return ft('ago_seconds', '{n} saniyə əvvəl', {'n': '$s'});
  }
  final m = diff.inMinutes;
  if (m < 60) {
    return ft('ago_minutes', '{n} dəqiqə əvvəl', {'n': '$m'});
  }
  final h = diff.inHours;
  if (h < 24) {
    return ft('ago_hours', '{n} saat əvvəl', {'n': '$h'});
  }
  return ft('ago_days', '{n} gün əvvəl', {'n': '${diff.inDays}'});
}

/// `41.0214° N, 32.8870° E`
String fCoordinates(double? lat, double? lon) {
  if (lat == null || lon == null) return '—';
  final ns = lat >= 0 ? 'N' : 'S';
  final ew = lon >= 0 ? 'E' : 'W';
  return '${lat.abs().toStringAsFixed(4)}° $ns, '
      '${lon.abs().toStringAsFixed(4)}° $ew';
}

/// Флаг страны из двухбуквенного кода: `AZ` → 🇦🇿. Так в прототипе, и это
/// дешевле, чем тащить картинки флагов.
String fFlag(String? countryCode) {
  final code = countryCode?.trim().toUpperCase();
  if (code == null || code.length != 2) return '';
  final a = code.codeUnitAt(0);
  final b = code.codeUnitAt(1);
  const first = 65; // A
  const last = 90; // Z
  if (a < first || a > last || b < first || b > last) return '';
  const base = 0x1F1E6;
  return String.fromCharCodes([base + a - first, base + b - first]);
}

/// `FL370` — эшелон из высоты в футах.
String fFlightLevel(num? feet) =>
    feet == null ? '—' : 'FL${(feet / 100).round().toString().padLeft(3, '0')}';

/// `6.4` → «6 yaş 5 ay». Целое число лет идёт без месяцев, меньше года —
/// только месяцами.
String fAircraftAge(double years) {
  final whole = years.floor();
  final months = ((years - whole) * 12).round();
  final yearWord = ft('unit_year', 'yaş');
  final monthWord = ft('unit_month', 'ay');
  if (whole <= 0) return '$months $monthWord';
  if (months <= 0 || months >= 12) {
    return '${months >= 12 ? whole + 1 : whole} $yearWord';
  }
  return '$whole $yearWord $months $monthWord';
}
