import 'package:rxdart/rxdart.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../cache/cache_manager.dart';
import '../network/api/auth_api.dart';
import '../network/request/forgot_password_request.dart';
import '../network/request/login_request.dart';
import '../network/request/otp_verify_request.dart';
import '../network/request/registration_request.dart';
import '../network/response/all_request_data.dart';
import '../network/response/login_response.dart';
import '../network/response/packages_response.dart';
import '../network/response/registration_response.dart';
import '../network/response/user.dart';

const tokenRefreshTimeOut = 60 * 60 * 1000;

class DataAuthRepository implements AuthRepository {
  final AuthApi _authApi = sl.get<AuthApi>();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  @override
  Future<void> login(LoginRequest request) async {
    final response = await _authApi.login(request);
    if (response != null) {
      await _cacheManager.saveUser(response.user);
    }
    return _cacheManager.saveAccessToken(response.token);
  }

  @override
  Stream<User> get userDetails => _cacheManager.userDetails.whereNotNull().asBroadcastStream();

  @override
  Future<bool> isLogged() async {
    var token = await _cacheManager.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> otpRegistration(int number) {
    return _authApi.getRegistration(number);
  }

  @override
  Future<void> sendRegistration(int number, int otpCode) async {
    final response = await _authApi.sendRegistration(number, otpCode);
    // if (response != null) {
    //   await _cacheManager.saveUser(response.user);
    // }
    return _cacheManager.saveAccessToken(response.token);
  }

  @override
  Future<void> sendOtpLogin(int number, int otpCode) async {
    final response = await _authApi.sendOtpLogin(number, otpCode);
    // if (response != null) {
    //   await _cacheManager.saveUser(response.user);
    // }
    return _cacheManager.saveAccessToken(response.token);
  }

  @override
  Future<void> customersMe() async {
    final response = await _authApi.customersMe();
    if (response != null) {
      await _cacheManager.saveUser(response);
    }
   }

  @override
  Future<void> registration(RegistrationRequest request)  async {
  final response = await _authApi.register(request);
  if (response != null) {
  await _cacheManager.saveUser(response.user);
  }
  return _cacheManager.saveAccessToken(response.token);
  }


  @override
  Future<RegistrationResponse> otpVerify(OtpVerifyRequest request, String token) {
    return _authApi.otpVerify(request, token);
  }

  @override
  Future<RegistrationResponse> otpSend(String token) {
    return _authApi.otpSend(token);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordrRequest request) {
    return _authApi.forgotPassword(request);
  }

  @override
  Stream<PackagesResponse> packages() {
    return _authApi.packages();
  }

  @override
  Stream<AllrequestData> allRequest(String data) {
    return _authApi.allRequest(data);
  }

  @override
  Future<bool> firstOpen() {
    return _cacheManager.isFirstOpen();
  }

  @override
  Future<void> setIsFirstOpen() {
    return _cacheManager.setIsFirstOpen();
  }
}
