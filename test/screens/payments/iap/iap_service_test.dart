import 'package:buking/screens/payments/iap/iap_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IAP cancellation detection', () {
    test('recognizes the StoreKit 2 cancellation thrown by TestFlight', () {
      final error = PlatformException(
        code: 'storekit2_purchase_cancelled',
        message: 'This transaction has been cancelled by the user',
      );

      expect(isIapCancellationError(error), isTrue);
    });

    test('does not hide a real store failure as a cancellation', () {
      final error = PlatformException(
        code: 'storekit2_purchase_failed',
        message: 'The product is unavailable',
      );

      expect(isIapCancellationError(error), isFalse);
    });
  });

  group('StoreKit duplicate-transaction detection', () {
    test('recognizes storekit_duplicate_product_object by code', () {
      final error = PlatformException(
        code: 'storekit_duplicate_product_object',
        message:
            'There is a pending transaction for the same product '
            'identifier. Please either wait for it to be finished or finish it '
            'manually using `completePurchase` to avoid edge cases.',
      );

      expect(isDuplicateTransactionError(error), isTrue);
      // A duplicate is not a user cancellation — the two must stay distinct.
      expect(isIapCancellationError(error), isFalse);
    });

    test('recognizes the duplicate by its message alone', () {
      final error = PlatformException(
        code: 'some_other_code',
        message:
            'There is a pending transaction for the same product '
            'identifier.',
      );

      expect(isDuplicateTransactionError(error), isTrue);
    });

    test('does not flag an unrelated store failure as a duplicate', () {
      final error = PlatformException(
        code: 'storekit2_purchase_failed',
        message: 'The product is unavailable',
      );

      expect(isDuplicateTransactionError(error), isFalse);
    });
  });

  group('Backend pay-path routing (quota vs promotion)', () {
    const base = 'https://api.wawatair.com/api/v1';

    test('quota packs classify as quota', () {
      expect(isQuotaProduct('wawat.app.quota.small'), isTrue);
      expect(isQuotaProduct('wawat.app.quota.medium'), isTrue);
      expect(isQuotaProduct('wawat.app.quota.large'), isTrue);
    });

    test('VIP and boost do not classify as quota', () {
      expect(isQuotaProduct('wawat.app.vip.1d'), isFalse);
      expect(isQuotaProduct('wawat.app.boost.small'), isFalse);
      expect(isQuotaProduct('wawat.app.verification'), isFalse);
    });

    test('a quota receipt routes to the listing-quota order endpoint', () {
      // This is the exact bug that stuck the spinner: a quota receipt sent to
      // /promotions/{id} 404s forever. It must hit the quota order endpoint.
      expect(
        backendPayPath(base, 'wawat.app.quota.medium', 'order-42'),
        '$base/listing-quota/orders/order-42/pay',
      );
    });

    test('a VIP/boost receipt routes to the promotions endpoint', () {
      expect(
        backendPayPath(base, 'wawat.app.vip.3d', 'promo-7'),
        '$base/promotions/promo-7/pay',
      );
      expect(
        backendPayPath(base, 'wawat.app.boost.large', 'promo-7'),
        '$base/promotions/promo-7/pay',
      );
    });

    test('the order id is percent-encoded in the path', () {
      expect(
        backendPayPath(base, 'wawat.app.quota.small', 'a/b c'),
        '$base/listing-quota/orders/a%2Fb%20c/pay',
      );
    });
  });
}
