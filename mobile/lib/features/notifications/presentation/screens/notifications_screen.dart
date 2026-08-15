import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_models.dart';
import '../../data/notification_repository.dart';
import '../providers/notification_providers.dart';

/// Notifications inbox (P8.2). Lists the user's notifications; tapping one marks
/// it read and opens the related booking. Surfaces the P8.1 backend inbox.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(ref),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
          await ref.read(notificationsProvider.future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _list(context, ref, items),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> items,
  ) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.notifications_none, size: 56, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Updates about your bookings will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 68, color: AppColors.divider),
      itemBuilder: (context, i) => _tile(context, ref, items[i]),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, AppNotification n) {
    final (icon, color) = _meta(n.type);
    return Material(
      color: n.read
          ? AppColors.surface
          : AppColors.surfaceBlue.withValues(alpha: 0.35),
      child: InkWell(
        onTap: () => _open(context, ref, n),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.body,
                      style: const TextStyle(
                        color: AppColors.textBody,
                        fontSize: 13,
                      ),
                    ),
                    if (n.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _fmtWhen(n.createdAt!.toLocal()),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!n.read)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    try {
      await ref.read(notificationRepositoryProvider).markRead(n.id);
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (_) {
      // Non-fatal: still navigate.
    }
    if (n.bookingId != null && context.mounted) {
      context.push('/booking/${n.bookingId}');
    }
  }

  Future<void> _markAllRead(WidgetRef ref) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (_) {
      // ignore; a refresh will reflect the true state
    }
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadCountProvider);
  }

  (IconData, Color) _meta(String type) => switch (type) {
    'BOOKING_REQUESTED' => (Icons.assignment_outlined, AppColors.accent),
    'BOOKING_ACCEPTED' => (Icons.check_circle_outline, AppColors.success),
    'BOOKING_EN_ROUTE' => (Icons.directions_car_filled, AppColors.info),
    'BOOKING_STARTED' => (Icons.build_outlined, AppColors.info),
    'BOOKING_COMPLETED' => (Icons.task_alt, AppColors.success),
    'BOOKING_CANCELLED' => (Icons.cancel_outlined, AppColors.error),
    'BOOKING_DECLINED' => (Icons.block, AppColors.error),
    'BOOKING_EXPIRED' => (Icons.timer_off_outlined, AppColors.textMuted),
    'PAYMENT_RELEASED' => (Icons.payments_outlined, AppColors.success),
    'REVIEW_RECEIVED' => (Icons.star_rounded, AppColors.accent),
    _ => (Icons.notifications_outlined, AppColors.primary),
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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmtWhen(DateTime dt) {
    final now = DateTime.now();
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final mm = dt.minute.toString().padLeft(2, '0');
    final time = '$h12:$mm $ampm';
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today · $time';
    }
    return '${_months[dt.month - 1]} ${dt.day} · $time';
  }
}
