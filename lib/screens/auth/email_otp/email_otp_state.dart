import '../../../data/network/api/email_otp_api.dart';

/// In-memory state for the e-mail OTP gate. Deliberately NOT persisted:
/// `required` is a feature flag the backend toggles, so it is re-read from the
/// status endpoint on every cold start / login (spec: don't cache it long).
class EmailOtpState {
  EmailOtpState._();
  static final EmailOtpState instance = EmailOtpState._();

  bool required = false;
  bool verified = false;
  String email = '';
  int attemptsLeft = 0;

  /// A code has been sent during THIS app run (either the server auto-sent it on
  /// register, or a send succeeded). Stops the screen from re-sending on open
  /// when a fresh code already exists.
  bool codeSentThisSession = false;

  /// Guards against stacking the OTP screen when several triggers fire at once
  /// (cold-start + a 403, for example) and while it is already on screen.
  bool busy = false;

  final EmailOtpApi _api = EmailOtpApi();

  /// Re-read the status from the server. Throws on network/auth failure so the
  /// caller can silently skip presenting the screen.
  Future<void> refresh() async {
    final s = await _api.getStatus();
    required = s.required;
    verified = s.verified;
    email = s.email;
    attemptsLeft = s.attemptsLeft;
  }

  void markVerified() {
    verified = true;
  }

  /// Clear per-account flags on sign-out so the next account starts clean.
  void reset() {
    required = false;
    verified = false;
    email = '';
    attemptsLeft = 0;
    codeSentThisSession = false;
    busy = false;
  }
}
