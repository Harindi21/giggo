import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/kyc_repository.dart';
import '../../data/models/kyc_models.dart';
import '../providers/kyc_providers.dart';

/// Provider identity verification (P2.3). Shows the current KYC state
/// (verified / under review / rejected) or a submission form. Surfaces P2.2.
class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  static const _docTypes = {
    'NIC': 'NIC',
    'PASSPORT': 'Passport',
    'DRIVING_LICENSE': 'Driving license',
  };

  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String _docType = 'NIC';
  bool _submitting = false;
  String? _error;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  void _prefillName() {
    if (_prefilled) return;
    final user = ref.read(authControllerProvider).user;
    if (user != null && _nameCtrl.text.isEmpty) {
      _nameCtrl.text = user.fullName;
    }
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _numberCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name and document number.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(kycRepositoryProvider)
          .submit(
            fullName: _nameCtrl.text.trim(),
            documentType: _docType,
            documentNumber: _numberCtrl.text.trim(),
            documentImageUrl: _imageCtrl.text.trim(),
          );
      ref.invalidate(myKycProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted for verification.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefillName();
    final async = ref.watch(myKycProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Get verified')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _message(e.toString()),
        data: (kyc) {
          if (kyc != null && kyc.isApproved) return _verified(kyc);
          if (kyc != null && kyc.isPending) return _pending(kyc);
          return _form(kyc); // null or rejected
        },
      ),
    );
  }

  Widget _verified(KycSubmission kyc) => _statusView(
    icon: Icons.verified,
    color: AppColors.success,
    title: "You're verified",
    body:
        'Your identity has been verified. The verified badge now appears on '
        'your profile across GIGGO.',
    detail: kyc,
  );

  Widget _pending(KycSubmission kyc) => _statusView(
    icon: Icons.hourglass_top,
    color: AppColors.warning,
    title: 'Under review',
    body:
        'Thanks! Your submission is being reviewed. We\'ll notify you once '
        'it\'s done — usually within a day.',
    detail: kyc,
  );

  Widget _statusView({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required KycSubmission detail,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 44,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textBody, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Column(
              children: [
                _row('Name', detail.fullName),
                _row(
                  'Document',
                  _docTypes[detail.documentType] ?? detail.documentType,
                ),
                _row('Number', detail.documentNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(KycSubmission? rejected) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (rejected != null && rejected.isRejected)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rejected.reviewNote?.isNotEmpty == true
                          ? 'Your last submission was not approved: ${rejected.reviewNote}. Please re-submit.'
                          : 'Your last submission was not approved. Please re-submit.',
                      style: const TextStyle(color: AppColors.textBody),
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            'Verify your identity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Verified providers earn a badge and win more trust. Your details '
            'are used only for verification.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Full name (as on document)',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _docType,
            decoration: const InputDecoration(labelText: 'Document type'),
            items: [
              for (final e in _docTypes.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: _submitting
                ? null
                : (v) => setState(() => _docType = v ?? 'NIC'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _numberCtrl,
            enabled: !_submitting,
            decoration: const InputDecoration(labelText: 'Document number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageCtrl,
            enabled: !_submitting,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Document photo link (optional)',
              hintText: 'https://…',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit for verification'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String msg) => Center(
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
        ],
      ),
    ),
  );
}
