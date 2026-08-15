import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tool_models.dart';
import '../../data/tool_repository.dart';

/// All available tools (category filtering happens client-side).
final toolsProvider = FutureProvider<List<Tool>>((ref) {
  return ref.watch(toolRepositoryProvider).list();
});

/// A single tool by slug.
final toolProvider = FutureProvider.family<Tool, String>((ref, slug) {
  return ref.watch(toolRepositoryProvider).getBySlug(slug);
});
