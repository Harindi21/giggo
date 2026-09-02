import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/data/models/provider_models.dart';
import 'package:mobile/features/discovery/presentation/widgets/provider_card_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

ProviderCard _card({bool verified = true}) => ProviderCard(
  id: 'pp1',
  userId: 'u1',
  fullName: 'Kamal Silva',
  headline: 'Experienced Plumber',
  district: 'Colombo',
  avgRating: 4.6,
  ratingCount: 12,
  jobsCompleted: 20,
  basePrice: 1500,
  hourlyRate: 800,
  available: true,
  verified: verified,
);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows name, location and a Book Now action', (tester) async {
    await tester.pumpWidget(_wrap(ProviderCardTile(provider: _card())));
    expect(find.text('Kamal Silva'), findsOneWidget);
    expect(find.text('Colombo'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });

  testWidgets('hides the verified badge for an unverified provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ProviderCardTile(provider: _card(verified: false))),
    );
    expect(find.byIcon(Icons.verified), findsNothing);
  });
}
