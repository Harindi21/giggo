import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/giggo_wordmark.dart';
import '../../../../core/widgets/provider_avatar.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/provider_models.dart';
import '../providers/discovery_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submitSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    context.push('/home/search?q=${Uri.encodeComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(recommendedProvidersProvider);
          ref.invalidate(unreadCountProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _exploreCard()),
            SliverToBoxAdapter(child: _recommendedSection()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            categories.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(child: _error(e.toString())),
              data: (list) => SliverList.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => _CategoryGroup(
                  category: list[i],
                  initiallyExpanded: i == 0,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _knowledgeCard()),
            SliverToBoxAdapter(child: _promoCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                Row(
                  children: [
                    _bell(),
                    const SizedBox(width: 4),
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
              ],
            ),
            const SizedBox(height: 18),
            _searchBar(),
          ],
        ),
      ),
    );
  }

  /// Orange square search button + white field, per the Figma home header.
  Widget _searchBar() {
    return Row(
      children: [
        InkWell(
          onTap: () => _submitSearch(_searchCtrl.text),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Search services',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bell() {
    final count = ref.watch(unreadCountProvider).value ?? 0;
    return IconButton(
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.notifications_none, color: Colors.white),
      ),
    );
  }

  Widget _exploreCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore your tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track requested, ongoing and completed tasks in one place.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textBody),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => context.go('/tasks'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text('View Tasks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _knowledgeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Material(
        color: AppColors.surfaceBlue.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/articles'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips & Guides',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get the most out of GIGGO — booking, payments and safety.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _promoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book a trusted professional',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'For any of your needs, without hesitation.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.handyman, color: AppColors.accent, size: 40),
          ],
        ),
      ),
    );
  }

  /// "Recommended for you" carousel (P3.4). Hidden while loading, on error, or
  /// when empty — so providers (who get a 403 here) simply don't see it.
  Widget _recommendedSection() {
    final rec = ref.watch(recommendedProvidersProvider);
    return rec.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 202,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _recCard(list[i]),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _recCard(ProviderCard p) {
    return SizedBox(
      width: 158,
      child: Card(
        child: InkWell(
          onTap: () => context.push('/home/provider/${p.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ProviderAvatar(
                  name: p.fullName,
                  imageUrl: p.avatarUrl,
                  radius: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  p.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    p.headline,
                    p.district,
                  ].where((e) => e != null && e.isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                RatingStars(
                  rating: p.avgRating,
                  count: p.ratingCount,
                  size: 13,
                ),
                const Spacer(),
                Text(
                  'Rs. ${p.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'from',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _error(String msg) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
        const SizedBox(height: 8),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => ref.invalidate(categoriesProvider),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

/// An expandable service-category group. Collapsed it shows just the name and a
/// chevron; expanded it lazily loads the category's skills and lays them out as
/// light-blue chips (matching the Figma home). Tapping a chip opens the
/// category's provider list.
class _CategoryGroup extends ConsumerStatefulWidget {
  final Category category;
  final bool initiallyExpanded;

  const _CategoryGroup({required this.category, this.initiallyExpanded = false});

  @override
  ConsumerState<_CategoryGroup> createState() => _CategoryGroupState();
}

class _CategoryGroupState extends ConsumerState<_CategoryGroup> {
  late bool _expanded = widget.initiallyExpanded;

  void _openCategory() {
    final name = Uri.encodeComponent(widget.category.name);
    context.push('/home/category/${widget.category.id}?name=$name');
  }

  // A skill chip searches for that service (the results screen filters by it).
  void _openSkill(String skillName) {
    context.push('/home/search?q=${Uri.encodeComponent(skillName)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: _skills(),
          ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _skills() {
    final skills = ref.watch(skillsProvider(widget.category.id));
    return skills.when(
      loading: () => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => ref.invalidate(skillsProvider(widget.category.id)),
          child: const Text("Couldn't load services — tap to retry"),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return GestureDetector(
            onTap: _openCategory,
            child: const Text(
              'See providers in this category',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final s in list) _chip(s.name)],
        );
      },
    );
  }

  Widget _chip(String label) {
    return GestureDetector(
      onTap: () => _openSkill(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
