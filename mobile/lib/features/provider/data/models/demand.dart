/// Demand outlook for one service category (AI #4). Mirrors CategoryDemandResponse.
class CategoryDemand {
  final String category;
  final List<int> weeklyCounts; // oldest → newest
  final int forecastNextWeek;
  final String trend; // rising | falling | steady

  const CategoryDemand({
    required this.category,
    required this.weeklyCounts,
    required this.forecastNextWeek,
    required this.trend,
  });

  factory CategoryDemand.fromJson(Map<String, dynamic> json) => CategoryDemand(
    category: json['category'] as String? ?? '',
    weeklyCounts: ((json['weeklyCounts'] as List<dynamic>?) ?? const [])
        .map((e) => (e as num).toInt())
        .toList(),
    forecastNextWeek: (json['forecastNextWeek'] as num?)?.toInt() ?? 0,
    trend: json['trend'] as String? ?? 'steady',
  );
}
