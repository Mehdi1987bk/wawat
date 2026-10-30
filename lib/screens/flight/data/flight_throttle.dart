import 'dart:async';

/// Свой бюджет раздела (§4.4): **3 запроса в секунду**. Превышение сервер
/// возвращает до контроллера — ни данных, ни кэша, — поэтому дешевле не
/// превышать вовсе.
///
/// Минутный потолок (45 авторизованному, 15 гостю) этим не контролируется:
/// его держат debounce поиска, 30-секундный кэш табло и карточки и запрет
/// опрашивать подписанный рейс.
class FlightThrottle {
  FlightThrottle({this.perSecond = 3});

  final int perSecond;

  final _sent = <DateTime>[];
  Future<void> _tail = Future<void>.value();

  /// Пропускает вызов не чаще, чем [perSecond] раз в секунду. Очередь —
  /// честная: вызовы уходят в том порядке, в котором пришли.
  Future<T> run<T>(Future<T> Function() action) {
    final slot = _tail.then((_) => _waitForSlot());
    _tail = slot.catchError((_) {});
    return slot.then((_) => action());
  }

  Future<void> _waitForSlot() async {
    while (true) {
      final now = DateTime.now();
      _sent.removeWhere((t) => now.difference(t).inMilliseconds >= 1000);
      if (_sent.length < perSecond) {
        _sent.add(now);
        return;
      }
      final oldest = _sent.first;
      final wait = 1000 - now.difference(oldest).inMilliseconds;
      await Future<void>.delayed(Duration(milliseconds: wait < 1 ? 1 : wait));
    }
  }
}
