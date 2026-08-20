import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/cache/cache_manager.dart';
import '../data/network/response/notification_response.dart';
import '../domain/repositories/auth_repository.dart';
import '../main.dart';
import '../screens/home/tabs/home_tab/notification/unread_notif_bloc.dart';
import '../screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'notification_banner.dart';
import 'notification_router.dart';
import 'pusher_service.dart';

/// Global, app-wide singleton for realtime in-app notifications.
///
/// Reuses the ONE shared Reverb socket ([PusherService]) — it only adds the
/// personal channel `private-notifications.{myPublicId}`, which carries two
/// events: `new_message_notification` (chat → chat badge + banner, suppressed
/// while inside that chat) and `new_notification` (all other types → the
/// notifications badge + a top banner, tap routed by `target`). On each event
/// it refreshes the relevant badge and shows the in-app banner. Lifecycle:
/// connects after login, re-checks on resume, re-subscribes on user switch,
/// tears down on logout.
class NotificationSocketService with WidgetsBindingObserver {
  NotificationSocketService._();

  static final NotificationSocketService instance =
      NotificationSocketService._();

  final PusherService _pusher = PusherService();

  /// Fires whenever a general notification arrives (`new_notification`) — an
  /// open notifications screen listens and refetches so live `is_interactive`
  /// (deal accepted/declined/confirmed elsewhere) updates immediately.
  final StreamController<void> _notificationsChanged =
      StreamController<void>.broadcast();
  Stream<void> get onNotificationsChanged => _notificationsChanged.stream;

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

  /// The chat currently open (or null). The FCM foreground path reads this to
  /// avoid a banner for the thread the user is already reading.
  String? get activeConversationId => _activeConversationId;

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
    // Clear the notifications badge immediately (logout / no token) so a guest
    // never sees the previous user's count.
    try {
      sl.get<UnreadNotificationBloc>().setUnreadCount(0);
    } catch (_) {}
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
    // Both events arrive on the same personal channel; the pusher layer tags
    // which one this is. Chat messages → new_message_notification; everything
    // else (proposals, deals, reviews, verification, system, …) →
    // new_notification. They intentionally never overlap.
    if (data['_event']?.toString() == 'new_notification') {
      _onNewNotification(data);
      return;
    }

    // ── new_message_notification (chat) ──
    // 1) Badge — ALWAYS, single source of truth, no extra API round-trip.
    final unread = _asInt(data['unreadCount']);
    if (unread != null) {
      try {
        sl.get<UnreadChatBloc>().setUnreadCount(unread);
      } catch (_) {}
    }

    final chatId = data['chatId']?.toString().trim() ?? '';
    if (chatId.isEmpty) return;

    // 2a) System cards (proposal/accepted/cancelled/delivered…) get their own
    // profile notification — never a duplicate "new message" banner. The badge
    // above still counts them (they're messages in the thread). The backend also
    // stopped emitting new_message_notification for cards; this is a safety net.
    final messageType = data['messageType']?.toString();
    if (messageType == 'system_card') return;

    // 2b) Already reading this thread → no banner (the chat updates live itself).
    if (_activeConversationId == chatId) return;

    // 3) Beautiful in-app banner; tap opens the chat. Pass the sender (WS uses
    // camelCase) as actor_* so the header shows instantly, like the FCM path.
    showNotificationBanner(
      NotificationBannerData.fromMap(data),
      onTap: () => openNotification(
        'conversation',
        chatId,
        {
          'conversation_id': chatId,
          'actor_name': data['senderName'],
          'actor_avatar_thumb_url': data['senderAvatar'],
        },
      ),
    );
  }

  /// `new_notification`: a general (non-chat) notification. Same element shape
  /// as GET /notifications + `unread_count`. Updates the notifications badge and
  /// shows the top banner; tap routes strictly by `target` (id may be null for
  /// address-less types → route by type only, handled by [openNotification]).
  void _onNewNotification(Map<String, dynamic> data) {
    final unread = _asInt(data['unread_count']);
    if (unread != null) {
      try {
        sl.get<UnreadNotificationBloc>().setUnreadCount(unread);
      } catch (_) {}
    }
    // Let an open notifications screen refetch so live is_interactive updates.
    if (!_notificationsChanged.isClosed) _notificationsChanged.add(null);

    final item = NotificationItem.fromJson(data);
    showNotificationBanner(
      NotificationBannerData.notification(
        title: item.title,
        body: item.body,
        type: item.type,
        // Human types (proposals, deals, reviews, follows…) carry an actor →
        // show avatar+name; system types have none → the type icon is used.
        actorName: item.actor?.name,
        actorAvatarUrl: item.actor?.avatarThumbUrl,
        // review_received extras → stars + comment.
        rating: item.reviewRating,
        comment: item.reviewComment,
      ),
      onTap: () => openNotification(
        item.target.type,
        item.target.id,
        item.target.params,
      ),
    );
  }

  int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }
}
