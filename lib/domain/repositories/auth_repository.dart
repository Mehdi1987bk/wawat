import 'dart:io';

import '../../data/network/request/courier_offer_model.dart';
import '../../data/network/request/courier_profile.dart';
import '../../data/network/request/create_listing_request.dart';
import '../../data/network/request/create_review_request.dart';
import '../../data/network/request/delete_listing_request.dart';
import '../../data/network/request/edit_status_offer_request.dart';
import '../../data/network/request/forgot_password_request.dart';
import '../../data/network/request/login_request.dart';
import '../../data/network/request/listing_proposal_request.dart';
import '../../data/network/request/notification_settings.dart';
import '../../data/network/request/offer_response.dart';
import '../../data/network/request/otp_verify_request.dart';
import '../../data/network/request/privacy_settings.dart';
import '../../data/network/request/registration_request.dart';
import '../../data/network/request/report_request.dart';
import '../../data/network/request/saved_search_request.dart';
import '../../data/network/request/support_request.dart';
import '../../data/network/response/all_request_data.dart';
import '../../data/network/response/cities_response.dart';
import '../../data/network/response/content_response.dart';
import '../../data/network/response/faq_response.dart';
import '../../data/network/response/language_response.dart';
import '../../data/network/response/listing_response.dart';
import '../../data/network/response/notification_response.dart';
import '../../data/network/response/offer_models.dart';
import '../../data/network/response/offer_type_model.dart';
import '../../data/network/response/package_types_response.dart';
import '../../data/network/response/packages_response.dart';
import '../../data/network/response/partner_user_response.dart';
import '../../data/network/response/privacy_policy_response.dart';
import '../../data/network/response/registration_response.dart';
import '../../data/network/response/reviews_response.dart';
import '../../data/network/response/saved_search_response.dart';
import '../../data/network/response/trending_routes_response.dart';
import '../../data/network/response/unread_chat_count_response.dart';
import '../../data/network/response/unread_count_response.dart';
import '../../data/network/response/user.dart';
import '../../data/network/response/document_type.dart';
import '../../data/network/response/verification_response.dart';
import '../entities/pagination.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);

  Future<bool> isLogged();

  Stream<User> get userDetails;

  Future<void> otpRegistration(int number);

  Future<void> sendRegistration(int number, int otpCode);

  Future<void> sendOtpLogin(int number, int otpCode);

  Future<void> customersMe();

  Future<ContentResponse> getContent({String? group});

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
    String? callingCode,
  );

  Future<void> forgotPassword(ForgotPasswordrRequest request);

  Future<void> privacyProfile(PrivacySettings request);

  Future<void> notificationsProfile(NotificationSettings request);

  Future<void> registerFcmToken(String fcmToken);

  Future<void> resendEmailVerification();

  Future<PackagesResponse> packages();

  Future<PackageTypesResponse> getPackageType();

  Future<CitiesResponse> getCities(String search);

  Future<void> createOffers(CourierOfferModel request);

  Future<void> createProfessional(CourierProfile request);

  Future<OfferTypeResponse> getOfferTypes();

  Future<PrivacyPolicyResponse> privacyPolicy();

  Future<UnreadCountResponse> notifUnread();

  Future<UnreadChatCountResponse> chatUnread();

  Future<FaqResponse> faqs();

  Stream<AllrequestData> allRequest(String data);

  Future<Pagination<OfferModel>> myOffers(int page);

  Future<void> editStatusOffer(String id, EditStatusOfferRequest request);

  Future<bool> firstOpen();

  Future<void> setFavorites(OfferResponse request);

  Future<VerificationResponse> verificationStatus();

  Future<void> addAvatar(File avatar);

  Future<void> sendReviews(CreateReviewRequest request);

  Future<ReviewsResponse> myAboutReviev();

  Future<ReviewsResponse> myAboutLeft();

  Future<void> notificationsRead(String id);

  Future<void> notificationsReadAll();

  Future<void> deleteNotification(String id);

  Future<void> submitVerification(
      {required File passport, required File selfie});

  /// KYC document types (id_card/passport/driver_license/selfie) with localized
  /// names — never hardcode the list.
  Future<List<DocumentType>> getDocumentTypes();

  /// Submit an ID document of the chosen [idType] + a selfie in one request.
  Future<void> submitVerificationDocs({
    required String idType,
    required File idFile,
    required File selfie,
  });

  Future<Pagination<OfferModel>> getFavorites(int page);

  Future<void> support(SupportRequest request);

  Future<void> setIsFirstOpen();

  Future<PartnerUserResponse> getUserById(int date);

  Future<NotificationResponse> notifications({
    bool? unread,
    int page = 1,
    int perPage = 20,
  });

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
  });

  Future<ListingResponse> getListingDetails(String id);

  Future<Pagination<Listing>> getMyListings({
    required int page,
    int? perPage,
  });

  Future<Pagination<Listing>> getListingFavorites({
    required int page,
    int? perPage,
  });

  Future<ListingResponse> createListing(
    CreateListingRequest request,
    String idempotencyKey,
  );

  Future<ListingResponse> updateListing(
    String id,
    CreateListingRequest request,
    String idempotencyKey,
  );

  Future<ListingResponse> pauseListing(String id);

  Future<ListingResponse> resumeListing(String id);

  Future<ListingResponse> repostListing(
    String id,
    CreateListingRequest request,
    String idempotencyKey,
  );

  Future<ListingMessageResponse> deleteListing(
    String id,
    DeleteListingRequest request,
  );

  Future<ListingMessageResponse> addListingFavorite(String id);

  Future<ListingMessageResponse> removeListingFavorite(String id);

  Future<ListingMessageResponse> createListingProposal(
    String id,
    ListingProposalRequest request,
    String idempotencyKey,
  );

  Future<ListingMessageResponse> reportListing(
    ReportRequest request,
    String idempotencyKey,
  );

  Future<PackageTypesResponse> getListingPackageTypes();

  Future<CitiesResponse> getListingCities(String? search, {int limit = 20});

  Future<CitiesResponse> getPopularCities();

  Future<TrendingRoutesResponse> getTrendingRoutes();

  Future<SavedSearchesResponse> getSavedSearches();

  Future<SavedSearchResponse> createSavedSearch(SavedSearchRequest request);

  Future<void> deleteSavedSearch(String id);

  Future<void> logout();
}
