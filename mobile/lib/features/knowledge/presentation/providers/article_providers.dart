import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/article_repository.dart';
import '../../data/models/article_models.dart';

/// Published articles, optionally filtered by a search query (P9.8). An empty
/// query returns everything; category filtering happens client-side.
final articlesProvider = FutureProvider.family<List<Article>, String>((ref, q) {
  return ref.watch(articleRepositoryProvider).list(q: q.isEmpty ? null : q);
});

/// A single article by slug (with content).
final articleProvider = FutureProvider.family<Article, String>((ref, slug) {
  return ref.watch(articleRepositoryProvider).getBySlug(slug);
});

/// "Recommended for you" guides for the signed-in user (P9.3).
final recommendedArticlesProvider = FutureProvider<List<Article>>((ref) {
  return ref.watch(articleRepositoryProvider).getRecommended();
});
