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
                // Push new-message payload carries the sender so the header
                // shows instantly (snake_case in FCM data).
                name: extra('actor_name'),
                avatarThumb: extra('actor_avatar_thumb_url'),
              ),
        identity: conversationId == null
            ? 'notifications'
            : 'conversation:$conversationId',
      );
      break;
    case 'listing':
      // saved_search_match also maps here; params.saved_search_id is optional.
      _push(
        nav,
        id == null ? NotificationScreen() : ListingDetailsScreen(listingId: id),
        identity: id == null ? 'notifications' : 'listing:$id',
      );
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
    // Push may fall back to the notification type when target_type is absent.
    case 'milestone_reached':
    case 'new_level':
    case 'tier_upgraded':
      _push(nav, const TierStatusScreen(), identity: 'tier');
      break;
    case 'security':
    case 'account':
      // No dedicated security/account screen yet → support is the closest hub.
      _push(nav, const SupportScreen(), identity: 'support');
      break;
    case 'announcement':
    case 'app_update':
      // Inbox / no in-app store screen yet → notifications feed.
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

/// Pushes [screen], tagging the route with [identity]. If the route already on
/// top carries the same identity (e.g. tapping a banner for the screen you are
/// already viewing, from an in-app banner or an FCM tap), the push is skipped so
/// an identical screen is never stacked twice.
void _push(NavigatorState nav, Widget screen, {String? identity}) {
  if (identity != null && _topRouteName(nav) == identity) return;
  nav.push(MaterialPageRoute(
    builder: (_) => screen,
    settings: RouteSettings(name: identity),
  ));
}

/// Reads the top route's name without popping (the `popUntil((_) => true)`
/// idiom visits only the topmost route and stops).
String? _topRouteName(NavigatorState nav) {
  String? name;
  nav.popUntil((route) {
    name = route.settings.name;
    return true;
  });
  return name;
}

/// Chat opened from a bare conversation id. The screen loads messages from the
/// id and the header upgrades to `meta.conversation` as they arrive; [name] and
/// [avatarThumb] (from the push's `actor_name` / `actor_avatar_thumb_url`) seed
/// the header so the sender shows INSTANTLY, before /messages returns.
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
