import 'catalog_models.dart';

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// Compact provider for list/search screens.
class ProviderCard {
  final String id;
  final String userId;
  final String fullName;
  final String? headline;
  final String? district;
  final String? avatarUrl;
  final double avgRating;
  final int ratingCount;
  final int jobsCompleted;
  final double basePrice;
  final double hourlyRate;
  final bool available;
  final bool verified;

  const ProviderCard({
    required this.id,
    required this.userId,
    required this.fullName,
    this.headline,
    this.district,
    this.avatarUrl,
    required this.avgRating,
    required this.ratingCount,
    required this.jobsCompleted,
    required this.basePrice,
    required this.hourlyRate,
    required this.available,
    required this.verified,
  });

  factory ProviderCard.fromJson(Map<String, dynamic> json) => ProviderCard(
        id: json['id'] as String,
        userId: json['userId'] as String,
        fullName: json['fullName'] as String,
        headline: json['headline'] as String?,
        district: json['district'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        avgRating: _toDouble(json['avgRating']),
        ratingCount: _toInt(json['ratingCount']),
        jobsCompleted: _toInt(json['jobsCompleted']),
        basePrice: _toDouble(json['basePrice']),
        hourlyRate: _toDouble(json['hourlyRate']),
        available: json['available'] as bool? ?? true,
        verified: json['verified'] as bool? ?? false,
      );
}

/// Full provider for the detail screen.
class ProviderDetail {
  final String id;
  final String userId;
  final String fullName;
  final String? headline;
  final String? bio;
  final int yearsExperience;
  final String? district;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final String? avatarUrl;
  final double avgRating;
  final int ratingCount;
  final int jobsCompleted;
  final double basePrice;
  final double hourlyRate;
  final bool available;
  final bool verified;
  final List<Skill> skills;

  const ProviderDetail({
    required this.id,
    required this.userId,
    required this.fullName,
    this.headline,
    this.bio,
    required this.yearsExperience,
    this.district,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.avatarUrl,
    required this.avgRating,
    required this.ratingCount,
    required this.jobsCompleted,
    required this.basePrice,
    required this.hourlyRate,
    required this.available,
    required this.verified,
    required this.skills,
  });

  factory ProviderDetail.fromJson(Map<String, dynamic> json) => ProviderDetail(
        id: json['id'] as String,
        userId: json['userId'] as String,
        fullName: json['fullName'] as String,
        headline: json['headline'] as String?,
        bio: json['bio'] as String?,
        yearsExperience: _toInt(json['yearsExperience']),
        district: json['district'] as String?,
        addressLine: json['addressLine'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        avatarUrl: json['avatarUrl'] as String?,
        avgRating: _toDouble(json['avgRating']),
        ratingCount: _toInt(json['ratingCount']),
        jobsCompleted: _toInt(json['jobsCompleted']),
        basePrice: _toDouble(json['basePrice']),
        hourlyRate: _toDouble(json['hourlyRate']),
        available: json['available'] as bool? ?? true,
        verified: json['verified'] as bool? ?? false,
        skills: (json['skills'] as List<dynamic>? ?? [])
            .map((e) => Skill.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
