/// A review shown on a provider's profile.
class Review {
  final String id;
  final String? reviewerName;
  final int stars;
  final String? body;
  final String? sentimentLabel; // positive | neutral | negative
  final int? sentimentStar;
  final String? sentimentEmotion;
  final double? enhancedRating;
  final DateTime? createdAt;

  const Review({
    required this.id,
    this.reviewerName,
    required this.stars,
    this.body,
    this.sentimentLabel,
    this.sentimentStar,
    this.sentimentEmotion,
    this.enhancedRating,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        reviewerName: json['reviewerName'] as String?,
        stars: (json['stars'] as num).toInt(),
        body: json['body'] as String?,
        sentimentLabel: json['sentimentLabel'] as String?,
        sentimentStar: (json['sentimentStar'] as num?)?.toInt(),
        sentimentEmotion: json['sentimentEmotion'] as String?,
        enhancedRating: (json['enhancedRating'] as num?)?.toDouble(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}
