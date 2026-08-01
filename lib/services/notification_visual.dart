import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../presentation/resourses/wawat_dark.dart';

/// Icon + accent + background for a notification [type]. Shared by the in-app
/// notification list and the live banner so both stay in lock-step (add a new
/// type once, here).
class NotificationVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const NotificationVisual(this.icon, this.color, this.background);
}

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _emerald = Color(0xFF059669);
const _emerald50 = Color(0xFFECFDF5);
const _red = Color(0xFFEF4444);
const _red50 = Color(0xFFFEF2F2);
const _amber = Color(0xFFB67C00);
const _amber50 = Color(0xFFFEF6E7);
const _ink500 = Color(0xFF64748B);
const _accent50 = Color(0x4DF2FC2A);

NotificationVisual notificationVisual(String type, [bool isDark = false]) {
  final Color brandFg = isDark ? WawatDark.brandText : _brand;
  final Color brandBg = isDark ? WawatDark.brandChip : _brand50;
  final Color emeraldFg = isDark ? WawatDark.success : _emerald;
  final Color emeraldBg = isDark ? WawatDark.successBg : _emerald50;
  final Color redFg = isDark ? WawatDark.dangerText : _red;
  final Color redBg = isDark ? WawatDark.dangerSoftBg : _red50;
  final Color amberFg = isDark ? WawatDark.warning : _amber;
  final Color amberBg = isDark ? WawatDark.warningBg : _amber50;
  final Color neutralFg = isDark ? WawatDark.textSecondary : _ink500;
  final Color neutralBg =
      isDark ? WawatDark.surfaceAlt : const Color(0x0D0F172A);
  final Color accentBg = isDark ? WawatDark.goldSoftBg : _accent50;
  return switch (type) {
    'proposal_received' =>
      NotificationVisual(PhosphorIconsFill.handshake, brandFg, brandBg),
    'proposal_countered' =>
      NotificationVisual(PhosphorIconsFill.arrowsClockwise, brandFg, brandBg),
    'proposal_accepted' ||
    'shipment_auto_completed' ||
    'listing_approved' =>
      NotificationVisual(PhosphorIconsFill.checkCircle, emeraldFg, emeraldBg),
    'proposal_declined' ||
    'listing_rejected' ||
    'verification_rejected' =>
      NotificationVisual(PhosphorIconsFill.xCircle, redFg, redBg),
    'shipment_picked_up' =>
      NotificationVisual(PhosphorIconsFill.package, brandFg, brandBg),
    'shipment_delivered' =>
      NotificationVisual(PhosphorIconsFill.shoppingBag, brandFg, brandBg),
    'shipment_completed' ||
    'account_verified' =>
      NotificationVisual(PhosphorIconsFill.sealCheck, emeraldFg, emeraldBg),
    'shipment_disputed' =>
      NotificationVisual(PhosphorIconsFill.warningOctagon, redFg, redBg),
    'shipment_cancelled' ||
    'account_suspended' =>
      NotificationVisual(PhosphorIconsFill.prohibit, redFg, redBg),
    'shipment_expired' || 'listing_expired' => NotificationVisual(
        PhosphorIconsFill.clockCountdown, neutralFg, neutralBg),
    'dispute_resolved' =>
      NotificationVisual(PhosphorIconsFill.scales, emeraldFg, emeraldBg),
    'counterparty_account_issue' =>
      NotificationVisual(PhosphorIconsFill.warningCircle, amberFg, amberBg),
    'proposal_expiring' ||
    'verification_processing' =>
      NotificationVisual(PhosphorIconsFill.hourglass, amberFg, amberBg),
    'listing_expiring' =>
      NotificationVisual(PhosphorIconsFill.hourglassMedium, amberFg, amberBg),
    'promotion_expired' =>
      NotificationVisual(PhosphorIconsFill.crownSimple, amberFg, amberBg),
    'delivery_confirm_reminder' =>
      NotificationVisual(PhosphorIconsFill.bellRinging, amberFg, amberBg),
    'trip_reminder' =>
      NotificationVisual(PhosphorIconsFill.airplaneTakeoff, brandFg, brandBg),
    'matching_listing' =>
      NotificationVisual(PhosphorIconsFill.sparkle, brandFg, brandBg),
    'new_message' =>
      NotificationVisual(PhosphorIconsFill.chatCircle, brandFg, brandBg),
    'message_awaiting_reply' =>
      NotificationVisual(PhosphorIconsFill.chatsCircle, amberFg, amberBg),
    'review_received' ||
    'review_reminder' =>
      NotificationVisual(PhosphorIconsFill.star, amberFg, amberBg),
    'review_prompt' =>
      NotificationVisual(PhosphorIconsFill.star, brandFg, brandBg),
    'review_request' =>
      NotificationVisual(PhosphorIconsFill.starHalf, brandFg, brandBg),
    'new_follower' =>
      NotificationVisual(PhosphorIconsFill.userPlus, brandFg, brandBg),
    'followed_user_listing' =>
      NotificationVisual(PhosphorIconsFill.bell, brandFg, brandBg),
    'saved_search_match' =>
      NotificationVisual(PhosphorIconsFill.bookmarkSimple, brandFg, brandBg),
    'system_announcement' =>
      NotificationVisual(PhosphorIconsFill.megaphone, brandFg, brandBg),
    'milestone_reached' =>
      NotificationVisual(PhosphorIconsFill.trophy, amberFg, accentBg),
    'inactive_winback' ||
    'welcome' =>
      NotificationVisual(PhosphorIconsFill.handWaving, brandFg, brandBg),
    'account_warning' =>
      NotificationVisual(PhosphorIconsFill.warning, amberFg, amberBg),
    'content_removed' =>
      NotificationVisual(PhosphorIconsFill.trash, redFg, redBg),
    'report_received_ack' =>
      NotificationVisual(PhosphorIconsFill.shieldCheck, brandFg, brandBg),
    'new_device_login' =>
      NotificationVisual(PhosphorIconsFill.deviceMobile, amberFg, amberBg),
    'password_changed' =>
      NotificationVisual(PhosphorIconsFill.lockKey, brandFg, brandBg),
    'email_changed' =>
      NotificationVisual(PhosphorIconsFill.envelopeSimple, brandFg, brandBg),
    'app_update_required' =>
      NotificationVisual(PhosphorIconsFill.downloadSimple, brandFg, brandBg),
    _ => NotificationVisual(PhosphorIconsFill.bell, brandFg, brandBg),
  };
}
