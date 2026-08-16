import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/rating_stars.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows "New" when there are no reviews', (tester) async {
    await tester.pumpWidget(_wrap(const RatingStars(rating: 0, count: 0)));
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('renders five star icons and the value + count', (tester) async {
    await tester.pumpWidget(
      _wrap(const RatingStars(rating: 4.6, count: 12, showValue: true)),
    );
    // Five star slots are always drawn for a non-empty rating.
    final stars = find.byWidgetPredicate(
      (w) =>
          w is Icon &&
          (w.icon == Icons.star_rounded ||
              w.icon == Icons.star_half_rounded ||
              w.icon == Icons.star_outline_rounded),
    );
    expect(stars, findsNWidgets(5));
    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('(12)'), findsOneWidget);
  });
}
