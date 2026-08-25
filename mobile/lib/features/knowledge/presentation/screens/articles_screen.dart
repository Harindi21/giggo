import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/giggo_wordmark.dart';
import '../../data/models/article_models.dart';
import '../providers/article_providers.dart';

/// Knowledge Hub (P9), aligned to the Figma: a navy header with the "Learn new
/// things / And master you trade" heading over a list of alternating
/// navy / light-blue article cards. Search, profession recommendations and
/// category filters are kept as useful additions.
class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
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
    final async = ref.watch(articlesProvider(_query));
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(articlesProvider(_query));
          await ref.read(articlesProvider(_query).future);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _searchBar(),
            ),
            async.when(
              loading: _spinner,
              error: (e, _) => _message(e.toString()),
              data: _body,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
            Text.rich(
              const TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnDark,
                ),
                children: [
                  TextSpan(text: 'Learn '),
                  TextSpan(
                    text: 'new',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  TextSpan(text: ' things\nAnd master you '),
                  TextSpan(
                    text: 'trade',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      onSubmitted: (v) => setState(() => _query = v.trim()),
      decoration: InputDecoration(
        hintText: 'Search guides…',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
      ),
    );
  }

  Widget _body(List<Article> items) {
    if (items.isEmpty) {
      return _message(
        _query.isEmpty
            ? 'No guides yet — check back soon.'
            : 'No guides match "$_query".',
      );
    }
    final categories = <String>{for (final a in items) a.category}.toList()
      ..sort();
    final filtered = _category == null
        ? items
        : items.where((a) => a.category == _category).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_query.isEmpty) _recommendedStrip(),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
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
          const SizedBox(height: 14),
          for (final (i, a) in filtered.indexed) _card(a, i),
        ],
      ),
    );
  }

  Widget _recommendedStrip() {
    final async = ref.watch(recommendedArticlesProvider);
    return async.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended for you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _recCard(list[i]),
              ),
            ),
            const SizedBox(height: 18),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _recCard(Article a) {
    return SizedBox(
      width: 220,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/articles/${a.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.category,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    a.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 13,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Read guide',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

  /// Article card with alternating navy / light-blue background (Figma hub).
  Widget _card(Article a, int index) {
    final dark = index.isOdd;
    final bg = dark ? AppColors.primary : AppColors.surfaceBlue;
    final titleColor = dark ? Colors.white : AppColors.textPrimary;
    final subColor = dark ? Colors.white70 : AppColors.textBody;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/articles/${a.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: titleColor,
                  ),
                ),
                if (a.excerpt.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    a.excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: subColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _spinner() => const Padding(
    padding: EdgeInsets.only(top: 120),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _message(String msg) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
    child: Column(
      children: [
        const Icon(
          Icons.menu_book_outlined,
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
