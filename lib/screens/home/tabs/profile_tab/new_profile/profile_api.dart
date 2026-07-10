import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../../../../data/network/response/language_response.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../main.dart';
import 'profile_models.dart';

class WawatProfileApi {
  final Dio _dio;

  WawatProfileApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  Future<Map<String, String>> content() async {
    final result = <String, String>{};
    for (final group in const ['profile', 'review', 'listing', 'menu']) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '$baseUrl/content',
          queryParameters: {'group': group},
        );
        final data = response.data?['data'];
        if (data is Map) {
          result.addAll(
            data.map(
                (key, value) => MapEntry(key.toString(), value.toString())),
          );
        }
      } catch (_) {
        // CMS must not block profile rendering.
      }
    }
    return result;
  }

  Future<WawatProfileUser> me() async {
    Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>('$baseUrl/me');
    } catch (_) {
      response = await _dio.get<Map<String, dynamic>>('$baseUrl/auth/me');
    }
    return WawatProfileResponse.fromJson(response.data ?? const {}).data;
  }

  Future<WawatProfileUser> user(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('$baseUrl/users/$id');
    return WawatProfileResponse.fromJson(response.data ?? const {}).data;
  }

  Future<Pagination<Listing>> myListings({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/listings/my',
      queryParameters: {'page': page, 'per_page': 20},
    );
    return Pagination<Listing>.fromJson(response.data ?? const {});
  }

  Future<Pagination<Listing>> userListings(String userId,
      {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/listings',
      queryParameters: {'user': userId, 'page': page, 'per_page': 20},
    );
    return Pagination<Listing>.fromJson(response.data ?? const {});
  }

  Future<PackageTypesResponse> packageTypes() async {
    final response =
        await _dio.get<Map<String, dynamic>>('$baseUrl/package-types');
    return PackageTypesResponse.fromJson(response.data ?? const {});
  }

  Future<LanguageResponse> languages() async {
    final response = await _dio.get<Map<String, dynamic>>('$baseUrl/languages');
    return LanguageResponse.fromJson(response.data ?? const {});
  }

  Future<WawatReviewResponse> reviews(String userId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/users/$userId/reviews',
      queryParameters: {'page': page, 'per_page': 20},
    );
    return WawatReviewResponse.fromJson(response.data ?? const {});
  }

  Future<WawatReviewResponse> reviewsLeft({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/reviews/left',
      queryParameters: {'page': page, 'per_page': 20},
    );
    return WawatReviewResponse.fromJson(response.data ?? const {});
  }

  Future<List<WawatProfileUser>> followers(
    String userId, {
    bool following = false,
    int page = 1,
  }) async {
    final endpoint = following ? 'following' : 'followers';
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/users/$userId/$endpoint',
      queryParameters: {'page': page, 'per_page': 40},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) =>
            WawatProfileUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<String> follow(String userId) async {
    final response =
        await _dio.post<Map<String, dynamic>>('$baseUrl/users/$userId/follow');
    return response.data?['message']?.toString() ?? 'İzləməyə başladınız.';
  }

  Future<String> unfollow(String userId) async {
    final response = await _dio
        .delete<Map<String, dynamic>>('$baseUrl/users/$userId/follow');
    return response.data?['message']?.toString() ?? 'İzləmə dayandırıldı.';
  }

  Future<String> block(String userId) async {
    final response =
        await _dio.post<Map<String, dynamic>>('$baseUrl/users/$userId/block');
    return response.data?['message']?.toString() ?? 'İstifadəçi bloklandı.';
  }

  Future<String> reportUser({
    required String userId,
    String? reasonCode,
    String? note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/reports',
      data: {
        'target_type': 'user',
        'target_id': userId,
        if (reasonCode != null) 'reason_code': reasonCode,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
      options: Options(headers: {'Idempotency-Key': _idempotencyKey('report')}),
    );
    return response.data?['message']?.toString() ?? 'Şikayət göndərildi.';
  }

  Future<WawatProfileUser> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$baseUrl/profile',
      data: data,
    );
    return WawatProfileResponse.fromJson(response.data ?? const {}).data;
  }

  Future<String> updatePrivacy(WawatPrivacySettings settings) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$baseUrl/profile/privacy',
      data: settings.toJson(),
    );
    return response.data?['message']?.toString() ??
        'Məxfilik parametrləri yeniləndi.';
  }

  Future<String> changePassword({
    required String currentPassword,
    required String password,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$baseUrl/profile/password',
      data: {
        'current_password': currentPassword,
        'password': password,
      },
    );
    return response.data?['message']?.toString() ?? 'Parol dəyişdirildi.';
  }

  Future<String> deleteAccount() async {
    final response =
        await _dio.delete<Map<String, dynamic>>('$baseUrl/profile/account');
    return response.data?['message']?.toString() ?? 'Hesabınız silindi.';
  }

  Future<String> uploadAvatar(File avatar) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/profile/avatar',
      data: FormData.fromMap({
        'avatar': await MultipartFile.fromFile(avatar.path),
      }),
    );
    return response.data?['message']?.toString() ?? 'Avatar yeniləndi.';
  }

  Future<String> deleteAvatar() async {
    final response =
        await _dio.delete<Map<String, dynamic>>('$baseUrl/profile/avatar');
    return response.data?['message']?.toString() ?? 'Avatar silindi.';
  }

  Future<String> replyReview({
    required String reviewId,
    required String reply,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/reviews/$reviewId/reply',
      data: {'reply': reply},
    );
    return response.data?['message']?.toString() ??
        'Cavabınız moderasiyaya göndərildi.';
  }

  Future<String> writeReview({
    required String shipmentId,
    required int rating,
    String? comment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/shipments/$shipmentId/review',
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
      options: Options(headers: {'Idempotency-Key': _idempotencyKey('review')}),
    );
    return response.data?['message']?.toString() ??
        'Rəyiniz moderasiyaya göndərildi.';
  }

  Future<String> requestReview(String shipmentId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/shipments/$shipmentId/review-request',
      options: Options(
        headers: {'Idempotency-Key': _idempotencyKey('review-request')},
      ),
    );
    return response.data?['message']?.toString() ?? 'Rəy istəyi göndərildi.';
  }

  Future<String> logout() async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>('$baseUrl/auth/logout');
      return response.data?['message']?.toString() ?? 'Çıxış edildi.';
    } catch (_) {
      return 'Çıxış edildi.';
    }
  }

  String _idempotencyKey(String scope) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return 'profile-$scope-$now-$random';
  }
}
