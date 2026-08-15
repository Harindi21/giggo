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

  IconData _iconFor(String category) {
    switch (category) {
      case 'Property Maintenance':
        return Icons.home_repair_service_outlined;
      case 'Moving & Delivery':
        return Icons.local_shipping_outlined;
      case 'Life Style & Personal':
        return Icons.spa_outlined;
      case 'Business & Professional':
        return Icons.business_center_outlined;
      case 'Vehicle Services':
        return Icons.directions_car_outlined;
      default:
        return Icons.category_outlined;
    }
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
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 18,
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
                itemBuilder: (context, i) => _categoryTile(list[i]),
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
            TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Search services or providers',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.accent,
                  ),
                  onPressed: () => _submitSearch(_searchCtrl.text),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _categoryTile(Category c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceBlue.withValues(alpha: 0.7),
            child: Icon(_iconFor(c.name), color: AppColors.primary),
          ),
          title: Text(
            c.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: c.description != null
              ? Text(
                  c.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onTap: () => context.push(
            '/home/category/${c.id}?name=${Uri.encodeComponent(c.name)}',
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
                  fontSize: 18,
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
