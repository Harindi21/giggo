import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';
import '../providers/booking_providers.dart';

/// Provider job management (P4.10). Lists the jobs assigned to the signed-in
/// provider, grouped into new requests / active / past, with inline lifecycle
/// actions (accept, decline, en route, start, complete) that drive the exact
/// timeline the customer sees.
class ProviderJobsScreen extends ConsumerStatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  ConsumerState<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends ConsumerState<ProviderJobsScreen> {
  static const _activeSet = {'ACCEPTED', 'EN_ROUTE', 'STARTED'};
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(profileProvider);
    final jobsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myBookingsProvider);
          await ref.read(myBookingsProvider.future);
        },
        child: meAsync.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (me) => jobsAsync.when(
            loading: () => _spinner(),
            error: (e, _) => _message(e.toString()),
            data: (all) => _list(me, all),
          ),
        ),
      ),
    );
  }

  Widget _list(UserModel me, List<Booking> all) {
    final mine = all.where((b) => b.providerId == me.id).toList();
    final requests = mine.where((b) => b.status == 'REQUESTED').toList();
    final active = mine.where((b) => _activeSet.contains(b.status)).toList();
    final past = mine
        .where((b) => b.status != 'REQUESTED' && !_activeSet.contains(b.status))
        .toList();

    if (mine.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.work_outline, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'No jobs yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'New booking requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (requests.isNotEmpty) ...[
          _sectionHeader('New requests', requests.length),
          for (final b in requests) _jobCard(b),
          const SizedBox(height: 8),
        ],
        if (active.isNotEmpty) ...[
          _sectionHeader('Active', active.length),
          for (final b in active) _jobCard(b),
          const SizedBox(height: 8),
        ],
        if (past.isNotEmpty) ...[
          _sectionHeader('Past', past.length),
          for (final b in past) _jobCard(b),
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

  Widget _jobCard(Booking b) {
    final title = _notBlank(b.taskTitle)
        ? b.taskTitle!
        : (b.skillName ?? 'Job');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                    if (_notBlank(b.taskTitle) && b.skillName != null)
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
          _row(Icons.event_outlined, _fmtDateTime(b.scheduledAt.toLocal())),
          if (_notBlank(b.contactName))
            _row(Icons.person_outline, b.contactName!),
          if (_notBlank(b.addressLine))
            _row(Icons.location_on_outlined, b.addressLine!),
          _row(
            Icons.payments_outlined,
            '${_rs(b.totalPrice)} • ${_fmtHours(b.estimatedHours)}',
          ),
          const SizedBox(height: 4),
          _actions(b),
        ],
      ),
    );
  }

  Widget _actions(Booking b) {
    final busy = _busyId == b.id;
    switch (b.status) {
      case 'REQUESTED':
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _decline(b),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy
                      ? null
                      : () => _run(
                          b.id,
                          () =>
                              ref.read(bookingRepositoryProvider).accept(b.id),
                          'Job accepted',
                        ),
                  child: _label(busy, 'Accept'),
                ),
              ),
            ],
          ),
        );
      case 'ACCEPTED':
        return _advanceRow(
          b,
          busy,
          'Start travel',
          () => ref.read(bookingRepositoryProvider).enRoute(b.id),
          'On the way',
          cancellable: true,
        );
      case 'EN_ROUTE':
        return _advanceRow(
          b,
          busy,
          'Start job',
          () => ref.read(bookingRepositoryProvider).start(b.id),
          'Job started',
          cancellable: true,
        );
      case 'STARTED':
        return _advanceRow(
          b,
          busy,
          'Mark complete',
          () => ref.read(bookingRepositoryProvider).complete(b.id),
          'Job completed',
          cancellable: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _advanceRow(
    Booking b,
    bool busy,
    String label,
    Future<Booking> Function() op,
    String okMsg, {
    required bool cancellable,
  }) {
    final primary = ElevatedButton.icon(
      onPressed: busy ? null : () => _run(b.id, op, okMsg),
      icon: busy
          ? const SizedBox.shrink()
          : const Icon(Icons.arrow_forward, size: 18),
      label: _label(busy, label),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (cancellable) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => _cancel(b),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: primary),
        ],
      ),
    );
  }

  Widget _label(bool busy, String text) => busy
      ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : Text(text);

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
    final ok = await _confirm(
      'Decline this request?',
      'The customer will be notified that you can\'t take this job.',
      'Decline',
    );
    if (!ok) return;
    await _run(
      b.id,
      () => ref.read(bookingRepositoryProvider).decline(b.id),
      'Request declined',
    );
  }

  Future<void> _cancel(Booking b) async {
    final ok = await _confirm(
      'Cancel this job?',
      'This cancels an accepted job. The customer will be notified.',
      'Cancel job',
    );
    if (!ok) return;
    await _run(
      b.id,
      () => ref.read(bookingRepositoryProvider).cancelBooking(b.id),
      'Job cancelled',
    );
  }

  Future<bool> _confirm(
    String title,
    String message,
    String confirmLabel,
  ) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
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
    'REQUESTED' => ('New', AppColors.accent),
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
