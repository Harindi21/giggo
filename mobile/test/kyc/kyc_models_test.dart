import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/kyc/data/models/kyc_models.dart';

void main() {
  test('parses an approved submission', () {
    final k = KycSubmission.fromJson({
      'id': 'k1',
      'fullName': 'Nimal Perera',
      'documentType': 'NIC',
      'documentNumber': '199012345678',
      'status': 'APPROVED',
      'submittedAt': '2026-08-16T00:00:00+05:30',
      'reviewedAt': '2026-08-16T01:00:00+05:30',
    });
    expect(k.fullName, 'Nimal Perera');
    expect(k.documentType, 'NIC');
    expect(k.isApproved, isTrue);
    expect(k.isPending, isFalse);
  });

  test('exposes pending/rejected getters', () {
    expect(_status('PENDING').isPending, isTrue);
    final rejected = _status('REJECTED');
    expect(rejected.isRejected, isTrue);
    expect(rejected.isApproved, isFalse);
  });
}

KycSubmission _status(String s) => KycSubmission.fromJson({
  'id': 'k',
  'fullName': 'X',
  'documentType': 'NIC',
  'documentNumber': '1',
  'status': s,
});
