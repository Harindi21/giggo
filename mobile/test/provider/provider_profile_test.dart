import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/provider/data/models/provider_profile.dart';

void main() {
  test('parses a provider profile with skills', () {
    final p = ProviderProfile.fromJson({
      'id': 'prof1',
      'userId': 'u1',
      'fullName': 'Kamal Perera',
      'bio': 'Reliable plumber',
      'yearsExperience': 5,
      'available': true,
      'headline': '24/7 plumbing',
      'district': 'Colombo',
      'addressLine': '12 Rose Rd',
      'latitude': 6.9,
      'longitude': 79.8,
      'basePrice': 500,
      'hourlyRate': 800,
      'avgRating': 4.6,
      'ratingCount': 12,
      'jobsCompleted': 30,
      'verified': true,
      'skills': [
        {'id': 's1', 'name': 'Pipe repair'},
        {'id': 's2', 'name': 'Drain cleaning'},
      ],
    });

    expect(p.fullName, 'Kamal Perera');
    expect(p.yearsExperience, 5);
    expect(p.available, isTrue);
    expect(p.district, 'Colombo');
    expect(p.basePrice, 500);
    expect(p.hourlyRate, 800);
    expect(p.verified, isTrue);
    expect(p.skillIds, ['s1', 's2']);
  });

  test('tolerates a fresh, empty profile', () {
    final p = ProviderProfile.fromJson({
      'id': 'prof1',
      'userId': 'u1',
      'fullName': 'New Provider',
      'basePrice': 0,
      'hourlyRate': 0,
      'avgRating': 0,
    });
    expect(p.yearsExperience, 0);
    expect(p.available, isTrue); // defaults on
    expect(p.skills, isEmpty);
    expect(p.latitude, isNull);
  });

  test('update payload omits null coordinates but keeps the rest', () {
    final json = const ProviderProfileUpdate(
      headline: 'Plumber',
      bio: 'bio',
      yearsExperience: 3,
      district: 'Kandy',
      addressLine: '',
      latitude: null,
      longitude: null,
      basePrice: 400,
      hourlyRate: 700,
      available: false,
      skillIds: ['s1'],
    ).toJson();

    expect(json.containsKey('latitude'), isFalse); // null-aware entry dropped
    expect(json.containsKey('longitude'), isFalse);
    expect(json['district'], 'Kandy');
    expect(json['available'], isFalse);
    expect(json['skillIds'], ['s1']);
  });
}
