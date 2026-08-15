import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';
import '../../data/models/payment_models.dart';
import '../providers/booking_providers.dart';

/// Customer job timeline / booking detail (P4.9). Shows the live lifecycle of a
/// booking as a vertical status timeline, the booking details and price
/// snapshot, and status-aware actions (track live / leave review / cancel).
class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

enum _NodeState { done, current, pending, cancelled }

class _Node {
  final String label;
  final String? subtitle;
  final DateTime? time;
  final IconData icon;
  final _NodeState state;
  const _Node(this.label, this.subtitle, this.time, this.icon, this.state);
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  static const _happyPath = [
    'REQUESTED',
    'ACCEPTED',
    'EN_ROUTE',
    'STARTED',
    'COMPLETED',
  ];
  static const _negative = {'CANCELLED', 'DECLINED', 'EXPIRED'};
  static const _active = {'REQUESTED', 'ACCEPTED', 'EN_ROUTE', 'STARTED'};

  bool _cancelling = false;

  String get _id => widget.bookingId;

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(_id));
    return Scaffold(
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _error(e.toString()),
        data: (b) => _content(b),
      ),
      bottomNavigationBar: bookingAsync.maybeWhen(
        data: (b) => _actionBar(b),
        orElse: () => null,
      ),
    );
  }

  Widget _content(Booking b) {
    final events = ref.watch(bookingTimelineProvider(_id)).value ?? const [];
    final providerName = ref
        .watch(providerDetailProvider(b.providerId))
        .value
        ?.fullName;
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(b, providerName),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Progress'),
                const SizedBox(height: 14),
                _timeline(b, events),
                const SizedBox(height: 20),
                _sectionTitle('Booking details'),
                const SizedBox(height: 10),
                _detailsCard(b),
                const SizedBox(height: 20),
                _sectionTitle('Price'),
                const SizedBox(height: 10),
                _priceCard(b),
                if (_showsPayment(b.status)) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Payment'),
                  const SizedBox(height: 10),
                  _paymentCard(b),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Header ----
  Widget _header(Booking b, String? providerName) {
    final color = _statusColor(b.status);
    final (label, _, _) = _meta(b.status);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Your booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                child: Text(
                  [
                    b.skillName,
                    if (providerName != null) 'with $providerName',
                  ].whereType<String>().join(' '),
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Timeline ----
  Widget _timeline(Booking b, List<StatusEvent> events) {
    final times = <String, DateTime>{};
    for (final e in events) {
      times[e.status] = e.at;
    }
    final status = b.status;
    final isNeg = _negative.contains(status);

    final nodes = <_Node>[];
    for (final s in _happyPath) {
      final reached = times.containsKey(s);
      final state = reached
          ? (s == status ? _NodeState.current : _NodeState.done)
          : _NodeState.pending;
      final (label, subtitle, icon) = _meta(s);
      nodes.add(_Node(label, subtitle, times[s], icon, state));
    }
    // Post-completion positive states.
    for (final s in ['RATED', 'PAID']) {
      if (times.containsKey(s)) {
        final (label, subtitle, icon) = _meta(s);
        nodes.add(
          _Node(
            label,
            subtitle,
            times[s],
            icon,
            s == status ? _NodeState.current : _NodeState.done,
          ),
        );
      }
    }
    if (isNeg) {
      // Drop steps that never happened, then append the terminal node.
      nodes.removeWhere((n) => n.state == _NodeState.pending);
      final (label, subtitle, icon) = _meta(status);
      nodes.add(
        _Node(
          label,
          b.cancelReason?.isNotEmpty == true ? b.cancelReason : subtitle,
          times[status],
          icon,
          _NodeState.cancelled,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < nodes.length; i++)
          _nodeRow(nodes[i], isFirst: i == 0, isLast: i == nodes.length - 1),
      ],
    );
  }

  Widget _nodeRow(_Node node, {required bool isFirst, required bool isLast}) {
    final reached =
        node.state == _NodeState.done || node.state == _NodeState.current;
    final aboveColor = node.state == _NodeState.cancelled
        ? AppColors.error
        : (reached ? AppColors.success : AppColors.divider);
    final belowColor = node.state == _NodeState.done
        ? AppColors.success
        : AppColors.divider;
    final emphasised =
        node.state == _NodeState.current || node.state == _NodeState.cancelled;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 6,
                color: isFirst ? Colors.transparent : aboveColor,
              ),
              _dot(node.state, node.icon),
              if (!isLast)
                Expanded(child: Container(width: 2, color: belowColor)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.label,
                          style: TextStyle(
                            fontWeight: emphasised
                                ? FontWeight.w800
                                : FontWeight.w700,
                            fontSize: 14.5,
                            color: node.state == _NodeState.pending
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (node.time != null)
                        Text(
                          _fmtDateTime(node.time!.toLocal()),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  if (node.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      node.subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(_NodeState state, IconData icon) {
    switch (state) {
      case _NodeState.done:
        return _circle(
          AppColors.success,
          const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case _NodeState.current:
        return _circle(
          AppColors.accent,
          Icon(icon, size: 13, color: Colors.white),
        );
      case _NodeState.cancelled:
        return _circle(
          AppColors.error,
          const Icon(Icons.close, size: 14, color: Colors.white),
        );
      case _NodeState.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Center(
            child: SizedBox(
              width: 7,
              height: 7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _circle(Color color, Widget child) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }

  // ---- Details ----
  Widget _detailsCard(Booking b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _row('Service', b.skillName ?? '—'),
          _row('When', _fmtDateTime(b.scheduledAt.toLocal())),
          _row('Estimated', _fmtHours(b.estimatedHours)),
          if (_notBlank(b.taskTitle)) _row('Task', b.taskTitle!),
          if (_notBlank(b.addressLine)) _row('Address', b.addressLine!),
          if (_notBlank(b.description)) _row('Notes', b.description!),
          if (_notBlank(b.contactName)) _row('Contact', b.contactName!),
          if (_notBlank(b.contactPhone)) _row('Phone', b.contactPhone!),
        ],
      ),
    );
  }

  Widget _priceCard(Booking b) {
    final hours = b.workingHours ?? b.estimatedHours;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          _priceRow('Base fee', _rs(b.basePrice ?? 0)),
          const SizedBox(height: 8),
          _priceRow(
            'Work fee (${_fmtHours(hours)}${b.hourlyRate != null ? ' × ${_rs(b.hourlyRate!)}' : ''})',
            _rs(b.workingFee ?? 0),
          ),
          const SizedBox(height: 8),
          _priceRow(
            (b.travelDistanceKm ?? 0) > 0
                ? 'Travel (${b.travelDistanceKm!.toStringAsFixed(1)} km)'
                : 'Travel',
            _rs(b.travelFee ?? 0),
            muted: (b.travelFee ?? 0) == 0,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _rs(b.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _showsPayment(String status) =>
      status == 'COMPLETED' || status == 'RATED' || status == 'PAID';

  Widget _paymentCard(Booking b) {
    final Payment? payment = ref.watch(bookingPaymentProvider(b.id)).value;
    final released = b.status == 'PAID' || (payment?.isReleased ?? false);
    final held = payment?.isHeld ?? false;
    final (String text, Color color) = released
        ? ('Paid — released to provider', AppColors.success)
        : held
        ? ('Held securely in escrow', AppColors.info)
        : ('Payment due', AppColors.accent);
    final amount = payment?.amount ?? b.totalPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          Icon(
            released ? Icons.verified : Icons.account_balance_wallet_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _rs(amount),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!released)
            ElevatedButton(
              onPressed: () => context.push('/payment/${b.id}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(held ? 'Release' : 'Pay now'),
            ),
        ],
      ),
    );
  }

  // ---- Actions ----
  Widget? _actionBar(Booking b) {
    final s = b.status;
    final List<Widget> buttons;
    if (_active.contains(s)) {
      buttons = [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelling ? null : () => _confirmCancel(),
            child: _cancelling
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _trackLive(b),
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Track live'),
          ),
        ),
      ];
    } else if (s == 'COMPLETED') {
      buttons = [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final rated = await context.push<bool>('/review/${b.id}');
              if (rated == true) {
                ref.invalidate(bookingDetailProvider(_id));
                ref.invalidate(bookingTimelineProvider(_id));
              }
            },
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('Leave a review'),
          ),
        ),
      ];
    } else if (_negative.contains(s)) {
      buttons = [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/book/${b.providerId}'),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Book again'),
          ),
        ),
      ];
    } else {
      // RATED / PAID — nothing actionable for the customer here.
      return null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: buttons),
      ),
    );
  }

  void _trackLive(Booking b) {
    final q = <String, String>{};
    if (b.latitude != null) q['destLat'] = '${b.latitude}';
    if (b.longitude != null) q['destLng'] = '${b.longitude}';
    final query = q.entries.map((e) => '${e.key}=${e.value}').join('&');
    context.push('/track/${b.id}${query.isEmpty ? '' : '?$query'}');
  }

  Future<void> _confirmCancel() async {
    final reasonCtrl = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancel this booking?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The provider will be notified.'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Reason (optional)',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep booking'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel booking'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      setState(() => _cancelling = true);
      await ref
          .read(bookingRepositoryProvider)
          .cancelBooking(_id, reason: reasonCtrl.text.trim());
      ref.invalidate(bookingDetailProvider(_id));
      ref.invalidate(bookingTimelineProvider(_id));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      reasonCtrl.dispose();
      if (mounted) setState(() => _cancelling = false);
    }
  }

  // ---- helpers ----
  Color _statusColor(String s) {
    if (_negative.contains(s)) return AppColors.error;
    if (s == 'COMPLETED' || s == 'RATED' || s == 'PAID') {
      return AppColors.success;
    }
    return AppColors.accent;
  }

  (String, String?, IconData) _meta(String s) => switch (s) {
    'REQUESTED' => (
      'Requested',
      'Waiting for the provider to accept',
      Icons.hourglass_bottom,
    ),
    'ACCEPTED' => ('Accepted', 'Provider accepted your request', Icons.check),
    'EN_ROUTE' => (
      'On the way',
      'Provider is heading to you',
      Icons.directions_car_filled,
    ),
    'STARTED' => ('In progress', 'Work has started', Icons.build),
    'COMPLETED' => ('Completed', 'Work finished', Icons.task_alt),
    'RATED' => ('Reviewed', 'You left a review', Icons.reviews),
    'PAID' => ('Paid', 'Payment settled', Icons.payments),
    'CANCELLED' => ('Cancelled', 'This booking was cancelled', Icons.close),
    'DECLINED' => ('Declined', 'Provider declined the request', Icons.block),
    'EXPIRED' => (
      'Expired',
      'Provider did not respond in time',
      Icons.timer_off,
    ),
    _ => (s, null, Icons.circle),
  };

  bool _notBlank(String? v) => v != null && v.trim().isNotEmpty;

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textBody,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: muted ? AppColors.textMuted : AppColors.textBody,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: muted ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );

  Widget _error(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    ),
  );

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
