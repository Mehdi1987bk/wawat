import 'package:flutter/material.dart';

import '../../../data/cache/cache_manager.dart';
import '../../../main.dart';
import '../../home/tabs/home_tab/widget/auth_modal_utils.dart';

/// Вход для раздела рейсов.
///
/// Рейсы, аэропорты и карта открыты гостю (`optional.auth`) — у него просто
/// ниже лимит запросов. Вход нужен только слежению: подписки и лента
/// уведомлений ходят под `auth:sanctum`, и без токена отдают
/// `401 UNAUTHENTICATED`.
///
/// Своего входа модуль не делает — открывается обычный вход приложения.
abstract final class FlightAuth {
  static Future<bool> signedIn() async {
    final token = await sl.get<CacheManager>().getToken();
    return token != null && token.isNotEmpty;
  }

  /// Открыть вход приложения. [onDone] вызывается после успешного входа —
  /// экран слежения на этом месте перезагружает список.
  static void present(BuildContext context, {VoidCallback? onDone}) {
    AuthModalUtils.showAuthRequiredModal(
      context,
      onLoginSuccess: onDone,
      onRegisterSuccess: onDone,
    );
  }
}
