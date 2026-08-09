import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/provider_avatar.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../data/models/provider_models.dart';

/// White provider card for list/search screens — avatar, name (+ verified),
/// headline/district, stars, price and a "Book Now" pill (mockup image27).
class ProviderCardTile extends StatelessWidget {
  const ProviderCardTile({super.key, required this.provider, this.onTap, this.onBook});

  final ProviderCard provider;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProviderAvatar(name: provider.fullName, imageUrl: provider.avatarUrl, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (provider.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 16, color: AppColors.info),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [provider.headline, provider.district].where((e) => e != null && e.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    RatingStars(rating: provider.avgRating, count: provider.ratingCount, size: 15),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${provider.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const Text('from', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onBook ?? onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
