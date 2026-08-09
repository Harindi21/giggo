import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A row of five orange stars for a 0–5 rating, with an optional review count.
/// Shows a muted "New" label when there are no reviews yet.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.size = 16,
    this.showValue = false,
  });

  final double rating;
  final int? count;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    if ((count ?? 0) == 0 && rating == 0) {
      return Text(
        'New',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: size * 0.8,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star_rounded
                : (rating >= i - 0.5
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded),
            size: size,
            color: AppColors.accent,
          ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ],
        if (count != null && count! > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(fontSize: size * 0.8, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
