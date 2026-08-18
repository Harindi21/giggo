/// A review as seen in the admin moderation queue (P6.5).
class AdminReview {
  final String id;
  final String providerId;
  final String? reviewerName;
  final int stars;
  final String? body;
  final String? sentimentLabel;
  final bool hidden;
  final String? moderationReason;
  final int reportCount;
  final DateTime? createdAt;

  const AdminReview({
    required this.id,
    required this.providerId,
    this.reviewerName,
    required this.stars,
    this.body,
    this.sentimentLabel,
    required this.hidden,
    this.moderationReason,
    required this.reportCount,
    this.createdAt,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) => AdminReview(
    id: json['id'] as String,
    providerId: json['providerId'] as String,
    reviewerName: json['reviewerName'] as String?,
    stars: (json['stars'] as num?)?.toInt() ?? 0,
    body: json['body'] as String?,
    sentimentLabel: json['sentimentLabel'] as String?,
    hidden: json['hidden'] as bool? ?? false,
    moderationReason: json['moderationReason'] as String?,
    reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
  );
}
