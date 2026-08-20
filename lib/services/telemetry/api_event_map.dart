import 'telemetry_events.dart';

/// Соответствие «эндпоинт → бизнес-событие».
///
/// Весь трафик приложения идёт через один [Dio], поэтому воронку выгоднее
/// строить здесь, а не расставлять `logEvent` по тридцати экранам: событие
/// «объявление создано» физически не может разойтись с фактом успешного
/// `POST /listings`, а новый экран получает аналитику бесплатно.
///
/// Ручные вызовы остаются только там, где события нет в сети: просмотры экранов,
/// применение фильтров, шаринг, тапы по баннерам.
class ApiEventMapping {
  const ApiEventMapping({
    this.onSuccess,
    this.onFailure,
    this.extraParams = const {},
  });

  /// Событие при 2xx. `null` — успех не логируем (GET-ы, поллинг).
  final String? onSuccess;

  /// Событие при ошибке. `null` — хватит общего `api_failure`.
  final String? onFailure;

  final Map<String, Object?> extraParams;
}

class _Rule {
  const _Rule(this.method, this.pattern, this.mapping);

  final String method;

  /// Матчится по **нормализованному** пути, где id уже схлопнуты в `{id}`
  /// (см. `TelemetryRedactor.endpoint`).
  final String pattern;
  final ApiEventMapping mapping;
}

/// Таблица правил. Порядок значения не имеет — совпадение точное.
const List<_Rule> _rules = [
  // ── Аутентификация ──────────────────────────────────────────────────────
  _Rule('POST', '/auth/login',
      ApiEventMapping(
          onSuccess: TelemetryEvents.login,
          onFailure: TelemetryEvents.loginFailed,
          extraParams: {TelemetryParams.method: 'password'})),
  _Rule('POST', '/api/checkOtpLogin',
      ApiEventMapping(
          onSuccess: TelemetryEvents.login,
          onFailure: TelemetryEvents.loginFailed,
          extraParams: {TelemetryParams.method: 'otp'})),
  _Rule('POST', '/auth/register',
      ApiEventMapping(
          onSuccess: TelemetryEvents.signUp,
          onFailure: TelemetryEvents.signUpFailed,
          extraParams: {TelemetryParams.method: 'form'})),
  _Rule('POST', '/api/checkOtpRegister',
      ApiEventMapping(
          onSuccess: TelemetryEvents.signUp,
          onFailure: TelemetryEvents.signUpFailed,
          extraParams: {TelemetryParams.method: 'otp'})),
  _Rule('PUT', '/api/sendOtp',
      ApiEventMapping(onSuccess: TelemetryEvents.otpRequested)),
  _Rule('POST', '/otp/send',
      ApiEventMapping(onSuccess: TelemetryEvents.otpRequested)),
  _Rule('POST', '/otp/verify',
      ApiEventMapping(
          onSuccess: TelemetryEvents.otpVerified,
          onFailure: TelemetryEvents.otpFailed)),
  _Rule('POST', '/auth/forgot-password/request',
      ApiEventMapping(onSuccess: TelemetryEvents.passwordResetRequested)),
  _Rule('POST', '/auth/forgot-password/reset',
      ApiEventMapping(onSuccess: TelemetryEvents.passwordResetCompleted)),
  _Rule('POST', '/auth/email/resend',
      ApiEventMapping(onSuccess: 'email_verification_resent')),

  // ── Профиль ─────────────────────────────────────────────────────────────
  _Rule('PUT', '/profile/personal',
      ApiEventMapping(
          onSuccess: TelemetryEvents.profileUpdated,
          extraParams: {TelemetryParams.source: 'personal'})),
  _Rule('PUT', '/profile/privacy',
      ApiEventMapping(
          onSuccess: TelemetryEvents.profileUpdated,
          extraParams: {TelemetryParams.source: 'privacy'})),
  _Rule('PUT', '/profile/notifications',
      ApiEventMapping(
          onSuccess: TelemetryEvents.profileUpdated,
          extraParams: {TelemetryParams.source: 'notifications'})),
  _Rule('PUT', '/profile/professional',
      ApiEventMapping(
          onSuccess: TelemetryEvents.profileUpdated,
          extraParams: {TelemetryParams.source: 'professional'})),
  _Rule('POST', '/profile/avatar',
      ApiEventMapping(onSuccess: TelemetryEvents.avatarUploaded)),
  _Rule('POST', '/auth/change-password',
      ApiEventMapping(
          onSuccess: TelemetryEvents.profileUpdated,
          extraParams: {TelemetryParams.source: 'password'})),
  _Rule('POST', '/verification/submit',
      ApiEventMapping(onSuccess: TelemetryEvents.verificationSubmitted)),

  // ── Объявления ──────────────────────────────────────────────────────────
  _Rule('POST', '/listings',
      ApiEventMapping(
          onSuccess: TelemetryEvents.listingCreated,
          onFailure: TelemetryEvents.listingCreateFailed)),
  _Rule('PATCH', '/listings/{id}',
      ApiEventMapping(onSuccess: TelemetryEvents.listingUpdated)),
  _Rule('DELETE', '/listings/{id}',
      ApiEventMapping(onSuccess: TelemetryEvents.listingDeleted)),
  _Rule('POST', '/listings/{id}/pause',
      ApiEventMapping(onSuccess: TelemetryEvents.listingPaused)),
  _Rule('POST', '/listings/{id}/resume',
      ApiEventMapping(onSuccess: TelemetryEvents.listingResumed)),
  _Rule('POST', '/listings/{id}/repost',
      ApiEventMapping(onSuccess: TelemetryEvents.listingReposted)),
  _Rule('POST', '/listings/{id}/favorite',
      ApiEventMapping(onSuccess: TelemetryEvents.addToWishlist)),
  _Rule('DELETE', '/listings/{id}/favorite',
      ApiEventMapping(onSuccess: TelemetryEvents.removeFromWishlist)),
  _Rule('POST', '/listings/{id}/proposals',
      ApiEventMapping(onSuccess: TelemetryEvents.proposalSent)),
  _Rule('POST', '/favorites/toggle',
      ApiEventMapping(onSuccess: TelemetryEvents.addToWishlist)),
  _Rule('POST', '/offers',
      ApiEventMapping(onSuccess: 'offer_created')),
  _Rule('PATCH', '/offers/{id}/status',
      ApiEventMapping(
          onSuccess: TelemetryEvents.dealAction,
          onFailure: TelemetryEvents.dealActionFailed)),
  _Rule('POST', '/reports',
      ApiEventMapping(onSuccess: TelemetryEvents.listingReported)),
  _Rule('POST', '/reviews',
      ApiEventMapping(onSuccess: TelemetryEvents.reviewSubmitted)),
  _Rule('POST', '/support',
      ApiEventMapping(onSuccess: TelemetryEvents.supportRequestSent)),

  // ── Поиск ───────────────────────────────────────────────────────────────
  _Rule('POST', '/saved-searches',
      ApiEventMapping(onSuccess: TelemetryEvents.savedSearchCreated)),
  _Rule('DELETE', '/saved-searches/{id}',
      ApiEventMapping(onSuccess: TelemetryEvents.savedSearchDeleted)),

  // ── Чат ─────────────────────────────────────────────────────────────────
  _Rule('POST', '/users/{id}/conversation',
      ApiEventMapping(onSuccess: TelemetryEvents.chatOpened)),
  _Rule('POST', '/conversations/{id}/messages',
      ApiEventMapping(
          onSuccess: TelemetryEvents.chatMessageSent,
          onFailure: TelemetryEvents.chatMessageFailed)),

  // ── Монетизация ─────────────────────────────────────────────────────────
  // Сам факт покупки (`purchase` c value/currency) логирует экран оплаты —
  // здесь только «платёж ушёл на сервер», чтобы видеть обрыв между попыткой
  // и подтверждением.
  _Rule('POST', '/listings/{id}/promotions',
      ApiEventMapping(
          onSuccess: TelemetryEvents.promotionStarted,
          onFailure: TelemetryEvents.purchaseFailed)),
  // Заказ создан на сервере. Не `begin_checkout` и не `purchase`: у GA4-событий
  // покупки обязательны value+currency, а интерцептор суммы не знает — их
  // логирует экран оплаты. Здесь фиксируем только серверный шаг, чтобы видеть
  // обрыв между «заказ создан» и «оплачен».
  _Rule('POST', '/listing-quota/orders',
      ApiEventMapping(
          onSuccess: 'quota_order_created',
          onFailure: 'quota_order_failed')),
  _Rule('POST', '/listing-quota/orders/{id}/pay',
      ApiEventMapping(onSuccess: 'quota_order_paid')),
];

/// Ищет правило для запроса. [method] — HTTP-метод, [normalizedPath] — путь,
/// уже прошедший через `TelemetryRedactor.endpoint`.
ApiEventMapping? mappingFor(String method, String normalizedPath) {
  final m = method.toUpperCase();
  for (final rule in _rules) {
    if (rule.method == m && rule.pattern == normalizedPath) {
      return rule.mapping;
    }
  }
  return null;
}
