import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'iap_catalog.dart';

const String kPurchasesBaseUrl = 'https://api.wawatair.com/api/v1';
const String kPurchaseCatalogEndpoint = '$kPurchasesBaseUrl/purchases/catalog';

abstract class IapCatalogLoader {
  Future<List<IapCatalogProduct>> load();
}

/// Authenticated catalogue loader used by the production application.
class BackendIapCatalogLoader implements IapCatalogLoader {
  const BackendIapCatalogLoader(
    this._dio, {
    this.endpoint = kPurchaseCatalogEndpoint,
  });

  final Dio _dio;
  final String endpoint;

  @override
  Future<List<IapCatalogProduct>> load() async {
    final response = await _dio.get<Map<String, dynamic>>(endpoint);
    return parseIapCatalog(response.data ?? const <String, dynamic>{});
  }
}

/// Local catalogue for the standalone StoreKit development entry point.
class DevIapCatalogLoader implements IapCatalogLoader {
  const DevIapCatalogLoader();

  @override
  Future<List<IapCatalogProduct>> load() async => kDevIapProducts;
}

/// Server-side receipt/token verification and promotion activation seam.
abstract class PurchaseValidator {
  Future<PurchaseValidationResult> validate(
    PurchaseDetails purchase, {
    required String orderId,
  });
}

class PurchaseValidationResult {
  const PurchaseValidationResult({required this.ok, required this.activated});

  final bool ok;
  final bool activated;
}

/// Temporary validator for StoreKit/Play Billing development builds only.
class DevPurchaseValidator implements PurchaseValidator {
  const DevPurchaseValidator();

  @override
  Future<PurchaseValidationResult> validate(
    PurchaseDetails purchase, {
    required String orderId,
  }) async {
    debugPrint(
      '[IAP] DEV validate productID=${purchase.productID} '
      'status=${purchase.status} '
      'orderId=$orderId '
      'hasToken=${purchase.verificationData.serverVerificationData.isNotEmpty}',
    );
    return const PurchaseValidationResult(ok: true, activated: true);
  }
}

/// Store product ids for the paid "increase listing limit" packs. These route
/// to the quota endpoint; every other product (VIP / boost) is a promotion.
@visibleForTesting
bool isQuotaProduct(String productId) =>
    productId.startsWith('wawat.app.quota');

/// The verification badge is a single per-user purchase (not an order), so its
/// receipt posts to the fixed `/verification/pay` endpoint.
@visibleForTesting
bool isVerificationProduct(String productId) =>
    productId.startsWith('wawat.app.verification');

/// The backend `/pay` path a store receipt must be posted to for [productId].
/// Quota packs → the listing-quota order endpoint; the verification badge →
/// the fixed verification endpoint; everything else (VIP/boost) → the
/// promotions endpoint. Getting this wrong is what stuck the quota spinner: a
/// quota receipt sent to `/promotions/{id}` 404s forever. Kept as a single
/// source of truth so [BackendPurchaseValidator.validate] and its test agree.
@visibleForTesting
String backendPayPath(String baseUrl, String productId, String orderId) {
  final id = Uri.encodeComponent(orderId);
  if (isVerificationProduct(productId)) {
    // Per-user badge, not an order → no id in the path.
    return '$baseUrl/verification/pay';
  }
  return isQuotaProduct(productId)
      ? '$baseUrl/listing-quota/orders/$id/pay'
      : '$baseUrl/promotions/$id/pay';
}

/// Sends the platform proof to the authenticated Wawatair backend.
///
/// The backend must verify it directly with Apple/Google, make activation
/// idempotent, and return `{ok: true, activated: true}` only after delivery.
///
/// One shared instance handles every product. The endpoint is derived from the
/// product family, NOT from a mutable "which screen is open" swap: StoreKit can
/// redeliver a transaction at any moment — notably at startup via
/// [IapService.recoverUnfinishedPurchases], and interleaved with other
/// products — so a global validator swap used to send quota receipts to
/// `/promotions/{id}/pay` and 404 (order not found), leaving the buy button
/// spinning forever. Routing by product removes that race entirely.
class BackendPurchaseValidator implements PurchaseValidator {
  const BackendPurchaseValidator(this._dio, {this.baseUrl = kPurchasesBaseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<PurchaseValidationResult> validate(
    PurchaseDetails purchase, {
    required String orderId,
  }) async {
    final method = Platform.isIOS
        ? 'apple'
        : Platform.isAndroid
        ? 'google'
        : 'unsupported';
    if (method == 'unsupported') {
      return const PurchaseValidationResult(ok: false, activated: false);
    }

    final proof = purchase.verificationData.serverVerificationData;
    if (proof.isEmpty || orderId.trim().isEmpty) {
      return const PurchaseValidationResult(ok: false, activated: false);
    }

    final path = backendPayPath(baseUrl, purchase.productID, orderId);

    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: <String, dynamic>{
        'method': method,
        if (Platform.isAndroid) 'purchase_token': proof,
        if (Platform.isIOS) 'receipt': proof,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final nested = body['data'];
    final result = nested is Map
        ? Map<String, dynamic>.from(nested)
        : Map<String, dynamic>.from(body);
    return PurchaseValidationResult(
      // Dio throws for 403/422/503. Reaching this line means the backend
      // returned HTTP 200 and the store transaction may be finished.
      ok: response.statusCode == 200,
      activated: result['activated'] == true || result['status'] == 'paid',
    );
  }
}

enum IapOutcome { purchased, restored, canceled, error, pending }

class IapResult {
  const IapResult(
    this.outcome, {
    this.productId,
    this.message,
    this.activated,
    this.code,
    this.orderId,
  });

  final IapOutcome outcome;
  final String? productId;
  final String? message;
  final bool? activated;

  /// Machine-readable error code from the backend envelope ({message, code}),
  /// so a screen can branch on the real reason instead of guessing from text.
  final String? code;

  /// The pending order this result was validated against. A success recovered
  /// from a lingering transaction must only be honored by the caller when it
  /// matches the order the caller is paying for — otherwise a leftover purchase
  /// from a previous attempt would jump straight to a success screen for the
  /// wrong order while the real charge is still being made.
  final String? orderId;

  bool get isSuccess =>
      outcome == IapOutcome.purchased || outcome == IapOutcome.restored;
}

/// The backend answers errors as `{message, code}` and the message is already
/// localized server-side. Surfacing it tells the user what actually went wrong
/// — a 409 "already redeemed" and a 503 "store unreachable" are very different
/// — instead of collapsing every failure into one generic line.
({String? message, String? code}) backendError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString().trim();
      final code = data['code']?.toString().trim();
      return (
        message: (message == null || message.isEmpty) ? null : message,
        code: (code == null || code.isEmpty) ? null : code,
      );
    }
  }
  return (message: null, code: null);
}

class IapService {
  IapService._();

  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier<List<ProductDetails>>(const []);
  final ValueNotifier<List<IapCatalogProduct>> catalogProducts =
      ValueNotifier<List<IapCatalogProduct>>(const []);
  final ValueNotifier<IapResult?> lastResult = ValueNotifier<IapResult?>(null);
  final ValueNotifier<String?> purchasing = ValueNotifier<String?>(null);

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  PurchaseValidator _validator = const DevPurchaseValidator();
  IapCatalogLoader _catalogLoader = const DevIapCatalogLoader();
  Future<void>? _initializing;
  Completer<IapResult>? _activePurchase;
  String? _activeProductId;
  String? _activeOrderId;
  // True only once we have committed to an attempt whose verdict the user is
  // waiting on (a launched `buyConsumable`, or a deliberate redelivery of an
  // unfinished purchase). StoreKit 1 replays previously-abandoned transactions
  // on the purchase stream; those must NOT be surfaced as "payment failed" —
  // that flashes a red error over a just-starting or unrelated purchase. This
  // flag lets `_emit` tell a real failure from a stale replay.
  bool _attemptAwaitingResult = false;
  final Set<String> _processingTransactions = <String>{};
  // Transactions fully delivered+finished during THIS app session. StoreKit 1
  // can replay the same transaction more than once (reconcile + the stream's
  // first-subscription replay). Re-validating it would credit whatever order is
  // active NOW — so a leftover purchase from a previous attempt would complete
  // the fresh attempt (success screen) before the user's real payment finishes.
  // Never process a transaction we already finished.
  final Set<String> _finishedTxnIds = <String>{};
  // StoreKit transaction identifiers present in the queue just before the
  // current `buyConsumable` launched. Any purchased transaction in this set is a
  // REPLAY of an older purchase, not the charge the user is making now, so it
  // must be validated against its OWN saved order (or drained) — never against
  // the freshly-created active order.
  Set<String> _preLaunchTxnIds = <String>{};
  final Map<String, PurchaseDetails> _unfinishedPurchases =
      <String, PurchaseDetails>{};
  final Map<String, IapResult> _latestResultsByProduct = <String, IapResult>{};

  static const String _pendingOrderKeyPrefix = 'iap.pending_order.';

  bool _available = false;
  bool get isAvailable => _available;

  List<String> notFoundIds = const [];

  void useValidator(PurchaseValidator validator) => _validator = validator;

  /// Current validator — lets a flow temporarily swap in its own (e.g. the
  /// listing-quota endpoint) and restore this afterwards.
  PurchaseValidator get validator => _validator;

  void useCatalogLoader(IapCatalogLoader loader) => _catalogLoader = loader;

  /// Starts the cross-platform billing client and retries unfinished purchases.
  ///
  /// Android may report Billing as unavailable while Play Store is still
  /// connecting. Do not permanently cache that negative result: an explicit
  /// product refresh must be able to establish a fresh connection.
  Future<void> init({bool retryIfUnavailable = false}) async {
    var current = _initializing;
    if (current != null) {
      await current;
      if (_available || !retryIfUnavailable) return;

      // Only the first caller that observed this completed attempt starts the
      // retry. Concurrent callers wait for the new attempt instead.
      if (identical(_initializing, current)) {
        _initializing = null;
      } else {
        await _initializing;
        return;
      }
    }

    current = _initializing;
    if (current == null) {
      current = _initialize();
      _initializing = current;
    }
    await current;
  }

  Future<void> _initialize() async {
    // Force StoreKit 1 on iOS. The plugin defaults to StoreKit 2 on iOS 15+,
    // where `serverVerificationData` is a JWS transaction the backend cannot
    // consume; under StoreKit 1 it is the base64 app receipt the backend
    // verifies via verifyReceipt (with the sandbox 21007 fallback for
    // TestFlight). Must run before purchaseStream is first read, since the
    // stream getter branches on the active StoreKit version.
    if (Platform.isIOS) {
      try {
        await InAppPurchaseStoreKitPlatform.enableStoreKit1();
        // enableStoreKit1() only flips the static `_useStoreKit2` flag. The
        // SK1 transaction observer that `purchaseStream` reads is created in
        // registerPlatform(), which already ran once at startup under the
        // default SK2 path — so `_sk1transactionObserver` was left
        // uninitialised and reading purchaseStream now throws a
        // LateInitializationError, which blows up init() and stops the store
        // from ever being queried (prices show 0 / "store unavailable").
        // The plugin documents "call enableStoreKit1 before registerPlatform";
        // re-run registration now, with the flag flipped, to build the SK1
        // stream before purchaseStream is read below.
        InAppPurchaseStoreKitPlatform.registerPlatform();
        debugPrint('[IAP] forced StoreKit 1 on iOS');
      } catch (error) {
        debugPrint('[IAP] enableStoreKit1 failed: $error');
      }
    }
    // Keep the whole billing bring-up inside one guard: a throw here (a bad
    // purchaseStream, an isAvailable() failure) must leave the store simply
    // unavailable, never reject init() — a rejected init blanks every price
    // screen because loadProducts never reaches queryProductDetails.
    try {
      // iOS: clear failed/canceled transactions left in the StoreKit queue by a
      // previous attempt BEFORE subscribing. StoreKit 1 replays every unfinished
      // transaction to a fresh purchaseStream subscriber, so a stale failure
      // would otherwise arrive as an `error` the instant the user taps pay —
      // flashing "Ödəniş alınmadı" right before (or over) the real purchase
      // sheet. Purchased/restored transactions are left in place: they are money
      // the user paid and must still be delivered after we subscribe.
      if (_subscription == null) {
        await _drainFailedStoreKitTransactions();
      }
      _subscription ??= _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: _onStreamError,
      );
      _available = await _iap.isAvailable();
      debugPrint('[IAP] init available=$_available');
      if (_available) await recoverUnfinishedPurchases();
    } catch (error, stack) {
      _available = false;
      debugPrint('[IAP] init error: $error\n$stack');
    }
  }

  /// iOS only. Finish (drop) every failed/canceled transaction sitting in the
  /// StoreKit 1 payment queue, low-level, so they are gone before the plugin's
  /// purchaseStream subscription replays them. A failed transaction carries no
  /// receipt and nothing to deliver — the only thing it can do if left is block
  /// the next `buyConsumable` (`storekit_duplicate_product_object`) and surface
  /// a spurious "payment failed". Purchased/restored transactions are NOT
  /// touched here; those are honored through the normal update path.
  Future<void> _drainFailedStoreKitTransactions() async {
    if (!Platform.isIOS) return;
    try {
      final queue = SKPaymentQueueWrapper();
      final all = await queue.transactions();
      var drained = 0;
      for (final transaction in all) {
        if (transaction.transactionState ==
            SKPaymentTransactionStateWrapper.failed) {
          try {
            await queue.finishTransaction(transaction);
            drained++;
          } catch (error) {
            debugPrint('[IAP] drain failed transaction error: $error');
          }
        }
      }
      if (drained > 0) {
        debugPrint('[IAP] drained $drained stale failed transaction(s)');
      }
    } catch (error) {
      debugPrint('[IAP] drain failed transactions error: $error');
    }
  }

  /// iOS only. Transaction identifiers currently sitting in the StoreKit 1
  /// payment queue. Snapshotting these right before `buyConsumable` lets us tell
  /// the charge the user is making now (a brand-new transaction, absent here)
  /// from a leftover purchase StoreKit is replaying (present here) — the latter
  /// must never credit the freshly-created order.
  Future<Set<String>> _currentStoreKitTxnIds() async {
    if (!Platform.isIOS) return <String>{};
    try {
      final queue = SKPaymentQueueWrapper();
      final all = await queue.transactions();
      return all
          .map((t) => t.transactionIdentifier)
          .whereType<String>()
          .toSet();
    } catch (error) {
      debugPrint('[IAP] snapshot transactions error: $error');
      return <String>{};
    }
  }

  /// Google Play exposes unconsumed one-time purchases explicitly. StoreKit
  /// replays unfinished transactions automatically as soon as purchaseStream
  /// is subscribed, including after an app restart.
  Future<void> recoverUnfinishedPurchases() async {
    if (!_available || !Platform.isAndroid) return;
    try {
      final addition = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases();
      if (response.error != null) {
        debugPrint('[IAP] queryPastPurchases error: ${response.error}');
      }
      if (response.pastPurchases.isNotEmpty) {
        await _onPurchaseUpdates(response.pastPurchases);
      }
    } catch (error) {
      debugPrint('[IAP] unfinished purchase recovery error: $error');
    }
  }

  /// iOS only. StoreKit 1 keeps every transaction in the payment queue until it
  /// is explicitly finished. A prior attempt that ended without a finish — a
  /// user cancel, an error, or a purchase whose delivery update was missed —
  /// stays in the queue, and the NEXT `buyConsumable` for the SAME product then
  /// throws `storekit_duplicate_product_object` ("There is a pending
  /// transaction for the same product identifier"), which is exactly what
  /// blocked re-buying `wawat.app.vip.1d`.
  ///
  /// Reconcile those lingering transactions through the normal update path
  /// [_onPurchaseUpdates]: a `failed`/`canceled` one is finished (dropped), a
  /// `purchased`/`restored` one is validated, delivered and finished (backend
  /// activation is idempotent, so an already-delivered purchase is honored, not
  /// double-charged). A `purchasing`/`deferred` transaction cannot be finished
  /// (StoreKit throws) so it is left for the live stream.
  ///
  /// Returns true when at least one finishable transaction was reconciled, so
  /// the caller can safely retry the charge.
  Future<bool> _reconcileStoreKitQueue(String productId) async {
    if (!Platform.isIOS) return false;
    try {
      final queue = SKPaymentQueueWrapper();
      final all = await queue.transactions();
      final toDeliver = <SKPaymentTransactionWrapper>[];
      var handled = false;
      for (final transaction in all) {
        if (transaction.payment.productIdentifier != productId) continue;
        final state = transaction.transactionState;
        if (state == SKPaymentTransactionStateWrapper.failed) {
          // A canceled/errored attempt: finish it directly and silently so it
          // stops blocking the queue. Routing it through _onPurchaseUpdates
          // would _emit a "canceled" that could complete the fresh purchase's
          // completer — so finish low-level instead, with no UI result.
          try {
            await queue.finishTransaction(transaction);
            handled = true;
          } catch (error) {
            debugPrint('[IAP] finish failed transaction error: $error');
          }
        } else if (state == SKPaymentTransactionStateWrapper.purchased ||
            state == SKPaymentTransactionStateWrapper.restored) {
          // A real purchase whose delivery/finish was missed — honor it.
          toDeliver.add(transaction);
        }
        // purchasing / deferred / unspecified: cannot be finished (StoreKit
        // throws); leave them for the live stream.
      }
      if (toDeliver.isNotEmpty) {
        var receipt = '';
        try {
          receipt = await SKReceiptManager.retrieveReceiptData();
        } catch (_) {
          // Server validation of a purchased transaction needs the receipt; a
          // missing one just leaves it unfinished for the stream to retry.
        }
        final details = toDeliver
            .map(
              (transaction) => AppStorePurchaseDetails.fromSKTransaction(
                transaction,
                receipt,
              ),
            )
            .toList();
        debugPrint(
          '[IAP] delivering ${details.length} lingering purchased '
          'transaction(s) for $productId',
        );
        await _onPurchaseUpdates(details);
        handled = true;
      }
      return handled;
    } catch (error) {
      debugPrint('[IAP] StoreKit queue reconcile error: $error');
      return false;
    }
  }

  Future<List<IapCatalogProduct>> loadCatalog({bool force = false}) async {
    if (!force && catalogProducts.value.isNotEmpty) {
      return catalogProducts.value;
    }
    final loaded = await _catalogLoader.load();
    catalogProducts.value = loaded;
    return loaded;
  }

  Future<List<ProductDetails>> loadProducts({
    bool forceCatalog = false,
    Set<IapProductKind>? kinds,
  }) async {
    // The backend catalogue is useful even when the device cannot currently
    // connect to Play Billing (for example while Play Store is starting).
    // Loading it first also lets the UI render the package list instead of
    // replacing the entire section with a generic error.
    final catalog = await loadCatalog(force: forceCatalog);
    final requestedCatalog = kinds == null
        ? catalog
        : catalog.where((product) => kinds.contains(product.kind)).toList();

    await init(retryIfUnavailable: forceCatalog);
    if (!_available && Platform.isAndroid && forceCatalog) {
      // Play Billing can still be connecting immediately after app startup.
      for (var attempt = 0; attempt < 2 && !_available; attempt++) {
        await Future<void>.delayed(Duration(milliseconds: 600 + attempt * 600));
        await init(retryIfUnavailable: true);
      }
    }
    if (!_available) {
      products.value = const [];
      notFoundIds = const [];
      debugPrint(
        '[IAP] store unavailable on ${Platform.operatingSystem}; '
        'catalog products=${requestedCatalog.length}',
      );
      return const [];
    }

    final productIds = requestedCatalog
        .map((product) => product.productId)
        .toSet();
    if (productIds.isEmpty) {
      products.value = const [];
      notFoundIds = const [];
      return const [];
    }

    var response = await _iap.queryProductDetails(productIds);
    if (Platform.isAndroid && forceCatalog && response.productDetails.isEmpty) {
      // A connected Play client may need one more round-trip after a freshly
      // installed internal-test build or after Play Store cache refresh.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      response = await _iap.queryProductDetails(productIds);
    }
    if (response.error != null) {
      debugPrint('[IAP] queryProductDetails error: ${response.error}');
    }
    notFoundIds = response.notFoundIDs;
    if (notFoundIds.isNotEmpty) {
      debugPrint('[IAP] products not found: $notFoundIds');
    }

    final order = requestedCatalog.map((product) => product.productId).toList();
    final loaded = <ProductDetails>[...response.productDetails]
      ..sort(
        (left, right) =>
            order.indexOf(left.id).compareTo(order.indexOf(right.id)),
      );
    products.value = loaded;
    return loaded;
  }

  ProductDetails? productDetailsFor(String productId) {
    for (final product in products.value) {
      if (product.id == productId) return product;
    }
    return null;
  }

  IapCatalogProduct? catalogProductFor(String productId) {
    for (final product in catalogProducts.value) {
      if (product.productId == productId) return product;
    }
    return null;
  }

  IapCatalogProduct? productForPromotion({
    required String promotionType,
    int? durationDays,
    String? boostPackage,
  }) {
    return iapProductForPromotion(
      catalogProducts.value,
      promotionType: promotionType,
      durationDays: durationDays,
      boostPackage: boostPackage,
    );
  }

  /// Starts a consumable purchase and resolves on the first actionable result:
  /// purchased / restored / canceled / error, or `pending` only for a deferred
  /// payment ([isDeferredPending]) — never for StoreKit's "sheet is opening".
  Future<IapResult> purchase(
    String productId, {
    required String orderId,
  }) async {
    if (orderId.trim().isEmpty) {
      return IapResult(
        IapOutcome.error,
        productId: productId,
        message: 'missing pending order id',
      );
    }
    // init() can itself redeliver an unconsumed transaction. Clear only this
    // product's previous result so we can distinguish that recovery from an
    // old UI error and avoid launching a second charge after successful
    // server verification.
    _latestResultsByProduct.remove(productId);
    lastResult.value = null;
    await init();
    // Reconcile the local marker with purchases actually owned by Google Play
    // before deciding that this product is still tied to an older order.
    // A launch failure can otherwise leave a marker that blocks every retry.
    await recoverUnfinishedPurchases();
    final recoveredResult = _latestResultsByProduct[productId];
    // Honor a recovered purchase only when it belongs to THIS order (don't
    // double-charge). A leftover success for a different/previous order must not
    // short-circuit into a success screen for the wrong order — drop it and let
    // the fresh charge proceed.
    if (recoveredResult != null &&
        recoveredResult.isSuccess &&
        recoveredResult.orderId == orderId) {
      return recoveredResult;
    }
    if (recoveredResult != null) {
      _latestResultsByProduct.remove(productId);
      lastResult.value = null;
    }
    // iOS: drain any transaction left in the StoreKit queue by an earlier
    // attempt BEFORE charging again, so this buy can't hit
    // `storekit_duplicate_product_object`. An already-delivered purchase found
    // here is honored (return it, don't charge twice); a cleared failed/canceled
    // one must not block the fresh buy, so drop its result and continue.
    if (Platform.isIOS) {
      await _reconcileStoreKitQueue(productId);
      final reconciled = _latestResultsByProduct[productId];
      // Same rule as above: an already-delivered purchase is honored only when
      // it is THIS order's. A leftover for another order is dropped so the fresh
      // buy runs and the success screen matches what the user just paid for.
      if (reconciled != null &&
          reconciled.isSuccess &&
          reconciled.orderId == orderId) {
        return reconciled;
      }
      if (reconciled != null) {
        _latestResultsByProduct.remove(productId);
        lastResult.value = null;
      }
    }
    var savedOrderId = await _pendingOrderId(productId);
    if (savedOrderId != null) {
      final unfinished = _unfinishedPurchases[productId];
      if (unfinished == null) {
        debugPrint(
          '[IAP] clearing stale pending order product=$productId '
          'order=$savedOrderId',
        );
        await _forgetPendingOrder(productId);
        savedOrderId = null;
      } else if (savedOrderId != orderId) {
        return IapResult(
          IapOutcome.error,
          productId: productId,
          message: 'unfinished_purchase_for_previous_order',
        );
      } else {
        final completer = Completer<IapResult>();
        _activePurchase = completer;
        _activeProductId = productId;
        _activeOrderId = orderId;
        // A deliberate redelivery the user is waiting on: its verdict (even a
        // failure) must reach the completer, so mark the attempt live. This
        // purchase IS the one whose order we are recovering, so it must never be
        // treated as a stale pre-launch replay.
        _attemptAwaitingResult = true;
        _preLaunchTxnIds = <String>{};
        await _validateDeliverAndFinish(unfinished);
        return completer.future;
      }
    }
    var product = productDetailsFor(productId);
    if (product == null) {
      await loadProducts();
      product = productDetailsFor(productId);
    }
    if (product == null) {
      return IapResult(
        IapOutcome.error,
        productId: productId,
        message: 'store product not found',
      );
    }
    // A previous attempt on THIS product can get stuck with no terminal
    // update (e.g. the App Store sign-in sheet never surfaces because the
    // sandbox account is not authenticated), which would otherwise latch the
    // buy button forever on "another purchase is already pending". Let the
    // user re-tap the same product to supersede that stale attempt; only a
    // genuinely different in-flight product still blocks.
    final bool retryingSameProduct = _activeProductId == productId;
    if ((purchasing.value != null || _activePurchase != null) &&
        !retryingSameProduct) {
      return IapResult(
        IapOutcome.error,
        productId: productId,
        message: 'another purchase is already pending',
      );
    }
    if (retryingSameProduct) {
      final stale = _activePurchase;
      if (stale != null && !stale.isCompleted) {
        stale.complete(
          IapResult(
            IapOutcome.canceled,
            productId: productId,
            message: 'superseded by retry',
          ),
        );
      }
      _activePurchase = null;
      _activeProductId = null;
      _activeOrderId = null;
      _attemptAwaitingResult = false;
      purchasing.value = null;
    }

    final completer = Completer<IapResult>();
    await _rememberPendingOrder(productId, orderId);
    _activePurchase = completer;
    _activeProductId = productId;
    _activeOrderId = orderId;
    // Not "awaiting" until buyConsumable actually launches: a stale transaction
    // StoreKit replays in this narrow window is a leftover, not this attempt's
    // result, and must be dropped rather than shown as a failure.
    _attemptAwaitingResult = false;
    await _startPurchase(product);
    return completer.future;
  }

  /// Fire-and-observe entry used by the development catalogue screen.
  Future<void> buy(ProductDetails product) {
    _activeProductId = product.id;
    _activeOrderId = 'dev-${DateTime.now().microsecondsSinceEpoch}';
    return _startPurchase(product);
  }

  Future<void> _startPurchase(
    ProductDetails product, {
    bool isRetry = false,
  }) async {
    if (purchasing.value != null) return;
    purchasing.value = product.id;
    // From here on any terminal update for this product IS this attempt's
    // result (including a launch failure just below), so let _emit surface it.
    _activeProductId ??= product.id;
    _attemptAwaitingResult = true;
    // Snapshot the queue so a purchase StoreKit replays from a previous attempt
    // (present here) is not mistaken for the charge this buyConsumable is about
    // to create (absent here). Only on the first launch — a retry re-uses the
    // same snapshot so the transaction it is recovering stays recognised.
    if (!isRetry) {
      _preLaunchTxnIds = await _currentStoreKitTxnIds();
    }
    try {
      final launched = await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
        // Validate first, then consume manually. Auto-consume would lose the
        // retryable Play token if the backend were temporarily unavailable.
        autoConsume: !Platform.isAndroid,
      );
      if (!launched) {
        await _forgetPendingOrder(product.id);
        _emit(
          IapResult(
            IapOutcome.error,
            productId: product.id,
            message: 'purchase was not started',
          ),
        );
      }
    } catch (error) {
      // A leftover transaction for the same product is still in the StoreKit
      // queue (a just-canceled/errored attempt, or a delivery whose finish was
      // missed): the next buyConsumable throws `storekit_duplicate_product_object`.
      // Clear the queue and retry the charge ONCE — the user must never see the
      // raw PlatformException. Keep the pending order saved so the retry can
      // still validate; only forget it on a real failure below.
      if (isDuplicateTransactionError(error) && !isRetry) {
        purchasing.value = null;
        await _reconcileStoreKitQueue(product.id);
        // Reconcile may have already delivered this product's real purchase.
        final reconciled = _latestResultsByProduct[product.id];
        if (reconciled != null && reconciled.isSuccess) return;
        debugPrint(
          '[IAP] cleared duplicate transaction; retrying ${product.id}',
        );
        await _startPurchase(product, isRetry: true);
        return;
      }
      await _forgetPendingOrder(product.id);
      // Retry still blocked (e.g. a stuck `purchasing` transaction that cannot be
      // finished). Never surface the raw error — report a soft, retryable state;
      // StoreKit replays the transaction on the purchaseStream where it resolves.
      if (isDuplicateTransactionError(error)) {
        debugPrint(
          '[IAP] duplicate transaction persists for ${product.id}; '
          'it will be finished via the purchase stream',
        );
        _emit(
          IapResult(
            IapOutcome.error,
            productId: product.id,
            message: 'previous transaction still pending',
          ),
        );
        return;
      }
      final canceled = isIapCancellationError(error);
      debugPrint('[IAP] buy ${canceled ? 'canceled' : 'error'}: $error');
      _emit(
        IapResult(
          canceled ? IapOutcome.canceled : IapOutcome.error,
          productId: product.id,
          message: canceled ? null : '$error',
        ),
      );
    }
  }

  /// Store restore entry retained for platform compliance and the dev screen.
  Future<void> restore() async {
    await init();
    await _iap.restorePurchases();
    await recoverUnfinishedPurchases();
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    debugPrint('[IAP] purchase stream error: $error');
    // Defensive: if a duplicate-transaction error arrives via the stream rather
    // than as a throw from buyConsumable, drain the queue and report a soft,
    // retryable state — never the raw `storekit_duplicate_product_object`.
    if (isDuplicateTransactionError(error)) {
      final productId = _activeProductId;
      if (productId != null) {
        unawaited(_reconcileStoreKitQueue(productId));
      }
      _emit(
        IapResult(
          IapOutcome.error,
          productId: productId,
          message: 'previous transaction still pending',
        ),
      );
      return;
    }
    final canceled = isIapCancellationError(error);
    _emit(
      IapResult(
        canceled ? IapOutcome.canceled : IapOutcome.error,
        productId: _activeProductId,
        message: canceled ? null : '$error',
      ),
    );
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (catalogProducts.value.isNotEmpty &&
          catalogProductFor(purchase.productID) == null) {
        debugPrint(
          '[IAP] store redelivered a product absent from catalogue: '
          '${purchase.productID}',
        );
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (isDeferredPending(purchase, isAndroid: Platform.isAndroid)) {
            _emit(IapResult(IapOutcome.pending, productId: purchase.productID));
          } else if (_activeProductId == purchase.productID) {
            // StoreKit 1 queued the payment; the Apple sheet is only opening.
            // Not a verdict: the caller keeps waiting (spinner) and the active
            // order stays bound until purchased / canceled / error arrives.
            purchasing.value = purchase.productID;
          }
          break;
        case PurchaseStatus.canceled:
          _unfinishedPurchases.remove(purchase.productID);
          await _forgetPendingOrder(purchase.productID);
          // StoreKit 1 keeps a canceled/failed transaction in the payment queue
          // until it is finished. Leaving it there makes the NEXT buyConsumable
          // for the same product throw `storekit_duplicate_product_object`, so
          // the user's second attempt fails. Finish it now.
          await _finishIfPending(purchase);
          _emit(IapResult(IapOutcome.canceled, productId: purchase.productID));
          break;
        case PurchaseStatus.error:
          _unfinishedPurchases.remove(purchase.productID);
          await _forgetPendingOrder(purchase.productID);
          await _finishIfPending(purchase);
          _emit(
            IapResult(
              IapOutcome.error,
              productId: purchase.productID,
              message: purchase.error?.message,
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _validateDeliverAndFinish(purchase);
          break;
      }
    }
  }

  Future<void> _validateDeliverAndFinish(PurchaseDetails purchase) async {
    final transactionKey =
        purchase.purchaseID ??
        '${purchase.productID}:${purchase.verificationData.serverVerificationData}';
    // Already delivered+finished this session. StoreKit 1 replays the same
    // transaction (reconcile + first-subscription replay); re-validating it would
    // credit whatever order is active NOW. Just finish it again and stop.
    if (_finishedTxnIds.contains(transactionKey)) {
      await _finishIfPending(purchase);
      return;
    }
    // A purchased/restored transaction that already existed in the queue before
    // the current buyConsumable launched is a REPLAY of a previous attempt, not
    // the charge the user is making now. Its own order was overwritten by the
    // fresh order, so re-crediting it would credit the NEW order — completing the
    // fresh attempt (blue success screen) before the real payment finishes, and
    // then double-charging when that payment lands. The backend is idempotent and
    // the source of truth, so draining it loses nothing: finish it and move on.
    final purchased =
        purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored;
    final isPreLaunchReplay =
        purchase.purchaseID != null &&
        _preLaunchTxnIds.contains(purchase.purchaseID);
    if (purchased && isPreLaunchReplay) {
      debugPrint(
        '[IAP] draining stale pre-launch purchase replay: '
        '${purchase.productID} txn=${purchase.purchaseID}',
      );
      await _finishIfPending(purchase);
      _finishedTxnIds.add(transactionKey);
      _unfinishedPurchases.remove(purchase.productID);
      return;
    }

    _unfinishedPurchases[purchase.productID] = purchase;
    if (!_processingTransactions.add(transactionKey)) return;

    try {
      final orderId = _activeProductId == purchase.productID
          ? _activeOrderId
          : await _pendingOrderId(purchase.productID);
      if (orderId == null || orderId.isEmpty) {
        _emit(
          IapResult(
            IapOutcome.error,
            productId: purchase.productID,
            message: 'pending order id is missing',
          ),
        );
        return;
      }

      final validation = await _validator.validate(purchase, orderId: orderId);
      if (!validation.ok) {
        _emit(
          IapResult(
            IapOutcome.error,
            productId: purchase.productID,
            message: 'purchase validation failed',
            orderId: orderId,
          ),
        );
        return;
      }

      if (Platform.isAndroid) {
        final addition = _iap
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final result = await addition.consumePurchase(purchase);
        if (result.responseCode != BillingResponse.ok) {
          throw StateError(
            'Google Play consume failed: ${result.debugMessage}',
          );
        }
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      _unfinishedPurchases.remove(purchase.productID);
      await _forgetPendingOrder(purchase.productID);
      _finishedTxnIds.add(transactionKey);

      _emit(
        IapResult(
          purchase.status == PurchaseStatus.restored
              ? IapOutcome.restored
              : IapOutcome.purchased,
          productId: purchase.productID,
          activated: validation.activated,
          orderId: orderId,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[IAP] validation/completion error: $error\n$stackTrace');
      final backend = backendError(error);
      // Two failures are permanent for THIS transaction, so the queue must drain:
      //  * 404 — the backend has no such order (expired / deleted / never created).
      //  * PURCHASE_NO_NEW_TRANSACTION — every transaction this receipt carries was
      //    already redeemed. StoreKit 1 keeps redelivering an unfinished
      //    transaction, so leaving it here means the same dead transaction is
      //    re-sent forever and a fresh purchase can never be created.
      // Every other failure (network, 5xx) is transient: leave the transaction
      // unfinished so the store can redeliver it after recovery.
      final permanentlyGone =
          (error is DioException && error.response?.statusCode == 404) ||
          backend.code == 'PURCHASE_NO_NEW_TRANSACTION';
      if (permanentlyGone) {
        _unfinishedPurchases.remove(purchase.productID);
        await _forgetPendingOrder(purchase.productID);
        _finishedTxnIds.add(transactionKey);
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (_) {}
        }
      }
      // Prefer the backend's own (already localized) message over the raw
      // exception dump, so the user sees the real reason.
      _emit(
        IapResult(
          IapOutcome.error,
          productId: purchase.productID,
          message: backend.message ?? '$error',
          code: backend.code,
        ),
      );
    } finally {
      _processingTransactions.remove(transactionKey);
    }
  }

  /// Finish a non-successful transaction so StoreKit 1 removes it from the
  /// payment queue. A canceled/failed transaction left unfinished makes the
  /// next `buyConsumable` for the same product throw
  /// `storekit_duplicate_product_object`. Safe when nothing is pending.
  Future<void> _finishIfPending(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(purchase);
    } catch (error) {
      debugPrint('[IAP] cleanup completePurchase failed: $error');
    }
  }

  void _emit(IapResult result) {
    final belongsToActive = _activeProductId == result.productId;
    final isFailure =
        result.outcome == IapOutcome.error ||
        result.outcome == IapOutcome.canceled;
    // Drop a failure that no live attempt is waiting on: it is StoreKit
    // replaying a previously-abandoned transaction (already finished by
    // _onPurchaseUpdates). Surfacing it would flash "Ödəniş alınmadı" right as
    // the real purchase sheet opens, and would poison _latestResultsByProduct
    // so the next purchase() short-circuits into a false failure.
    if (isFailure && !(belongsToActive && _attemptAwaitingResult)) {
      purchasing.value = null;
      return;
    }

    lastResult.value = result;
    final productId = result.productId;
    if (productId != null) {
      _latestResultsByProduct[productId] = result;
    }
    final terminal = result.outcome != IapOutcome.pending;

    if (result.outcome == IapOutcome.pending || terminal) {
      purchasing.value = result.outcome == IapOutcome.pending
          ? result.productId
          : null;
    }

    // Only the attempt the user launched may complete the completer. A success
    // StoreKit replays before buyConsumable has launched (a leftover from a
    // previous order) is still recorded and finished above, but must NOT resolve
    // the fresh attempt's future — otherwise the caller jumps to a success
    // screen for the old order while the new charge is only just beginning.
    // A success must also be for the order the user is paying for right now.
    // StoreKit can hand us a delivered purchase for a DIFFERENT (older) order
    // while the fresh charge is still on screen; that must never resolve this
    // attempt's future into a premature success. Failures and pending updates
    // carry no order id, so they still surface normally.
    final matchesActiveOrder =
        result.orderId == null ||
        _activeOrderId == null ||
        result.orderId == _activeOrderId;
    final completesActiveAttempt =
        belongsToActive && _attemptAwaitingResult && matchesActiveOrder;
    final completer = _activePurchase;
    if (completer != null && completesActiveAttempt && !completer.isCompleted) {
      // A deferred payment (Play pending / Ask to Buy — never StoreKit's
      // "purchasing", see isDeferredPending) can last for hours; return control
      // to the UI while keeping the service subscribed for the final update,
      // which then finds its order via the saved pending-order marker.
      completer.complete(result);
      _activePurchase = null;
      _activeProductId = null;
      _activeOrderId = null;
      _attemptAwaitingResult = false;
    } else if (terminal && completesActiveAttempt) {
      _activePurchase = null;
      _activeProductId = null;
      _activeOrderId = null;
      _attemptAwaitingResult = false;
    }
  }

  Future<void> _rememberPendingOrder(String productId, String orderId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_pendingOrderKeyPrefix$productId', orderId);
  }

  Future<String?> _pendingOrderId(String productId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$_pendingOrderKeyPrefix$productId');
  }

  Future<void> _forgetPendingOrder(String productId) async {
    if (_activeProductId == productId &&
        (_activeOrderId?.startsWith('dev-') ?? false)) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_pendingOrderKeyPrefix$productId');
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _initializing = null;
    _activePurchase = null;
    _activeProductId = null;
    _activeOrderId = null;
    _attemptAwaitingResult = false;
    _processingTransactions.clear();
    _finishedTxnIds.clear();
    _preLaunchTxnIds = <String>{};
    _unfinishedPurchases.clear();
    _latestResultsByProduct.clear();
    catalogProducts.value = const [];
    products.value = const [];
    purchasing.value = null;
  }
}

/// Whether a `pending` update is a payment the user genuinely cannot finish
/// now — Google Play's pending (cash at a terminal, a slow bank) or StoreKit's
/// Ask to Buy (`deferred`). Only these hand control back to the screen, which
/// then says "payment is processing". StoreKit 1 also reports `purchasing` as
/// pending the moment the payment is queued, BEFORE the Apple sheet appears;
/// treating that as a verdict flashed "payment failed" before every charge.
@visibleForTesting
bool isDeferredPending(PurchaseDetails purchase, {required bool isAndroid}) {
  if (purchase.status != PurchaseStatus.pending) return false;
  if (purchase is AppStorePurchaseDetails) {
    return purchase.skPaymentTransaction.transactionState ==
        SKPaymentTransactionStateWrapper.deferred;
  }
  return isAndroid;
}

/// StoreKit 2 can report a user cancellation by throwing before the purchase
/// reaches [InAppPurchase.purchaseStream]. Google Play versions may use a
/// similar platform error. Treat these values as a normal cancellation, never
/// as an application failure that should be displayed to the user.
@visibleForTesting
bool isIapCancellationError(Object error) {
  final parts = <String>[
    if (error is PlatformException) error.code,
    if (error is PlatformException) error.message ?? '',
    if (error is PlatformException) '${error.details ?? ''}',
    '$error',
  ];
  final value = parts.join(' ').toLowerCase();
  return value.contains('storekit2_purchase_cancelled') ||
      value.contains('storekit2_purchase_canceled') ||
      value.contains('purchase_cancelled') ||
      value.contains('purchase_canceled') ||
      value.contains('user_cancelled') ||
      value.contains('user_canceled') ||
      value.contains('cancelled by the user') ||
      value.contains('canceled by the user');
}

/// StoreKit 1 throws `storekit_duplicate_product_object` when a previous
/// transaction for the same product is still unfinished in the payment queue.
/// It is transient: the pending transaction arrives on
/// [InAppPurchase.purchaseStream] and is finished there, so it must never reach
/// the user as a raw PlatformException.
@visibleForTesting
bool isDuplicateTransactionError(Object error) {
  final parts = <String>[
    if (error is PlatformException) error.code,
    if (error is PlatformException) error.message ?? '',
    '$error',
  ];
  final value = parts.join(' ').toLowerCase();
  return value.contains('storekit_duplicate_product_object') ||
      value.contains('pending transaction for the same product');
}
