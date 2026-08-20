import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/provider/data/models/earnings.dart';

void main() {
  test('parses an earnings summary and exposes canWithdraw', () {
    final s = EarningsSummary.fromJson({
      'available': 650,
      'inEscrow': 270,
      'pendingWithdrawal': 200,
      'withdrawn': 500,
      'lifetimeEarned': 1350,
      'currency': 'LKR',
    });
    expect(s.available, 650);
    expect(s.inEscrow, 270);
    expect(s.lifetimeEarned, 1350);
    expect(s.canWithdraw, isTrue);
  });

  test('canWithdraw is false with a zero balance and defaults are safe', () {
    final s = EarningsSummary.fromJson({'available': 0});
    expect(s.canWithdraw, isFalse);
    expect(s.currency, 'LKR');
    expect(s.lifetimeEarned, 0);
  });

  test('parses a payout with status and reference', () {
    final p = Payout.fromJson({
      'id': 'po1',
      'amount': 400,
      'currency': 'LKR',
      'status': 'PAID',
      'method': 'BANK_TRANSFER',
      'reference': 'BANK-REF-9',
      'requestedAt': '2026-08-20T10:00:00+05:30',
      'processedAt': '2026-08-21T09:00:00+05:30',
    });
    expect(p.amount, 400);
    expect(p.status, 'PAID');
    expect(p.reference, 'BANK-REF-9');
    expect(p.processedAt, isNotNull);
  });
}
