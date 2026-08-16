import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/data/models/payment_models.dart';

void main() {
  test('parses a held payment and exposes state getters', () {
    final p = Payment.fromJson({
      'id': 'pay1',
      'bookingId': 'b1',
      'amount': 3500,
      'currency': 'LKR',
      'commission': 350,
      'providerPayout': 3150,
      'status': 'HELD',
      'gateway': 'stub',
      'gatewayRef': 'STUB-ABC',
      'paidAt': '2026-08-16T10:00:00+05:30',
    });
    expect(p.amount, 3500);
    expect(p.commission, 350);
    expect(p.providerPayout, 3150);
    expect(p.isHeld, isTrue);
    expect(p.isReleased, isFalse);
    expect(p.isPending, isFalse);
  });

  test('treats PENDING and FAILED as pending', () {
    expect(_status('PENDING').isPending, isTrue);
    expect(_status('FAILED').isPending, isTrue);
    expect(_status('RELEASED').isReleased, isTrue);
  });
}

Payment _status(String s) => Payment.fromJson({
  'id': 'x',
  'bookingId': 'b',
  'amount': 1,
  'status': s,
  'gateway': 'stub',
});
