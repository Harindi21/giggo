import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../booking/data/models/payment_models.dart';
import '../../data/earnings_repository.dart';
import '../../data/models/earnings.dart';
import '../providers/earnings_providers.dart';

/// Provider earnings dashboard (P7.10): balance, withdrawals, and history,
/// surfacing /api/v1/provider/earnings.
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  bool _busy = false;

  String _money(double v) => 'Rs. ${v.toStringAsFixed(2)}';

  String _date(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.year}/${l.month.toString().padLeft(2, '0')}/${l.day.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    ref.invalidate(earningsSummaryProvider);
    ref.invalidate(myPayoutsProvider);
    ref.invalidate(earningsHistoryProvider);
  }

  Future<void> _withdraw(EarningsSummary s) async {
    final ctrl = TextEditingController(text: s.available.toStringAsFixed(0));
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw earnings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available: ${_money(s.available)}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs. ',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Funds are transferred to your registered bank account after review.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, s.available),
            child: const Text('Withdraw all'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(ctrl.text.trim()) ?? 0),
            child: const Text('Request'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;

    setState(() => _busy = true);
    try {
      // Withdrawing the whole balance sends null so the backend takes "all".
      final full = (amount - s.available).abs() < 0.005;
      await ref
          .read(earningsRepositoryProvider)
          .requestPayout(amount: full ? null : amount);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Withdrawal requested.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(earningsSummaryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Earnings')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _error(e.toString()),
          data: (summary) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _balanceCard(summary),
              const SizedBox(height: 12),
              _statsRow(summary),
              const SizedBox(height: 24),
              _sectionTitle('Withdrawals'),
              const SizedBox(height: 8),
              _payoutsList(),
              const SizedBox(height: 24),
              _sectionTitle('Payment history'),
              const SizedBox(height: 8),
              _historyList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard(EarningsSummary s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available to withdraw',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _money(s.available),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (!s.canWithdraw || _busy) ? null : () => _withdraw(s),
              icon: _busy
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.account_balance_outlined, size: 18),
              label: Text(s.canWithdraw ? 'Withdraw' : 'Nothing to withdraw'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(EarningsSummary s) {
    return Row(
      children: [
        _stat('In escrow', _money(s.inEscrow), Icons.lock_outline),
        const SizedBox(width: 10),
        _stat('Pending', _money(s.pendingWithdrawal), Icons.hourglass_top),
        const SizedBox(width: 10),
        _stat('Lifetime', _money(s.lifetimeEarned), Icons.trending_up),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payoutsList() {
    final async = ref.watch(myPayoutsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _muted('Could not load withdrawals.'),
      data: (payouts) {
        if (payouts.isEmpty) {
          return _muted('No withdrawals yet.');
        }
        return Column(children: [for (final p in payouts) _payoutTile(p)]);
      },
    );
  }

  Widget _payoutTile(Payout p) {
    final (Color color, String label) = switch (p.status) {
      'PAID' => (AppColors.success, 'Paid'),
      'REJECTED' => (AppColors.error, 'Rejected'),
      _ => (AppColors.warning, 'Requested'),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _money(p.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.status == 'REJECTED' && p.note != null
                      ? p.note!
                      : 'Requested ${_date(p.requestedAt)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _chip(label, color),
        ],
      ),
    );
  }

  Widget _historyList() {
    final async = ref.watch(earningsHistoryProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _muted('Could not load history.'),
      data: (payments) {
        if (payments.isEmpty) {
          return _muted('No payments yet — complete jobs to start earning.');
        }
        return Column(children: [for (final p in payments) _historyTile(p)]);
      },
    );
  }

  Widget _historyTile(Payment p) {
    final (Color color, String label) = switch (p.status) {
      'RELEASED' => (AppColors.success, 'Earned'),
      'HELD' => (AppColors.info, 'In escrow'),
      'REFUNDED' => (AppColors.error, 'Refunded'),
      _ => (AppColors.textMuted, p.status),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _money(p.providerPayout),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fee ${_money(p.commission)} · ${_date(p.releasedAt ?? p.paidAt ?? p.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _chip(label, color),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );

  Widget _muted(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
  );

  Widget _error(String msg) => ListView(
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
      const SizedBox(height: 8),
      Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    ],
  );
}
