import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_preference.dart';
import '../../data/notification_repository.dart';
import '../providers/notification_providers.dart';

/// Push notification preferences (P8.5): toggle push per category. In-app
/// notifications always appear in the inbox; this only controls push.
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  String? _busyCategory;

  Future<void> _toggle(NotificationPreference pref, bool value) async {
    setState(() => _busyCategory = pref.category);
    try {
      await ref
          .read(notificationRepositoryProvider)
          .setPreference(pref.category, value);
      ref.invalidate(notificationPreferencesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyCategory = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                'Choose which push notifications you receive. You\'ll still see '
                'everything in your inbox.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ),
            for (final p in prefs) _row(p),
          ],
        ),
      ),
    );
  }

  Widget _row(NotificationPreference p) {
    final busy = _busyCategory == p.category;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        value: p.pushEnabled,
        onChanged: busy ? null : (v) => _toggle(p, v),
        activeThumbColor: AppColors.accent,
        title: Text(
          p.label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          p.description,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        secondary: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),
      ),
    );
  }
}
