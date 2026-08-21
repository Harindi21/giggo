double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// Platform analytics for the admin dashboard (mirrors AdminMetricsResponse).
class AdminMetrics {
  final double gmv;
  final double platformRevenue;
  final String currency;
  final int totalBookings;
  final int activeJobs;
  final int completedJobs;
  final double conversionRate;
  final int totalUsers;
  final int customers;
  final int providers;
  final int verifiedProviders;
  final int newUsers30d;
  final double repeatCustomerRate;
  final int openDisputes;
  final int toolOrders;
  final double toolSales;
  final List<CategoryStat> topCategories;

  const AdminMetrics({
    required this.gmv,
    required this.platformRevenue,
    required this.currency,
    required this.totalBookings,
    required this.activeJobs,
    required this.completedJobs,
    required this.conversionRate,
    required this.totalUsers,
    required this.customers,
    required this.providers,
    required this.verifiedProviders,
    required this.newUsers30d,
    required this.repeatCustomerRate,
    required this.openDisputes,
    required this.toolOrders,
    required this.toolSales,
    required this.topCategories,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) => AdminMetrics(
    gmv: _toDouble(json['gmv']),
    platformRevenue: _toDouble(json['platformRevenue']),
    currency: json['currency'] as String? ?? 'LKR',
    totalBookings: _toInt(json['totalBookings']),
    activeJobs: _toInt(json['activeJobs']),
    completedJobs: _toInt(json['completedJobs']),
    conversionRate: _toDouble(json['conversionRate']),
    totalUsers: _toInt(json['totalUsers']),
    customers: _toInt(json['customers']),
    providers: _toInt(json['providers']),
    verifiedProviders: _toInt(json['verifiedProviders']),
    newUsers30d: _toInt(json['newUsers30d']),
    repeatCustomerRate: _toDouble(json['repeatCustomerRate']),
    openDisputes: _toInt(json['openDisputes']),
    toolOrders: _toInt(json['toolOrders']),
    toolSales: _toDouble(json['toolSales']),
    topCategories: (json['topCategories'] as List<dynamic>? ?? [])
        .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class CategoryStat {
  final String name;
  final int bookings;

  const CategoryStat({required this.name, required this.bookings});

  factory CategoryStat.fromJson(Map<String, dynamic> json) => CategoryStat(
    name: json['name'] as String? ?? '',
    bookings: _toInt(json['bookings']),
  );
}
