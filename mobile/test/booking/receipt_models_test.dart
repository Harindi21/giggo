import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/data/models/receipt_models.dart';

void main() {
  test('parses a receipt with line items and the escrow split', () {
    final r = Receipt.fromJson({
      'receiptNumber': 'GIG-202608-1A2B3C4D',
      'issuedAt': '2026-08-16T10:00:00+05:30',
      'bookingId': '1a2b3c4d-0000-0000-0000-000000000000',
      'paymentId': 'pay1',
      'customerName': 'Ann',
      'providerName': 'Kamal',
      'serviceName': 'Plumbing',
      'taskTitle': 'Fix leaking pipe',
      'scheduledAt': '2026-08-16T09:00:00+05:30',
      'completedAt': '2026-08-16T11:00:00+05:30',
      'basePrice': 500,
      'hourlyRate': 500,
      'workingHours': 2,
      'workingFee': 1000,
      'travelDistanceKm': 5,
      'travelFee': 250,
      'total': 1750,
      'currency': 'LKR',
      'paymentStatus': 'HELD',
      'gateway': 'stub',
      'paidAt': '2026-08-16T10:00:00+05:30',
      'platformCommission': 175,
      'providerPayout': 1575,
    });

    expect(r.receiptNumber, 'GIG-202608-1A2B3C4D');
    expect(r.customerName, 'Ann');
    expect(r.providerName, 'Kamal');
    expect(r.serviceName, 'Plumbing');
    expect(r.total, 1750);
    expect(r.platformCommission, 175);
    expect(r.providerPayout, 1575);
    expect(r.isReleased, isFalse);
    expect(r.issuedAt, isNotNull);
  });

  test('isReleased reflects a settled payment and defaults hold gracefully', () {
    final released = Receipt.fromJson({
      'receiptNumber': 'GIG-202608-DEADBEEF',
      'bookingId': 'b1',
      'paymentId': 'p1',
      'total': 1000,
      'paymentStatus': 'RELEASED',
    });
    expect(released.isReleased, isTrue);
    expect(released.currency, 'LKR'); // default
    expect(released.gateway, 'stub'); // default
    expect(released.basePrice, 0); // absent numbers default to 0
  });
}
