import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/marketplace/data/models/order_models.dart';

void main() {
  test('parses a paid order', () {
    final o = ToolOrder.fromJson({
      'id': 'o1',
      'toolId': 't1',
      'toolName': 'Cordless Drill',
      'unitPrice': 12500,
      'quantity': 2,
      'totalPrice': 25000,
      'currency': 'LKR',
      'status': 'PAID',
      'paidAt': '2026-08-18T10:00:00+05:30',
    });
    expect(o.toolName, 'Cordless Drill');
    expect(o.quantity, 2);
    expect(o.totalPrice, 25000);
    expect(o.isPaid, isTrue);
    expect(o.isPending, isFalse);
  });

  test('exposes pending/cancelled getters', () {
    expect(_status('PENDING').isPending, isTrue);
    expect(_status('CANCELLED').isCancelled, isTrue);
  });
}

ToolOrder _status(String s) => ToolOrder.fromJson({
  'id': 'o',
  'toolId': 't',
  'toolName': 'X',
  'unitPrice': 1,
  'quantity': 1,
  'totalPrice': 1,
  'status': s,
});
