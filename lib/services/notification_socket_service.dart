import 'dart:async';

import 'package:flutter/foundation.dart';
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

class NotificationSocketService with WidgetsBindingObserver {
  NotificationSocketService._();

  static final NotificationSocketService instance =
      NotificationSocketService._();

  final PusherService _pusher = PusherService();

  final StreamController<void> _notificationsChanged =
      StreamController<void>.broadcast();
  Stream<void> get onNotificationsChanged => _notificationsChanged.stream;

  final StreamController<void> _chatActivity =
      StreamController<void>.broadcast();
  Stream<void> get onChatActivity => _chatActivity.stream;

  String? _subscribedPublicId;
  bool _observerAdded = false;

  final List<String> _openConversations = [];
  final ValueNotifier<String?> _activeConversation = ValueNotifier(null);

  void init() {
    if (!_observerAdded) {
      _observerAdded = true;
      WidgetsBinding.instance.addObserver(this);
    }
    unawaited(ensureConnected());
  }

  void enterConversation(String conversationId) {
    _openConversations.add(conversationId);
    _activeConversation.value = conversationId;
  }

  void leaveConversation(String conversationId) {
    final index = _openConversations.lastIndexOf(conversationId);
    if (index >= 0) _openConversations.removeAt(index);
    _activeConversation.value =
        _openConversations.isEmpty ? null : _openConversations.last;
  }

  String? get activeConversationId => _activeConversation.value;

  ValueListenable<String?> get activeConversation => _activeConversation;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ensureConnected());
    }
  }

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

      final previous = _subscribedPublicId;
      if (previous != null && previous != publicId) {
        await _pusher.unsubscribeFromNotifications(previous, _onEvent);
      }

      await _pusher.initialize(token);
      await _pusher.subscribeToNotifications(publicId, _onEvent);
      _subscribedPublicId = publicId;
    } catch (_) {
    }
  }

  Future<void> onLogout() async {
    try {
      await _reset();
    } catch (_) {
    }
    try {
      sl.get<UnreadChatBloc>().onLogout();
    } catch (_) {}
    await _pusher.disconnect();
  }

  Future<void> _reset() async {
    final id = _subscribedPublicId;
    _subscribedPublicId = null;
    _openConversations.clear();
    _activeConversation.value = null;
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

  @visibleForTesting
  void handleEventForTest(Map<String, dynamic> data) => _onEvent(data);

  void _onEvent(Map<String, dynamic> data) {
    if (data['_event']?.toString() == 'new_notification') {
      _onNewNotification(data);
      return;
    }

    final unread = _asInt(data['unreadCount']);
    if (unread != null) {
      try {
        sl.get<UnreadChatBloc>().setUnreadCount(unread);
      } catch (_) {}
    }

    if (!_chatActivity.isClosed) _chatActivity.add(null);

    final chatId = data['chatId']?.toString().trim() ?? '';
    if (chatId.isEmpty) return;

    final messageType = data['messageType']?.toString();
    if (messageType == 'system_card') return;

    if (activeConversationId == chatId) return;

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

  void _onNewNotification(Map<String, dynamic> data) {
    final unread = _asInt(data['unread_count']);
    if (unread != null) {
      try {
        sl.get<UnreadNotificationBloc>().setUnreadCount(unread);
      } catch (_) {}
    }
    if (!_notificationsChanged.isClosed) _notificationsChanged.add(null);

    final item = NotificationItem.fromJson(data);
    showNotificationBanner(
      NotificationBannerData.notification(
        title: item.title,
        body: item.body,
        type: item.type,
        actorName: item.actor?.name,
        actorAvatarUrl: item.actor?.avatarThumbUrl,
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
