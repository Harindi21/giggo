import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/marketplace/data/models/tool_models.dart';

void main() {
  test('parses a tool', () {
    final t = Tool.fromJson({
      'id': 't1',
      'slug': 'cordless-drill-18v',
      'name': 'Cordless Drill 18V',
      'category': 'Power Tools',
      'brand': 'Bosch',
      'description': 'Compact 18V drill',
      'price': 12500,
      'currency': 'LKR',
      'available': true,
    });
    expect(t.slug, 'cordless-drill-18v');
    expect(t.name, 'Cordless Drill 18V');
    expect(t.category, 'Power Tools');
    expect(t.price, 12500);
    expect(t.available, isTrue);
  });

  test('defaults currency and handles a missing brand/image', () {
    final t = Tool.fromJson({
      'id': 't2',
      'slug': 'gloves',
      'name': 'Gloves',
      'category': 'Safety Gear',
      'description': 'Cut resistant',
      'price': 2500,
    });
    expect(t.currency, 'LKR');
    expect(t.brand, isNull);
    expect(t.imageUrl, isNull);
    expect(t.available, isTrue);
  });
}
