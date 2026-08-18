import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dispute/data/dispute_repository.dart';
import '../../../dispute/data/models/dispute_models.dart';
import '../../../dispute/presentation/providers/dispute_providers.dart';

/// Admin dispute queue (P4.7): review open disputes and resolve them by
/// refunding the escrow or dismissing.
class DisputesQueueScreen extends ConsumerStatefulWidget {
  const DisputesQueueScreen({super.key});

  @override
  ConsumerState<DisputesQueueScreen> createState() =>
      _DisputesQueueScreenState();
}

class _DisputesQueueScreenState extends ConsumerState<DisputesQueueScreen> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(openDisputesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(openDisputesProvider);
          await ref.read(openDisputesProvider.future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _list(items),
        ),
      ),
    );
  }

  Widget _list(List<Dispute> items) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.gavel_outlined, size: 56, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'No open disputes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [for (final d in items) _card(d)],
    );
  }

  Widget _card(Dispute d) {
    final busy = _busyId == d.id;
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
          Text(
            d.reason,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Booking ${d.bookingId.substring(0, 8)}…',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _resolve(d, refund: false),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _resolve(d, refund: true),
                  child: busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Refund'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resolve(Dispute d, {required bool refund}) async {
    final noteCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            refund ? 'Refund the customer?' : 'Dismiss this dispute?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                refund
                    ? 'Any funds held in escrow will be refunded to the customer.'
                    : 'The dispute will be closed with no refund.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Note (optional)',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(refund ? 'Refund' : 'Dismiss'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      setState(() => _busyId = d.id);
      await ref
          .read(disputeRepositoryProvider)
          .resolve(d.id, refund: refund, note: noteCtrl.text.trim());
      ref.invalidate(openDisputesProvider);
      _snack(refund ? 'Refunded and resolved.' : 'Dispute dismissed.');
    } catch (e) {
      _snack(e.toString());
    } finally {
      noteCtrl.dispose();
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
