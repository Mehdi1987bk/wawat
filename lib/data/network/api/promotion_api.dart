import 'package:dio/dio.dart';

import '../request/promotion_request.dart';
import '../response/promotion_response.dart';

class PromotionApi {
  PromotionApi(this._dio, {String baseUrl = 'https://api.wawatair.com/api/v1'})
      : _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  Future<PromotionPricingResponse> getPricing() async {
    final response =
        await _dio.get<Map<String, dynamic>>('$_baseUrl/promotions/pricing');
    return PromotionPricingResponse.fromJson(response.data ?? const {});
  }

  Future<PromotionResponse> createPromotion(
    String listingId,
    PromotionRequest request, {
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/listings/$listingId/promotions',
      data: request.toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PromotionResponse.fromJson(response.data ?? const {});
  }

  Future<PromotionsResponse> getMyPromotions({
    String? status,
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/me/promotions',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'per_page': perPage,
      },
    );
    return PromotionsResponse.fromJson(response.data ?? const {});
  }

  Future<PromotionResponse> getPromotion(String promotionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/promotions/$promotionId',
    );
    return PromotionResponse.fromJson(response.data ?? const {});
  }

  Future<PromotionResponse> extendPromotion(
    String promotionId,
    PromotionExtendRequest request, {
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/promotions/$promotionId/extend',
      data: request.toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PromotionResponse.fromJson(response.data ?? const {});
  }

  Future<PromotionResponse> payPromotion(
    String promotionId,
    PromotionPayRequest request, {
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/promotions/$promotionId/pay',
      data: request.toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PromotionResponse.fromJson(response.data ?? const {});
  }
}
