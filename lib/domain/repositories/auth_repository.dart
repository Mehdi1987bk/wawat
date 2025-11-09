import '../../data/network/request/forgot_password_request.dart';
import '../../data/network/request/login_request.dart';
import '../../data/network/request/otp_verify_request.dart';
import '../../data/network/request/registration_request.dart';
import '../../data/network/response/all_request_data.dart';
import '../../data/network/response/login_response.dart';
import '../../data/network/response/packages_response.dart';
import '../../data/network/response/registration_response.dart';
import '../../data/network/response/user.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);

  Future<bool> isLogged();

  Stream<User> get userDetails;

  Future<void> otpRegistration(int number);

  Future<void> sendRegistration(int number, int otpCode);

  Future<void> sendOtpLogin(int number, int otpCode);

  Future<void> customersMe();

  Future<RegistrationResponse> registration(RegistrationRequest request);

  Future<RegistrationResponse> otpVerify(OtpVerifyRequest request, String token);

  Future<RegistrationResponse> otpSend(String token);

  Future<void> forgotPassword(ForgotPasswordrRequest request);

  Stream<PackagesResponse> packages();

  Stream<AllrequestData> allRequest(String data);

  Future<bool> firstOpen();

  Future<void> setIsFirstOpen();
}
