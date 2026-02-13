import 'dart:io';

import '../../data/network/request/courier_offer_model.dart';
import '../../data/network/request/courier_profile.dart';
import '../../data/network/request/create_review_request.dart';
import '../../data/network/request/delivery_offer_request.dart';
import '../../data/network/request/edit_status_offer_request.dart';
import '../../data/network/request/forgot_password_request.dart';
import '../../data/network/request/login_request.dart';
import '../../data/network/request/notification_settings.dart';
import '../../data/network/request/offer_response.dart';
import '../../data/network/request/otp_verify_request.dart';
import '../../data/network/request/privacy_settings.dart';
import '../../data/network/request/registration_request.dart';
import '../../data/network/request/support_request.dart';
import '../../data/network/response/all_request_data.dart';
import '../../data/network/response/cities_response.dart';
import '../../data/network/response/faq_response.dart';
import '../../data/network/response/language_response.dart';
import '../../data/network/response/login_response.dart';
import '../../data/network/response/notification_response.dart';
import '../../data/network/response/offer_models.dart';
import '../../data/network/response/offer_type_model.dart';
import '../../data/network/response/offer_types_response.dart';
import '../../data/network/response/package_types_response.dart';
import '../../data/network/response/packages_response.dart';
import '../../data/network/response/partner_user_response.dart';
import '../../data/network/response/privacy_policy_response.dart';
import '../../data/network/response/registration_response.dart';
import '../../data/network/response/reviews_response.dart';
import '../../data/network/response/unread_chat_count_response.dart';
import '../../data/network/response/unread_count_response.dart';
import '../../data/network/response/user.dart';
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

  Future<void> notificationsRead(int date);

  Future<void> submitVerification(
      {required File passport, required File selfie});

  Future<Pagination<OfferModel>> getFavorites(int page);

  Future<void> support(SupportRequest request);

  Future<void> setIsFirstOpen();

  Future<PartnerUserResponse> getUserById(int date);

  Future<NotificationResponse> notifications();

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
