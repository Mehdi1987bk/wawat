
import 'receipt.dart';

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
    : const [];

String? _string(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

int _int(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _double(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value?.toString().trim().toLowerCase();
  return s == 'true' || s == '1';
}

class QuotaPricingResponse {
  final QuotaPricing data;

  const QuotaPricingResponse({required this.data});

  factory QuotaPricingResponse.fromJson(Map<String, dynamic> json) =>
      QuotaPricingResponse(
        data: QuotaPricing.fromJson(_map(json['data']) ?? const {}),
      );
}

class QuotaPricing {
  final String currency;
  final List<QuotaTypePricing> types;

  const QuotaPricing({required this.currency, required this.types});

  factory QuotaPricing.fromJson(Map<String, dynamic> json) => QuotaPricing(
        currency: _string(json['currency']) ?? 'AZN',
        types: _mapList(json['types'])
            .map(QuotaTypePricing.fromJson)
            .toList(growable: false),
      );

  QuotaTypePricing? forType(String type) {
    for (final t in types) {
      if (t.type == type) return t;
    }
    return null;
  }
}

class QuotaTypePricing {
  final String type;
  final String label;
  final List<QuotaPlan> plans;

  const QuotaTypePricing({
    required this.type,
    required this.label,
    required this.plans,
  });

  factory QuotaTypePricing.fromJson(Map<String, dynamic> json) =>
      QuotaTypePricing(
        type: _string(json['type']) ?? '',
        label: _string(json['label']) ?? '',
        plans: _mapList(json['plans'])
            .map(QuotaPlan.fromJson)
            .toList(growable: false),
      );
}

class QuotaPlan {
  final int extraListings;
  final double price;
  final String currency;
  final double? perListing;
  final String packageLabel;
  final String? badge;

  const QuotaPlan({
    required this.extraListings,
    required this.price,
    required this.currency,
    this.perListing,
    required this.packageLabel,
    this.badge,
  });

  factory QuotaPlan.fromJson(Map<String, dynamic> json) => QuotaPlan(
        extraListings: _int(json['extra_listings']),
        price: _double(json['price']),
        currency: _string(json['currency']) ?? 'AZN',
        perListing:
            json['per_listing'] == null ? null : _double(json['per_listing']),
        packageLabel: _string(json['package_label']) ?? '',
        badge: _string(json['badge']),
      );

  bool get isBestValue => badge == 'best_value';
}

class QuotaOrderResponse {
  final QuotaOrder data;
  final String? message;
  final Receipt? receipt;

  const QuotaOrderResponse({required this.data, this.message, this.receipt});

  factory QuotaOrderResponse.fromJson(Map<String, dynamic> json) =>
      QuotaOrderResponse(
        data: QuotaOrder.fromJson(_map(json['data']) ?? const {}),
        message: _string(json['message']),
        receipt: Receipt.fromResponse(json),
      );
}

class QuotaOrder {
  final String id;
  final String type;
  final String typeLabel;
  final int extraListings;
  final String packageLabel;
  final double amount;
  final String currency;
  final String status;
  final String statusLabel;
  final String? providerRef;
  final String? paidAt;
  final String? createdAt;
  final QuotaPayment? payment;

  const QuotaOrder({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.extraListings,
    required this.packageLabel,
    required this.amount,
    required this.currency,
    required this.status,
    required this.statusLabel,
    this.providerRef,
    this.paidAt,
    this.createdAt,
    this.payment,
  });

  factory QuotaOrder.fromJson(Map<String, dynamic> json) {
    final paymentJson = _map(json['payment']);
    return QuotaOrder(
      id: _string(json['id']) ?? '',
      type: _string(json['type']) ?? '',
      typeLabel: _string(json['type_label']) ?? '',
      extraListings: _int(json['extra_listings']),
      packageLabel: _string(json['package_label']) ?? '',
      amount: _double(json['amount']),
      currency: _string(json['currency']) ?? 'AZN',
      status: _string(json['status']) ?? 'pending_payment',
      statusLabel: _string(json['status_label']) ?? '',
      providerRef: _string(json['provider_ref']),
      paidAt: _string(json['paid_at']),
      createdAt: _string(json['created_at']),
      payment: paymentJson == null ? null : QuotaPayment.fromJson(paymentJson),
    );
  }

  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'failed' || status == 'canceled';
  bool get isPending => status == 'pending_payment';

  String? get checkoutUrl => payment?.checkoutUrl;
}

class QuotaPayment {
  final String? method;
  final String? reference;
  final String? status;
  final String? checkoutUrl;
  final bool mock;

  const QuotaPayment({
    this.method,
    this.reference,
    this.status,
    this.checkoutUrl,
    this.mock = true,
  });

  factory QuotaPayment.fromJson(Map<String, dynamic> json) => QuotaPayment(
        method: _string(json['method']),
        reference: _string(json['reference']),
        status: _string(json['status']),
        checkoutUrl: _string(json['checkout_url']),
        mock: json['mock'] == null ? true : _bool(json['mock']),
      );
}
