/// Перечисления модуля (§8). Все наши значения — snake_case.
///
/// Подписи на экране **всегда** берутся из `status_label`: он уже переведён на
/// язык пользователя, и добавленный на сервере статус не оставит пустоту.
/// Значения ниже нужны только для логики — иконки, цвета, ветвления.
library;

enum FlightStatusGroup { beforeDeparture, inAir, special, finished }

/// 13 значений `status`.
class FlightStatus {
  FlightStatus._();

  static const unknown = 'unknown';
  static const expected = 'expected';
  static const checkIn = 'check_in';
  static const boarding = 'boarding';
  static const gateClosed = 'gate_closed';
  static const departed = 'departed';
  static const enRoute = 'en_route';
  static const approaching = 'approaching';
  static const diverted = 'diverted';
  static const delayed = 'delayed';
  static const arrived = 'arrived';
  static const canceled = 'canceled';
  static const canceledUncertain = 'canceled_uncertain';

  /// Порядок — как в §8, экран словаря статусов идёт по нему.
  static const all = <String>[
    unknown,
    expected,
    checkIn,
    boarding,
    gateClosed,
    departed,
    enRoute,
    approaching,
    diverted,
    delayed,
    arrived,
    canceled,
    canceledUncertain,
  ];

  static FlightStatusGroup groupOf(String? status) {
    switch (status) {
      case departed:
      case enRoute:
      case approaching:
      case diverted:
        return FlightStatusGroup.inAir;
      case delayed:
        return FlightStatusGroup.special;
      case arrived:
      case canceled:
      case canceledUncertain:
        return FlightStatusGroup.finished;
      default:
        return FlightStatusGroup.beforeDeparture;
    }
  }

  static bool isInAir(String? status) =>
      groupOf(status) == FlightStatusGroup.inAir;

  static bool isFinished(String? status) =>
      groupOf(status) == FlightStatusGroup.finished;

  static bool isCanceled(String? status) =>
      status == canceled || status == canceledUncertain;
}

/// `codeshare_status`.
class CodeshareStatus {
  CodeshareStatus._();

  static const unknown = 'unknown';
  static const operator = 'operator';
  static const codeshared = 'codeshared';
}

/// `quality` внутри `departure` и `arrival` — массив, свой для каждой стороны.
class FlightQuality {
  FlightQuality._();

  static const basic = 'basic';
  static const live = 'live';
  static const approximate = 'approximate';
}

/// `direction` табло.
class BoardDirection {
  BoardDirection._();

  static const departure = 'departure';
  static const arrival = 'arrival';
  static const both = 'both';
}

/// Девять событий подписки. `terminal_changed` и `baggage_belt` в набор по
/// умолчанию не входят — их нужно передавать явно.
class WatchEvent {
  WatchEvent._();

  static const statusChanged = 'status_changed';
  static const scheduleChanged = 'schedule_changed';
  static const gateChanged = 'gate_changed';
  static const terminalChanged = 'terminal_changed';
  static const baggageBelt = 'baggage_belt';
  static const departed = 'departed';
  static const arrived = 'arrived';
  static const canceled = 'canceled';
  static const diverted = 'diverted';

  /// Порядок тумблеров на экране подписки — как в §8.
  static const all = <String>[
    statusChanged,
    scheduleChanged,
    gateChanged,
    terminalChanged,
    baggageBelt,
    departed,
    arrived,
    canceled,
    diverted,
  ];

  /// Что сервер включит сам, если `events` не передать.
  static const defaults = <String>[
    statusChanged,
    scheduleChanged,
    gateChanged,
    departed,
    arrived,
    canceled,
    diverted,
  ];
}

/// Типы уведомлений модуля. Фильтр по типу на сервере не поддержан
/// (`/notifications` принимает только `?unread=` и `?per_page=`), поэтому
/// ленту рейсов приложение отбирает по этому списку само.
class FlightNotificationType {
  FlightNotificationType._();

  static const statusChanged = 'flight_status_changed';
  static const scheduleChanged = 'flight_schedule_changed';
  static const gateChanged = 'flight_gate_changed';
  static const terminalChanged = 'flight_terminal_changed';
  static const baggageBelt = 'flight_baggage_belt';
  static const departed = 'flight_departed';
  static const arrived = 'flight_arrived';
  static const canceled = 'flight_canceled';
  static const diverted = 'flight_diverted';

  static const all = <String>{
    statusChanged,
    scheduleChanged,
    gateChanged,
    terminalChanged,
    baggageBelt,
    departed,
    arrived,
    canceled,
    diverted,
  };

  static bool isFlight(String? type) => type != null && all.contains(type);
}

/// Статусы потоков провайдера (`/airports/{code}/feeds`, `/flight-data/health`)
/// — проходят как есть, своей трансформации нет.
class FeedStatus {
  FeedStatus._();

  static const ok = 'OK';
  static const okPartial = 'OKPartial';
  static const down = 'Down';
  static const degraded = 'Degraded';
  static const unavailable = 'Unavailable';
  static const unknown = 'Unknown';
}
