double? _toDoubleN(dynamic v) => (v as num?)?.toDouble();
double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// Itemised price estimate from `POST /bookings/quote`
/// (mockup image32: Base Fee / Work fee / Travel / Total).
class PricingBreakdown {
  final double basePrice;
  final double workingHours;
  final double hourlyRate;
  final double workingFee;
  final double travelDistanceKm;
  final double travelFeePerKm;
  final double travelFee;
  final double totalPrice;

  const PricingBreakdown({
    required this.basePrice,
    required this.workingHours,
    required this.hourlyRate,
    required this.workingFee,
    required this.travelDistanceKm,
    required this.travelFeePerKm,
    required this.travelFee,
    required this.totalPrice,
  });

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) =>
      PricingBreakdown(
        basePrice: _toDouble(json['basePrice']),
        workingHours: _toDouble(json['workingHours']),
        hourlyRate: _toDouble(json['hourlyRate']),
        workingFee: _toDouble(json['workingFee']),
        travelDistanceKm: _toDouble(json['travelDistanceKm']),
        travelFeePerKm: _toDouble(json['travelFeePerKm']),
        travelFee: _toDouble(json['travelFee']),
        totalPrice: _toDouble(json['totalPrice']),
      );
}

/// One entry in a booking's status history (`GET /bookings/{id}/timeline`).
class StatusEvent {
  final String status;
  final DateTime at;

  const StatusEvent({required this.status, required this.at});

  factory StatusEvent.fromJson(Map<String, dynamic> json) => StatusEvent(
    status: json['status'] as String,
    at: DateTime.parse(json['at'] as String),
  );
}

/// A booking / job as returned by the booking APIs. The price fields are the
/// snapshot taken when the booking was created.
class Booking {
  final String id;
  final String customerId;
  final String providerId;
  final String skillId;
  final String? skillName;
  final String status;
  final DateTime scheduledAt;
  final double estimatedHours;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final String? taskTitle;
  final String? description;
  final String? contactName;
  final String? contactPhone;
  final DateTime? requestExpiresAt;
  final double totalPrice;
  final double? basePrice;
  final double? hourlyRate;
  final double? workingHours;
  final double? workingFee;
  final double? travelDistanceKm;
  final double? travelFee;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.skillId,
    this.skillName,
    required this.status,
    required this.scheduledAt,
    required this.estimatedHours,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.taskTitle,
    this.description,
    this.contactName,
    this.contactPhone,
    this.requestExpiresAt,
    required this.totalPrice,
    this.basePrice,
    this.hourlyRate,
    this.workingHours,
    this.workingFee,
    this.travelDistanceKm,
    this.travelFee,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    customerId: json['customerId'] as String,
    providerId: json['providerId'] as String,
    skillId: json['skillId'] as String,
    skillName: json['skillName'] as String?,
    status: json['status'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    estimatedHours: _toDouble(json['estimatedHours']),
    addressLine: json['addressLine'] as String?,
    latitude: _toDoubleN(json['latitude']),
    longitude: _toDoubleN(json['longitude']),
    taskTitle: json['taskTitle'] as String?,
    description: json['description'] as String?,
    contactName: json['contactName'] as String?,
    contactPhone: json['contactPhone'] as String?,
    requestExpiresAt: _toDate(json['requestExpiresAt']),
    totalPrice: _toDouble(json['totalPrice']),
    basePrice: _toDoubleN(json['basePrice']),
    hourlyRate: _toDoubleN(json['hourlyRate']),
    workingHours: _toDoubleN(json['workingHours']),
    workingFee: _toDoubleN(json['workingFee']),
    travelDistanceKm: _toDoubleN(json['travelDistanceKm']),
    travelFee: _toDoubleN(json['travelFee']),
    acceptedAt: _toDate(json['acceptedAt']),
    startedAt: _toDate(json['startedAt']),
    completedAt: _toDate(json['completedAt']),
    cancelledAt: _toDate(json['cancelledAt']),
    cancelReason: json['cancelReason'] as String?,
    createdAt: _toDate(json['createdAt']),
  );
}
