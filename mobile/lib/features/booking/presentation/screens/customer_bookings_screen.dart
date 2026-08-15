import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../data/models/booking_models.dart';
import '../providers/booking_providers.dart';

/// Customer bookings dashboard (P4.11). Lists the signed-in customer's bookings
/// grouped into active / history; each card opens the booking detail + status
/// timeline (P4.9). Replaces the interim tracking launcher.
class CustomerBookingsScreen extends ConsumerWidget {
  const CustomerBookingsScreen({super.key});

  static const _activeSet = {'REQUESTED', 'ACCEPTED', 'EN_ROUTE', 'STARTED'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(profileProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBookingsProvider);
          await ref.read(myBookingsProvider.future);
        },
        child: meAsync.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (me) => bookingsAsync.when(
            loading: () => _spinner(),
            error: (e, _) => _message(e.toString()),
            data: (all) => _list(context, me, all),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, UserModel me, List<Booking> all) {
    final mine = all.where((b) => b.customerId == me.id).toList();
    final active = mine.where((b) => _activeSet.contains(b.status)).toList();
    final history = mine.where((b) => !_activeSet.contains(b.status)).toList();

    if (mine.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.event_note_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'No bookings yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find a trusted professional and book your first service.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Find a provider'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (active.isNotEmpty) ...[
          _sectionHeader('Active', active.length),
          for (final b in active) _bookingCard(context, b),
          const SizedBox(height: 8),
        ],
        if (history.isNotEmpty) ...[
          _sectionHeader('History', history.length),
          for (final b in history) _bookingCard(context, b),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Booking b) {
    final title = _notBlank(b.taskTitle)
        ? b.taskTitle!
        : (b.skillName ?? 'Booking');
    final showSkill = _notBlank(b.taskTitle) && b.skillName != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          onTap: () => context.push('/booking/${b.id}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (showSkill)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                b.skillName!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _statusChip(b.status),
                  ],
                ),
                const SizedBox(height: 12),
                _row(
                  Icons.event_outlined,
                  _fmtDateTime(b.scheduledAt.toLocal()),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _row(
                        Icons.payments_outlined,
                        '${_rs(b.totalPrice)} • ${_fmtHours(b.estimatedHours)}',
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textBody, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (label, color) = _statusMeta(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color) _statusMeta(String s) => switch (s) {
    'REQUESTED' => ('Requested', AppColors.accent),
    'ACCEPTED' => ('Accepted', AppColors.info),
    'EN_ROUTE' => ('On the way', AppColors.info),
    'STARTED' => ('In progress', AppColors.info),
    'COMPLETED' => ('Completed', AppColors.success),
    'RATED' => ('Reviewed', AppColors.success),
    'PAID' => ('Paid', AppColors.success),
    'CANCELLED' => ('Cancelled', AppColors.error),
    'DECLINED' => ('Declined', AppColors.error),
    'EXPIRED' => ('Expired', AppColors.textMuted),
    _ => (s, AppColors.textMuted),
  };

  Widget _spinner() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 160),
      Center(child: CircularProgressIndicator()),
    ],
  );

  Widget _message(String msg) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 120),
      const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
      const SizedBox(height: 8),
      Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    ],
  );

  bool _notBlank(String? v) => v != null && v.trim().isNotEmpty;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _rs(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  String _fmtHours(double h) =>
      h == h.roundToDouble() ? '${h.toInt()} h' : '${h.toStringAsFixed(1)} h';

  String _fmtDateTime(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year} · $h12:$mm $ampm';
  }
}
