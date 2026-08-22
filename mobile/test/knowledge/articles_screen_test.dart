import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/knowledge/data/models/article_models.dart';
import 'package:mobile/features/knowledge/presentation/providers/article_providers.dart';
import 'package:mobile/features/knowledge/presentation/screens/articles_screen.dart';

void main() {
  testWidgets('renders articles and a category filter chip', (tester) async {
    final articles = [
      const Article(
        id: 'a1',
        slug: 'staying-safe',
        title: 'Staying safe with home services',
        category: 'Safety',
        excerpt: 'A few habits go a long way.',
        authorName: 'GIGGO Team',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [articlesProvider.overrideWith((ref, q) async => articles)],
        child: const MaterialApp(home: ArticlesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Staying safe with home services'), findsOneWidget);
    expect(find.text('A few habits go a long way.'), findsOneWidget);
    // "All" chip plus the article's own category.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Safety'), findsWidgets);
  });
}
