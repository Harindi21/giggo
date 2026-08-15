import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/article_repository.dart';
import '../../data/models/article_models.dart';

/// All published articles (category filtering happens client-side).
final articlesProvider = FutureProvider<List<Article>>((ref) {
  return ref.watch(articleRepositoryProvider).list();
});

/// A single article by slug (with content).
final articleProvider = FutureProvider.family<Article, String>((ref, slug) {
  return ref.watch(articleRepositoryProvider).getBySlug(slug);
});
