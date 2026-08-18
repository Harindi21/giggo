import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dispute/data/models/dispute_models.dart';

void main() {
  test('parses an open dispute', () {
    final d = Dispute.fromJson({
      'id': 'd1',
      'bookingId': 'b1',
      'raisedBy': 'u1',
      'reason': 'Work not finished',
      'status': 'OPEN',
      'createdAt': '2026-08-18T09:00:00+05:30',
    });
    expect(d.reason, 'Work not finished');
    expect(d.isOpen, isTrue);
    expect(d.isRefunded, isFalse);
    expect(d.resolvedAt, isNull);
  });

  test('exposes resolved state getters', () {
    expect(_status('RESOLVED_REFUNDED').isRefunded, isTrue);
    expect(_status('RESOLVED_DISMISSED').isDismissed, isTrue);
    expect(_status('RESOLVED_DISMISSED').isOpen, isFalse);
  });
}

Dispute _status(String s) => Dispute.fromJson({
  'id': 'd',
  'bookingId': 'b',
  'raisedBy': 'u',
  'reason': 'x',
  'status': s,
});
