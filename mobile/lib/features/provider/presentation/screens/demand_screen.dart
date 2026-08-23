import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/demand_repository.dart';
import '../../data/models/demand.dart';

/// Provider demand insights (AI #4): per-category weekly demand + next-week
/// forecast and trend, from GET /api/v1/provider/demand.
class DemandScreen extends ConsumerWidget {
  const DemandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myDemandProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Demand insights')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myDemandProvider);
          await ref.read(myDemandProvider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 100),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.insights_outlined, size: 56, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No demand data yet.\nAdd skills to your profile to see insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Bookings per week over the last 8 weeks, with next week\'s '
                    'forecast for your service categories.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ),
                for (final d in items) _card(d),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(CategoryDemand d) {
    final (Color color, IconData icon, String label) = switch (d.trend) {
      'rising' => (AppColors.success, Icons.trending_up, 'Rising'),
      'falling' => (AppColors.error, Icons.trending_down, 'Falling'),
      _ => (AppColors.textMuted, Icons.trending_flat, 'Steady'),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bars(d.weeklyCounts),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Next week forecast: ',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              Text(
                '~${d.forecastNextWeek} booking${d.forecastNextWeek == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bars(List<int> counts) {
    final max = counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final c in counts)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$c',
                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: (44 * (c / max)).clamp(3, 44).toDouble(),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
