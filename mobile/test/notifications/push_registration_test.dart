import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/push_registration.dart';

void main() {
  test('platformTag returns a backend DevicePlatform value', () {
    // The default test platform is android.
    expect(platformTag(), anyOf('ANDROID', 'IOS', 'WEB'));
  });

  test('generatePushToken is a stub-prefixed opaque token', () {
    final a = generatePushToken();
    final b = generatePushToken();
    expect(a, startsWith('stub-'));
    expect(a.length, greaterThan('stub-'.length + 16));
    expect(a, isNot(equals(b))); // random per call
  });
}
