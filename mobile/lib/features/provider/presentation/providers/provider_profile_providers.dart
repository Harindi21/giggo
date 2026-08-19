import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../discovery/data/discovery_repository.dart';
import '../../../discovery/data/models/catalog_models.dart';
import '../../data/models/provider_profile.dart';
import '../../data/provider_profile_repository.dart';

/// The signed-in provider's own profile.
final myProviderProfileProvider = FutureProvider<ProviderProfile>((ref) {
  return ref.watch(myProviderProfileRepositoryProvider).getMyProfile();
});

/// A category paired with its skills, for the profile skill picker.
typedef CategorySkills = ({Category category, List<Skill> skills});

/// The full service taxonomy (categories with their skills), loaded once for
/// the skill multi-select.
final catalogSkillsProvider = FutureProvider<List<CategorySkills>>((ref) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  final categories = await repo.getCategories();
  return Future.wait(
    categories.map(
      (c) async => (category: c, skills: await repo.getSkills(c.id)),
    ),
  );
});
