/// State of the current user's KYC verification, from `GET /verification`.
///
/// Verification is a PAID, two-step flow: (1) submit documents → admin review,
/// (2) once documents are `approved`, pay the fee → the `is_verified` badge
/// activates. Document approval alone does NOT verify the account — payment
/// does. A `rejected` request can be resubmitted for free.
class VerificationState {
  final String id;

  /// `pending` | `processing` | `approved` | `rejected`.
  final String status;

  /// Server-localized status label (already in the request locale).
  final String statusLabel;

  /// Present only when [status] is `rejected`.
  final String? rejectionReason;
  final String? submittedAt;
  final String? reviewedAt;
  final VerificationPayment payment;
  final List<VerificationDocument> documents;

  const VerificationState({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    required this.payment,
    this.documents = const [],
  });

  bool get isPending => status == 'pending' || status == 'processing';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Documents approved but the fee isn't paid yet → show the payment step.
  bool get awaitingPayment => isApproved && payment.required && !payment.paid;

  /// Fully verified through this request (documents approved AND fee paid).
  bool get isPaidVerified => isApproved && payment.paid;

  factory VerificationState.fromJson(Map<String, dynamic> json) {
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
    );
  }
}

/// Fee + payment status for a verification request. Amount/currency are always
/// taken from here (server-configured), never hardcoded. `mock` is true while
/// the real payment provider isn't wired — paying just flips `paid` to true.
class VerificationPayment {
  final double feeAmount;
  final String currency;

  /// True ONLY when the request is `approved` and the fee is still unpaid.
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

/// What the verification screen needs on load: the current [state] (null when
/// the user has never submitted) plus the fee to advertise on the intro screen.
///
/// The fee is read from the active request's `payment` when there is one; when
/// there's no request yet the repository also looks for a top-level fee hint so
/// the intro can still show "paid — {amount} {currency}". Null when the backend
/// exposes no fee for the not-submitted case (intro then omits the number).
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

/// Result of `POST /verification/pay` — the updated verification plus the
/// server's localized success message.
class VerificationPayResult {
  final VerificationState state;
  final String? message;

  const VerificationPayResult({required this.state, this.message});
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
