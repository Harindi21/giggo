import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../discovery/data/discovery_repository.dart';

/// Rate & review a completed job (P6.7). Submits stars + text; the backend scores
/// the text with NLP and returns the sentiment we show back to the customer.
class RateReviewScreen extends ConsumerStatefulWidget {
  const RateReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends ConsumerState<RateReviewScreen> {
  int _stars = 0;
  final _bodyCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1) {
      setState(() => _error = 'Please tap a star rating first.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final review = await ref
          .read(discoveryRepositoryProvider)
          .submitReview(widget.bookingId, _stars, _bodyCtrl.text.trim());
      if (!mounted) return;
      final sentiment = review.sentimentLabel;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sentiment == null
              ? 'Thanks for your review!'
              : 'Thanks! We read your review as "$sentiment".'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate your provider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How was the service?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    iconSize: 40,
                    onPressed: _submitting ? null : () => setState(() => _stars = i),
                    icon: Icon(
                      i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              maxLength: 2000,
              enabled: !_submitting,
              decoration: const InputDecoration(
                hintText: 'Tell others about your experience (optional)…',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit review'),
            ),
          ],
        ),
      ),
    );
  }
}
