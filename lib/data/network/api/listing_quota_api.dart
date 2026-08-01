import 'package:dio/dio.dart';

import '../response/listing_quota_response.dart';

/// Hand-written Dio wrapper for the paid "increase listing limit" endpoints,
/// mirroring [PromotionApi]. Mutating calls carry an `Idempotency-Key` header
/// (double-charge guard), exactly like the promo/VIP payment flow.
///
/// Instantiate with `ListingQuotaApi(sl.get<Dio>())` — the shared Dio's
/// interceptor injects the Bearer token when logged in and simply omits it when
/// not, so `getPricing()` (public) works either way.
class ListingQuotaApi {
  ListingQuotaApi(this._dio,
      {String baseUrl = 'https://api.wawatair.com/api/v1'})
      : _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  /// PUBLIC — plan pricing for the plan-selection screen.
  Future<QuotaPricingResponse> getPricing() async {
    final response =
        await _dio.get<Map<String, dynamic>>('$_baseUrl/listing-quota/pricing');
    return QuotaPricingResponse.fromJson(response.data ?? const {});
  }

  /// Creates a `pending_payment` order.
  Future<QuotaOrderResponse> createOrder({
    required String type, // trip | shipment_post
    required int extraListings, // 1 | 3 | 5
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/listing-quota/orders',
      data: {'type': type, 'extra_listings': extraListings},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return QuotaOrderResponse.fromJson(response.data ?? const {});
  }

  /// Pays an order. [mockOutcome] (success|failure|pending) drives the mock
  /// result; omit to use the server default. Reuse the SAME [idempotencyKey]
  /// across retries of one order so re-tapping never double-charges.
  Future<QuotaOrderResponse> payOrder(
    String orderId, {
    required String method, // card | balance
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

  /// Single order (receipt data). Owner-only (403 otherwise).
  Future<QuotaOrderResponse> getOrder(String orderId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('$_baseUrl/listing-quota/orders/$orderId');
    return QuotaOrderResponse.fromJson(response.data ?? const {});
  }
}
