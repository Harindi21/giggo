import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/admin_metrics_repository.dart';
import '../../data/models/admin_metrics.dart';

/// Admin analytics dashboard (P11.1, P11.7): GMV, jobs, users, disputes and
/// top categories, from GET /api/v1/admin/metrics.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminMetricsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminMetricsProvider);
          await ref.read(adminMetricsProvider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.bar_chart_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          data: (m) => _content(m),
        ),
      ),
    );
  }

  Widget _content(AdminMetrics m) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _gmvCard(m),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _stat('Active jobs', '${m.activeJobs}', Icons.work_outline),
            _stat(
              'Completed',
              '${m.completedJobs}',
              Icons.check_circle_outline,
            ),
            _stat('Conversion', '${m.conversionRate}%', Icons.percent),
            _stat('Repeat rate', '${m.repeatCustomerRate}%', Icons.repeat),
            _stat('Users', '${m.totalUsers}', Icons.people_outline),
            _stat('New (30d)', '${m.newUsers30d}', Icons.person_add_alt),
            _stat(
              'Providers',
              '${m.verifiedProviders}/${m.providers}',
              Icons.verified_outlined,
            ),
            _stat(
              'Open disputes',
              '${m.openDisputes}',
              Icons.gavel_outlined,
              alert: m.openDisputes > 0,
            ),
            _stat(
              'Tool orders',
              '${m.toolOrders}',
              Icons.shopping_bag_outlined,
            ),
            _stat('Tool sales', _money(m.toolSales), Icons.storefront_outlined),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Top categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _topCategories(m.topCategories),
      ],
    );
  }

  Widget _gmvCard(AdminMetrics m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gross merchandise value',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _money(m.gmv),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Platform revenue',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _money(m.platformRevenue),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String label,
    String value,
    IconData icon, {
    bool alert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert ? AppColors.error : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 18,
            color: alert ? AppColors.error : AppColors.primary,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: alert ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _topCategories(List<CategoryStat> categories) {
    if (categories.isEmpty) {
      return const Text(
        'No bookings yet.',
        style: TextStyle(color: AppColors.textMuted),
      );
    }
    final max = categories.first.bookings.clamp(1, 1 << 30);
    return Column(
      children: [
        for (final c in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    c.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: c.bookings / max,
                      minHeight: 10,
                      backgroundColor: AppColors.surfaceBlue.withValues(
                        alpha: 0.4,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${c.bookings}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _money(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'Rs. $buf';
  }
}
