import 'package:dio/dio.dart' hide Headers;

import 'package:retrofit/retrofit.dart';

import '../../../main.dart';
import '../request/forgot_password_request.dart';
import '../request/login_request.dart';
import '../request/otp_verify_request.dart';
import '../request/registration_request.dart';
import '../response/all_request_data.dart';
import '../response/login_response.dart';
import '../response/packages_response.dart';
import '../response/registration_response.dart';
import '../response/send_otp_response.dart';
import '../response/user.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<LoginResponse> login(
    @Body() LoginRequest request,
  );

  @PUT('/api/sendOtp')
  Future<void> getRegistration(@Query("phoneNumber") int number);

  @POST('/api/checkOtpRegister')
  Future<SendOtpResponse> sendRegistration(
      @Query("phoneNumber") int number, @Query("otpCode") int otpCode);

  @POST('/api/checkOtpLogin')
  Future<SendOtpResponse> sendOtpLogin(
      @Query("phoneNumber") int number, @Query("otpCode") int otpCode);

  @POST('/auth/register')
  Future<LoginResponse> register(
    @Body() RegistrationRequest request,
  );

  @POST('/otp/verify')
  Future<RegistrationResponse> otpVerify(
    @Body() OtpVerifyRequest request,
    @Header('Authorization') String token,
  );

  @POST('/otp/send')
  Future<RegistrationResponse> otpSend(
    @Header('Authorization') String token,
  );

  @PUT('/api/updatePassword')
  Future<void> forgotPassword(@Body() ForgotPasswordrRequest request);

  @GET('/api/all-requests/2022-12-01/{date}')
  Stream<AllrequestData> allRequest(
    @Path() String date,
  );

  @GET('/customers/me')
  Future<User> customersMe();

  @GET('/api/packages')
  Stream<PackagesResponse> packages();
}
