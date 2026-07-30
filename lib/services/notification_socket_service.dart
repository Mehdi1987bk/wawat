import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/cache/cache_manager.dart';
import '../domain/repositories/auth_repository.dart';
import '../main.dart';
import '../screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'notification_banner.dart';
import 'notification_router.dart';
import 'pusher_service.dart';

/// Global, app-wide singleton for new-message notifications.
///
/// Reuses the ONE shared Reverb socket ([PusherService]) — it only adds the
/// personal channel `private-notifications.{myPublicId}` (event
/// `new_message_notification`). On each event it always refreshes the global
/// unread badge, and shows a beautiful in-app banner unless the user is already
/// inside that chat. Lifecycle: connects after login, re-checks on resume,
/// re-subscribes on user switch, tears down on logout.
class NotificationSocketService with WidgetsBindingObserver {
  NotificationSocketService._();

  static final NotificationSocketService instance =
      NotificationSocketService._();

  final PusherService _pusher = PusherService();

  String? _subscribedPublicId;
  String? _activeConversationId;
  bool _observerAdded = false;

  /// Register the lifecycle observer once and make the first connection attempt.
  void init() {
    if (!_observerAdded) {
      _observerAdded = true;
      WidgetsBinding.instance.addObserver(this);
    }
    unawaited(ensureConnected());
  }

  /// The chat the user is currently viewing — its banner is suppressed. Set from
  /// [ChatConversationScreen] on open, cleared on close.
  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ensureConnected());
    }
  }

  /// Idempotent connect + subscribe. Safe to call repeatedly (the 20s realtime
  /// loop and app-resume both call it); a no-op once already subscribed.
  Future<void> ensureConnected() async {
    try {
      final token = await sl.get<CacheManager>().getToken();
      if (token == null || token.isEmpty) {
        await _reset();
        return;
      }

      final publicId = await _myPublicId();
      if (publicId == null || publicId.isEmpty) return;
      if (_subscribedPublicId == publicId) return;

      // User switched accounts → leave the previous personal channel first.
      final previous = _subscribedPublicId;
      if (previous != null && previous != publicId) {
        await _pusher.unsubscribeFromNotifications(previous, _onEvent);
      }

      await _pusher.initialize(token);
      await _pusher.subscribeToNotifications(publicId, _onEvent);
      _subscribedPublicId = publicId;
    } catch (_) {
      // Best-effort — the realtime loop retries on the next tick.
    }
  }

  /// Call on logout: leave the channel and clear all state.
  Future<void> onLogout() => _reset();

  Future<void> _reset() async {
    final id = _subscribedPublicId;
    _subscribedPublicId = null;
    _activeConversationId = null;
    if (id != null) {
      await _pusher.unsubscribeFromNotifications(id, _onEvent);
    }
  }

  Future<String?> _myPublicId() async {
    try {
      final me = await sl
          .get<AuthRepository>()
          .userDetails
          .first
          .timeout(const Duration(seconds: 4));
      return me.id?.toString();
    } catch (_) {
      return null;
    }
  }

  void _onEvent(Map<String, dynamic> data) {
    // 1) Badge — ALWAYS, single source of truth, no extra API round-trip.
    final unread = _asInt(data['unreadCount']);
    if (unread != null) {
      try {
        sl.get<UnreadChatBloc>().setUnreadCount(unread);
      } catch (_) {}
    }

    final chatId = data['chatId']?.toString().trim() ?? '';
    if (chatId.isEmpty) return;

    // 2) Already reading this thread → no banner (the chat updates live itself).
    if (_activeConversationId == chatId) return;

    // 3) Beautiful in-app banner; tap opens the chat.
    showNotificationBanner(
      NotificationBannerData.fromMap(data),
      onTap: () => openNotification(
        'conversation',
        chatId,
        {'conversation_id': chatId},
      ),
    );
  }

  int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }
}
