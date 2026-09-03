import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/sentiment_badge.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('maps sentiment labels to text', (tester) async {
    await tester.pumpWidget(_wrap(const SentimentBadge(label: 'positive')));
    expect(find.text('Positive'), findsOneWidget);

    await tester.pumpWidget(_wrap(const SentimentBadge(label: 'negative')));
    expect(find.text('Negative'), findsOneWidget);

    await tester.pumpWidget(_wrap(const SentimentBadge(label: 'neutral')));
    expect(find.text('Mixed'), findsOneWidget);
  });

  testWidgets('renders nothing for a null/empty label', (tester) async {
    await tester.pumpWidget(_wrap(const SentimentBadge(label: null)));
    expect(find.byType(Text), findsNothing);
  });
}
