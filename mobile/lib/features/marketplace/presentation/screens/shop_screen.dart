import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/giggo_wordmark.dart';
import '../../data/models/tool_models.dart';
import '../providers/tool_providers.dart';
import 'tool_category_icon.dart';

/// Tool Marketplace shop (P10.2), aligned to the Figma: a navy header with a
/// search toolbar over a 2-column grid of product cards (photo on top, navy
/// footer with name, price and an add-to-cart circle). Serves both roles.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _category; // null = All
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(toolsProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(toolsProvider);
          await ref.read(toolsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            ...async.when(
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _message(e.toString()),
                ),
              ],
              data: _gridSlivers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const GiggoWordmark(fontSize: 26, onDark: true),
                InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(24),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                InkWell(
                  onTap: _showMenu,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(width: 10),
                _circleBtn(Icons.shopping_cart, () => context.push('/orders')),
                const SizedBox(width: 10),
                _circleBtn(
                  Icons.search,
                  () => setState(() => _query = _searchCtrl.text.trim()),
                ),
                const SizedBox(width: 12),
                Expanded(child: _searchField()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      onSubmitted: (v) => setState(() => _query = v.trim()),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalizations.of(context).shopSearchProducts,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showMenu() {
    final items = ref.read(toolsProvider).value ?? const <Tool>[];
    final categories = <String>{for (final t in items) t.category}.toList()
      ..sort();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(
                Icons.favorite_border,
                color: AppColors.primary,
              ),
              title: Text(AppLocalizations.of(context).shopSavedTools),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/wishlist');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
              ),
              title: Text(AppLocalizations.of(context).shopMyOrders),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/orders');
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                AppLocalizations.of(context).shopCategories,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _catTile(
              sheetCtx,
              AppLocalizations.of(context).shopAllCategories,
              null,
            ),
            for (final c in categories) _catTile(sheetCtx, c, c),
          ],
        ),
      ),
    );
  }

  Widget _catTile(BuildContext sheetCtx, String label, String? value) {
    final selected = _category == value;
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.accent)
          : null,
      selected: selected,
      onTap: () {
        setState(() => _category = value);
        Navigator.pop(sheetCtx);
      },
    );
  }

  List<Widget> _gridSlivers(List<Tool> items) {
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _message(AppLocalizations.of(context).shopNoTools),
        ),
      ];
    }
    var filtered = _category == null
        ? items
        : items.where((t) => t.category == _category).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.name.toLowerCase().contains(q) ||
                (t.brand?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _message(AppLocalizations.of(context).shopNoMatch),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _toolCard(filtered[i]),
            childCount: filtered.length,
          ),
        ),
      ),
    ];
  }

  Widget _toolCard(Tool t) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/tools/${t.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _toolImage(t)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context).pricePrefix} ${t.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _cartCircle(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolImage(Tool t) {
    Widget fallback() => Container(
      color: AppColors.surfaceBlue.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          toolCategoryIcon(t.category),
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );

    if (t.imageUrl == null || t.imageUrl!.isEmpty) return fallback();
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Image.network(
        t.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                color: Colors.white,
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _cartCircle(Tool t) {
    final enabled = t.available;
    return InkWell(
      onTap: enabled
          ? () => context.push('/checkout/${t.slug}')
          : () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).shopUnavailable),
              ),
            ),
      customBorder: const CircleBorder(),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: enabled ? 1 : 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _message(String msg) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.textMuted,
          size: 44,
        ),
        const SizedBox(height: 8),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    ),
  );
}
