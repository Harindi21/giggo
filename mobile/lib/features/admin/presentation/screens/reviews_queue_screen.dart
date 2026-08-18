import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../data/admin_review_repository.dart';
import '../../data/models/admin_review_models.dart';
import '../providers/admin_review_providers.dart';

/// Admin review moderation queue (P6.5): report-flagged reviews, hide/restore.
class ReviewsQueueScreen extends ConsumerStatefulWidget {
  const ReviewsQueueScreen({super.key});

  @override
  ConsumerState<ReviewsQueueScreen> createState() => _ReviewsQueueScreenState();
}

class _ReviewsQueueScreenState extends ConsumerState<ReviewsQueueScreen> {
  bool _reportedOnly = false;
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminReviewsProvider(_reportedOnly));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          Row(
            children: [
              const Text('Reported only', style: TextStyle(fontSize: 12.5)),
              Switch(
                value: _reportedOnly,
                onChanged: (v) => setState(() => _reportedOnly = v),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminReviewsProvider(_reportedOnly));
          await ref.read(adminReviewsProvider(_reportedOnly).future);
        },
        child: async.when(
          loading: () => _spinner(),
          error: (e, _) => _message(e.toString()),
          data: (items) => _list(items),
        ),
      ),
    );
  }

  Widget _list(List<AdminReview> items) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.rate_review_outlined,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            _reportedOnly ? 'No reported reviews' : 'No reviews',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [for (final r in items) _card(r)],
    );
  }

  Widget _card(AdminReview r) {
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.reviewerName ?? 'Customer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              RatingStars(rating: r.stars.toDouble(), size: 14),
            ],
          ),
          if (r.body != null && r.body!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              r.body!,
              style: const TextStyle(color: AppColors.textBody, height: 1.35),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (r.reportCount > 0)
                _tag(
                  '${r.reportCount} report${r.reportCount == 1 ? '' : 's'}',
                  AppColors.warning,
                ),
              if (r.hidden) _tag('Hidden', AppColors.error),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: r.hidden
                ? OutlinedButton(
                    onPressed: busy ? null : () => _restore(r),
                    child: const Text('Restore'),
                  )
                : ElevatedButton(
                    onPressed: busy ? null : () => _hide(r),
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Hide'),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _hide(AdminReview r) async {
    final reasonCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hide this review?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'It will be removed from the provider profile and its rating.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Reason (optional)',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hide'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await _run(
        r.id,
        () => ref
            .read(adminReviewRepositoryProvider)
            .hide(r.id, reasonCtrl.text.trim()),
        'Review hidden.',
      );
    } finally {
      reasonCtrl.dispose();
    }
  }

  Future<void> _restore(AdminReview r) => _run(
    r.id,
    () => ref.read(adminReviewRepositoryProvider).restore(r.id),
    'Review restored.',
  );

  Future<void> _run(String id, Future<void> Function() op, String okMsg) async {
    setState(() => _busyId = id);
    try {
      await op();
      ref.invalidate(adminReviewsProvider(_reportedOnly));
      _snack(okMsg);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

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
      const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
      const SizedBox(height: 8),
      Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    ],
  );
}
