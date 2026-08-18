/// A dispute raised on a booking (P4.6/P4.7).
class Dispute {
  final String id;
  final String bookingId;
  final String raisedBy;
  final String reason;
  final String status; // OPEN | RESOLVED_REFUNDED | RESOLVED_DISMISSED
  final String? resolutionNote;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const Dispute({
    required this.id,
    required this.bookingId,
    required this.raisedBy,
    required this.reason,
    required this.status,
    this.resolutionNote,
    this.createdAt,
    this.resolvedAt,
  });

  bool get isOpen => status == 'OPEN';
  bool get isRefunded => status == 'RESOLVED_REFUNDED';
  bool get isDismissed => status == 'RESOLVED_DISMISSED';

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    raisedBy: json['raisedBy'] as String,
    reason: json['reason'] as String,
    status: json['status'] as String,
    resolutionNote: json['resolutionNote'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.tryParse(json['resolvedAt'] as String)
        : null,
  );
}
