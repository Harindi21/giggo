import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/article_repository.dart';
import '../../data/models/article_models.dart';
import '../providers/article_providers.dart';

/// Knowledge Hub article detail (P9.2) with view tracking + helpfulness rating (P9.4).
class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _rated = false;

  @override
  void initState() {
    super.initState();
    // Count the view once (fire-and-forget; never blocks the read).
    Future.microtask(() async {
      try {
        await ref.read(articleRepositoryProvider).recordView(widget.slug);
      } catch (_) {
        // ignore — a view-count hiccup must not affect reading
      }
    });
  }

  Future<void> _rate(int rating) async {
    setState(() => _rated = true);
    try {
      await ref.read(articleRepositoryProvider).rate(widget.slug, rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for the feedback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _rated = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(articleProvider(widget.slug));
    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _error(context, e.toString()),
        data: (a) => _content(context, a),
      ),
    );
  }

  Widget _content(BuildContext context, Article a) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${a.category} · ${a.authorName}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                _metrics(a),
                const SizedBox(height: 20),
                for (final para in _paragraphs(a.content ?? a.excerpt)) ...[
                  Text(
                    para,
                    style: const TextStyle(
                      color: AppColors.textBody,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                _helpful(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrics(Article a) {
    return Row(
      children: [
        const Icon(Icons.visibility_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '${a.viewCount + 1} views',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        if (a.ratingCount > 0) ...[
          const SizedBox(width: 12),
          const Icon(Icons.star_rounded, size: 15, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(
            '${a.avgRating.toStringAsFixed(1)} (${a.ratingCount})',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _helpful() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            _rated ? 'Thanks for rating this guide!' : 'Was this guide helpful?',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (!_rated) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    iconSize: 30,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _rate(i),
                    icon: const Icon(
                      Icons.star_outline_rounded,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text(
                  'Knowledge Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.menu_book_outlined, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _paragraphs(String content) => content
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  Widget _error(BuildContext context, String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    ),
  );
}
