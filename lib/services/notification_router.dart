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
import '../screens/home/tabs/profile_tab/verification/verification_screen.dart';
import '../wawat_app.dart';

Map<String, dynamic>? _pendingNotificationData;

/// PUSH entry point (FCM onMessageOpenedApp / getInitialMessage / local-notif
/// tap). Reads the unified `target_type` / `target_id` from the FCM data map
/// and routes exactly like an in-app tap. Secondary ids (conversation_id,
/// saved_search_id, …) live flat in `data`.
void handleNotificationNavigation(Map<String, dynamic> data) {
  if (navigatorKey.currentState == null) {
    _pendingNotificationData = Map<String, dynamic>.from(data);
    return;
  }
  _routeFromPush(data);
}

/// Cold-start push taps can arrive before MaterialApp creates its Navigator.
/// Call this after the first frame so the tap is not silently lost.
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

  // `target_type` is always present; keep `type` as a fallback for any older
  // queued payloads. `target_id` is absent for address-less types.
  final targetType = s('target_type') ?? s('type') ?? 'none';
  final targetId = s('target_id');
  openNotification(targetType, targetId, data);
}

/// The single navigation router used for BOTH the in-app list tap and push.
/// Route STRICTLY by [targetType] (never by notification type or raw data).
/// [id] is a public_id/username, or null → open a SCREEN, not an entity.
/// [extras] carries secondary navigation ids (conversation_id, saved_search_id…).
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
      // Deal details / order — the review-compose flow lives on the deal too.
      _push(nav,
          id == null ? NotificationScreen() : DealDetailScreen(shipmentId: id));
      break;
    case 'conversation':
      final conversationId = id ?? extra('conversation_id');
      _push(
        nav,
        conversationId == null
            ? NotificationScreen()
            : _chatScreen(conversationId),
      );
      break;
    case 'listing':
      // saved_search_match also maps here; params.saved_search_id is optional.
      _push(
          nav,
          id == null
              ? NotificationScreen()
              : ListingDetailsScreen(listingId: id));
      break;
    case 'review':
      // My profile → reviews tab.
      _openMyProfile(nav, initialTab: 1);
      break;
    case 'profile':
      // new_follower carries a USERNAME here; null → my own profile.
      if (id == null) {
        _openMyProfile(nav);
      } else {
        _push(nav, PublicProfileScreen(userId: id));
      }
      break;
    case 'report':
      _push(nav, const ReportsScreen());
      break;
    case 'verification':
      _openVerification(nav);
      break;
    case 'security':
    case 'account':
      // No dedicated security/account screen yet → support is the closest hub.
      _push(nav, const SupportScreen());
      break;
    case 'announcement':
    case 'app_update':
      // Inbox / no in-app store screen yet → notifications feed.
      _push(nav, NotificationScreen());
      break;
    case 'home':
      nav.popUntil((route) => route.isFirst);
      break;
    case 'none':
    default:
      _push(nav, NotificationScreen());
      break;
  }
}

void _push(NavigatorState nav, Widget screen) {
  nav.push(MaterialPageRoute(builder: (_) => screen));
}

/// Chat opened from a bare conversation id — a minimal [Conversation] is enough:
/// the screen loads messages from the id and the header fills in as they arrive.
Widget _chatScreen(String conversationId) {
  return ChatConversationScreen(
    conversation: Conversation(
      id: conversationId,
      user: const ChatUser(id: 0, fullname: ''),
      unreadCount: 0,
      isPinned: false,
      isArchived: false,
    ),
  );
}

Future<void> _openMyProfile(NavigatorState nav, {int initialTab = 0}) async {
  final me = await _currentUser();
  // Open our own profile through the public route so it keeps a back button;
  // WawatProfileScreen already recognises it as our own (edit, no follow).
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
