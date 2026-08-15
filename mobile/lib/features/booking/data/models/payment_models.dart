double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// A payment for a booking (P7). Mirrors the backend PaymentResponse.
class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final double commission;
  final double providerPayout;
  final String status; // PENDING | HELD | RELEASED | REFUNDED | FAILED
  final String gateway;
  final String? gatewayRef;
  final String? checkoutUrl; // only present right after initiate
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final DateTime? createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.commission,
    required this.providerPayout,
    required this.status,
    required this.gateway,
    this.gatewayRef,
    this.checkoutUrl,
    this.paidAt,
    this.releasedAt,
    this.createdAt,
  });

  bool get isHeld => status == 'HELD';
  bool get isReleased => status == 'RELEASED';
  bool get isPending => status == 'PENDING' || status == 'FAILED';

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    amount: _toDouble(json['amount']),
    currency: json['currency'] as String? ?? 'LKR',
    commission: _toDouble(json['commission']),
    providerPayout: _toDouble(json['providerPayout']),
    status: json['status'] as String,
    gateway: json['gateway'] as String? ?? 'stub',
    gatewayRef: json['gatewayRef'] as String?,
    checkoutUrl: json['checkoutUrl'] as String?,
    paidAt: _toDate(json['paidAt']),
    releasedAt: _toDate(json['releasedAt']),
    createdAt: _toDate(json['createdAt']),
  );
}
