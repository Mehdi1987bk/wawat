import 'dart:convert';

/// Единая таксономия событий приложения.
///
/// Одни и те же имена уходят в три места — Firebase Analytics, хлебные крошки
/// Crashlytics и панель бэкенда (`POST /telemetry/batch`), — поэтому таксономия
/// живёт в одном файле, а не растекается по вызовам.
///
/// Где возможно, взяты **рекомендованные GA4-имена** (`login`, `sign_up`,
/// `search`, `view_item`, `add_to_wishlist`, `begin_checkout`, `purchase`,
/// `share`): для них Firebase рисует готовые отчёты (воронки, LTV, retention)
/// без ручной настройки. Остальное — кастомные события.
///
/// Ограничения Firebase Analytics, которые соблюдает [TelemetrySchema]:
///  • имя события: ≤40 символов, `[A-Za-z0-9_]`, начинается с буквы;
///  • ≤25 параметров на событие, имя параметра ≤40 символов;
///  • строковое значение ≤100 символов;
///  • имя user property ≤24 символов, значение ≤36;
///  • зарезервированные имена (`app_open`, `session_start`, `first_open`,
///    `user_engagement`, `notification_*`, `ad_*`, префиксы `firebase_`,
///    `google_`, `ga_`) использовать нельзя — SDK собирает их сам.
class TelemetryEvents {
  TelemetryEvents._();

  // ── Жизненный цикл ──────────────────────────────────────────────────────
  // NB: `app_open` / `session_start` / `first_open` — зарезервированы Firebase,
  // поэтому свои события называются иначе.
  static const appStarted = 'app_started';
  static const appForeground = 'app_foreground';
  static const appBackground = 'app_background';
  static const offlineGateShown = 'offline_gate_shown';
  static const backOnline = 'back_online';

  // ── Онбординг ───────────────────────────────────────────────────────────
  static const introViewed = 'intro_viewed';
  static const introCompleted = 'intro_completed';
  static const introSkipped = 'intro_skipped';

  // ── Аутентификация (GA4: login / sign_up) ───────────────────────────────
  static const login = 'login';
  static const loginFailed = 'login_failed';
  static const signUp = 'sign_up';
  static const signUpFailed = 'sign_up_failed';
  static const otpRequested = 'otp_requested';
  static const otpVerified = 'otp_verified';
  static const otpFailed = 'otp_failed';
  static const logout = 'logout';
  static const passwordResetRequested = 'password_reset_requested';
  static const passwordResetCompleted = 'password_reset_completed';
  static const sessionExpired = 'session_expired';

  // ── Объявления ──────────────────────────────────────────────────────────
  static const viewItem = 'view_item'; // GA4: просмотр карточки объявления
  static const listingCreateStarted = 'listing_create_started';
  static const listingCreateSubmitted = 'listing_create_submitted';
  static const listingCreated = 'listing_created';
  static const listingCreateFailed = 'listing_create_failed';
  static const listingUpdated = 'listing_updated';
  static const listingPaused = 'listing_paused';
  static const listingResumed = 'listing_resumed';
  static const listingReposted = 'listing_reposted';
  static const listingDeleted = 'listing_deleted';
  static const addToWishlist = 'add_to_wishlist'; // GA4: в избранное
  static const removeFromWishlist = 'remove_from_wishlist'; // GA4: из избранного
  static const proposalSent = 'proposal_sent';
  static const listingReported = 'listing_reported';
  static const share = 'share'; // GA4

  // ── Поиск ───────────────────────────────────────────────────────────────
  static const search = 'search'; // GA4
  static const searchFiltersApplied = 'search_filters_applied';
  static const searchNoResults = 'search_no_results';
  static const savedSearchCreated = 'saved_search_created';
  static const savedSearchDeleted = 'saved_search_deleted';
  static const trendingRouteTapped = 'trending_route_tapped';

  // ── Чат ─────────────────────────────────────────────────────────────────
  static const chatOpened = 'chat_opened';
  static const chatMessageSent = 'chat_message_sent';
  static const chatMessageFailed = 'chat_message_failed';
  static const chatReplyUsed = 'chat_reply_used';
  static const chatMessageDeleted = 'chat_message_deleted';
  static const chatSocketDropped = 'chat_socket_dropped';

  // ── Сделки (Sövdələşmələrim) ────────────────────────────────────────────
  static const dealViewed = 'deal_viewed';
  static const dealAction = 'deal_action';
  static const dealActionFailed = 'deal_action_failed';

  // ── Монетизация (GA4: begin_checkout / purchase) ────────────────────────
  static const beginCheckout = 'begin_checkout';
  static const purchase = 'purchase';
  static const purchaseFailed = 'purchase_failed';
  static const promotionStarted = 'promotion_started';
  static const quotaLimitHit = 'quota_limit_hit';
  static const receiptOpened = 'receipt_opened';
  static const receiptDownloaded = 'receipt_downloaded';

  // ── Профиль и верификация ───────────────────────────────────────────────
  static const profileUpdated = 'profile_updated';
  static const avatarUploaded = 'avatar_uploaded';
  static const verificationStarted = 'verification_started';
  static const verificationSubmitted = 'verification_submitted';
  static const verificationResult = 'verification_result';
  static const referralCodeEntered = 'referral_code_entered';
  static const referralShared = 'referral_shared';
  static const rateAppPrompted = 'rate_app_prompted';
  static const rateAppSubmitted = 'rate_app_submitted';
  static const reviewSubmitted = 'review_submitted';
  static const supportRequestSent = 'support_request_sent';
  static const tierViewed = 'tier_viewed';
  static const languageChanged = 'language_changed';
  static const themeChanged = 'theme_changed';

  // ── Уведомления ─────────────────────────────────────────────────────────
  static const pushPermissionResult = 'push_permission_result';
  static const pushReceivedForeground = 'push_received_fg';
  static const pushOpened = 'push_opened';
  static const inAppBannerTapped = 'in_app_banner_tapped';

  // ── Техническое здоровье (питает панель «проблем») ──────────────────────
  static const apiFailure = 'api_failure';
  static const apiSlow = 'api_slow';
  static const appError = 'app_error'; // обработанное исключение (non-fatal)
  static const renderError = 'render_error'; // ошибка из FlutterError.onError
  static const featureUnavailable = 'feature_unavailable';
  static const screenView = 'screen_view'; // логируется через logScreenView
}

/// Имена параметров событий. Держим в одном месте, чтобы `listing_id` не стал
/// где-то `listingId` — в GA4 это были бы две несводимые колонки.
class TelemetryParams {
  TelemetryParams._();

  static const screen = 'screen';
  static const screenClass = 'screen_class';
  static const source = 'source';
  static const method = 'method';
  static const result = 'result';
  static const reason = 'reason';

  static const itemId = 'item_id'; // GA4
  static const itemCategory = 'item_category'; // GA4
  static const listingId = 'listing_id';
  static const listingType = 'listing_type';
  static const fromCity = 'from_city';
  static const toCity = 'to_city';

  static const searchTerm = 'search_term'; // GA4
  static const filterCount = 'filter_count';
  static const resultCount = 'result_count';

  static const conversationId = 'conversation_id';
  static const messageLength = 'message_length';

  static const value = 'value'; // GA4 (сумма)
  static const currency = 'currency'; // GA4 (ISO-4217, обязателен с value)
  static const transactionId = 'transaction_id'; // GA4
  static const packageId = 'package_id';
  static const durationDays = 'duration_days';

  static const endpoint = 'endpoint';
  static const httpMethod = 'http_method';
  static const statusCode = 'status_code';
  static const durationMs = 'duration_ms';
  static const errorType = 'error_type';
  static const errorMessage = 'error_message';
  static const isOffline = 'is_offline';
  static const attempt = 'attempt';
}

/// User properties. Имя ≤24 символов, значение ≤36 — Firebase режет молча.
class TelemetryUserProps {
  TelemetryUserProps._();

  static const userType = 'user_type'; // guest | user | courier | pro
  static const isVerified = 'is_verified';
  static const appLocale = 'app_locale';
  static const themeMode = 'theme_mode';
  static const tierLevel = 'tier_level';
  static const hasListings = 'has_listings';
  static const pushEnabled = 'push_enabled';
}

/// Приведение имён и значений к тому, что Firebase Analytics реально примет.
///
/// Вызывается один раз на входе в [Telemetry.event] — вызывающему коду не нужно
/// помнить лимиты. Всё, что не влезает, обрезается, а не роняет событие: тихо
/// отброшенное событие хуже, чем обрезанное.
class TelemetrySchema {
  TelemetrySchema._();

  static const int maxEventNameLength = 40;
  static const int maxParamNameLength = 40;
  static const int maxParamValueLength = 100;
  static const int maxParams = 25;
  static const int maxUserPropNameLength = 24;
  static const int maxUserPropValueLength = 36;

  /// Префиксы, зарезервированные Firebase: событие с таким именем SDK отбросит.
  static const _reservedPrefixes = ['firebase_', 'google_', 'ga_'];

  static final _illegal = RegExp(r'[^a-z0-9_]');
  static final _leadingNonLetter = RegExp(r'^[^a-z]+');
  static final _repeatedUnderscore = RegExp(r'_{2,}');

  /// `Listing Details/Screen` → `listing_details_screen`.
  static String name(String raw) {
    var s = raw.trim().toLowerCase().replaceAll(_illegal, '_');
    s = s.replaceAll(_repeatedUnderscore, '_').replaceAll(_leadingNonLetter, '');
    for (final p in _reservedPrefixes) {
      if (s.startsWith(p)) s = 'app_$s';
    }
    if (s.isEmpty) s = 'unknown';
    return s.length <= maxEventNameLength
        ? s
        : s.substring(0, maxEventNameLength);
  }

  /// Firebase принимает только `String` и `num`. `bool` → `'true'/'false'`
  /// (в консоли читается лучше, чем 1/0), коллекции → компактный JSON,
  /// `null` — выбрасываем, иначе SDK отбросит событие целиком.
  static Map<String, Object> params(Map<String, Object?>? raw) {
    final out = <String, Object>{};
    if (raw == null || raw.isEmpty) return out;
    for (final entry in raw.entries) {
      if (out.length >= maxParams) break;
      final v = entry.value;
      if (v == null) continue;
      final key = _clampName(entry.key, maxParamNameLength);
      if (key.isEmpty) continue;
      if (v is num) {
        out[key] = v;
      } else if (v is bool) {
        out[key] = v ? 'true' : 'false';
      } else if (v is String) {
        final s = v.trim();
        if (s.isEmpty) continue;
        out[key] = _clampValue(s, maxParamValueLength);
      } else if (v is Iterable || v is Map) {
        out[key] = _clampValue(_encode(v), maxParamValueLength);
      } else {
        out[key] = _clampValue(v.toString(), maxParamValueLength);
      }
    }
    return out;
  }

  static String userPropName(String raw) =>
      _clampName(raw, maxUserPropNameLength);

  static String userPropValue(String raw) =>
      _clampValue(raw.trim(), maxUserPropValueLength);

  static String _clampName(String raw, int max) {
    final n = name(raw);
    return n.length <= max ? n : n.substring(0, max);
  }

  static String _clampValue(String raw, int max) =>
      raw.length <= max ? raw : '${raw.substring(0, max - 1)}…';

  static String _encode(Object v) {
    try {
      return jsonEncode(v);
    } catch (_) {
      return v.toString();
    }
  }
}
