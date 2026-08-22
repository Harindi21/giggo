import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/discovery_providers.dart';

/// Per-dimension rating breakdown on the provider detail screen (P6.6).
/// Hidden entirely until at least one dimension has been rated.
class RatingBreakdownSection extends ConsumerWidget {
  const RatingBreakdownSection({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ratingBreakdownProvider(providerId));
    return async.maybeWhen(
      data: (b) {
        if (!b.hasRatings) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _bar('Service', b.service),
            _bar('Punctuality', b.punctuality),
            _bar('Value', b.value),
            const SizedBox(height: 8),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _bar(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textBody),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score <= 0 ? 0 : score / 5.0,
                minHeight: 10,
                backgroundColor: AppColors.surfaceBlue.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              score <= 0 ? '—' : score.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
