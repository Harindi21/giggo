/// ETA to the destination, from the backend (P5.4).
class EtaInfo {
  final int etaMinutes;
  final double distanceKm;
  final double speedKmhUsed;
  final double providerLatitude;
  final double providerLongitude;
  final DateTime? basedOn;

  const EtaInfo({
    required this.etaMinutes,
    required this.distanceKm,
    required this.speedKmhUsed,
    required this.providerLatitude,
    required this.providerLongitude,
    this.basedOn,
  });

  factory EtaInfo.fromJson(Map<String, dynamic> json) => EtaInfo(
        etaMinutes: (json['etaMinutes'] as num).toInt(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        speedKmhUsed: (json['speedKmhUsed'] as num?)?.toDouble() ?? 0,
        providerLatitude: (json['providerLatitude'] as num).toDouble(),
        providerLongitude: (json['providerLongitude'] as num).toDouble(),
        basedOn: json['basedOn'] != null ? DateTime.tryParse(json['basedOn'] as String) : null,
      );
}
