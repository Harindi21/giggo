double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// A provider's average ratings by dimension (P6.6).
class RatingBreakdown {
  final double service;
  final double punctuality;
  final double value;
  final int count;

  const RatingBreakdown({
    required this.service,
    required this.punctuality,
    required this.value,
    required this.count,
  });

  /// True when at least one dimension has been scored.
  bool get hasRatings =>
      count > 0 && (service > 0 || punctuality > 0 || value > 0);

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) => RatingBreakdown(
    service: _toDouble(json['service']),
    punctuality: _toDouble(json['punctuality']),
    value: _toDouble(json['value']),
    count: _toInt(json['count']),
  );
}
