import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Small coloured pill showing a review's NLP sentiment (Positive / Mixed / Negative).
class SentimentBadge extends StatelessWidget {
  const SentimentBadge({super.key, required this.label});

  final String? label; // positive | neutral | negative

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return const SizedBox.shrink();
    final (text, color) = switch (label!.toLowerCase()) {
      'positive' => ('Positive', AppColors.success),
      'negative' => ('Negative', AppColors.error),
      _ => ('Mixed', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
