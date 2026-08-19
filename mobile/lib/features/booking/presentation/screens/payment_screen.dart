import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/booking_repository.dart';
import '../../data/models/payment_models.dart';
import '../providers/booking_providers.dart';

/// Payment / escrow checkout (P7.2). Surfaces the escrow lifecycle: the customer
/// pays (funds held by the platform), then releases them to the provider minus
/// the platform fee. The gateway redirect is stubbed — in production "Pay" opens
/// the PayHere hosted checkout.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _busy = false;
  String? _error;

  String get _id => widget.bookingId;

  Future<void> _pay(Payment? current) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(bookingRepositoryProvider);
      var payment = current ?? await repo.initiatePayment(_id);
      if (payment.isPending) {
        // Stands in for the gateway's capture callback.
        payment = await repo.confirmPayment(payment.id);
      }
      ref.invalidate(bookingPaymentProvider(_id));
      ref.invalidate(bookingReceiptProvider(_id));
      _snack('Payment secured — held safely in escrow.');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _release(Payment payment) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(bookingRepositoryProvider).releasePayment(payment.id);
      ref.invalidate(bookingPaymentProvider(_id));
      ref.invalidate(bookingReceiptProvider(_id));
      ref.invalidate(bookingDetailProvider(_id));
      ref.invalidate(bookingTimelineProvider(_id));
      _snack('Released to the provider. Thank you!');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(bookingPaymentProvider(_id));
    final bookingTotal = ref
        .watch(bookingDetailProvider(_id))
        .value
        ?.totalPrice;

    return Scaffold(
      body: paymentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorView(e.toString()),
        data: (payment) => _content(payment, bookingTotal),
      ),
      bottomNavigationBar: paymentAsync.maybeWhen(
        data: (payment) => _actionBar(payment, bookingTotal),
        orElse: () => null,
      ),
    );
  }

  Widget _content(Payment? payment, double? bookingTotal) {
    final total = payment?.amount ?? bookingTotal ?? 0;
    final stage = _stage(payment);
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepper(stage),
                const SizedBox(height: 24),
                _sectionTitle('Payment summary'),
                const SizedBox(height: 10),
                _summaryCard(payment, total),
                const SizedBox(height: 16),
                _escrowNote(stage),
                if (payment != null &&
                    (payment.isHeld || payment.isReleased)) ...[
                  const SizedBox(height: 16),
                  _receiptLink(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Text(
                'Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- escrow stepper ----
  Widget _stepper(int stage) {
    return Row(
      children: [
        _step(0, stage, 'Pay', Icons.credit_card),
        _connector(stage >= 1),
        _step(1, stage, 'In escrow', Icons.lock_outline),
        _connector(stage >= 2),
        _step(2, stage, 'Released', Icons.verified_outlined),
      ],
    );
  }

  Widget _step(int index, int stage, String label, IconData icon) {
    final done = index < stage || stage == 2;
    final current = index == stage && stage < 2;
    final Color color = done
        ? AppColors.success
        : (current ? AppColors.accent : AppColors.border);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(done ? Icons.check : icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: current || done ? FontWeight.w700 : FontWeight.w500,
              color: current || done
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _connector(bool active) => Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: active ? AppColors.success : AppColors.border,
    ),
  );

  // ---- summary ----
  Widget _summaryCard(Payment? payment, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          _row('Amount', _rs(total)),
          if (payment != null) ...[
            const SizedBox(height: 8),
            _row('Platform fee', '- ${_rs(payment.commission)}', muted: true),
            const Divider(height: 20),
            _row('Provider receives', _rs(payment.providerPayout), bold: true),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'A small platform fee is applied when you pay; the rest goes to '
              'your provider.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _receiptLink() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: () => context.push('/receipt/$_id'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'View receipt',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _escrowNote(int stage) {
    final (icon, text) = switch (stage) {
      0 => (
        Icons.shield_outlined,
        'Your payment is held securely by GIGGO and only released to the '
            'provider when you confirm the job is done.',
      ),
      1 => (
        Icons.lock_outline,
        'Funds are held in escrow. Release them once you are happy with the '
            'completed work.',
      ),
      _ => (
        Icons.verified_outlined,
        'Payment released to the provider. This booking is settled.',
      ),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textBody),
          ),
        ),
      ],
    );
  }

  // ---- action bar ----
  Widget? _actionBar(Payment? payment, double? bookingTotal) {
    final stage = _stage(payment);
    if (stage == 2) {
      return null; // settled
    }
    final label = stage == 1
        ? 'Release to provider'
        : 'Pay ${_rs(payment?.amount ?? bookingTotal ?? 0)}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy
                ? null
                : () => stage == 1 ? _release(payment!) : _pay(payment),
            icon: _busy
                ? const SizedBox.shrink()
                : Icon(
                    stage == 1 ? Icons.lock_open : Icons.credit_card,
                    size: 18,
                  ),
            label: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }

  int _stage(Payment? payment) {
    if (payment == null || payment.isPending) return 0;
    if (payment.isHeld) return 1;
    if (payment.isReleased) return 2;
    return 0; // refunded / failed → back to pay
  }

  Widget _row(
    String label,
    String value, {
    bool muted = false,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: muted ? AppColors.textMuted : AppColors.textBody,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
            fontSize: bold ? 15 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: muted
                ? AppColors.textMuted
                : (bold ? AppColors.accent : AppColors.textPrimary),
            fontWeight: FontWeight.w800,
            fontSize: bold ? 16 : 14,
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

  Widget _errorView(String msg) => Center(
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

  String _rs(double v) => 'Rs. ${v.toStringAsFixed(0)}';
}
