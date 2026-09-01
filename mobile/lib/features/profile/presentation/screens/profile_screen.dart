import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/giggo_wordmark.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../kyc/presentation/providers/kyc_providers.dart';
import '../../data/profile_repository.dart';

/// Profile tab, aligned to the Figma: a navy header (wordmark + bell) over a
/// centred avatar with an edit badge, the user's name, and underlined field
/// rows. Provider/admin management options are kept below as useful additions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: profileAsync.when(
        loading: () => Column(
          children: [
            _header(context),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (e, _) => Column(
          children: [
            _header(context),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(e.toString(), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
        data: (user) => ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _avatar(context, ref, user),
                  const SizedBox(height: 14),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field(
                    l.profileName,
                    user.fullName,
                    onEdit: () => _editName(context, ref, user.fullName),
                  ),
                  _field(l.profileEmail, user.email),
                  _field(
                    l.profilePhone,
                    user.phone.isEmpty ? l.profileNotSet : user.phone,
                  ),
                  if (user.role == 'PROVIDER') ...[
                    const SizedBox(height: 12),
                    _providerProfileTile(context),
                    const SizedBox(height: 8),
                    _earningsTile(context),
                    const SizedBox(height: 8),
                    _demandTile(context),
                    const SizedBox(height: 8),
                    _availabilityTile(context),
                    const SizedBox(height: 8),
                    _verificationTile(context, ref),
                  ],
                  if (user.role == 'ADMIN') ...[
                    const SizedBox(height: 12),
                    _adminTile(context),
                  ],
                  const SizedBox(height: 12),
                  _languageTile(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const GiggoWordmark(fontSize: 26, onDark: true),
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context, WidgetRef ref, UserModel user) {
    return Center(
      child: SizedBox(
        width: 116,
        height: 116,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: AppColors.surfaceBlue,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: InkWell(
                onTap: () => _editName(context, ref, user.fullName),
                customBorder: const CircleBorder(),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit, size: 18, color: AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _demandTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _navTile(
      context,
      Icons.insights_outlined,
      l.profileDemandInsights,
      l.profileDemandInsightsSub,
      '/demand',
    );
  }

  Widget _availabilityTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _navTile(
      context,
      Icons.schedule_outlined,
      l.profileWorkingHours,
      l.profileWorkingHoursSub,
      '/availability',
    );
  }

  Widget _earningsTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _navTile(
      context,
      Icons.account_balance_wallet_outlined,
      l.profileEarnings,
      l.profileEarningsSub,
      '/earnings',
    );
  }

  Widget _providerProfileTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _navTile(
      context,
      Icons.badge_outlined,
      l.profileMyProviderProfile,
      l.profileMyProviderProfileSub,
      '/provider-profile',
    );
  }

  Widget _adminTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _navTile(
      context,
      Icons.admin_panel_settings_outlined,
      l.profileAdminConsole,
      l.profileAdminConsoleSub,
      '/admin',
    );
  }

  Widget _navTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _verificationTile(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final kyc = ref.watch(myKycProvider).value;
    final (String hint, Color color, IconData icon) = switch (kyc?.status) {
      'APPROVED' => (l.profileVerified, AppColors.success, Icons.verified),
      'PENDING' => (
        l.profileUnderReview,
        AppColors.warning,
        Icons.hourglass_top,
      ),
      'REJECTED' => (
        l.profileActionNeeded,
        AppColors.error,
        Icons.error_outline,
      ),
      _ => (l.profileNotVerified, AppColors.textMuted, Icons.verified_outlined),
    };
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          l.profileVerification,
          style: const TextStyle(
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

  /// Language switcher (English / සිංහල), persisted across launches.
  Widget _languageTile(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current =
        ref.watch(localeControllerProvider)?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final currentLabel = current == 'si'
        ? l.languageSinhala
        : l.languageEnglish;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.translate, color: Colors.white),
        ),
        title: Text(
          l.settingsLanguage,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          currentLabel,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => _showLanguagePicker(context, ref),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final current =
        ref.read(localeControllerProvider)?.languageCode ??
        Localizations.localeOf(context).languageCode;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.settingsChooseLanguage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            _languageOption(ctx, ref, 'en', l.languageEnglish, current == 'en'),
            _languageOption(ctx, ref, 'si', l.languageSinhala, current == 'si'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(
    BuildContext sheetContext,
    WidgetRef ref,
    String code,
    String label,
    bool selected,
  ) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.accent)
          : null,
      onTap: () {
        ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
        Navigator.pop(sheetContext);
      },
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.profileEditName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.profileFullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.commonSave),
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
        ).showSnackBar(SnackBar(content: Text(l.profileNameUpdated)));
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
