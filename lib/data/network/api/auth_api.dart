import 'dart:io';

import 'package:dio/dio.dart' hide Headers;

import 'package:retrofit/retrofit.dart';

import '../../../domain/entities/pagination.dart';
import '../../../main.dart';
import '../request/courier_offer_model.dart';
import '../request/courier_profile.dart';
import '../request/delivery_offer_request.dart';
import '../request/forgot_password_request.dart';
import '../request/login_request.dart';
import '../request/notification_settings.dart';
import '../request/offer_response.dart';
import '../request/otp_verify_request.dart';
import '../request/privacy_settings.dart';
import '../request/registration_request.dart';
import '../request/user_request.dart';
import '../response/all_request_data.dart';
import '../response/cities_response.dart';
import '../response/language_response.dart';
import '../response/login_response.dart';
import '../response/login_response_data.dart';
import '../response/offer_models.dart';
import '../response/offer_type_model.dart';
import '../response/offer_types_response.dart';
import '../response/package_types_response.dart';
import '../response/packages_response.dart';
import '../response/registration_response.dart';
import '../response/send_otp_response.dart';
import '../response/user.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/api/v1/auth/login')
  Future<LoginResponseData> login(
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

  @POST('/api/v1/auth/register')
  Future<LoginResponseData> register(
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

  @GET('/api/v1/auth/me')
  Future<LoginResponseData> customersMe();

  @GET('/api/v1/dictionaries/languages')
  Future<LanguageResponse> getLanguages();

  @PUT('/api/v1/profile/personal')
  Future<void> profileEdit(@Body() UserRequest request);

  @PUT('/api/v1/profile/privacy')
  Future<void> privacyProfile(@Body() PrivacySettings request);

  @PUT('/api/v1/profile/notifications')
  Future<void> notificationsProfile(@Body() NotificationSettings request);

  @POST('/api/v1/offers')
  Future<void> createOffers(@Body() CourierOfferModel request);

  @PUT('/api/v1/profile/professional')
  Future<void> createProfessional(@Body() CourierProfile request);

  @GET('/api/packages')
  Future<PackagesResponse> packages();

  @GET('/api/v1/dictionaries/package-types')
  Future<PackageTypesResponse> getPackageType();

  @GET('/api/v1/geo/cities')
  Future<CitiesResponse> getCities();

  @GET('/api/v1/dictionaries/offer-types')
  Future<OfferTypeResponse> getOfferTypes();

  @GET('/api/v1/offers/my')
  Future<OfferListResponse> myOffers();

  // ✅ ДОБАВЛЕНО: Метод поиска офферов с пагинацией
  @GET('/api/v1/offers')
  Future<Pagination<OfferModel>>  searchOffers(
    @Query('offer_type') String? offerType,
    @Query('package_type') String? packageType,
    @Query('city_from_id') int? cityFromId,
    @Query('city_to_id') int? cityToId,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
    @Query('page') int page,
  );

  @POST('/api/v1/favorites/toggle')
  Future<void> setFavorites(@Body() OfferResponse request);
}
