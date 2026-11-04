import '../../../data/network/api/email_otp_api.dart';

class EmailOtpState {
  EmailOtpState._();
  static final EmailOtpState instance = EmailOtpState._();

  bool required = false;
  bool verified = false;
  String email = '';
  int attemptsLeft = 0;

  bool codeSentThisSession = false;

  bool busy = false;

  final EmailOtpApi _api = EmailOtpApi();

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

  void reset() {
    required = false;
    verified = false;
    email = '';
    attemptsLeft = 0;
    codeSentThisSession = false;
    busy = false;
  }
}
