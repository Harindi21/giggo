import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/discovery_repository.dart';
import '../providers/discovery_providers.dart';
import 'review_card.dart';

/// "Reviews" section for the provider detail screen (P6.8 + P6.9 sentiment badges).
class ProviderReviewsSection extends ConsumerWidget {
  const ProviderReviewsSection({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reviews = ref.watch(providerReviewsProvider(providerId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.reviewsTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        reviews.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            l.reviewsLoadError,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Text(
                l.reviewsEmpty,
                style: const TextStyle(color: AppColors.textMuted),
              );
            }
            return Column(
              children: [
                for (final r in list) ...[
                  ReviewCard(
                    review: r,
                    onReport: () => _report(context, ref, r.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _report(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.reviewReportTitle),
        content: Text(l.reviewReportBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.reviewReport),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(discoveryRepositoryProvider).reportReview(reviewId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.reviewReported)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
