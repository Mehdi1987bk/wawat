import 'package:flutter/widgets.dart';

import 'telemetry.dart';

/// Навигационные хлебные крошки.
///
/// Точный `screen_view` логирует `BaseState.initState` — там известен реальный
/// тип экрана. Наблюдатель нужен для другого: он видит то, чего не видит
/// `BaseState`, — диалоги, боттом-шиты и `pushAndRemoveUntil`. Именно эта
/// последовательность («открыл шит → нажал → упало») отвечает на вопрос
/// «как воспроизвести» в отчёте Crashlytics.
///
/// Приложение почти не использует именованные маршруты, поэтому имя берём
/// best-effort: `settings.name`, иначе тип маршрута.
class TelemetryRouteObserver extends NavigatorObserver {
  int _depth = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _depth++;
    Telemetry.instance
        .breadcrumb('nav push ${_describe(route)} (depth $_depth)');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_depth > 0) _depth--;
    Telemetry.instance.breadcrumb('nav pop ${_describe(route)}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    Telemetry.instance.breadcrumb(
        'nav replace ${_describe(oldRoute)} → ${_describe(newRoute)}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_depth > 0) _depth--;
    Telemetry.instance.breadcrumb('nav remove ${_describe(route)}');
    super.didRemove(route, previousRoute);
  }

  String _describe(Route<dynamic>? route) {
    if (route == null) return 'none';
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    if (route is PopupRoute) return 'dialog/${route.runtimeType}';
    return route.runtimeType.toString();
  }
}
