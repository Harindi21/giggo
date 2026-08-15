import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/discovery_providers.dart';
import 'review_card.dart';

/// "Reviews" section for the provider detail screen (P6.8 + P6.9 sentiment badges).
class ProviderReviewsSection extends ConsumerWidget {
  const ProviderReviewsSection({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(providerReviewsProvider(providerId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        reviews.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const Text('Could not load reviews.',
              style: TextStyle(color: AppColors.textMuted)),
          data: (list) {
            if (list.isEmpty) {
              return const Text('No reviews yet — be the first after your booking.',
                  style: TextStyle(color: AppColors.textMuted));
            }
            return Column(
              children: [
                for (final r in list) ...[
                  ReviewCard(review: r),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
