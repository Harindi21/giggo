import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/provider_avatar.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../../core/widgets/sentiment_badge.dart';
import '../../data/models/review.dart';

/// A single review (mockup image44 "Reviews About You"): reviewer, stars, text,
/// date and the NLP sentiment badge.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.onReport});

  final Review review;

  /// When provided, shows a small "report" action for moderation (P6.5).
  final VoidCallback? onReport;

  String _date(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProviderAvatar(
                name: review.reviewerName ?? 'Customer',
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? 'Customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RatingStars(rating: review.stars.toDouble(), size: 14),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  _date(review.createdAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              if (onReport != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Report',
                  onPressed: onReport,
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          if (review.body != null && review.body!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.body!,
              style: const TextStyle(color: AppColors.textBody, height: 1.35),
            ),
          ],
          if (review.sentimentLabel != null) ...[
            const SizedBox(height: 8),
            SentimentBadge(label: review.sentimentLabel),
          ],
        ],
      ),
    );
  }
}
