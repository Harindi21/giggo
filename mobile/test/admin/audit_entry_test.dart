import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin/data/models/audit_entry.dart';

void main() {
  test('parses an audit entry with actor and detail', () {
    final e = AuditEntry.fromJson({
      'id': 'a1',
      'actorName': 'Admin Ann',
      'action': 'PAYOUT_PAID',
      'targetType': 'PAYOUT',
      'targetId': 'po1',
      'detail': 'ref=BANK-9',
      'createdAt': '2026-08-21T10:00:00+05:30',
    });
    expect(e.action, 'PAYOUT_PAID');
    expect(e.actorName, 'Admin Ann');
    expect(e.detail, 'ref=BANK-9');
    expect(e.createdAt, isNotNull);
  });

  test('tolerates missing optional fields', () {
    final e = AuditEntry.fromJson({'id': 'a2', 'action': 'KYC_APPROVED'});
    expect(e.action, 'KYC_APPROVED');
    expect(e.actorName, isNull);
    expect(e.detail, isNull);
    expect(e.createdAt, isNull);
  });
}
