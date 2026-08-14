import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tracking/data/models/provider_location.dart';

void main() {
  test('parses a location frame from the tracking socket', () {
    final loc = ProviderLocation.fromJson({
      'jobId': 'job-1',
      'latitude': 6.93,
      'longitude': 79.9,
      'headingDegrees': null,
      'speedKmh': 22.5,
      'accuracyMeters': null,
      'at': '2026-08-13T10:00:00+05:30',
    });

    expect(loc.jobId, 'job-1');
    expect(loc.latitude, 6.93);
    expect(loc.longitude, 79.9);
    expect(loc.speedKmh, 22.5);
    expect(loc.headingDegrees, isNull);
    expect(loc.at, isNotNull);
  });

  test('handles integer coordinates and missing optional fields', () {
    final loc = ProviderLocation.fromJson({
      'jobId': 'job-2',
      'latitude': 7,
      'longitude': 80,
    });

    expect(loc.latitude, 7.0);
    expect(loc.longitude, 80.0);
    expect(loc.speedKmh, isNull);
    expect(loc.at, isNull);
  });
}
