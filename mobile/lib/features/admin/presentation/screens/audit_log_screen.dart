import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/admin_audit_repository.dart';
import '../../data/models/audit_entry.dart';

/// Admin audit-log viewer (P11.10): a timestamped feed of privileged actions.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminAuditProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Audit log')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminAuditProvider);
          await ref.read(adminAuditProvider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 100),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.history, size: 56, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No admin actions recorded yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: entries.length,
              itemBuilder: (_, i) => _tile(entries[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _tile(AuditEntry e) {
    final (String label, Color color, IconData icon) = _describe(e.action);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.actorName ?? 'Admin'}'
                  '${e.detail != null && e.detail!.isNotEmpty ? ' · ${e.detail}' : ''}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textBody,
                  ),
                ),
                if (e.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _dateTime(e.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _describe(String action) {
    switch (action) {
      case 'KYC_APPROVED':
        return ('KYC approved', AppColors.success, Icons.verified_outlined);
      case 'KYC_REJECTED':
        return ('KYC rejected', AppColors.error, Icons.gpp_bad_outlined);
      case 'DISPUTE_RESOLVED':
        return ('Dispute resolved', AppColors.info, Icons.gavel_outlined);
      case 'REVIEW_HIDDEN':
        return (
          'Review hidden',
          AppColors.warning,
          Icons.visibility_off_outlined,
        );
      case 'REVIEW_RESTORED':
        return (
          'Review restored',
          AppColors.success,
          Icons.visibility_outlined,
        );
      case 'PAYOUT_PAID':
        return ('Payout paid', AppColors.success, Icons.payments_outlined);
      case 'PAYOUT_REJECTED':
        return ('Payout rejected', AppColors.error, Icons.money_off_outlined);
      case 'COMMISSION_SET':
        return ('Commission set', AppColors.info, Icons.percent);
      case 'COMMISSION_CLEARED':
        return ('Commission cleared', AppColors.textMuted, Icons.percent);
      default:
        return (action, AppColors.primary, Icons.bolt_outlined);
    }
  }

  String _dateTime(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}/${two(l.month)}/${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}
