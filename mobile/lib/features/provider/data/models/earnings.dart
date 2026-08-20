double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// A provider's earnings at a glance (mirrors the backend EarningsSummaryResponse).
class EarningsSummary {
  final double available;
  final double inEscrow;
  final double pendingWithdrawal;
  final double withdrawn;
  final double lifetimeEarned;
  final String currency;

  const EarningsSummary({
    required this.available,
    required this.inEscrow,
    required this.pendingWithdrawal,
    required this.withdrawn,
    required this.lifetimeEarned,
    required this.currency,
  });

  bool get canWithdraw => available > 0;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) => EarningsSummary(
    available: _toDouble(json['available']),
    inEscrow: _toDouble(json['inEscrow']),
    pendingWithdrawal: _toDouble(json['pendingWithdrawal']),
    withdrawn: _toDouble(json['withdrawn']),
    lifetimeEarned: _toDouble(json['lifetimeEarned']),
    currency: json['currency'] as String? ?? 'LKR',
  );
}

/// A provider withdrawal (mirrors the backend PayoutResponse).
class Payout {
  final String id;
  final double amount;
  final String currency;
  final String status; // REQUESTED | PAID | REJECTED
  final String method;
  final String? reference;
  final String? note;
  final DateTime? requestedAt;
  final DateTime? processedAt;

  const Payout({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.reference,
    this.note,
    this.requestedAt,
    this.processedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
    id: json['id'] as String,
    amount: _toDouble(json['amount']),
    currency: json['currency'] as String? ?? 'LKR',
    status: json['status'] as String? ?? 'REQUESTED',
    method: json['method'] as String? ?? 'BANK_TRANSFER',
    reference: json['reference'] as String?,
    note: json['note'] as String?,
    requestedAt: _toDate(json['requestedAt']),
    processedAt: _toDate(json['processedAt']),
  );
}
