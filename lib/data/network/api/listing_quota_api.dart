import 'package:dio/dio.dart';

import '../response/listing_quota_response.dart';

class ListingQuotaApi {
  ListingQuotaApi(this._dio,
      {String baseUrl = 'https://api.wawatair.com/api/v1'})
      : _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  Future<QuotaPricingResponse> getPricing() async {
    final response =
        await _dio.get<Map<String, dynamic>>('$_baseUrl/listing-quota/pricing');
    return QuotaPricingResponse.fromJson(response.data ?? const {});
  }

  Future<QuotaOrderResponse> createOrder({
    required String type,
    required int extraListings,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/listing-quota/orders',
      data: {'type': type, 'extra_listings': extraListings},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return QuotaOrderResponse.fromJson(response.data ?? const {});
  }

  Future<QuotaOrderResponse> payOrder(
    String orderId, {
    required String method,
    String? mockOutcome,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/listing-quota/orders/$orderId/pay',
      data: {
        'method': method,
        if (mockOutcome != null) 'mock_outcome': mockOutcome,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return QuotaOrderResponse.fromJson(response.data ?? const {});
  }

  Future<QuotaOrderResponse> getOrder(String orderId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('$_baseUrl/listing-quota/orders/$orderId');
    return QuotaOrderResponse.fromJson(response.data ?? const {});
  }
}
