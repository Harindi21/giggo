double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// A payment receipt / invoice for a paid booking (P4.12-4.14). Mirrors the
/// backend ReceiptResponse: snapshotted price line items plus the escrow split.
class Receipt {
  final String receiptNumber;
  final DateTime? issuedAt;
  final String bookingId;
  final String paymentId;
  final String? customerName;
  final String? providerName;
  final String? serviceName;
  final String? taskTitle;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  // ---- price line items ----
  final double basePrice;
  final double hourlyRate;
  final double workingHours;
  final double workingFee;
  final double travelDistanceKm;
  final double travelFee;
  final double total;
  final String currency;
  // ---- payment / escrow ----
  final String paymentStatus; // HELD | RELEASED
  final String gateway;
  final DateTime? paidAt;
  final double platformCommission;
  final double providerPayout;

  const Receipt({
    required this.receiptNumber,
    this.issuedAt,
    required this.bookingId,
    required this.paymentId,
    this.customerName,
    this.providerName,
    this.serviceName,
    this.taskTitle,
    this.scheduledAt,
    this.completedAt,
    required this.basePrice,
    required this.hourlyRate,
    required this.workingHours,
    required this.workingFee,
    required this.travelDistanceKm,
    required this.travelFee,
    required this.total,
    required this.currency,
    required this.paymentStatus,
    required this.gateway,
    this.paidAt,
    required this.platformCommission,
    required this.providerPayout,
  });

  bool get isReleased => paymentStatus == 'RELEASED';

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    receiptNumber: json['receiptNumber'] as String,
    issuedAt: _toDate(json['issuedAt']),
    bookingId: json['bookingId'] as String,
    paymentId: json['paymentId'] as String,
    customerName: json['customerName'] as String?,
    providerName: json['providerName'] as String?,
    serviceName: json['serviceName'] as String?,
    taskTitle: json['taskTitle'] as String?,
    scheduledAt: _toDate(json['scheduledAt']),
    completedAt: _toDate(json['completedAt']),
    basePrice: _toDouble(json['basePrice']),
    hourlyRate: _toDouble(json['hourlyRate']),
    workingHours: _toDouble(json['workingHours']),
    workingFee: _toDouble(json['workingFee']),
    travelDistanceKm: _toDouble(json['travelDistanceKm']),
    travelFee: _toDouble(json['travelFee']),
    total: _toDouble(json['total']),
    currency: json['currency'] as String? ?? 'LKR',
    paymentStatus: json['paymentStatus'] as String? ?? 'HELD',
    gateway: json['gateway'] as String? ?? 'stub',
    paidAt: _toDate(json['paidAt']),
    platformCommission: _toDouble(json['platformCommission']),
    providerPayout: _toDouble(json['providerPayout']),
  );
}
