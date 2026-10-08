import 'localization_service.dart';

/// Названия месяцев из CMS, один источник на всё приложение.
///
/// CMS держит два набора:
///   month.jan … month.dec          — полные («Yanvar», «Fevral», …)
///   common.month_jan … _dec        — краткие («Yan», «Fev», …)
/// AZ-фолбэки повторяют прежние захардкоженные массивы, чтобы при пустой CMS
/// вид не менялся.

const List<String> _fullFallback = [
  'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'İyun',
  'İyul', 'Avqust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr',
];

const List<String> _shortFallback = [
  'Yan', 'Fev', 'Mar', 'Apr', 'May', 'İyun',
  'İyul', 'Avq', 'Sen', 'Okt', 'Noy', 'Dek',
];

const List<String> _code = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun',
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

/// Полное название месяца [month] (1–12), например «Yanvar». Пусто вне диапазона.
String monthFull(int month) {
  if (month < 1 || month > 12) return '';
  final i = month - 1;
  return tr('month.${_code[i]}', _fullFallback[i]);
}

/// Краткое название месяца [month] (1–12), например «Yan». Пусто вне диапазона.
String monthShort(int month) {
  if (month < 1 || month > 12) return '';
  final i = month - 1;
  return tr('common.month_${_code[i]}', _shortFallback[i]);
}
