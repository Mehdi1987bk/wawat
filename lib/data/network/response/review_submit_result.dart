/// Result of `POST /shipments/{id}/review`.
///
/// The backend decides whether a review is published immediately or held for
/// moderation and returns that in `data.status`:
///   • "approved" → live now, target rating updated instantly (4–5★, no comment).
///   • "pending"  → sent to moderation (1–3★, or 4–5★ with a comment).
class ReviewSubmitResult {
  final String status;
  final String message;

  const ReviewSubmitResult({required this.status, required this.message});

  bool get isApproved => status == 'approved';

  factory ReviewSubmitResult.fromResponse(Map<String, dynamic>? body) {
    final map = body ?? const <String, dynamic>{};
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : const <String, dynamic>{};
    final status =
        (data['status'] ?? map['status'])?.toString().trim().toLowerCase();
    final message = map['message']?.toString().trim();
    return ReviewSubmitResult(
      status: (status == null || status.isEmpty) ? 'pending' : status,
      message: (message == null || message.isEmpty) ? '' : message,
    );
  }
}
