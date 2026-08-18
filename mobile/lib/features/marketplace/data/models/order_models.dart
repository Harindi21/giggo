double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// A tool order (P10). Mirrors the backend OrderResponse.
class ToolOrder {
  final String id;
  final String toolId;
  final String toolName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String currency;
  final String status; // PENDING | PAID | CANCELLED
  final String? gatewayRef;
  final String? checkoutUrl; // only present right after placing
  final String? contactName;
  final String? contactPhone;
  final String? shippingAddress;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const ToolOrder({
    required this.id,
    required this.toolId,
    required this.toolName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.currency,
    required this.status,
    this.gatewayRef,
    this.checkoutUrl,
    this.contactName,
    this.contactPhone,
    this.shippingAddress,
    this.paidAt,
    this.createdAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isPaid => status == 'PAID';
  bool get isCancelled => status == 'CANCELLED';

  factory ToolOrder.fromJson(Map<String, dynamic> json) => ToolOrder(
    id: json['id'] as String,
    toolId: json['toolId'] as String,
    toolName: json['toolName'] as String,
    unitPrice: _toDouble(json['unitPrice']),
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    totalPrice: _toDouble(json['totalPrice']),
    currency: json['currency'] as String? ?? 'LKR',
    status: json['status'] as String,
    gatewayRef: json['gatewayRef'] as String?,
    checkoutUrl: json['checkoutUrl'] as String?,
    contactName: json['contactName'] as String?,
    contactPhone: json['contactPhone'] as String?,
    shippingAddress: json['shippingAddress'] as String?,
    paidAt: _toDate(json['paidAt']),
    createdAt: _toDate(json['createdAt']),
  );
}
