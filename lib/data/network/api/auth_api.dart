import 'dart:io';

import 'package:dio/dio.dart' hide Headers;

import 'package:retrofit/retrofit.dart';

import '../../../domain/entities/pagination.dart';
import '../../../main.dart';
import '../request/change_password_request.dart';
import '../request/create_listing_request.dart';
import '../request/courier_offer_model.dart';
import '../request/courier_profile.dart';
import '../request/create_review_request.dart';
import '../request/delete_listing_request.dart';
import '../request/edit_status_offer_request.dart';
import '../request/forgot_password_request.dart';
import '../request/forgot_password_request_email.dart';
import '../request/forgot_password_reset_request.dart';
import '../request/forgot_password_verify_request.dart';
import '../request/login_request.dart';
import '../request/listing_proposal_request.dart';
import '../request/fcm_token_request.dart';
import '../request/notification_settings.dart';
import '../request/offer_response.dart';
import '../request/otp_verify_request.dart';
import '../request/privacy_settings.dart';
import '../request/registration_request.dart';
import '../request/report_request.dart';
import '../request/saved_search_request.dart';
import '../request/support_request.dart';
import '../request/user_request.dart';
import '../response/all_request_data.dart';
import '../response/cities_response.dart';
import '../response/content_response.dart';
import '../response/countries_response.dart';
import '../response/faq_response.dart';
import '../response/forgot_password_response.dart';
import '../response/language_response.dart';
import '../response/listing_response.dart';
import '../response/login_response_data.dart';
import '../response/me_response_data.dart';
import '../response/notification_response.dart';
import '../response/offer_models.dart';
import '../response/offer_type_model.dart';
import '../response/package_types_response.dart';
import '../response/packages_response.dart';
import '../response/partner_user_response.dart';
import '../response/privacy_policy_response.dart';
import '../response/registration_response.dart';
import '../response/reviews_response.dart';
import '../response/send_otp_response.dart';
import '../response/saved_search_response.dart';
import '../response/trending_routes_response.dart';
import '../response/unread_chat_count_response.dart';
import '../response/unread_count_response.dart';
import '../response/verification_response.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/auth/login')
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

  @POST('/auth/register')
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

  @GET('/auth/me')
  Future<MeResponseData> customersMe();

  @GET('/content')
  Future<ContentResponse> getContent(
    @Query('group') String? group,
  );

  @GET('/languages')
  Future<LanguageResponse> getLanguages();

  @PUT('/api/v1/profile/personal')
  Future<void> profileEdit(@Body() UserRequest request);

  @PUT('/api/v1/profile/privacy')
  Future<void> privacyProfile(@Body() PrivacySettings request);

  @PUT('/profile/notifications')
  Future<void> notificationsProfile(@Body() NotificationSettings request);

  @POST('/fcm-tokens')
  Future<void> registerFcmToken(@Body() FcmTokenRequest request);

  @POST('/api/v1/offers')
  Future<void> createOffers(@Body() CourierOfferModel request);

  @PUT('/api/v1/profile/professional')
  Future<void> createProfessional(@Body() CourierProfile request);

  @GET('/api/packages')
  Future<PackagesResponse> packages();

  @GET('/api/v1/dictionaries/package-types')
  Future<PackageTypesResponse> getPackageType();

  @GET('/api/v1/geo/cities')
  Future<CitiesResponse> getCities(
    @Query("q") String search,
    @Query("limit") int limit,
  );

  @GET('/api/v1/dictionaries/offer-types')
  Future<OfferTypeResponse> getOfferTypes();

  @GET('/api/v1/offers/my')
  Future<Pagination<OfferModel>> myOffers(
    @Query('page') int page,
  );

  @PATCH('/api/v1/offers/{id}/status')
  Future<void> editStatusOffer(
    @Path() String id,
    @Body() EditStatusOfferRequest request,
  );

  @GET('/api/v1/offers')
  Future<Pagination<OfferModel>> searchOffers(
    @Query('offer_type') String? offerType,
    @Query('package_type') String? packageType,
    @Query('city_from_id') int? cityFromId,
    @Query('city_to_id') int? cityToId,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
    @Query('sort') String? sort,
    @Query('page') int page,
  );

  @GET('/api/v1/offers/favorites')
  Future<Pagination<OfferModel>> getFavorites(
    @Query('page') int page,
  );

  @GET('/listings')
  Future<Pagination<Listing>> getListings(
    @Query('type') String? type,
    @Query('city_from_id') int? cityFromId,
    @Query('city_to_id') int? cityToId,
    @Query('verified_only') bool? verifiedOnly,
    @Query('following') bool? following,
    @Query('package_types[]') List<String>? packageTypes,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
    @Query('weight_min') double? weightMin,
    @Query('weight_max') double? weightMax,
    @Query('price_min') double? priceMin,
    @Query('price_max') double? priceMax,
    @Query('rating_min') double? ratingMin,
    @Query('tier_min') String? tierMin,
    @Query('sort') String? sort,
    @Query('seed') int? seed,
    @Query('page') int page,
    @Query('per_page') int? perPage,
  );

  @GET('/listings/{id}')
  Future<ListingResponse> getListingDetails(@Path() String id);

  @GET('/listings/my')
  Future<Pagination<Listing>> getMyListings(
    @Query('page') int page,
    @Query('per_page') int? perPage,
  );

  @GET('/listings/favorites')
  Future<Pagination<Listing>> getListingFavorites(
    @Query('page') int page,
    @Query('per_page') int? perPage,
  );

  @POST('/listings')
  Future<ListingResponse> createListing(
    @Body() CreateListingRequest request,
    @Header('Idempotency-Key') String idempotencyKey,
  );

  @PATCH('/listings/{id}')
  Future<ListingResponse> updateListing(
    @Path() String id,
    @Body() CreateListingRequest request,
    @Header('Idempotency-Key') String idempotencyKey,
  );

  @POST('/listings/{id}/pause')
  Future<ListingResponse> pauseListing(@Path() String id);

  @POST('/listings/{id}/resume')
  Future<ListingResponse> resumeListing(@Path() String id);

  @POST('/listings/{id}/repost')
  Future<ListingResponse> repostListing(
    @Path() String id,
    @Body() CreateListingRequest request,
    @Header('Idempotency-Key') String idempotencyKey,
  );

  @DELETE('/listings/{id}')
  Future<ListingMessageResponse> deleteListing(
    @Path() String id,
    @Body() DeleteListingRequest request,
  );

  @POST('/listings/{id}/favorite')
  Future<ListingMessageResponse> addListingFavorite(@Path() String id);

  @DELETE('/listings/{id}/favorite')
  Future<ListingMessageResponse> removeListingFavorite(@Path() String id);

  @POST('/listings/{id}/proposals')
  Future<ListingMessageResponse> createListingProposal(
    @Path() String id,
    @Body() ListingProposalRequest request,
    @Header('Idempotency-Key') String idempotencyKey,
  );

  @POST('/reports')
  Future<ListingMessageResponse> reportListing(
    @Body() ReportRequest request,
    @Header('Idempotency-Key') String idempotencyKey,
  );

  @GET('/package-types')
  Future<PackageTypesResponse> getListingPackageTypes();

  @GET('/cities')
  Future<CitiesResponse> getListingCities(
    @Query("q") String? search,
    @Query("limit") int limit,
  );

  @GET('/cities/popular')
  Future<CitiesResponse> getPopularCities();

  @GET('/search/trending-routes')
  Future<TrendingRoutesResponse> getTrendingRoutes();

  @GET('/saved-searches')
  Future<SavedSearchesResponse> getSavedSearches();

  @POST('/saved-searches')
  Future<SavedSearchResponse> createSavedSearch(
    @Body() SavedSearchRequest request,
  );

  @DELETE('/saved-searches/{id}')
  Future<void> deleteSavedSearch(@Path() String id);

  @POST('/api/v1/support')
  Future<void> support(
    @Body() SupportRequest request,
  );

  @GET('/api/v1/users/{date}')
  Future<PartnerUserResponse> getUserById(
    @Path() int date,
  );

  @POST('/notifications/{id}/read')
  Future<void> notificationsRead(
    @Path() String id,
  );

  @POST('/notifications/read-all')
  Future<void> notificationsReadAll();

  @DELETE('/notifications/{id}')
  Future<void> deleteNotification(@Path() String id);

  @GET('/notifications')
  Future<NotificationResponse> notifications(
    @Query('unread') bool? unread,
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @POST('/api/v1/favorites/toggle')
  Future<void> setFavorites(@Body() OfferResponse request);

  @GET('/api/v1/verification/status')
  Future<VerificationResponse> verificationStatus();

  @POST('/api/v1/profile/avatar')
  Future<void> addAvatar(
    @Part(name: 'avatar') File avatar,
  );

  @POST('/api/v1/reviews')
  Future<void> sendReviews(
    @Body() CreateReviewRequest request,
  );

  @POST('/api/v1/verification/submit')
  Future<void> submitVerification({
    @Part(name: 'documents[passport]') required File passport,
    @Part(name: 'documents[selfie]') required File selfie,
  });

  @GET('/api/v1/reviews/received')
  Future<ReviewsResponse> myAboutReviev();

  @GET('/api/v1/reviews/left')
  Future<ReviewsResponse> myAboutLeft();

  @POST('/auth/forgot-password/request')
  Future<ForgotPasswordResponse> forgotPasswordRequest(
    @Body() ForgotPasswordRequestEmail request,
  );

  @POST('/auth/forgot-password/verify')
  Future<void> forgotPasswordVerify(
    @Body() ForgotPasswordVerifyRequest request,
  );

  @POST('/auth/forgot-password/reset')
  Future<void> forgotPasswordReset(
    @Body() ForgotPasswordResetRequest request,
  );

  @POST('/auth/email/resend')
  Future<void> resendEmailVerification();

  @GET('/api/v1/geo/countries')
  Future<CountriesResponse> getCountries();

  @POST('/api/v1/auth/change-password')
  Future<void> changePassword(@Body() ChangePasswordRequest request);

  @GET('/api/v1/privacy-policy')
  Future<PrivacyPolicyResponse> privacyPolicy();

  @GET('/api/v1/faqs')
  Future<FaqResponse> faqs();

  @GET('/notifications/unread-count')
  Future<UnreadCountResponse> notifUnread();

  @GET('/chats/unread-count')
  Future<UnreadChatCountResponse> chatUnread();
}
