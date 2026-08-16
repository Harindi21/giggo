import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/models/notification_models.dart';

void main() {
  test('parses a notification with a related booking', () {
    final n = AppNotification.fromJson({
      'id': 'n1',
      'type': 'BOOKING_ACCEPTED',
      'title': 'Booking accepted',
      'body': 'Your provider accepted the booking.',
      'bookingId': 'b1',
      'read': false,
      'createdAt': '2026-08-16T09:05:00+05:30',
    });
    expect(n.type, 'BOOKING_ACCEPTED');
    expect(n.bookingId, 'b1');
    expect(n.read, isFalse);
    expect(n.createdAt, isNotNull);
  });

  test('defaults read to false and tolerates a missing booking', () {
    final n = AppNotification.fromJson({
      'id': 'n2',
      'type': 'REVIEW_RECEIVED',
      'title': 'New review',
      'body': 'You received a review.',
    });
    expect(n.read, isFalse);
    expect(n.bookingId, isNull);
  });
}
