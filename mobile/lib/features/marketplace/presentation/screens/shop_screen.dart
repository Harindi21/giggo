import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/tool_models.dart';
import '../providers/tool_providers.dart';
import 'tool_category_icon.dart';

/// Tool Marketplace shop (P10.2): browse tools by category. Surfaces P10.1.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _category; // null = All

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(toolsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tool Marketplace')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(toolsProvider);
          await ref.read(toolsProvider.future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _body(items),
        ),
      ),
    );
  }

  Widget _body(List<Tool> items) {
    if (items.isEmpty) {
      return _message('No tools listed yet — check back soon.');
    }
    final categories = <String>{for (final t in items) t.category}.toList()
      ..sort();
    final filtered = _category == null
        ? items
        : items.where((t) => t.category == _category).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              children: [
                _chip(
                  'All',
                  _category == null,
                  () => setState(() => _category = null),
                ),
                for (final c in categories)
                  _chip(c, _category == c, () => setState(() => _category = c)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.74,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _toolCard(filtered[i]),
              childCount: filtered.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _toolCard(Tool t) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: () => context.push('/tools/${t.slug}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlue.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusCard),
                  ),
                ),
                child: Center(
                  child: Icon(
                    toolCategoryIcon(t.category),
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (t.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        t.brand!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Rs. ${t.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
  );
}
