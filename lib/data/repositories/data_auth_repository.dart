import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/pagination.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../cache/cache_manager.dart';
import '../network/api/auth_api.dart';
import '../network/request/courier_offer_model.dart';
import '../network/request/courier_profile.dart';
import '../network/request/create_review_request.dart';
import '../network/request/delivery_offer_request.dart';
import '../network/request/edit_status_offer_request.dart';
import '../network/request/forgot_password_request.dart';
import '../network/request/login_request.dart';
import '../network/request/fcm_token_request.dart';
import '../network/request/notification_settings.dart';
import '../network/request/offer_response.dart';
import '../network/request/otp_verify_request.dart';
import '../network/request/privacy_settings.dart';
import '../network/request/registration_request.dart';
import '../network/request/support_request.dart';
import '../network/request/user_request.dart';
import '../network/response/all_request_data.dart';
import '../network/response/cities_response.dart';
import '../network/response/faq_response.dart';
import '../network/response/language_response.dart';
import '../network/response/login_response.dart';
import '../network/response/notification_response.dart';
import '../network/response/offer_models.dart';
import '../network/response/offer_type_model.dart';
import '../network/response/offer_types_response.dart';
import '../network/response/package_types_response.dart';
import '../network/response/packages_response.dart';
import '../network/response/partner_user_response.dart';
import '../network/response/privacy_policy_response.dart';
import '../network/response/registration_response.dart';
import '../network/response/reviews_response.dart';
import '../network/response/unread_chat_count_response.dart';
import '../network/response/unread_count_response.dart';
import '../network/response/user.dart';
import '../network/response/verification_response.dart';

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
    try {
      final response = await _authApi.customersMe();
      if (response != null) {
        await _cacheManager.saveUser(response.data.user);
      }
    } catch (e) {
      // Если 401 - очищаем токен
      if (e is DioException && e.response?.statusCode == 401) {
        await _cacheManager.clear();
        print('🔒 Token expired, cleared cache');
      }
      rethrow;
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

  @override
  Future<void> profileEdit(
      String name,
      String email,
      String phone,
      String location,
      String about,
      String? callingCode,
      ) {
    return _authApi.profileEdit(UserRequest(
      fullname: name,
      email: email,
      phone: phone,
      about: about,
      locationText: location,
      callingCode: callingCode,
    ));
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
  Future<void> notificationsProfile(NotificationSettings request) {
    return _authApi.notificationsProfile(request);
  }

  @override
  Future<void> registerFcmToken(String fcmToken) {
    return _authApi.registerFcmToken(FcmTokenRequest(fcmToken: fcmToken));
  }

  @override
  Future<PackagesResponse> packages() {
    return _authApi.packages();
  }

  @override
  Future<PackageTypesResponse> getPackageType() {
    return _authApi.getPackageType();
  }

  @override
  Future<CitiesResponse> getCities(String search) {
    return _authApi.getCities(search, 200);
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
  Future<PrivacyPolicyResponse> privacyPolicy(){
    return _authApi.privacyPolicy();
  }

  @override
  Future<UnreadCountResponse> notifUnread(){
    return _authApi.notifUnread();
  }

  @override
  Future<UnreadChatCountResponse> chatUnread(){
    return _authApi.chatUnread();
  }

  @override
  Future<FaqResponse> faqs(){
    return _authApi.faqs();
  }

  @override
  Stream<AllrequestData> allRequest(String data) {
    return _authApi.allRequest(data);
  }

  @override
  Future<Pagination<OfferModel>> myOffers(int page) {
    return _authApi.myOffers(page);
  }

  @override
  Future<void> editStatusOffer(String id, EditStatusOfferRequest request) {
    return _authApi.editStatusOffer(id, request);
  }

  @override
  Future<bool> firstOpen() {
    return _cacheManager.isFirstOpen();
  }

  @override
  Future<void> setIsFirstOpen() {
    return _cacheManager.setIsFirstOpen();
  }

  Future<void> setFavorites(OfferResponse request) {
    return _authApi.setFavorites(request);
  }

  Future<VerificationResponse> verificationStatus() async {
    return _authApi.verificationStatus();
  }

  Future<void> addAvatar(File avatar) {
    return _authApi.addAvatar(avatar);
  }

  Future<void> sendReviews(
    CreateReviewRequest request,
  ) {
    return _authApi.sendReviews(request);
  }

  Future<ReviewsResponse> myAboutReviev() {
    return _authApi.myAboutReviev();
  }

  Future<ReviewsResponse> myAboutLeft() {
    return _authApi.myAboutLeft();
  }

  Future<void> notificationsRead(int date) {
    return _authApi.notificationsRead(date);
  }

  Future<void> submitVerification(
      {required File passport, required File selfie}) {
    return _authApi.submitVerification(
      passport: passport,
      selfie: selfie,
    );
  }

  Future<Pagination<OfferModel>> getFavorites(int page) {
    return _authApi.getFavorites(page);
  }

  Future<void> support(SupportRequest request) {
    return _authApi.support(request);
  }

  Future<PartnerUserResponse> getUserById(int date) {
    return _authApi.getUserById(date);
  }

  Future<NotificationResponse> notifications() {
    return _authApi.notifications();
  }

  @override
  Future<void> logout() {
    return _cacheManager.clear();
  }

  @override
  Future<Pagination<OfferModel>> searchOffers({
    String? offerType,
    String? packageType,
    int? cityFromId,
    int? cityToId,
    String? dateFrom,
    String? dateTo,
    String? sort,
    required int page,
  }) async {
    try {
      final response = await _authApi.searchOffers(
        offerType,
        packageType,
        cityFromId,
        cityToId,
        dateFrom,
        dateTo,
        sort,
        page,
      );
      return response;
    } catch (e) {
      return Pagination<OfferModel>(data: [], lastPage: 1);
    }
  }
}
