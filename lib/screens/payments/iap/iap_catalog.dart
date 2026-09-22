library;

/// Product kind returned by `GET /api/v1/purchases/catalog`.
enum IapProductKind {
  vip('vip'),
  featured('featured'),
  quota('quota'),
  verification('verification'),
  unknown('unknown');

  const IapProductKind(this.apiValue);

  final String apiValue;

  static IapProductKind fromApi(String? value) {
    for (final kind in values) {
      if (kind.apiValue == value) return kind;
    }
    return IapProductKind.unknown;
  }
}

/// A consumable product defined by the Wawatair backend catalogue.
///
/// Product identifiers and fallback prices are never sourced from the app in
/// production. The backend catalogue selects the store product, while
/// App Store / Google Play remains the source of the displayed localized price.
class IapCatalogProduct {
  const IapCatalogProduct({
    required this.productId,
    required this.kind,
    required this.price,
    required this.currency,
    this.packageId,
    this.name,
    this.description,
    this.durationDays,
    this.boostPackage,
    this.guaranteedMin,
    this.guaranteedMax,
    this.recommended = false,
    this.sortOrder,
    this.listingType,
    this.extraListings,
  });

  factory IapCatalogProduct.fromJson(Map<String, dynamic> json) {
    return IapCatalogProduct(
      productId: json['product_id']?.toString() ?? '',
      kind: IapProductKind.fromApi(json['kind']?.toString()),
      price: _double(json['price']) ?? 0,
      currency: json['currency']?.toString() ?? 'AZN',
      packageId: _string(json['package_id'] ?? json['id']),
      name: _string(json['name'] ?? json['label']),
      description: _string(json['description']),
      durationDays: _int(json['duration_days']),
      boostPackage: json['package']?.toString(),
      guaranteedMin: _int(json['guaranteed_min']),
      guaranteedMax: _int(json['guaranteed_max']),
      recommended: _bool(json['recommended']) ?? false,
      sortOrder: _int(json['sort_order']),
      listingType: json['listing_type']?.toString(),
      extraListings: _int(json['extra_listings']),
    );
  }

  final String productId;
  final IapProductKind kind;
  final double price;
  final String currency;
  final String? packageId;

  /// Localized by the backend according to `Accept-Language`.
  final String? name;
  final String? description;
  final int? durationDays;
  final String? boostPackage;
  final int? guaranteedMin;
  final int? guaranteedMax;
  final bool recommended;
  final int? sortOrder;
  final String? listingType;
  final int? extraListings;

  bool get isPromotion =>
      kind == IapProductKind.vip || kind == IapProductKind.featured;
}

List<IapCatalogProduct> parseIapCatalog(Map<String, dynamic> json) {
  final data = json['data'];
  final products = data is Map ? data['products'] : null;
  if (products is! List) return const [];
  return products
      .whereType<Map>()
      .map(
        (item) => IapCatalogProduct.fromJson(Map<String, dynamic>.from(item)),
      )
      .where(
        (product) =>
            product.productId.isNotEmpty &&
            product.kind != IapProductKind.unknown,
      )
      .toList(growable: false);
}

IapCatalogProduct? iapProductForPromotion(
  Iterable<IapCatalogProduct> products, {
  required String promotionType,
  int? durationDays,
  String? boostPackage,
}) {
  for (final product in products) {
    if (product.kind.apiValue != promotionType) continue;
    if (product.kind == IapProductKind.vip &&
        product.durationDays == durationDays) {
      return product;
    }
    if (product.kind == IapProductKind.featured &&
        product.boostPackage == boostPackage) {
      return product;
    }
  }
  return null;
}

/// Local StoreKit catalogue used only by `lib/dev_iap.dart`.
/// Production replaces it with `GET /purchases/catalog` before querying stores.
const List<IapCatalogProduct> kDevIapProducts = [
  IapCatalogProduct(
    productId: 'wawat.app.vip.1d',
    kind: IapProductKind.vip,
    durationDays: 1,
    name: 'VİP · 1 gün',
    description: 'Elanı 1 gün VİP et',
    price: 0.99,
    currency: 'USD',
  ),
  IapCatalogProduct(
    productId: 'wawat.app.vip.3d',
    kind: IapProductKind.vip,
    durationDays: 3,
    name: 'VİP · 3 gün',
    description: 'Elanı 3 gün VİP et',
    price: 1.99,
    currency: 'USD',
  ),
  IapCatalogProduct(
    productId: 'wawat.app.vip.5d',
    kind: IapProductKind.vip,
    durationDays: 5,
    name: 'VİP · 5 gün',
    description: 'Elanı 5 gün VİP et',
    price: 2.99,
    currency: 'USD',
  ),
  IapCatalogProduct(
    productId: 'wawat.app.boost.small',
    kind: IapProductKind.featured,
    boostPackage: 'small',
    name: 'Önə çıxarılan · Kiçik',
    description: 'Zəmanətli göstəriş paketi',
    guaranteedMin: 117,
    guaranteedMax: 235,
    price: 9,
    currency: 'AZN',
  ),
  IapCatalogProduct(
    productId: 'wawat.app.boost.medium',
    kind: IapProductKind.featured,
    boostPackage: 'medium',
    name: 'Önə çıxarılan · Orta',
    description: 'Zəmanətli göstəriş paketi',
    guaranteedMin: 352,
    guaranteedMax: 588,
    recommended: true,
    price: 19,
    currency: 'AZN',
  ),
  IapCatalogProduct(
    productId: 'wawat.app.boost.large',
    kind: IapProductKind.featured,
    boostPackage: 'large',
    name: 'Önə çıxarılan · Böyük',
    description: 'Zəmanətli göstəriş paketi',
    price: 39,
    currency: 'AZN',
  ),
];

int? _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

double? _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

String? _string(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

bool? _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

/// The backend contract is ready. It can still be disabled explicitly with
/// `--dart-define=IAP_ENABLED=false` for emergency rollback builds.
const bool kIapEnabled = bool.fromEnvironment(
  'IAP_ENABLED',
  defaultValue: true,
);
