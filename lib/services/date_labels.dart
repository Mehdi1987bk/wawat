import 'localization_service.dart';

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

String monthFull(int month) {
  if (month < 1 || month > 12) return '';
  final i = month - 1;
  return tr('month.${_code[i]}', _fullFallback[i]);
}

String monthShort(int month) {
  if (month < 1 || month > 12) return '';
  final i = month - 1;
  return tr('common.month_${_code[i]}', _shortFallback[i]);
}
