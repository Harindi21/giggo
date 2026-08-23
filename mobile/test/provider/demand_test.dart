import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/provider/data/models/demand.dart';

void main() {
  test('parses a category demand outlook', () {
    final d = CategoryDemand.fromJson({
      'category': 'Plumbing',
      'weeklyCounts': [0, 1, 2, 1, 3, 2, 4, 5],
      'forecastNextWeek': 6,
      'trend': 'rising',
    });
    expect(d.category, 'Plumbing');
    expect(d.weeklyCounts, hasLength(8));
    expect(d.weeklyCounts.last, 5);
    expect(d.forecastNextWeek, 6);
    expect(d.trend, 'rising');
  });

  test('defaults are safe when fields are missing', () {
    final d = CategoryDemand.fromJson({'category': 'Electrical'});
    expect(d.weeklyCounts, isEmpty);
    expect(d.forecastNextWeek, 0);
    expect(d.trend, 'steady');
  });
}
