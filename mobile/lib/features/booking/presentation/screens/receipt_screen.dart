import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/receipt_models.dart';
import '../providers/booking_providers.dart';

/// Payment receipt / invoice for a paid booking (P4.12-4.14). Shows the
/// snapshotted price line items and the escrow settlement, and can be copied
/// to the clipboard to share.
class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingReceiptProvider(bookingId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _message(context, e.toString()),
        data: (receipt) => receipt == null
            ? _message(
                context,
                'Your receipt will be available once the payment is captured.',
              )
            : _Invoice(receipt: receipt),
      ),
    );
  }

  Widget _message(BuildContext context, String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textMuted,
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    ),
  );
}

class _Invoice extends StatelessWidget {
  const _Invoice({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: _card(),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text(
                  'Receipt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy to share',
                icon: const Icon(Icons.ios_share, color: Colors.white),
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.border),
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
                    const Text(
                      'GIGGO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Payment receipt',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 16),
          _kv('Receipt no.', receipt.receiptNumber),
          if (receipt.issuedAt != null)
            _kv('Issued', _dateTime(receipt.issuedAt!)),
          _kv('Booking', _short(receipt.bookingId)),
          const _Rule(),
          _party('Billed to', receipt.customerName),
          const SizedBox(height: 10),
          _party('Service by', receipt.providerName),
          if (receipt.serviceName != null) ...[
            const SizedBox(height: 10),
            _party('Service', receipt.serviceName),
          ],
          if (receipt.taskTitle != null && receipt.taskTitle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _party('Job', receipt.taskTitle),
          ],
          if (receipt.completedAt != null) ...[
            const SizedBox(height: 10),
            _party('Completed', _dateTime(receipt.completedAt!)),
          ],
          const _Rule(),
          _lineItem('Base call-out', receipt.basePrice),
          _lineItem(
            'Labour · ${_num(receipt.workingHours)} h × ${_money(receipt.hourlyRate)}',
            receipt.workingFee,
          ),
          _lineItem(
            'Travel · ${_num(receipt.travelDistanceKm)} km',
            receipt.travelFee,
          ),
          const SizedBox(height: 8),
          const _Rule(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total paid',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _money(receipt.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _escrowBox(),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'This is a computer-generated receipt.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final released = receipt.isReleased;
    final color = released ? AppColors.success : AppColors.info;
    final label = released ? 'PAID' : 'IN ESCROW';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            released ? Icons.verified : Icons.lock_outline,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _escrowBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          _split('Platform fee', receipt.platformCommission),
          const SizedBox(height: 8),
          _split('Provider received', receipt.providerPayout, bold: true),
          const Divider(height: 20),
          _split0(
            'Method',
            '${_gateway(receipt.gateway)}${receipt.paidAt != null ? ' · ${_date(receipt.paidAt!)}' : ''}',
          ),
        ],
      ),
    );
  }

  // ---- rows ----
  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
        Text(
          v,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textBody,
          ),
        ),
      ],
    ),
  );

  Widget _party(String label, String? value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textMuted,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value ?? '—',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );

  Widget _lineItem(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textBody),
          ),
        ),
        Text(
          _money(value),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _split(String label, double value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: bold ? AppColors.textPrimary : AppColors.textBody,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      Text(
        _money(value),
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: bold ? AppColors.success : AppColors.textPrimary,
        ),
      ),
    ],
  );

  Widget _split0(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textBody),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );

  // ---- share ----
  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _asText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt copied to clipboard.')),
      );
    }
  }

  String _asText() {
    final b = StringBuffer()
      ..writeln('GIGGO — Payment receipt')
      ..writeln('Receipt no. ${receipt.receiptNumber}')
      ..writeln(receipt.isReleased ? 'Status: PAID' : 'Status: IN ESCROW');
    if (receipt.issuedAt != null) {
      b.writeln('Issued: ${_dateTime(receipt.issuedAt!)}');
    }
    b
      ..writeln('Billed to: ${receipt.customerName ?? '—'}')
      ..writeln('Service by: ${receipt.providerName ?? '—'}')
      ..writeln('Service: ${receipt.serviceName ?? '—'}')
      ..writeln('---')
      ..writeln('Base call-out: ${_money(receipt.basePrice)}')
      ..writeln(
        'Labour ${_num(receipt.workingHours)}h x ${_money(receipt.hourlyRate)}: ${_money(receipt.workingFee)}',
      )
      ..writeln(
        'Travel ${_num(receipt.travelDistanceKm)}km: ${_money(receipt.travelFee)}',
      )
      ..writeln('Total paid: ${_money(receipt.total)}')
      ..writeln('---')
      ..writeln('Platform fee: ${_money(receipt.platformCommission)}')
      ..writeln('Provider received: ${_money(receipt.providerPayout)}')
      ..writeln('Method: ${_gateway(receipt.gateway)}');
    return b.toString();
  }

  // ---- formatting ----
  String _money(double v) => 'Rs. ${v.toStringAsFixed(2)}';
  String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  String _short(String id) =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  String _gateway(String g) => g == 'stub' ? 'GIGGO Pay' : g;

  String _date(DateTime d) {
    final l = d.toLocal();
    return '${l.year}/${_pad(l.month)}/${_pad(l.day)}';
  }

  String _dateTime(DateTime d) {
    final l = d.toLocal();
    return '${l.year}/${_pad(l.month)}/${_pad(l.day)} ${_pad(l.hour)}:${_pad(l.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.divider),
  );
}
