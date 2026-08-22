import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/data/models/rating_breakdown.dart';

void main() {
  test('parses dimension averages and reports hasRatings', () {
    final b = RatingBreakdown.fromJson({
      'service': 4.3,
      'punctuality': 0.0,
      'value': 3.9,
      'count': 8,
    });
    expect(b.service, 4.3);
    expect(b.punctuality, 0.0);
    expect(b.value, 3.9);
    expect(b.count, 8);
    expect(b.hasRatings, isTrue);
  });

  test('hasRatings is false when nothing is scored', () {
    final b = RatingBreakdown.fromJson({
      'service': 0,
      'punctuality': 0,
      'value': 0,
      'count': 0,
    });
    expect(b.hasRatings, isFalse);
  });
}
