import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../kyc/presentation/providers/kyc_providers.dart';
import '../../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(e.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 34, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _EditableRow(
              label: 'Full name',
              value: user.fullName,
              onEdit: () => _editName(context, ref, user.fullName),
            ),
            _ReadOnlyRow(label: 'Email', value: user.email),
            _ReadOnlyRow(label: 'Phone', value: user.phone),
            _ReadOnlyRow(label: 'Role', value: user.role),
            if (user.role == 'PROVIDER') ...[
              const SizedBox(height: 8),
              _providerProfileTile(context),
              const SizedBox(height: 8),
              _earningsTile(context),
              const SizedBox(height: 8),
              _verificationTile(context, ref),
            ],
            if (user.role == 'ADMIN') ...[
              const SizedBox(height: 8),
              _adminTile(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _earningsTile(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
        ),
        title: const Text(
          'Earnings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Balance, withdrawals & payment history',
          style: TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push('/earnings'),
      ),
    );
  }

  Widget _providerProfileTile(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.badge_outlined, color: Colors.white),
        ),
        title: const Text(
          'My provider profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Bio, rates, service area, skills & availability',
          style: TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push('/provider-profile'),
      ),
    );
  }

  Widget _verificationTile(BuildContext context, WidgetRef ref) {
    final kyc = ref.watch(myKycProvider).value;
    final (String hint, Color color, IconData icon) = switch (kyc?.status) {
      'APPROVED' => ('Verified', AppColors.success, Icons.verified),
      'PENDING' => ('Under review', AppColors.warning, Icons.hourglass_top),
      'REJECTED' => ('Action needed', AppColors.error, Icons.error_outline),
      _ => ('Not verified', AppColors.textMuted, Icons.verified_outlined),
    };
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(hint, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push('/kyc'),
      ),
    );
  }

  Widget _adminTile(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
        ),
        title: const Text(
          'Admin console',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Review provider verifications',
          style: TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push('/admin'),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == current) return;

    try {
      await ref.read(profileRepositoryProvider).updateName(newName);
      ref.invalidate(profileProvider); // re-fetch fresh data
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Name updated')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _EditableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _EditableRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.textBody),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: onEdit,
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: AppColors.textBody),
      ),
    );
  }
}
