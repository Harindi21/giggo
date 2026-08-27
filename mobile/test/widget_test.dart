import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('App boots through splash into onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GiggoApp()));
    await tester.pump(); // splash first frame

    // The splash schedules a short timer before moving to onboarding.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.textContaining('Continue'), findsOneWidget);
  });
}
