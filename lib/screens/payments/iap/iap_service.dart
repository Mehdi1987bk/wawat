import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
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

/// The backend `/pay` path a store receipt must be posted to for [productId].
/// Quota packs → the listing-quota order endpoint; everything else (VIP/boost)
/// → the promotions endpoint. Getting this wrong is what stuck the quota
/// spinner: a quota receipt sent to `/promotions/{id}` 404s forever. Kept as a
/// single source of truth so [BackendPurchaseValidator.validate] and its test
/// agree.
@visibleForTesting
String backendPayPath(String baseUrl, String productId, String orderId) {
  final id = Uri.encodeComponent(orderId);
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
  const IapResult(this.outcome, {this.productId, this.message, this.activated});

  final IapOutcome outcome;
  final String? productId;
  final String? message;
  final bool? activated;

  bool get isSuccess =>
      outcome == IapOutcome.purchased || outcome == IapOutcome.restored;
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
  final Set<String> _processingTransactions = <String>{};
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

  /// Starts a consumable purchase and resolves on the first actionable result.
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
    if (recoveredResult != null) {
      return recoveredResult;
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
      purchasing.value = null;
    }

    final completer = Completer<IapResult>();
    await _rememberPendingOrder(productId, orderId);
    _activePurchase = completer;
    _activeProductId = productId;
    _activeOrderId = orderId;
    await _startPurchase(product);
    return completer.future;
  }

  /// Fire-and-observe entry used by the development catalogue screen.
  Future<void> buy(ProductDetails product) {
    _activeProductId = product.id;
    _activeOrderId = 'dev-${DateTime.now().microsecondsSinceEpoch}';
    return _startPurchase(product);
  }

  Future<void> _startPurchase(ProductDetails product) async {
    if (purchasing.value != null) return;
    purchasing.value = product.id;
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
      await _forgetPendingOrder(product.id);
      // A leftover transaction for the same product is still in the payment
      // queue (usually a just-canceled attempt whose finish is still in
      // flight). StoreKit replays it on the purchaseStream where the
      // canceled/error branch finishes it — never surface the raw
      // PlatformException; report a soft, retryable state instead.
      if (isDuplicateTransactionError(error)) {
        debugPrint(
          '[IAP] duplicate pending transaction for ${product.id}; '
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
          _emit(IapResult(IapOutcome.pending, productId: purchase.productID));
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
    _unfinishedPurchases[purchase.productID] = purchase;
    final transactionKey =
        purchase.purchaseID ??
        '${purchase.productID}:${purchase.verificationData.serverVerificationData}';
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

      _emit(
        IapResult(
          purchase.status == PurchaseStatus.restored
              ? IapOutcome.restored
              : IapOutcome.purchased,
          productId: purchase.productID,
          activated: validation.activated,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[IAP] validation/completion error: $error\n$stackTrace');
      // A 404 on the order-scoped /pay path means the backend has no such order
      // (expired / deleted / never created) — redelivery can never succeed and
      // would keep hijacking the stream and latching the buy button forever.
      // Finish it so the queue drains. Every other failure (network, 5xx) is
      // transient: leave the transaction unfinished so the store can redeliver
      // it after recovery.
      final permanentlyGone =
          error is DioException && error.response?.statusCode == 404;
      if (permanentlyGone) {
        _unfinishedPurchases.remove(purchase.productID);
        await _forgetPendingOrder(purchase.productID);
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (_) {}
        }
      }
      _emit(
        IapResult(
          IapOutcome.error,
          productId: purchase.productID,
          message: '$error',
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
    lastResult.value = result;
    final productId = result.productId;
    if (productId != null) {
      _latestResultsByProduct[productId] = result;
    }
    final terminal = result.outcome != IapOutcome.pending;
    final belongsToActive = _activeProductId == result.productId;

    if (result.outcome == IapOutcome.pending || terminal) {
      purchasing.value = result.outcome == IapOutcome.pending
          ? result.productId
          : null;
    }

    final completer = _activePurchase;
    if (completer != null && belongsToActive && !completer.isCompleted) {
      // Pending can last for hours on Google Play; return control to the UI
      // while keeping the service subscribed for the eventual final update.
      completer.complete(result);
      _activePurchase = null;
      _activeProductId = null;
      _activeOrderId = null;
    } else if (terminal && belongsToActive) {
      _activePurchase = null;
      _activeProductId = null;
      _activeOrderId = null;
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
    _processingTransactions.clear();
    _unfinishedPurchases.clear();
    _latestResultsByProduct.clear();
    catalogProducts.value = const [];
    products.value = const [];
    purchasing.value = null;
  }
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
