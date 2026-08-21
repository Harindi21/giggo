import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin/data/models/admin_metrics.dart';

void main() {
  test('parses platform metrics with top categories', () {
    final m = AdminMetrics.fromJson({
      'gmv': 12000,
      'platformRevenue': 1000,
      'currency': 'LKR',
      'totalBookings': 10,
      'activeJobs': 3,
      'completedJobs': 5,
      'conversionRate': 50.0,
      'totalUsers': 8,
      'customers': 5,
      'providers': 3,
      'verifiedProviders': 2,
      'newUsers30d': 4,
      'repeatCustomerRate': 25.0,
      'openDisputes': 1,
      'toolOrders': 2,
      'toolSales': 2000,
      'topCategories': [
        {'name': 'Plumbing', 'bookings': 6},
        {'name': 'Electrical', 'bookings': 4},
      ],
    });

    expect(m.gmv, 12000);
    expect(m.platformRevenue, 1000);
    expect(m.conversionRate, 50.0);
    expect(m.repeatCustomerRate, 25.0);
    expect(m.verifiedProviders, 2);
    expect(m.topCategories, hasLength(2));
    expect(m.topCategories.first.name, 'Plumbing');
    expect(m.topCategories.first.bookings, 6);
  });

  test('defaults are safe when fields are missing', () {
    final m = AdminMetrics.fromJson({});
    expect(m.gmv, 0);
    expect(m.currency, 'LKR');
    expect(m.totalBookings, 0);
    expect(m.topCategories, isEmpty);
  });
}
