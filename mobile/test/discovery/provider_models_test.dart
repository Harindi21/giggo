import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discovery/data/models/provider_models.dart';

void main() {
  test('parses a provider card', () {
    final c = ProviderCard.fromJson({
      'id': 'pp1',
      'userId': 'u1',
      'fullName': 'Kamal',
      'headline': 'Experienced Plumber',
      'district': 'Colombo',
      'avgRating': 4.6,
      'ratingCount': 12,
      'jobsCompleted': 20,
      'basePrice': 1500,
      'hourlyRate': 800,
      'available': true,
      'verified': true,
    });
    expect(c.id, 'pp1');
    expect(c.fullName, 'Kamal');
    expect(c.avgRating, 4.6);
    expect(c.verified, isTrue);
  });

  test('provider card tolerates missing numeric/bool fields', () {
    final c = ProviderCard.fromJson({
      'id': 'pp2',
      'userId': 'u2',
      'fullName': 'New Pro',
    });
    expect(c.avgRating, 0);
    expect(c.ratingCount, 0);
    expect(c.available, isTrue);
    expect(c.verified, isFalse);
  });

  test('parses provider detail with skills', () {
    final d = ProviderDetail.fromJson({
      'id': 'pp1',
      'userId': 'u1',
      'fullName': 'Kamal',
      'yearsExperience': 5,
      'avgRating': 4.6,
      'ratingCount': 12,
      'jobsCompleted': 20,
      'basePrice': 1500,
      'hourlyRate': 800,
      'available': true,
      'verified': true,
      'skills': [
        {'id': 's1', 'categoryId': 'c1', 'name': 'Pipe repair'},
      ],
    });
    expect(d.yearsExperience, 5);
    expect(d.skills, hasLength(1));
    expect(d.skills.first.name, 'Pipe repair');
  });
}
