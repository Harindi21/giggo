import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/tool_models.dart';
import '../../data/tool_repository.dart';
import '../providers/tool_providers.dart';
import 'tool_category_icon.dart';

/// Saved tools / wishlist (P10.3).
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(wishlistProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.shopSavedTools)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wishlistProvider);
          await ref.read(wishlistProvider.future);
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
          data: (tools) {
            if (tools.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Icon(
                    Icons.favorite_border,
                    size: 56,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.wishlistEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: tools.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _tile(context, ref, tools[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, Tool t) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => context.push('/tools/${t.slug}'),
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceBlue.withValues(alpha: 0.5),
          child: Icon(toolCategoryIcon(t.category), color: AppColors.primary),
        ),
        title: Text(
          t.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${l.pricePrefix} ${t.price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: IconButton(
          tooltip: l.wishlistRemove,
          icon: const Icon(Icons.favorite, color: AppColors.accent),
          onPressed: () async {
            try {
              await ref.read(toolRepositoryProvider).removeFromWishlist(t.id);
              ref.invalidate(wishlistProvider);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          },
        ),
      ),
    );
  }
}
