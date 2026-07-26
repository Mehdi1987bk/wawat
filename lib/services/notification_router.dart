import 'package:flutter/material.dart';

import '../screens/home/tabs/home_tab/notification/notification_screen.dart';
import '../screens/home/tabs/listings/details/listing_details_screen.dart';
import '../screens/home/tabs/profile_tab/deals/deal_detail_screen.dart';
import '../screens/home/tabs/profile_tab/new_profile/new_profile_screen.dart';
import '../wawat_app.dart';

/// Навигация по нажатию на пуш (см. §4 спецификации). Маршрут выбирается по
/// data['type'] и присутствующим id. Открывает экран через глобальный
/// navigatorKey; для чата без сделки / аккаунт-системных / неизвестных типов —
/// лента уведомлений (GET /notifications).
void handleNotificationNavigation(Map<String, dynamic> data) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;

  String? val(String key) {
    final s = data[key]?.toString().trim() ?? '';
    return s.isEmpty ? null : s;
  }

  final type = val('type') ?? '';
  final shipmentId = val('shipment_id');
  final listingId = val('listing_id');
  final userId = val('user_id') ?? val('follower_id') ?? val('actor_id');

  Widget screen;
  if (shipmentId != null) {
    // Сделка/посылка/предложение/напоминания/отзыв/чат по сделке.
    screen = DealDetailScreen(shipmentId: shipmentId);
  } else if (listingId != null) {
    // Объявления: одобрено/отклонено/истекает/матч и т.п.
    screen = ListingDetailsScreen(listingId: listingId);
  } else if (type == 'new_follower' && userId != null) {
    screen = PublicProfileScreen(userId: userId);
  } else {
    // Чат без сделки, аккаунт/система, неизвестный тип → лента уведомлений.
    screen = NotificationScreen();
  }

  nav.push(MaterialPageRoute(builder: (_) => screen));
}
