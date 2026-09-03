import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/order_models.dart';
import '../../data/order_repository.dart';
import '../providers/order_providers.dart';

/// "My Orders" (P10.4): the user's tool orders with status, and pay/cancel for
/// anything still pending.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).shopMyOrders)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myOrdersProvider);
          await ref.read(myOrdersProvider.future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _list(items),
        ),
      ),
    );
  }

  Widget _list(List<ToolOrder> items) {
    final l = AppLocalizations.of(context);
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            l.ordersEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.ordersEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [for (final o in items) _card(o)],
    );
  }

  Widget _card(ToolOrder o) {
    final l = AppLocalizations.of(context);
    final busy = _busyId == o.id;
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
                child: Text(
                  o.toolName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(o.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.ordersLine(
              o.quantity,
              '${l.pricePrefix} ${o.unitPrice.toStringAsFixed(0)}',
              '${l.pricePrefix} ${o.totalPrice.toStringAsFixed(0)}',
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.textBody),
          ),
          if (o.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _run(o.id, 'cancel'),
                    child: Text(l.commonCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _run(o.id, 'pay'),
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l.payStepPay),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _run(String id, String action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busyId = id);
    try {
      final repo = ref.read(orderRepositoryProvider);
      await (action == 'pay' ? repo.pay(id) : repo.cancel(id));
      ref.invalidate(myOrdersProvider);
      _snack(action == 'pay' ? l.ordersPaymentComplete : l.ordersCancelled);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _statusChip(String status) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'PAID' => (l.statusPaid, AppColors.success),
      'CANCELLED' => (l.statusCancelled, AppColors.error),
      _ => (l.ordersPending, AppColors.accent),
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
}
