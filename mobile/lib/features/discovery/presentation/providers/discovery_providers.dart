import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/discovery_repository.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/provider_models.dart';
import '../../data/models/review.dart';

/// All active service categories.
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(discoveryRepositoryProvider).getCategories();
});

/// Skills within a category.
final skillsProvider = FutureProvider.family<List<Skill>, String>((
  ref,
  categoryId,
) {
  return ref.watch(discoveryRepositoryProvider).getSkills(categoryId);
});

/// Filters for a provider search.
class ProviderQuery {
  final String? categoryId;
  final String? skillId;
  final String? district;
  final String? query;

  const ProviderQuery({
    this.categoryId,
    this.skillId,
    this.district,
    this.query,
  });

  ProviderQuery copyWith({
    Object? categoryId = _keep,
    Object? skillId = _keep,
    Object? district = _keep,
    Object? query = _keep,
  }) {
    return ProviderQuery(
      categoryId: categoryId == _keep ? this.categoryId : categoryId as String?,
      skillId: skillId == _keep ? this.skillId : skillId as String?,
      district: district == _keep ? this.district : district as String?,
      query: query == _keep ? this.query : query as String?,
    );
  }

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is ProviderQuery &&
      other.categoryId == categoryId &&
      other.skillId == skillId &&
      other.district == district &&
      other.query == query;

  @override
  int get hashCode => Object.hash(categoryId, skillId, district, query);
}

/// Provider search results for a set of filters.
final providerSearchProvider =
    FutureProvider.family<List<ProviderCard>, ProviderQuery>((ref, q) {
      return ref
          .watch(discoveryRepositoryProvider)
          .searchProviders(
            categoryId: q.categoryId,
            skillId: q.skillId,
            district: q.district,
            query: q.query,
          );
    });

/// Full detail for one provider.
final providerDetailProvider = FutureProvider.family<ProviderDetail, String>((
  ref,
  id,
) {
  return ref.watch(discoveryRepositoryProvider).getProvider(id);
});

/// Personalised "recommended for you" providers for the signed-in customer (P3.4).
final recommendedProvidersProvider = FutureProvider<List<ProviderCard>>((ref) {
  return ref.watch(discoveryRepositoryProvider).getRecommendations(limit: 10);
});

/// Reviews for a provider (by provider-profile id).
final providerReviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  id,
) {
  return ref.watch(discoveryRepositoryProvider).getProviderReviews(id);
});
