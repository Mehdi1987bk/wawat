import 'package:flutter/material.dart';

import '../data/network/response/chat_response.dart';
import '../data/network/response/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../main.dart';
import '../screens/chat/chat/chat_conversation_screen.dart';
import '../screens/home/tabs/home_tab/notification/notification_screen.dart';
import '../screens/home/tabs/listings/details/listing_details_screen.dart';
import '../screens/home/tabs/profile_tab/deals/deal_detail_screen.dart';
import '../screens/home/tabs/profile_tab/new_profile/new_profile_screen.dart';
import '../screens/home/tabs/profile_tab/reports/reports_screen.dart';
import '../screens/home/tabs/profile_tab/support/support_screen.dart';
import '../screens/home/tabs/profile_tab/tier/tier_status_screen.dart';
import '../screens/home/tabs/profile_tab/verification/verification_screen.dart';
import '../wawat_app.dart';

Map<String, dynamic>? _pendingNotificationData;

void handleNotificationNavigation(Map<String, dynamic> data) {
  if (navigatorKey.currentState == null) {
    _pendingNotificationData = Map<String, dynamic>.from(data);
    return;
  }
  _routeFromPush(data);
}

void flushPendingNotificationNavigation() {
  final data = _pendingNotificationData;
  if (data == null || navigatorKey.currentState == null) return;
  _pendingNotificationData = null;
  _routeFromPush(data);
}

void _routeFromPush(Map<String, dynamic> data) {
  String? s(String key) {
    final value = data[key]?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  final targetType = s('target_type') ?? s('type') ?? 'none';
  final targetId = s('target_id');
  openNotification(targetType, targetId, data);
}

void openNotification(
  String targetType,
  String? id,
  Map<String, dynamic> extras,
) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;

  String? extra(String key) {
    final value = extras[key]?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  switch (targetType) {
    case 'shipment':
    case 'review_compose':
      _push(
        nav,
        id == null ? NotificationScreen() : DealDetailScreen(shipmentId: id),
        identity: id == null ? 'notifications' : 'shipment:$id',
      );
      break;
    case 'conversation':
      final conversationId = id ?? extra('conversation_id');
      _push(
        nav,
        conversationId == null
            ? NotificationScreen()
            : _chatScreen(
                conversationId,
                name: extra('actor_name'),
                avatarThumb: extra('actor_avatar_thumb_url'),
              ),
        identity: conversationId == null
            ? 'notifications'
            : 'conversation:$conversationId',
      );
      break;
    case 'listing':
      _push(
        nav,
        id == null ? NotificationScreen() : ListingDetailsScreen(listingId: id),
        identity: id == null ? 'notifications' : 'listing:$id',
      );
      break;
    case 'review':
      _openMyProfile(nav, initialTab: 1);
      break;
    case 'profile':
      if (id == null) {
        _openMyProfile(nav);
      } else {
        _push(nav, PublicProfileScreen(userId: id), identity: 'profile:$id');
      }
      break;
    case 'report':
      _push(nav, const ReportsScreen(), identity: 'reports');
      break;
    case 'verification':
      _openVerification(nav);
      break;
    case 'tier':
    case 'status':
    case 'level':
    case 'milestone_reached':
    case 'new_level':
    case 'tier_upgraded':
      _push(nav, const TierStatusScreen(), identity: 'tier');
      break;
    case 'security':
    case 'account':
      _push(nav, const SupportScreen(), identity: 'support');
      break;
    case 'announcement':
    case 'app_update':
      _push(nav, NotificationScreen(), identity: 'notifications');
      break;
    case 'home':
      nav.popUntil((route) => route.isFirst);
      break;
    case 'none':
    default:
      _push(nav, NotificationScreen(), identity: 'notifications');
      break;
  }
}

void _push(NavigatorState nav, Widget screen, {String? identity}) {
  if (identity != null && _topRouteName(nav) == identity) return;
  nav.push(MaterialPageRoute(
    builder: (_) => screen,
    settings: RouteSettings(name: identity),
  ));
}

String? _topRouteName(NavigatorState nav) {
  String? name;
  nav.popUntil((route) {
    name = route.settings.name;
    return true;
  });
  return name;
}

Widget _chatScreen(String conversationId, {String? name, String? avatarThumb}) {
  return ChatConversationScreen(
    conversation: Conversation(
      id: conversationId,
      user: ChatUser(
        id: 0,
        fullname: name?.trim() ?? '',
        avatarThumb: avatarThumb?.trim(),
      ),
      unreadCount: 0,
      isPinned: false,
      isArchived: false,
    ),
  );
}

Future<void> _openMyProfile(NavigatorState nav, {int initialTab = 0}) async {
  final me = await _currentUser();
  final userId = me?.username ?? me?.id?.toString();
  if (userId == null || userId.isEmpty) {
    _push(nav, NotificationScreen());
    return;
  }
  _push(nav, PublicProfileScreen(userId: userId, initialTab: initialTab));
}

Future<void> _openVerification(NavigatorState nav) async {
  final me = await _currentUser();
  _push(nav, me == null ? NotificationScreen() : VerificationScreen(user: me));
}

Future<User?> _currentUser() async {
  try {
    return await sl.get<AuthRepository>().userDetails.first;
  } catch (_) {
    return null;
  }
}
