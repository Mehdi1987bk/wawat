import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../domain/entities/pagination.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../cache/cache_manager.dart';
import '../network/api/auth_api.dart';
import '../network/request/courier_offer_model.dart';
import '../network/request/courier_profile.dart';
import '../network/request/delivery_offer_request.dart';
import '../network/request/forgot_password_request.dart';
import '../network/request/login_request.dart';
import '../network/request/notification_settings.dart';
import '../network/request/offer_response.dart';
import '../network/request/otp_verify_request.dart';
import '../network/request/privacy_settings.dart';
import '../network/request/registration_request.dart';
import '../network/request/user_request.dart';
import '../network/response/all_request_data.dart';
import '../network/response/cities_response.dart';
import '../network/response/language_response.dart';
import '../network/response/login_response.dart';
import '../network/response/offer_models.dart';
import '../network/response/offer_type_model.dart';
import '../network/response/offer_types_response.dart';
import '../network/response/package_types_response.dart';
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
      await _cacheManager.saveUser(response.data.user);
    }
    return _cacheManager.saveAccessToken(response.data.token ?? "");
  }

  @override
  Stream<User> get userDetails =>
      _cacheManager.userDetails.whereNotNull().asBroadcastStream();

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
      await _cacheManager.saveUser(response.data.user);
    }
  }

  @override
  Future<void> registration(RegistrationRequest request) async {
    final response = await _authApi.register(request);
    if (response != null) {
      await _cacheManager.saveUser(response.data.user);
    }
    return _cacheManager.saveAccessToken(response.data.token ?? "");
  }

  @override
  Future<RegistrationResponse> otpVerify(
      OtpVerifyRequest request, String token) {
    return _authApi.otpVerify(request, token);
  }

  @override
  Future<RegistrationResponse> otpSend(String token) {
    return _authApi.otpSend(token);
  }

  @override
  Future<LanguageResponse> getLanguages() {
    return _authApi.getLanguages();
  }

  Future<void> profileEdit(
      String name,
      String email,
      String phone,
      String location,
      String about,
      ) {
    return _authApi.profileEdit(UserRequest(fullname: name, email: email, phone: phone,about: about,locationText: location) );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordrRequest request) {
    return _authApi.forgotPassword(request);
  }

  @override
  Future<void> privacyProfile(PrivacySettings request) {
    return _authApi.privacyProfile(request);
  }

  @override
  Future<void> notificationsProfile(  NotificationSettings request) {
    return _authApi.notificationsProfile(request);
  }

  @override
  Future<PackagesResponse> packages() {
    return _authApi.packages();
  }

  @override
  Future<PackageTypesResponse> getPackageType(){
    return _authApi.getPackageType();
  }


  @override
  Future<CitiesResponse> getCities(){
    return _authApi.getCities();
  }

  @override
  Future<void> createOffers(CourierOfferModel request) {
    return _authApi.createOffers(request);
  }

  @override
  Future<void> createProfessional(CourierProfile request) {
    return _authApi.createProfessional(request);
  }

  @override
  Future<OfferTypeResponse> getOfferTypes() {
    return _authApi.getOfferTypes();
  }

  @override
  Stream<AllrequestData> allRequest(String data) {
    return _authApi.allRequest(data);
  }

  @override
  Future<OfferListResponse> myOffers() {
    return _authApi.myOffers( );
  }

  @override
  Future<bool> firstOpen() {
    return _cacheManager.isFirstOpen();
  }

  @override
  Future<void> setIsFirstOpen() {
    return _cacheManager.setIsFirstOpen();
  }

  Future<void> setFavorites(  OfferResponse request) {
    return _authApi.setFavorites(request);
  }


  @override
  @override
  Future<Pagination<OfferModel>>  searchOffers(
      String? offerType,
      String? packageType,
      int? cityFromId,
      int? cityToId,
      String? dateFrom,
      String? dateTo,
      int page,
      )async {
    try {
      final response = await _authApi.searchOffers(
        offerType,
        packageType,
        cityFromId,
        cityToId,
        dateFrom,
        dateTo,
        page,
      );
      return response;
    } catch (e) {
      return Pagination<OfferModel>(data: [], lastPage: 1);
    }
  }
}
