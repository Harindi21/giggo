import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_review_repository.dart';
import '../../data/models/admin_review_models.dart';

/// Admin review queue; `reportedOnly` filters to reported reviews (P6.5).
final adminReviewsProvider = FutureProvider.family<List<AdminReview>, bool>((
  ref,
  reportedOnly,
) {
  return ref
      .watch(adminReviewRepositoryProvider)
      .list(reportedOnly: reportedOnly);
});
