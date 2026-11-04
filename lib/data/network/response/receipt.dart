class Receipt {
  final String kind;
  final String number;
  final String title;
  final double amount;
  final String currency;
  final String status;
  final bool isPaid;
  final String? paidAt;
  final String? method;
  final String? reference;
  final List<ReceiptItem> items;
  final String supportEmail;

  final String? pdfUrl;

  const Receipt({
    required this.kind,
    required this.number,
    required this.title,
    required this.amount,
    required this.currency,
    required this.status,
    required this.isPaid,
    this.paidAt,
    this.method,
    this.reference,
    this.items = const [],
    required this.supportEmail,
    this.pdfUrl,
  });

  static Receipt? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    return Receipt(
      kind: _string(json['kind']) ?? '',
      number: _string(json['number']) ?? '',
      title: _string(json['title']) ?? '',
      amount: _double(json['amount']),
      currency: _string(json['currency']) ?? 'AZN',
      status: _string(json['status']) ?? 'none',
      isPaid: _bool(json['is_paid']),
      paidAt: _string(json['paid_at']),
      method: _string(json['method']),
      reference: _string(json['reference']),
      items: _list(json['items'])
          .map(ReceiptItem.fromJson)
          .where((e) => e.label.isNotEmpty || e.value.isNotEmpty)
          .toList(growable: false),
      supportEmail: _string(json['support_email']) ?? 'support@wawatair.com',
      pdfUrl: _string(json['pdf_url']),
    );
  }

  static Receipt? fromResponse(Map<String, dynamic>? body) {
    if (body == null) return null;
    final root = body['receipt'];
    if (root is Map) return fromJson(Map<String, dynamic>.from(root));
    final data = body['data'];
    if (data is Map && data['receipt'] is Map) {
      return fromJson(Map<String, dynamic>.from(data['receipt'] as Map));
    }
    return null;
  }
}

class ReceiptItem {
  final String label;
  final String value;

  const ReceiptItem({required this.label, required this.value});

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    label: _string(json['label']) ?? '',
    value: _string(json['value']) ?? '',
  );
}

String? _string(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

double _double(Object? v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

bool _bool(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().trim().toLowerCase();
  return s == 'true' || s == '1';
}

List<Map<String, dynamic>> _list(Object? v) => v is List
    ? v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false)
    : const [];
