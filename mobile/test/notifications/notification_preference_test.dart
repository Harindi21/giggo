import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/models/notification_preference.dart';

void main() {
  test('parses a preference and exposes a human label', () {
    final p = NotificationPreference.fromJson({
      'category': 'PAYMENTS',
      'pushEnabled': false,
    });
    expect(p.category, 'PAYMENTS');
    expect(p.pushEnabled, isFalse);
    expect(p.label, 'Payments');
    expect(p.description, isNotEmpty);
  });

  test('defaults pushEnabled to true and copyWith flips it', () {
    final p = NotificationPreference.fromJson({'category': 'BOOKINGS'});
    expect(p.pushEnabled, isTrue);
    expect(p.copyWith(pushEnabled: false).pushEnabled, isFalse);
    expect(p.label, 'Bookings');
  });
}
