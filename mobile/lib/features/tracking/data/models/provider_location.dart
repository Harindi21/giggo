/// A provider's live position for a job, received over the tracking socket.
class ProviderLocation {
  final String jobId;
  final double latitude;
  final double longitude;
  final double? headingDegrees;
  final double? speedKmh;
  final double? accuracyMeters;
  final DateTime? at;

  const ProviderLocation({
    required this.jobId,
    required this.latitude,
    required this.longitude,
    this.headingDegrees,
    this.speedKmh,
    this.accuracyMeters,
    this.at,
  });

  factory ProviderLocation.fromJson(Map<String, dynamic> json) => ProviderLocation(
        jobId: json['jobId'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        headingDegrees: (json['headingDegrees'] as num?)?.toDouble(),
        speedKmh: (json['speedKmh'] as num?)?.toDouble(),
        accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
        at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
      );
}
