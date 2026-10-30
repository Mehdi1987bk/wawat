import '../../../data/network/response/notification_response.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../main.dart';
import 'models/flight.dart';
import 'models/flight_enums.dart';

/// Уведомления раздела из общей ленты приложения.
///
/// Фильтра по типу у `/notifications` нет — он принимает только `unread` и
/// `per_page`, поэтому рейсовые отбираются здесь по списку типов (§11).
/// Лента не относится к бюджету `throttle:flightdata`, но и дёргать её на
/// каждом экране незачем: ответ держится минуту.
class FlightNotifications {
  FlightNotifications._();

  static const _ttl = Duration(minutes: 1);
  static const _perPage = 50;

  static List<NotificationItem>? _unread;
  static DateTime? _at;
  static List<NotificationItem>? _feed;
  static DateTime? _feedAt;

  /// Непрочитанные уведомления по рейсам. Пусто и без запроса, если входа нет.
  static Future<List<NotificationItem>> unread({bool force = false}) async {
    final cached = _unread;
    final at = _at;
    if (!force &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < _ttl) {
      return cached;
    }
    final response = await sl.get<AuthRepository>().notifications(
          unread: true,
          perPage: _perPage,
        );
    final items = response.data
        .where((item) => FlightNotificationType.isFlight(item.type))
        .where((item) => item.isUnread)
        .toList();
    _unread = items;
    _at = DateTime.now();
    return items;
  }

  /// История уведомлений по одному рейсу — для карточки привязанного
  /// объявления. Цель у всех девяти типов одинаковая (§11):
  /// `target.type == 'flight'`, `target.id` — номер, `target.params` — дата и
  /// код вылета. Фильтра по цели у `/notifications` нет, поэтому отбор здесь.
  static Future<List<NotificationItem>> forFlight(
    FlightKey key, {
    bool force = false,
  }) async {
    final cached = _feed;
    final at = _feedAt;
    final items = (!force &&
            cached != null &&
            at != null &&
            DateTime.now().difference(at) < _ttl)
        ? cached
        : await _loadFeed();
    final number = key.number.replaceAll(' ', '').toUpperCase();
    return items.where((item) {
      final target = item.target;
      if (target.type != 'flight') return false;
      final id = target.id?.replaceAll(' ', '').toUpperCase();
      if (id != number) return false;
      final date = target.params['flight_date']?.toString();
      if (date != null && date.isNotEmpty && date != key.flightDate) {
        return false;
      }
      final code = target.params['departure_code']?.toString();
      if (code != null &&
          code.isNotEmpty &&
          key.departureCode != null &&
          code.toUpperCase() != key.departureCode!.toUpperCase()) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  /// Лента уведомлений по рейсам целиком — прочитанные тоже. Это нижний
  /// список на экране слежения.
  static Future<List<NotificationItem>> feed({bool force = false}) async {
    final cached = _feed;
    final at = _feedAt;
    if (!force &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < _ttl) {
      return cached;
    }
    return _loadFeed();
  }

  /// «Hamısını oxu» — отмечает прочитанными все уведомления, не только
  /// рейсовые: другого эндпоинта у приложения нет.
  static Future<void> readAll() async {
    await sl.get<AuthRepository>().notificationsReadAll();
    forget();
  }

  static Future<List<NotificationItem>> _loadFeed() async {
    final response =
        await sl.get<AuthRepository>().notifications(perPage: _perPage);
    final items = response.data
        .where((item) => FlightNotificationType.isFlight(item.type))
        .toList(growable: false);
    _feed = items;
    _feedAt = DateTime.now();
    return items;
  }

  /// Последний известный счётчик без запроса — для значков на плитках.
  static int get cachedUnreadCount => _unread?.length ?? 0;

  /// После прочтения уведомления значок должен погаснуть сразу.
  static void forget() {
    _unread = null;
    _at = null;
    _feed = null;
    _feedAt = null;
  }
}
