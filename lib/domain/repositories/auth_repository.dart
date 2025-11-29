import 'dart:io';

import '../../data/network/request/courier_offer_model.dart';
import '../../data/network/request/courier_profile.dart';
import '../../data/network/request/delivery_offer_request.dart';
import '../../data/network/request/forgot_password_request.dart';
import '../../data/network/request/login_request.dart';
import '../../data/network/request/notification_settings.dart';
import '../../data/network/request/offer_response.dart';
import '../../data/network/request/otp_verify_request.dart';
import '../../data/network/request/privacy_settings.dart';
import '../../data/network/request/registration_request.dart';
import '../../data/network/response/all_request_data.dart';
import '../../data/network/response/cities_response.dart';
import '../../data/network/response/language_response.dart';
import '../../data/network/response/login_response.dart';
import '../../data/network/response/offer_models.dart';
import '../../data/network/response/offer_type_model.dart';
import '../../data/network/response/offer_types_response.dart';
import '../../data/network/response/package_types_response.dart';
import '../../data/network/response/packages_response.dart';
import '../../data/network/response/registration_response.dart';
import '../../data/network/response/user.dart';
import '../entities/pagination.dart';

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

  Future<CitiesResponse> getCities();

  Future<void> createOffers(CourierOfferModel request);

  Future<void> createProfessional(CourierProfile request);

  Future<OfferTypeResponse> getOfferTypes();

  Stream<AllrequestData> allRequest(String data);

  Future<OfferListResponse> myOffers();

  Future<bool> firstOpen();

  Future<void> setFavorites(OfferResponse request);

  Future<Pagination<OfferModel>> getFavorites(int page);

  Future<void> setIsFirstOpen();

  Future<Pagination<OfferModel>> searchOffers({
    String? offerType,
    String? packageType,
    int? cityFromId,
    int? cityToId,
    String? dateFrom,
    String? dateTo,
    String? sort,
    required int page,
  });

  Future<void> logout();
}
