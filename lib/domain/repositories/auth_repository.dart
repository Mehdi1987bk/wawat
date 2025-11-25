import 'dart:io';

import '../../data/network/request/courier_profile.dart';
import '../../data/network/request/delivery_offer_request.dart';
import '../../data/network/request/forgot_password_request.dart';
import '../../data/network/request/login_request.dart';
import '../../data/network/request/notification_settings.dart';
import '../../data/network/request/otp_verify_request.dart';
import '../../data/network/request/privacy_settings.dart';
import '../../data/network/request/registration_request.dart';
import '../../data/network/response/all_request_data.dart';
import '../../data/network/response/language_response.dart';
import '../../data/network/response/login_response.dart';
import '../../data/network/response/offer_types_response.dart';
import '../../data/network/response/package_types_response.dart';
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

  Future<void> registration(RegistrationRequest request);

  Future<RegistrationResponse> otpVerify(
      OtpVerifyRequest request, String token);

  Future<RegistrationResponse> otpSend(String token);

  Future<LanguageResponse> getLanguages();

  Future<void> profileEdit(
    String name,
    String email,
    String phone,
    String location,
    String about,
  );

  Future<void> forgotPassword(ForgotPasswordrRequest request);

  Future<void> privacyProfile(PrivacySettings request);

  Future<void> notificationsProfile(NotificationSettings request);

  Future<PackagesResponse> packages();

  Future<PackageTypesResponse> getPackageType();

  Future<void> createOffers(DeliveryOfferRequest request);

  Future<void> createProfessional(CourierProfile request);

  Stream<OfferTypesResponse> getOfferTypes();

  Stream<AllrequestData> allRequest(String data);

  Future<bool> firstOpen();

  Future<void> setIsFirstOpen();
}
