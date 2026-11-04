import 'receipt.dart';

class VerificationState {
  final String id;

  final String status;

  final String statusLabel;

  final String? rejectionReason;
  final String? submittedAt;
  final String? reviewedAt;
  final VerificationPayment payment;
  final List<VerificationDocument> documents;

  final Receipt? receipt;

  const VerificationState({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    required this.payment,
    this.documents = const [],
    this.receipt,
  });

  bool get isPending => status == 'pending' || status == 'processing';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  bool get awaitingPayment => isApproved && payment.required && !payment.paid;

  bool get isPaidVerified => isApproved && payment.paid;

  factory VerificationState.fromJson(
    Map<String, dynamic> json, {
    Receipt? fallbackReceipt,
  }) {
    return VerificationState(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      rejectionReason: _str(json['rejection_reason']),
      submittedAt: _str(json['submitted_at']),
      reviewedAt: _str(json['reviewed_at']),
      payment: VerificationPayment.fromJson(_map(json['payment'])),
      documents: _list(json['documents'])
          .whereType<Map>()
          .map((e) =>
              VerificationDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      receipt: Receipt.fromJson(_map(json['receipt'])) ?? fallbackReceipt,
    );
  }
}

class VerificationPayment {
  final double feeAmount;
  final String currency;

  final bool required;
  final bool paid;
  final String? paidAt;
  final double? chargedAmount;
  final bool mock;

  const VerificationPayment({
    required this.feeAmount,
    required this.currency,
    required this.required,
    required this.paid,
    this.paidAt,
    this.chargedAmount,
    this.mock = true,
  });

  factory VerificationPayment.fromJson(Map<String, dynamic> json) {
    return VerificationPayment(
      feeAmount: _double(json['fee_amount']) ?? 0,
      currency: json['currency']?.toString() ?? 'AZN',
      required: _bool(json['required']) ?? false,
      paid: _bool(json['paid']) ?? false,
      paidAt: _str(json['paid_at']),
      chargedAmount: _double(json['charged_amount']),
      mock: _bool(json['mock']) ?? true,
    );
  }
}

class VerificationDocument {
  final String? type;
  final String? originalName;
  final String? mime;
  final int? size;

  const VerificationDocument({
    this.type,
    this.originalName,
    this.mime,
    this.size,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      type: _str(json['type']),
      originalName: _str(json['original_name']),
      mime: _str(json['mime']),
      size: _int(json['size']),
    );
  }
}

class VerificationSnapshot {
  final VerificationState? state;
  final double? feeAmount;
  final String? currency;

  const VerificationSnapshot({
    this.state,
    this.feeAmount,
    this.currency,
  });
}

class VerificationPayResult {
  final VerificationState state;
  final String? message;
  final String? checkoutUrl;

  const VerificationPayResult({
    required this.state,
    this.message,
    this.checkoutUrl,
  });
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<dynamic> _list(Object? value) => value is List ? value : const [];

String? _str(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _double(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool? _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}
