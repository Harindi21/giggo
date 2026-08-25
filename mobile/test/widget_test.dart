import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('App renders the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GiggoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
  });
}
