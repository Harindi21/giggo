import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/knowledge/data/models/article_models.dart';

void main() {
  test('parses a full article (with content)', () {
    final a = Article.fromJson({
      'id': 'a1',
      'slug': 'staying-safe',
      'title': 'Staying safe',
      'category': 'Safety',
      'excerpt': 'A few habits go a long way.',
      'content': 'Para one.\n\nPara two.',
      'authorName': 'GIGGO Team',
      'publishedAt': '2026-08-16T00:00:00+05:30',
    });
    expect(a.slug, 'staying-safe');
    expect(a.content, contains('Para two'));
    expect(a.authorName, 'GIGGO Team');
    expect(a.publishedAt, isNotNull);
  });

  test('parses a summary (no content) and defaults author', () {
    final a = Article.fromJson({
      'id': 'a2',
      'slug': 'tips',
      'title': 'Tips',
      'category': 'For Customers',
      'excerpt': 'Short.',
    });
    expect(a.content, isNull);
    expect(a.authorName, 'GIGGO Team');
  });
}
