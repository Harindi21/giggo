import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../kyc/data/kyc_repository.dart';
import '../../../kyc/data/models/kyc_models.dart';
import '../../../kyc/presentation/providers/kyc_providers.dart';

/// Admin console (P11): KYC review queue. Approving flips the provider's
/// verified badge (backend) and notifies them.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String? _busyId;

  static const _docTypes = {
    'NIC': 'NIC',
    'PASSPORT': 'Passport',
    'DRIVING_LICENSE': 'Driving license',
  };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(pendingKycProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification queue'),
        actions: [
          IconButton(
            tooltip: 'Analytics',
            onPressed: () => context.push('/admin/dashboard'),
            icon: const Icon(Icons.bar_chart, color: Colors.white),
          ),
          TextButton(
            onPressed: () => context.push('/admin/reviews'),
            child: const Text('Reviews', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => context.push('/admin/disputes'),
            child: const Text(
              'Disputes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingKycProvider);
          await ref.read(pendingKycProvider.future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _list(items),
        ),
      ),
    );
  }

  Widget _list(List<KycSubmission> items) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(
            Icons.verified_user_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No pending verifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Provider KYC submissions will appear here for review.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [for (final k in items) _card(k)],
    );
  }

  Widget _card(KycSubmission k) {
    final busy = _busyId == k.id;
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
            k.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          _row(
            Icons.badge_outlined,
            '${_docTypes[k.documentType] ?? k.documentType} · ${k.documentNumber}',
          ),
          if (k.submittedAt != null)
            _row(Icons.schedule, _fmtDate(k.submittedAt!.toLocal())),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _reject(k),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _approve(k),
                  child: busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approve(KycSubmission k) async {
    await _run(
      k.id,
      () => ref.read(kycRepositoryProvider).approve(k.id),
      '${k.fullName} verified',
    );
  }

  Future<void> _reject(KycSubmission k) async {
    final noteCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject submission?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The provider will be asked to re-submit.'),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await _run(
        k.id,
        () =>
            ref.read(kycRepositoryProvider).reject(k.id, noteCtrl.text.trim()),
        'Submission rejected',
      );
    } finally {
      noteCtrl.dispose();
    }
  }

  Future<void> _run(
    String id,
    Future<KycSubmission> Function() op,
    String okMsg,
  ) async {
    setState(() => _busyId = id);
    try {
      await op();
      ref.invalidate(pendingKycProvider);
      _snack(okMsg);
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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmtDate(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final mm = dt.minute.toString().padLeft(2, '0');
    return 'Submitted ${_months[dt.month - 1]} ${dt.day} · $h12:$mm $ampm';
  }
}
