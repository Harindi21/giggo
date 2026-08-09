import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/provider_avatar.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../data/models/provider_models.dart';
import '../providers/discovery_providers.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(providerDetailProvider(providerId));

    return Scaffold(
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _error(context, e.toString()),
        data: (p) => _content(context, p),
      ),
      bottomNavigationBar: detail.maybeWhen(
        data: (p) => _bookBar(context, p),
        orElse: () => null,
      ),
    );
  }

  Widget _content(BuildContext context, ProviderDetail p) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(context, p)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statsRow(p),
                const SizedBox(height: 20),
                if (p.bio != null && p.bio!.isNotEmpty) ...[
                  _sectionTitle('About'),
                  const SizedBox(height: 6),
                  Text(p.bio!, style: const TextStyle(color: AppColors.textBody, height: 1.4)),
                  const SizedBox(height: 20),
                ],
                if (p.skills.isNotEmpty) ...[
                  _sectionTitle('Services offered'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final s in p.skills) Chip(label: Text(s.name))],
                  ),
                  const SizedBox(height: 20),
                ],
                _sectionTitle('Pricing'),
                const SizedBox(height: 10),
                _pricingCard(p),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, ProviderDetail p) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ProviderAvatar(name: p.fullName, imageUrl: p.avatarUrl, radius: 38),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  p.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (p.verified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 18, color: AppColors.accent),
                              ],
                            ],
                          ),
                          if (p.headline != null) ...[
                            const SizedBox(height: 2),
                            Text(p.headline!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                          const SizedBox(height: 6),
                          RatingStars(rating: p.avgRating, count: p.ratingCount, size: 16, showValue: true),
                          if (p.district != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(
                                  [p.addressLine, p.district].where((e) => e != null && e.isNotEmpty).join(', '),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow(ProviderDetail p) {
    return Row(
      children: [
        _stat('${p.jobsCompleted}', 'Jobs done'),
        _stat('${p.yearsExperience} yr', 'Experience'),
        _stat(p.available ? 'Available' : 'Busy', 'Status',
            color: p.available ? AppColors.success : AppColors.warning),
      ],
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: color ?? AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _pricingCard(ProviderDetail p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _priceRow('Base fee', 'Rs. ${p.basePrice.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _priceRow('Work fee', 'Rs. ${p.hourlyRate.toStringAsFixed(0)} / hour'),
          const SizedBox(height: 8),
          _priceRow('Travel', 'Rs. 50 / km', muted: true),
          const Divider(height: 20),
          const Text(
            'Final price is confirmed with a full breakdown before you book.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: muted ? AppColors.textMuted : AppColors.textBody)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: muted ? AppColors.textMuted : AppColors.textPrimary)),
      ],
    );
  }

  Widget _bookBar(BuildContext context, ProviderDetail p) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Starting from', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('Rs. ${p.basePrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: p.available
                    ? () {
                        // Booking flow is wired in Phase B (P4).
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking flow arrives in the next update.')),
                        );
                      }
                    : null,
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      );

  Widget _error(BuildContext context, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
              const SizedBox(height: 8),
              Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
}
