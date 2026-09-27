import 'package:buking/data/network/api/promotion_api.dart';
import 'package:buking/data/network/response/listing_response.dart';
import 'package:buking/data/network/response/promotion_response.dart';
import 'package:buking/data/network/response/receipt.dart';
import 'package:buking/screens/home/tabs/listings/promotion/promotion_screens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves `GET /promotions/{id}` from memory and counts the calls.
class _FakePromotionApi extends PromotionApi {
  _FakePromotionApi(this._response) : super(Dio());

  final Future<PromotionResponse> Function() _response;
  int calls = 0;

  @override
  Future<PromotionResponse> getPromotion(String promotionId) {
    calls++;
    return _response();
  }
}

final _activeVip = Promotion.fromJson(const {
  'id': 'promo-1',
  'listing_id': 'listing-1',
  'type': 'vip',
  'type_label': 'VİP',
  'status': 'active',
  'status_label': 'Aktiv',
  'duration_days': 3,
  'amount': 5,
});

Receipt _receipt({String title = 'VİP · 3 gün'}) => Receipt(
  kind: 'promotion',
  number: 'WA-12345678',
  title: title,
  amount: 5,
  currency: 'AZN',
  status: 'paid',
  isPaid: true,
  method: 'app_store',
  supportEmail: 'support@wawatair.com',
);

Future<void> _pumpStatus(
  WidgetTester tester,
  PromotionApi api, {
  Receipt? receipt,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PromotionStatusScreen(
        api: api,
        listing: Listing(id: 'listing-1', type: 'trip', status: 'active'),
        content: const {},
        initialPromotion: _activeVip,
        receipt: receipt,
        storePriceLabel: r'$4.99',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('status screen after a store purchase', () {
    testWidgets('receipt handed over → «Qəbz» at once, no extra request', (
      tester,
    ) async {
      final api = _FakePromotionApi(() async => throw StateError('unused'));
      await _pumpStatus(tester, api, receipt: _receipt());

      expect(find.text('Qəbz'), findsOneWidget);
      expect(api.calls, 0);
    });

    testWidgets('receipt missing → fetched by the screen, «Qəbz» appears', (
      tester,
    ) async {
      final api = _FakePromotionApi(
        () async => PromotionResponse(data: _activeVip, receipt: _receipt()),
      );
      await _pumpStatus(tester, api);

      expect(api.calls, 1);
      expect(find.text('Qəbz'), findsOneWidget);
    });

    testWidgets('receipt fetch fails → screen still works, just no «Qəbz»', (
      tester,
    ) async {
      final api = _FakePromotionApi(() async => throw Exception('offline'));
      await _pumpStatus(tester, api);

      expect(find.text('Qəbz'), findsNothing);
      expect(find.text('Elanıma bax'), findsOneWidget);
    });
  });
}
