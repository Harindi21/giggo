import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/data/models/booking_models.dart';

void main() {
  test('parses a full booking', () {
    final b = Booking.fromJson({
      'id': 'b1',
      'customerId': 'c1',
      'providerId': 'p1',
      'skillId': 's1',
      'skillName': 'Plumbing',
      'status': 'COMPLETED',
      'scheduledAt': '2026-08-16T09:00:00+05:30',
      'estimatedHours': 2,
      'addressLine': 'No. 9',
      'latitude': 6.9,
      'longitude': 79.8,
      'taskTitle': 'Fix sink',
      'totalPrice': 3500,
      'basePrice': 1500,
      'travelFee': 0,
      'cancelReason': null,
      'createdAt': '2026-08-16T08:00:00+05:30',
    });
    expect(b.id, 'b1');
    expect(b.status, 'COMPLETED');
    expect(b.skillName, 'Plumbing');
    expect(b.estimatedHours, 2);
    expect(b.totalPrice, 3500);
    expect(b.latitude, 6.9);
    // 09:00+05:30 parses to the 03:30 UTC instant (Dart normalises offsets).
    expect(b.scheduledAt.toUtc().toIso8601String(), '2026-08-16T03:30:00.000Z');
  });

  test('parses a minimal booking (nullable fields absent)', () {
    final b = Booking.fromJson({
      'id': 'b2',
      'customerId': 'c1',
      'providerId': 'p1',
      'skillId': 's1',
      'status': 'REQUESTED',
      'scheduledAt': '2026-08-16T09:00:00Z',
      'estimatedHours': 1,
      'totalPrice': 1000,
    });
    expect(b.skillName, isNull);
    expect(b.latitude, isNull);
    expect(b.cancelReason, isNull);
    expect(b.completedAt, isNull);
  });

  test('parses a pricing breakdown', () {
    final p = PricingBreakdown.fromJson({
      'basePrice': 1500,
      'workingHours': 2,
      'hourlyRate': 800,
      'workingFee': 1600,
      'travelDistanceKm': 4.2,
      'travelFeePerKm': 50,
      'travelFee': 210,
      'totalPrice': 3310,
    });
    expect(p.basePrice, 1500);
    expect(p.workingFee, 1600);
    expect(p.travelFee, 210);
    expect(p.totalPrice, 3310);
  });

  test('parses a status event', () {
    final e = StatusEvent.fromJson({
      'status': 'ACCEPTED',
      'at': '2026-08-16T09:05:00+05:30',
    });
    expect(e.status, 'ACCEPTED');
    expect(e.at, isNotNull);
  });
}
