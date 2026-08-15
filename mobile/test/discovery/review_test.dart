import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/data/models/review.dart';

void main() {
  test('parses a review with sentiment', () {
    final r = Review.fromJson({
      'id': 'r1',
      'reviewerName': 'Ann',
      'stars': 5,
      'body': 'great work',
      'sentimentLabel': 'positive',
      'sentimentStar': 5,
      'sentimentEmotion': 'satisfaction',
      'enhancedRating': 4.8,
      'createdAt': '2026-08-15T10:00:00+05:30',
    });
    expect(r.stars, 5);
    expect(r.reviewerName, 'Ann');
    expect(r.sentimentLabel, 'positive');
    expect(r.enhancedRating, 4.8);
    expect(r.createdAt, isNotNull);
  });

  test('handles a bare review (no sentiment / body)', () {
    final r = Review.fromJson({'id': 'r2', 'stars': 3});
    expect(r.sentimentLabel, isNull);
    expect(r.body, isNull);
    expect(r.createdAt, isNull);
  });
}
