import 'package:buking/screens/payments/iap/iap_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

const _productId = 'wawat.app.verification';

final _verificationData = PurchaseVerificationData(
  localVerificationData: '',
  serverVerificationData: '',
  source: 'test',
);

AppStorePurchaseDetails _storeKit(SKPaymentTransactionStateWrapper state) =>
    AppStorePurchaseDetails.fromSKTransaction(
      SKPaymentTransactionWrapper(
        payment: const SKPaymentWrapper(productIdentifier: _productId),
        transactionState: state,
      ),
      '',
    );

PurchaseDetails _play(PurchaseStatus status) => PurchaseDetails(
  productID: _productId,
  verificationData: _verificationData,
  transactionDate: null,
  status: status,
);

void main() {
  group('StoreKit 1 (iOS)', () {
    test('"purchasing" is pending but only means the sheet is opening', () {
      final purchase = _storeKit(SKPaymentTransactionStateWrapper.purchasing);

      expect(purchase.status, PurchaseStatus.pending);
      expect(isDeferredPending(purchase, isAndroid: false), isFalse);
    });

    test('Ask to Buy ("deferred") is a real deferred payment', () {
      final purchase = _storeKit(SKPaymentTransactionStateWrapper.deferred);

      expect(purchase.status, PurchaseStatus.pending);
      expect(isDeferredPending(purchase, isAndroid: false), isTrue);
    });

    test('a finished purchase is never pending', () {
      final purchase = _storeKit(SKPaymentTransactionStateWrapper.purchased);

      expect(isDeferredPending(purchase, isAndroid: false), isFalse);
    });
  });

  group('Google Play (Android)', () {
    test('pending is a real deferred payment (cash, slow bank)', () {
      expect(
        isDeferredPending(_play(PurchaseStatus.pending), isAndroid: true),
        isTrue,
      );
    });

    test('purchased / canceled / error are not pending', () {
      for (final status in [
        PurchaseStatus.purchased,
        PurchaseStatus.canceled,
        PurchaseStatus.error,
      ]) {
        expect(isDeferredPending(_play(status), isAndroid: true), isFalse);
      }
    });
  });

  test('a non-StoreKit pending on iOS keeps the caller waiting', () {
    expect(
      isDeferredPending(_play(PurchaseStatus.pending), isAndroid: false),
      isFalse,
    );
  });
}
