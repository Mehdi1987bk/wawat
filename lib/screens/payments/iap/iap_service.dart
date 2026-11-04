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

class DevIapCatalogLoader implements IapCatalogLoader {
  const DevIapCatalogLoader();

  @override
  Future<List<IapCatalogProduct>> load() async => kDevIapProducts;
}

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

@visibleForTesting
bool isQuotaProduct(String productId) =>
    productId.startsWith('wawat.app.quota');

@visibleForTesting
bool isVerificationProduct(String productId) =>
    productId.startsWith('wawat.app.verification');

@visibleForTesting
String backendPayPath(String baseUrl, String productId, String orderId) {
  final id = Uri.encodeComponent(orderId);
  if (isVerificationProduct(productId)) {
    return '$baseUrl/verification/pay';
  }
  return isQuotaProduct(productId)
      ? '$baseUrl/listing-quota/orders/$id/pay'
      : '$baseUrl/promotions/$id/pay';
}

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

  final String? code;

  final String? orderId;

  bool get isSuccess =>
      outcome == IapOutcome.purchased || outcome == IapOutcome.restored;
}

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
  bool _attemptAwaitingResult = false;
  final Set<String> _processingTransactions = <String>{};
  final Set<String> _finishedTxnIds = <String>{};
  Set<String> _preLaunchTxnIds = <String>{};
  final Map<String, PurchaseDetails> _unfinishedPurchases =
      <String, PurchaseDetails>{};
  final Map<String, IapResult> _latestResultsByProduct = <String, IapResult>{};

  static const String _pendingOrderKeyPrefix = 'iap.pending_order.';

  bool _available = false;
  bool get isAvailable => _available;

  List<String> notFoundIds = const [];

  void useValidator(PurchaseValidator validator) => _validator = validator;

  PurchaseValidator get validator => _validator;

  void useCatalogLoader(IapCatalogLoader loader) => _catalogLoader = loader;

  Future<void> init({bool retryIfUnavailable = false}) async {
    var current = _initializing;
    if (current != null) {
      await current;
      if (_available || !retryIfUnavailable) return;

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
    if (Platform.isIOS) {
      try {
        await InAppPurchaseStoreKitPlatform.enableStoreKit1();
        InAppPurchaseStoreKitPlatform.registerPlatform();
        debugPrint('[IAP] forced StoreKit 1 on iOS');
      } catch (error) {
        debugPrint('[IAP] enableStoreKit1 failed: $error');
      }
    }
    try {
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
          try {
            await queue.finishTransaction(transaction);
            handled = true;
          } catch (error) {
            debugPrint('[IAP] finish failed transaction error: $error');
          }
        } else if (state == SKPaymentTransactionStateWrapper.purchased ||
            state == SKPaymentTransactionStateWrapper.restored) {
          toDeliver.add(transaction);
        }
      }
      if (toDeliver.isNotEmpty) {
        var receipt = '';
        try {
          receipt = await SKReceiptManager.retrieveReceiptData();
        } catch (_) {
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
    final catalog = await loadCatalog(force: forceCatalog);
    final requestedCatalog = kinds == null
        ? catalog
        : catalog.where((product) => kinds.contains(product.kind)).toList();

    await init(retryIfUnavailable: forceCatalog);
    if (!_available && Platform.isAndroid && forceCatalog) {
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
    _latestResultsByProduct.remove(productId);
    lastResult.value = null;
    await init();
    await recoverUnfinishedPurchases();
    final recoveredResult = _latestResultsByProduct[productId];
    if (recoveredResult != null &&
        recoveredResult.isSuccess &&
        recoveredResult.orderId == orderId) {
      return recoveredResult;
    }
    if (recoveredResult != null) {
      _latestResultsByProduct.remove(productId);
      lastResult.value = null;
    }
    if (Platform.isIOS) {
      await _reconcileStoreKitQueue(productId);
      final reconciled = _latestResultsByProduct[productId];
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
    _attemptAwaitingResult = false;
    await _startPurchase(product);
    return completer.future;
  }

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
    _activeProductId ??= product.id;
    _attemptAwaitingResult = true;
    if (!isRetry) {
      _preLaunchTxnIds = await _currentStoreKitTxnIds();
    }
    try {
      final launched = await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
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
      if (isDuplicateTransactionError(error) && !isRetry) {
        purchasing.value = null;
        await _reconcileStoreKitQueue(product.id);
        final reconciled = _latestResultsByProduct[product.id];
        if (reconciled != null && reconciled.isSuccess) return;
        debugPrint(
          '[IAP] cleared duplicate transaction; retrying ${product.id}',
        );
        await _startPurchase(product, isRetry: true);
        return;
      }
      await _forgetPendingOrder(product.id);
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

  Future<void> restore() async {
    await init();
    await _iap.restorePurchases();
    await recoverUnfinishedPurchases();
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    debugPrint('[IAP] purchase stream error: $error');
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
            purchasing.value = purchase.productID;
          }
          break;
        case PurchaseStatus.canceled:
          _unfinishedPurchases.remove(purchase.productID);
          await _forgetPendingOrder(purchase.productID);
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
    if (_finishedTxnIds.contains(transactionKey)) {
      await _finishIfPending(purchase);
      return;
    }
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

    final matchesActiveOrder =
        result.orderId == null ||
        _activeOrderId == null ||
        result.orderId == _activeOrderId;
    final completesActiveAttempt =
        belongsToActive && _attemptAwaitingResult && matchesActiveOrder;
    final completer = _activePurchase;
    if (completer != null && completesActiveAttempt && !completer.isCompleted) {
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

@visibleForTesting
bool isDeferredPending(PurchaseDetails purchase, {required bool isAndroid}) {
  if (purchase.status != PurchaseStatus.pending) return false;
  if (purchase is AppStorePurchaseDetails) {
    return purchase.skPaymentTransaction.transactionState ==
        SKPaymentTransactionStateWrapper.deferred;
  }
  return isAndroid;
}

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
