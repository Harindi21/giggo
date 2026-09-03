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

/// Provider job management (P4.10), aligned to the Figma: a navy header over
/// four sections (Tasks Requests, Tasks To Do, Ongoing Tasks, Tasks Completed)
/// with the lifecycle actions (accept/deny, start journey, start task, end task)
/// that drive the exact timeline the customer sees.
class ProviderJobsScreen extends ConsumerStatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  ConsumerState<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends ConsumerState<ProviderJobsScreen> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(profileProvider);
    final jobsAsync = ref.watch(myBookingsProvider);

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
              data: (me) => jobsAsync.when(
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
    final mine = all.where((b) => b.providerId == me.id).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    if (mine.isEmpty) return _empty();

    List<Booking> inState(Set<String> s) =>
        mine.where((b) => s.contains(b.status)).toList();

    final requests = inState({'REQUESTED'});
    final toDo = inState({'ACCEPTED'});
    final ongoing = inState({'EN_ROUTE', 'STARTED'});
    final completed = inState({
      'COMPLETED',
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
          _section(l.tasksRequests, requests),
          _section(l.tasksToDo, toDo),
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
    final name = _notBlank(b.contactName)
        ? b.contactName!
        : (_notBlank(b.taskTitle)
              ? b.taskTitle!
              : (b.skillName ?? l.tasksJobFallback));
    final service = _notBlank(b.contactName)
        ? (b.taskTitle ?? b.skillName)
        : (_notBlank(b.taskTitle) ? b.skillName : null);
    final busy = _busyId == b.id;

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
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ..._topRightActions(b, busy),
            ],
          ),
          if (service != null) ...[
            const SizedBox(height: 4),
            Text(
              service,
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
          const SizedBox(height: 10),
          if (_notBlank(b.addressLine))
            _infoRow(Icons.location_on_outlined, b.addressLine!),
          _infoRow(Icons.event_outlined, _fmtDateTime(b.scheduledAt.toLocal())),
          if (b.status == 'STARTED' && b.startedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              l.tasksStartedAt(_fmtTime(b.startedAt!.toLocal())),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _bottomActions(b, busy),
        ],
      ),
    );
  }

  /// Accept/Deny (requests) or Cancel (accepted / en route), top-right of card.
  List<Widget> _topRightActions(Booking b, bool busy) {
    final l = AppLocalizations.of(context);
    switch (b.status) {
      case 'REQUESTED':
        return [
          _pill(
            l.tasksAccept,
            busy
                ? null
                : () => _run(
                    b.id,
                    () => ref.read(bookingRepositoryProvider).accept(b.id),
                    l.jobAccepted,
                  ),
          ),
          const SizedBox(width: 8),
          _pill(l.tasksDeny, busy ? null : () => _decline(b), subtle: true),
        ];
      case 'ACCEPTED':
      case 'EN_ROUTE':
        return [_pill(l.commonCancel, busy ? null : () => _cancel(b))];
      default:
        return const [];
    }
  }

  Widget _bottomActions(Booking b, bool busy) {
    final l = AppLocalizations.of(context);
    final pills = <Widget>[];
    switch (b.status) {
      case 'REQUESTED':
        pills.add(_pill(l.tasksViewMap, () => _openMap(b)));
        pills.add(
          _pill(l.tasksViewFee, () => context.push('/booking/${b.id}')),
        );
        break;
      case 'ACCEPTED':
        pills.add(
          _pill(
            l.tasksStartJourney,
            busy
                ? null
                : () => _run(
                    b.id,
                    () => ref.read(bookingRepositoryProvider).enRoute(b.id),
                    l.jobOnTheWay,
                  ),
          ),
        );
        pills.add(_pill(l.tasksViewMap, () => _openMap(b)));
        break;
      case 'EN_ROUTE':
        pills.add(
          _pill(
            l.tasksStartTask,
            busy
                ? null
                : () => _run(
                    b.id,
                    () => ref.read(bookingRepositoryProvider).start(b.id),
                    l.jobStarted,
                  ),
          ),
        );
        pills.add(_pill(l.tasksViewJourney, () => _openMap(b)));
        break;
      case 'STARTED':
        pills.add(
          _pill(
            l.tasksEndTask,
            busy
                ? null
                : () => _run(
                    b.id,
                    () => ref.read(bookingRepositoryProvider).complete(b.id),
                    l.jobCompleted,
                  ),
          ),
        );
        pills.add(
          _pill(l.tasksViewFee, () => context.push('/booking/${b.id}')),
        );
        break;
      default: // COMPLETED / PAID / RATED / CANCELLED / DECLINED / EXPIRED
        return Row(
          children: [
            _statusTag(b.status),
            const Spacer(),
            Text(
              _fmtDate((b.completedAt ?? b.scheduledAt).toLocal()),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        );
    }

    return Row(
      children: [
        for (final p in pills) ...[p, const SizedBox(width: 10)],
        const Spacer(),
        _circle(Icons.call, () => _comingSoon(l.tasksCalling)),
        const SizedBox(width: 10),
        _circle(Icons.chat_bubble, () => _comingSoon(l.tasksChat)),
      ],
    );
  }

  void _openMap(Booking b) {
    var loc = '/track/${b.id}';
    if (b.latitude != null && b.longitude != null) {
      loc += '?destLat=${b.latitude}&destLng=${b.longitude}';
    }
    context.push(loc);
  }

  void _comingSoon(String what) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).tasksComingSoon(what)),
      ),
    );
  }

  // ---- actions plumbing ----
  Future<void> _run(
    String id,
    Future<Booking> Function() op,
    String okMsg,
  ) async {
    setState(() => _busyId = id);
    try {
      await op();
      ref.invalidate(myBookingsProvider);
      _snack(okMsg);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _decline(Booking b) async {
    final l = AppLocalizations.of(context);
    final ok = await _confirm(
      l.tasksDeclineTitle,
      l.tasksDeclineBody,
      l.tasksDecline,
    );
    if (!ok) return;
    await _run(
      b.id,
      () => ref.read(bookingRepositoryProvider).decline(b.id),
      l.requestDeclined,
    );
  }

  Future<void> _cancel(Booking b) async {
    final l = AppLocalizations.of(context);
    final ok = await _confirm(
      l.tasksCancelJobTitle,
      l.tasksCancelJobBody,
      l.tasksCancelJob,
    );
    if (!ok) return;
    await _run(
      b.id,
      () => ref.read(bookingRepositoryProvider).cancelBooking(b.id),
      l.jobCancelled,
    );
  }

  Future<bool> _confirm(
    String title,
    String message,
    String confirmLabel,
  ) async {
    final l = AppLocalizations.of(context);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.tasksKeep),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- small UI helpers ----
  Widget _pill(String label, VoidCallback? onTap, {bool subtle = false}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: subtle
              ? AppColors.accent.withValues(alpha: 0.14)
              : AppColors.accent.withValues(alpha: enabled ? 1 : 0.5),
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

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textBody, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTag(String status) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'COMPLETED' => (l.statusCompleted, AppColors.success),
      'PAID' => (l.statusPaid, AppColors.success),
      'RATED' => (l.statusRated, AppColors.success),
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
          const Icon(Icons.work_outline, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            l.tasksNoJobs,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.tasksNoJobsBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
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

  String _fmtDateTime(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year} · $h12:$mm $ampm';
  }
}
