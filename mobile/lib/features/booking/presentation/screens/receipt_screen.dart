import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context);
    final async = ref.watch(bookingReceiptProvider(bookingId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _message(context, e.toString()),
        data: (receipt) => receipt == null
            ? _message(context, l.receiptUnavailable)
            : _Invoice(receipt: receipt),
      ),
    );
  }

  Widget _message(BuildContext context, String msg) {
    final l = AppLocalizations.of(context);
    return Center(
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
              child: Text(l.commonGoBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _Invoice extends StatelessWidget {
  const _Invoice({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(context, l)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: _card(l),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, AppLocalizations l) {
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
              Expanded(
                child: Text(
                  l.receiptTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: l.receiptCopyTooltip,
                icon: const Icon(Icons.ios_share, color: Colors.white),
                onPressed: () => _copy(context, l),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(AppLocalizations l) {
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
                      l.receiptPaymentReceipt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(l),
            ],
          ),
          const SizedBox(height: 16),
          _kv(l.receiptNo, receipt.receiptNumber),
          if (receipt.issuedAt != null)
            _kv(l.receiptIssued, _dateTime(receipt.issuedAt!)),
          _kv(l.receiptBooking, _short(receipt.bookingId)),
          const _Rule(),
          _party(l.receiptBilledTo, receipt.customerName),
          const SizedBox(height: 10),
          _party(l.receiptServiceBy, receipt.providerName),
          if (receipt.serviceName != null) ...[
            const SizedBox(height: 10),
            _party(l.bookingSectionService, receipt.serviceName),
          ],
          if (receipt.taskTitle != null && receipt.taskTitle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _party(l.receiptJob, receipt.taskTitle),
          ],
          if (receipt.completedAt != null) ...[
            const SizedBox(height: 10),
            _party(l.receiptCompleted, _dateTime(receipt.completedAt!)),
          ],
          const _Rule(),
          _lineItem(l.receiptBaseCallout, _money(l, receipt.basePrice)),
          _lineItem(
            l.receiptLabour(
              _num(receipt.workingHours),
              _money(l, receipt.hourlyRate),
            ),
            _money(l, receipt.workingFee),
          ),
          _lineItem(
            l.receiptTravelLine(_num(receipt.travelDistanceKm)),
            _money(l, receipt.travelFee),
          ),
          const SizedBox(height: 8),
          const _Rule(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.receiptTotalPaid,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _money(l, receipt.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _escrowBox(l),
          const SizedBox(height: 14),
          Center(
            child: Text(
              l.receiptComputerGenerated,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(AppLocalizations l) {
    final released = receipt.isReleased;
    final color = released ? AppColors.success : AppColors.info;
    final label = released ? l.receiptStatusPaid : l.receiptStatusInEscrow;
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

  Widget _escrowBox(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          _split(l.commonPlatformFee, _money(l, receipt.platformCommission)),
          const SizedBox(height: 8),
          _split(
            l.receiptProviderReceived,
            _money(l, receipt.providerPayout),
            bold: true,
          ),
          const Divider(height: 20),
          _split0(
            l.receiptMethod,
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

  Widget _lineItem(String label, String value) => Padding(
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
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _split(String label, String value, {bool bold = false}) => Row(
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
        value,
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
  Future<void> _copy(BuildContext context, AppLocalizations l) async {
    await Clipboard.setData(ClipboardData(text: _asText(l)));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.receiptCopied)));
    }
  }

  String _asText(AppLocalizations l) {
    final b = StringBuffer()
      ..writeln('GIGGO ${l.receiptPaymentReceipt}')
      ..writeln('${l.receiptNo} ${receipt.receiptNumber}')
      ..writeln(
        receipt.isReleased ? l.receiptStatusPaid : l.receiptStatusInEscrow,
      );
    if (receipt.issuedAt != null) {
      b.writeln('${l.receiptIssued}: ${_dateTime(receipt.issuedAt!)}');
    }
    b
      ..writeln('${l.receiptBilledTo}: ${receipt.customerName ?? '—'}')
      ..writeln('${l.receiptServiceBy}: ${receipt.providerName ?? '—'}')
      ..writeln('${l.bookingSectionService}: ${receipt.serviceName ?? '—'}')
      ..writeln('---')
      ..writeln('${l.receiptBaseCallout}: ${_money(l, receipt.basePrice)}')
      ..writeln(
        '${l.receiptLabour(_num(receipt.workingHours), _money(l, receipt.hourlyRate))}: ${_money(l, receipt.workingFee)}',
      )
      ..writeln(
        '${l.receiptTravelLine(_num(receipt.travelDistanceKm))}: ${_money(l, receipt.travelFee)}',
      )
      ..writeln('${l.receiptTotalPaid}: ${_money(l, receipt.total)}')
      ..writeln('---')
      ..writeln(
        '${l.commonPlatformFee}: ${_money(l, receipt.platformCommission)}',
      )
      ..writeln(
        '${l.receiptProviderReceived}: ${_money(l, receipt.providerPayout)}',
      )
      ..writeln('${l.receiptMethod}: ${_gateway(receipt.gateway)}');
    return b.toString();
  }

  // ---- formatting ----
  String _money(AppLocalizations l, double v) =>
      '${l.pricePrefix} ${v.toStringAsFixed(2)}';
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
