import 'telemetry_events.dart';

class ApiEventMapping {
  const ApiEventMapping({
    this.onSuccess,
    this.onFailure,
    this.extraParams = const {},
  });

  final String? onSuccess;

  final String? onFailure;

  final Map<String, Object?> extraParams;
}

class _Rule {
  const _Rule(this.method, this.pattern, this.mapping);

  final String method;

  final String pattern;
  final ApiEventMapping mapping;
}

const List<_Rule> _rules = [
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

  _Rule('POST', '/saved-searches',
      ApiEventMapping(onSuccess: TelemetryEvents.savedSearchCreated)),
  _Rule('DELETE', '/saved-searches/{id}',
      ApiEventMapping(onSuccess: TelemetryEvents.savedSearchDeleted)),

  _Rule('POST', '/users/{id}/conversation',
      ApiEventMapping(onSuccess: TelemetryEvents.chatOpened)),
  _Rule('POST', '/conversations/{id}/messages',
      ApiEventMapping(
          onSuccess: TelemetryEvents.chatMessageSent,
          onFailure: TelemetryEvents.chatMessageFailed)),

  _Rule('POST', '/listings/{id}/promotions',
      ApiEventMapping(
          onSuccess: TelemetryEvents.promotionStarted,
          onFailure: TelemetryEvents.purchaseFailed)),
  _Rule('POST', '/listing-quota/orders',
      ApiEventMapping(
          onSuccess: 'quota_order_created',
          onFailure: 'quota_order_failed')),
  _Rule('POST', '/listing-quota/orders/{id}/pay',
      ApiEventMapping(onSuccess: 'quota_order_paid')),
];

ApiEventMapping? mappingFor(String method, String normalizedPath) {
  final m = method.toUpperCase();
  for (final rule in _rules) {
    if (rule.method == m && rule.pattern == normalizedPath) {
      return rule.mapping;
    }
  }
  return null;
}
