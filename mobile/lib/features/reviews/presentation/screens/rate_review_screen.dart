import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';

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
  int _service = 0;
  int _punctuality = 0;
  int _value = 0;
  final _bodyCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_stars < 1) {
      setState(() => _error = l.reviewErrStars);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final review = await ref
          .read(discoveryRepositoryProvider)
          .submitReview(
            widget.bookingId,
            _stars,
            _bodyCtrl.text.trim(),
            serviceRating: _service == 0 ? null : _service,
            punctualityRating: _punctuality == 0 ? null : _punctuality,
            valueRating: _value == 0 ? null : _value,
          );
      if (!mounted) return;
      final sentiment = review.sentimentLabel;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sentiment == null
                ? l.reviewThanks
                : l.reviewThanksSentiment(sentiment),
          ),
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

  Widget _dimensionRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: const TextStyle(color: AppColors.textBody)),
        ),
        for (int i = 1; i <= 5; i++)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 26,
            onPressed: _submitting ? null : () => onChanged(i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.accent,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.reviewHowWasService,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    iconSize: 40,
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _stars = i),
                    icon: Icon(
                      i <= _stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              l.reviewRateDetails,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            _dimensionRow(
              l.bookingSectionService,
              _service,
              (v) => setState(() => _service = v),
            ),
            _dimensionRow(
              l.reviewPunctuality,
              _punctuality,
              (v) => setState(() => _punctuality = v),
            ),
            _dimensionRow(
              l.reviewValue,
              _value,
              (v) => setState(() => _value = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              maxLength: 2000,
              enabled: !_submitting,
              decoration: InputDecoration(
                hintText: l.reviewBodyHint,
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
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l.reviewSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
