double? _toDoubleN(dynamic v) => (v as num?)?.toDouble();
double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;

/// A skill attached to a provider profile.
class ProfileSkill {
  final String id;
  final String name;

  const ProfileSkill({required this.id, required this.name});

  factory ProfileSkill.fromJson(Map<String, dynamic> json) => ProfileSkill(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
  );
}

/// The signed-in provider's own profile (mirrors the backend
/// ProviderProfileResponse). Editable via [MyProviderProfileRepository].
class ProviderProfile {
  final String id;
  final String userId;
  final String fullName;
  final String? bio;
  final int yearsExperience;
  final bool available;
  final String? headline;
  final String? district;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final double basePrice;
  final double hourlyRate;
  final double avgRating;
  final int ratingCount;
  final int jobsCompleted;
  final bool verified;
  final String? avatarUrl;
  final List<ProfileSkill> skills;

  const ProviderProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.bio,
    required this.yearsExperience,
    required this.available,
    this.headline,
    this.district,
    this.addressLine,
    this.latitude,
    this.longitude,
    required this.basePrice,
    required this.hourlyRate,
    required this.avgRating,
    required this.ratingCount,
    required this.jobsCompleted,
    required this.verified,
    this.avatarUrl,
    required this.skills,
  });

  List<String> get skillIds => skills.map((s) => s.id).toList();

  factory ProviderProfile.fromJson(Map<String, dynamic> json) => ProviderProfile(
    id: json['id'] as String,
    userId: json['userId'] as String,
    fullName: json['fullName'] as String? ?? '',
    bio: json['bio'] as String?,
    yearsExperience: (json['yearsExperience'] as num?)?.toInt() ?? 0,
    available: json['available'] as bool? ?? true,
    headline: json['headline'] as String?,
    district: json['district'] as String?,
    addressLine: json['addressLine'] as String?,
    latitude: _toDoubleN(json['latitude']),
    longitude: _toDoubleN(json['longitude']),
    basePrice: _toDouble(json['basePrice']),
    hourlyRate: _toDouble(json['hourlyRate']),
    avgRating: _toDouble(json['avgRating']),
    ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    jobsCompleted: (json['jobsCompleted'] as num?)?.toInt() ?? 0,
    verified: json['verified'] as bool? ?? false,
    avatarUrl: json['avatarUrl'] as String?,
    skills: (json['skills'] as List<dynamic>? ?? [])
        .map((e) => ProfileSkill.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// The editable fields sent to PUT /provider/profile.
class ProviderProfileUpdate {
  final String bio;
  final int yearsExperience;
  final String headline;
  final String district;
  final String addressLine;
  final double? latitude;
  final double? longitude;
  final double basePrice;
  final double hourlyRate;
  final bool available;
  final List<String> skillIds;

  const ProviderProfileUpdate({
    required this.bio,
    required this.yearsExperience,
    required this.headline,
    required this.district,
    required this.addressLine,
    this.latitude,
    this.longitude,
    required this.basePrice,
    required this.hourlyRate,
    required this.available,
    required this.skillIds,
  });

  Map<String, dynamic> toJson() => {
    'bio': bio,
    'yearsExperience': yearsExperience,
    'headline': headline,
    'district': district,
    'addressLine': addressLine,
    'latitude': ?latitude,
    'longitude': ?longitude,
    'basePrice': basePrice,
    'hourlyRate': hourlyRate,
    'available': available,
    'skillIds': skillIds,
  };
}
