import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/pagination.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../services/push_notification_service.dart';
import '../cache/cache_manager.dart';
import '../network/api/auth_api.dart';
import '../network/request/create_listing_request.dart';
import '../network/request/courier_offer_model.dart';
import '../network/request/courier_profile.dart';
import '../network/request/create_review_request.dart';
import '../network/request/delete_listing_request.dart';
import '../network/request/edit_status_offer_request.dart';
import '../network/request/forgot_password_request.dart';
import '../network/request/login_request.dart';
import '../network/request/listing_proposal_request.dart';
import '../network/request/fcm_token_request.dart';
import '../network/request/notification_settings.dart';
import '../network/request/offer_response.dart';
import '../network/request/otp_verify_request.dart';
import '../network/request/privacy_settings.dart';
import '../network/request/registration_request.dart';
import '../network/request/report_request.dart';
import '../network/request/saved_search_request.dart';
import '../network/request/support_request.dart';
import '../network/request/user_request.dart';
import '../network/response/all_request_data.dart';
import '../network/response/cities_response.dart';
import '../network/response/content_response.dart';
import '../network/response/faq_response.dart';
import '../network/response/language_response.dart';
import '../network/response/listing_response.dart';
import '../network/response/notification_response.dart';
import '../network/response/offer_models.dart';
import '../network/response/offer_type_model.dart';
import '../network/response/package_types_response.dart';
import '../network/response/packages_response.dart';
import '../network/response/partner_user_response.dart';
import '../network/response/privacy_policy_response.dart';
import '../network/response/registration_response.dart';
import '../network/response/reviews_response.dart';
import '../network/response/saved_search_response.dart';
import '../network/response/trending_routes_response.dart';
import '../network/response/unread_chat_count_response.dart';
import '../network/response/unread_count_response.dart';
import '../network/response/user.dart';
import '../network/response/document_type.dart';
import '../network/response/verification_state.dart';
import '../../services/telemetry/telemetry.dart';
import '../../services/telemetry/telemetry_events.dart';

const tokenRefreshTimeOut = 60 * 60 * 1000;

class DataAuthRepository implements AuthRepository {
  final AuthApi _authApi = sl.get<AuthApi>();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  @override
  Future<void> login(LoginRequest request) async {
    final response = await _authApi.login(request);
    await _cacheManager.saveUser(response.data.user);
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
      await _cacheManager.saveUser(response.data);
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
  Future<ContentResponse> getContent({String? group}) {
    return _authApi.getContent(group);
  }

  @override
  Future<void> registration(RegistrationRequest request) async {
    final response = await _authApi.register(request);
    await _cacheManager.saveUser(response.data.user);
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
    final deviceType = Platform.isIOS ? 'ios' : 'android';
    return _authApi.registerFcmToken(
      FcmTokenRequest(token: fcmToken, deviceType: deviceType),
    );
  }

  @override
  Future<void> resendEmailVerification() {
    return _authApi.resendEmailVerification();
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
  Future<PrivacyPolicyResponse> privacyPolicy() {
    return _authApi.privacyPolicy();
  }

  @override
  Future<UnreadCountResponse> notifUnread() {
    return _authApi.notifUnread();
  }

  @override
  Future<UnreadChatCountResponse> chatUnread() {
    return _authApi.chatUnread();
  }

  @override
  Future<FaqResponse> faqs() {
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

  @override
  Future<VerificationSnapshot> getVerification() async {
    final response = await sl.get<Dio>().get<dynamic>('$baseUrl/verification');
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final data = body['data'];
    final state = data is Map
        ? VerificationState.fromJson(Map<String, dynamic>.from(data))
        : null;
    // Fee for the intro: the active request's payment when there is one, else a
    // top-level hint if the backend exposes one for the not-submitted case.
    double? fee = state?.payment.feeAmount;
    String? currency = state?.payment.currency;
    // String-tolerant parse: the backend may serialize money as a JSON string
    // ("50.00"), same as the model's amount parsing — a hard `as num` cast would
    // throw and drop the intro fee on an otherwise-valid response.
    if (fee == null && body['payment'] is Map) {
      final p = Map<String, dynamic>.from(body['payment'] as Map);
      fee = double.tryParse(p['fee_amount']?.toString() ?? '');
      currency = p['currency']?.toString() ?? currency;
    }
    if (fee == null && body['fee_amount'] != null) {
      fee = double.tryParse(body['fee_amount'].toString());
      currency ??= body['currency']?.toString();
    }
    return VerificationSnapshot(
      state: state,
      feeAmount: fee,
      currency: currency,
    );
  }

  @override
  Future<VerificationPayResult> payVerification() async {
    final response = await sl.get<Dio>().post<dynamic>(
      '$baseUrl/verification/pay',
      data: const <String, dynamic>{},
    );
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final data = body['data'];
    if (data is! Map) {
      throw StateError('verification/pay returned no verification');
    }
    return VerificationPayResult(
      state: VerificationState.fromJson(Map<String, dynamic>.from(data)),
      message: body['message']?.toString(),
    );
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

  Future<void> notificationsRead(String id) {
    return _authApi.notificationsRead(id);
  }

  Future<void> notificationsReadAll() {
    return _authApi.notificationsReadAll();
  }

  Future<void> deleteNotification(String id) {
    return _authApi.deleteNotification(id);
  }

  Future<void> submitVerification(
      {required File passport, required File selfie}) {
    return _authApi.submitVerification(
      passport: passport,
      selfie: selfie,
    );
  }

  @override
  Future<List<DocumentType>> getDocumentTypes() async {
    final response =
        await sl.get<Dio>().get<dynamic>('$baseUrl/document-types');
    final body = response.data;
    final list = body is Map ? body['data'] : body;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => DocumentType.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  @override
  Future<void> submitVerificationDocs({
    required String idType,
    required File idFile,
    required File selfie,
  }) async {
    // Dynamic document-type key — `documents[<code>]` — so any /document-types
    // code (id_card/passport/driver_license) works without hardcoding.
    final form = FormData.fromMap({
      'documents[$idType]': await MultipartFile.fromFile(idFile.path),
      'documents[selfie]': await MultipartFile.fromFile(selfie.path),
    });
    await sl.get<Dio>().post<dynamic>(
          '$baseUrl/verification/submit',
          data: form,
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

  Future<NotificationResponse> notifications({
    bool? unread,
    int page = 1,
    int perPage = 20,
  }) {
    return _authApi.notifications(unread, page, perPage);
  }

  @override
  Future<void> logout() async {
    // Снять токен пуша с бэка, чтобы на разлогиненное устройство не шли пуши.
    final token = PushNotificationService().fcmToken;
    if (token != null && token.isNotEmpty) {
      try {
        await sl.get<Dio>().delete<void>(
          '$baseUrl/fcm-tokens',
          data: {'token': token},
        );
      } catch (_) {
        // best-effort — не блокируем выход из аккаунта.
      }
    }
    // Личность сбрасываем здесь явно, а не полагаемся на поток `userDetails`:
    // `clear()` чистит Hive-бокс целиком, и событие watch по конкретному ключу
    // может не прийти. Иначе события гостя после выхода продолжали бы
    // приписываться предыдущему пользователю.
    Telemetry.instance.event(TelemetryEvents.logout);
    await Telemetry.instance.clearIdentity();
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

  @override
  Future<Pagination<Listing>> getListings({
    String? type,
    int? cityFromId,
    int? cityToId,
    bool? verifiedOnly,
    bool? following,
    List<String>? packageTypes,
    String? dateFrom,
    String? dateTo,
    double? weightMin,
    double? weightMax,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    String? tierMin,
    String? sort,
    int? seed,
    required int page,
    int? perPage,
  }) {
    return _authApi.getListings(
      type,
      cityFromId,
      cityToId,
      verifiedOnly,
      following,
      packageTypes,
      dateFrom,
      dateTo,
      weightMin,
      weightMax,
      priceMin,
      priceMax,
      ratingMin,
      tierMin,
      sort,
      seed,
      page,
      perPage,
    );
  }

  @override
  Future<ListingResponse> getListingDetails(String id) {
    return _authApi.getListingDetails(id);
  }

  @override
  Future<Pagination<Listing>> getMyListings({
    required int page,
    int? perPage,
  }) {
    return _authApi.getMyListings(page, perPage);
  }

  @override
  Future<Pagination<Listing>> getListingFavorites({
    required int page,
    int? perPage,
  }) {
    return _authApi.getListingFavorites(page, perPage);
  }

  @override
  Future<ListingResponse> createListing(
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return _authApi.createListing(request, idempotencyKey);
  }

  @override
  Future<ListingResponse> updateListing(
    String id,
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return _authApi.updateListing(id, request, idempotencyKey);
  }

  @override
  Future<ListingResponse> pauseListing(String id) {
    return _authApi.pauseListing(id);
  }

  @override
  Future<ListingResponse> resumeListing(String id) {
    return _authApi.resumeListing(id);
  }

  @override
  Future<ListingResponse> repostListing(
    String id,
    CreateListingRequest request,
    String idempotencyKey,
  ) {
    return _authApi.repostListing(id, request, idempotencyKey);
  }

  @override
  Future<ListingMessageResponse> deleteListing(
    String id,
    DeleteListingRequest request,
  ) {
    return _authApi.deleteListing(id, request);
  }

  @override
  Future<ListingMessageResponse> addListingFavorite(String id) {
    return _authApi.addListingFavorite(id);
  }

  @override
  Future<ListingMessageResponse> removeListingFavorite(String id) {
    return _authApi.removeListingFavorite(id);
  }

  @override
  Future<ListingMessageResponse> createListingProposal(
    String id,
    ListingProposalRequest request,
    String idempotencyKey,
  ) {
    return _authApi.createListingProposal(id, request, idempotencyKey);
  }

  @override
  Future<ListingMessageResponse> reportListing(
    ReportRequest request,
    String idempotencyKey,
  ) {
    return _authApi.reportListing(request, idempotencyKey);
  }

  @override
  Future<PackageTypesResponse> getListingPackageTypes() {
    return _authApi.getListingPackageTypes();
  }

  @override
  Future<CitiesResponse> getListingCities(String? search, {int limit = 20}) {
    return _authApi.getListingCities(search, limit);
  }

  @override
  Future<CitiesResponse> getPopularCities() {
    return _authApi.getPopularCities();
  }

  @override
  Future<TrendingRoutesResponse> getTrendingRoutes() {
    return _authApi.getTrendingRoutes();
  }

  @override
  Future<SavedSearchesResponse> getSavedSearches() {
    return _authApi.getSavedSearches();
  }

  @override
  Future<SavedSearchResponse> createSavedSearch(SavedSearchRequest request) {
    return _authApi.createSavedSearch(request);
  }

  @override
  Future<void> deleteSavedSearch(String id) {
    return _authApi.deleteSavedSearch(id);
  }
}
