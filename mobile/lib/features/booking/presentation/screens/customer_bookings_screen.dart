import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/giggo_top_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';
import '../providers/booking_providers.dart';

/// Customer tasks dashboard (P4.11), aligned to the Figma: a navy header over
/// four status sections (Tasks Requested, Tasks To Get Done, Ongoing Tasks and
/// Tasks Completed), each a light-blue card with the relevant actions.
class CustomerBookingsScreen extends ConsumerStatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  ConsumerState<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState
    extends ConsumerState<CustomerBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(profileProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBookingsProvider);
          await ref.read(myBookingsProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const GiggoTopBar(),
            meAsync.when(
              loading: _spinner,
              error: (e, _) => _message(e.toString()),
              data: (me) => bookingsAsync.when(
                loading: _spinner,
                error: (e, _) => _message(e.toString()),
                data: (all) => _content(me, all),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(UserModel me, List<Booking> all) {
    final l = AppLocalizations.of(context);
    final mine = all.where((b) => b.customerId == me.id).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    if (mine.isEmpty) return _empty();

    List<Booking> inState(Set<String> s) =>
        mine.where((b) => s.contains(b.status)).toList();

    final requested = inState({'REQUESTED'});
    final toDo = inState({'ACCEPTED'});
    final ongoing = inState({'EN_ROUTE', 'STARTED', 'COMPLETED'});
    final completed = inState({
      'PAID',
      'RATED',
      'CANCELLED',
      'DECLINED',
      'EXPIRED',
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(l.tasksRequested, requested),
          _section(l.tasksToGetDone, toDo),
          _section(l.tasksOngoing, ongoing),
          _section(l.tasksCompleted, completed),
        ],
      ),
    );
  }

  Widget _section(String title, List<Booking> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        for (final b in items) _card(b),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _card(Booking b) {
    final l = AppLocalizations.of(context);
    final title = _notBlank(b.taskTitle)
        ? b.taskTitle!
        : (b.skillName ?? l.tasksTaskFallback);
    final subtitle = _notBlank(b.taskTitle) ? b.skillName : null;
    final canCancel = b.status == 'REQUESTED' || b.status == 'ACCEPTED';
    final awaitingPay = b.status == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 8),
                _pill(l.commonCancel, () => _cancel(b)),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (_notBlank(b.description)) ...[
            const SizedBox(height: 6),
            Text(
              b.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textBody),
            ),
          ],
          if (awaitingPay) _times(b),
          const SizedBox(height: 14),
          _actions(b),
        ],
      ),
    );
  }

  /// Started / ended / duration block shown once the provider ends the task.
  Widget _times(Booking b) {
    final l = AppLocalizations.of(context);
    final lines = <String>[
      if (b.startedAt != null)
        l.tasksProviderStartedAt(_fmtTime(b.startedAt!.toLocal())),
      if (b.completedAt != null)
        l.tasksEndedAt(_fmtTime(b.completedAt!.toLocal())),
      if (b.startedAt != null && b.completedAt != null)
        l.tasksDuration(_duration(b.startedAt!, b.completedAt!)),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Text(
              line,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _actions(Booking b) {
    final l = AppLocalizations.of(context);
    final pills = <Widget>[];
    switch (b.status) {
      case 'REQUESTED':
      case 'ACCEPTED':
        pills.add(
          _pill(l.tasksViewFee, () => context.push('/booking/${b.id}')),
        );
        break;
      case 'EN_ROUTE':
      case 'STARTED':
        pills.add(_pill(l.tasksViewJourney, () => _openJourney(b)));
        pills.add(
          _pill(l.tasksViewFee, () => context.push('/booking/${b.id}')),
        );
        break;
      case 'COMPLETED':
        pills.add(_pill(l.tasksPayFee, () => context.push('/payment/${b.id}')));
        pills.add(
          _pill(l.tasksViewFee, () => context.push('/booking/${b.id}')),
        );
        break;
      case 'PAID':
        pills.add(_pill(l.tasksRate, () => context.push('/review/${b.id}')));
        pills.add(
          _pill(
            l.receiptTitle,
            () => context.push('/receipt/${b.id}'),
            subtle: true,
          ),
        );
        break;
      case 'RATED':
        pills.add(
          _pill(
            l.receiptTitle,
            () => context.push('/receipt/${b.id}'),
            subtle: true,
          ),
        );
        break;
      default: // CANCELLED / DECLINED / EXPIRED
        return Row(
          children: [
            _statusTag(b.status),
            const Spacer(),
            Text(
              _fmtDate(b.scheduledAt.toLocal()),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        );
    }

    final showContact = b.status != 'PAID' && b.status != 'RATED';
    return Row(
      children: [
        for (final p in pills) ...[p, const SizedBox(width: 10)],
        const Spacer(),
        if (showContact) ...[
          _circle(Icons.call, () => _comingSoon(l.tasksCalling)),
          const SizedBox(width: 10),
          _circle(Icons.chat_bubble, () => _comingSoon(l.tasksChat)),
        ] else
          Text(
            _fmtDate((b.completedAt ?? b.scheduledAt).toLocal()),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
      ],
    );
  }

  void _openJourney(Booking b) {
    var loc = '/track/${b.id}';
    if (b.latitude != null && b.longitude != null) {
      loc += '?destLat=${b.latitude}&destLng=${b.longitude}';
    }
    context.push(loc);
  }

  Future<void> _cancel(Booking b) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(l.tasksCancelTaskTitle),
        content: Text(l.tasksCancelTaskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(l.tasksKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: Text(
              l.tasksCancelTask,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(b.id);
      ref.invalidate(myBookingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.tasksTaskCancelled)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.tasksCouldNotCancel('$e'))));
      }
    }
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).tasksComingSoon(what)),
      ),
    );
  }

  // ---- Small building blocks ----

  Widget _pill(String label, VoidCallback onTap, {bool subtle = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: subtle
              ? AppColors.accent.withValues(alpha: 0.14)
              : AppColors.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: subtle ? AppColors.accentDark : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  Widget _statusTag(String status) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'CANCELLED' => (l.statusCancelled, AppColors.error),
      'DECLINED' => (l.statusDeclined, AppColors.error),
      'EXPIRED' => (l.statusExpired, AppColors.textMuted),
      _ => (status, AppColors.textMuted),
    };
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

  Widget _empty() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Column(
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            l.tasksNoTasks,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.tasksNoTasksBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.search, size: 18),
            label: Text(l.tasksFindProvider),
          ),
        ],
      ),
    );
  }

  Widget _spinner() => const Padding(
    padding: EdgeInsets.only(top: 160),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _message(String msg) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
    child: Column(
      children: [
        const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
        const SizedBox(height: 8),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    ),
  );

  bool _notBlank(String? v) => v != null && v.trim().isNotEmpty;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmtDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _duration(DateTime a, DateTime b) {
    final mins = b.difference(a).inMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    return '${h}h ${m}min';
  }
}
