import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/provider/data/models/working_hour.dart';

void main() {
  test('parses backend HH:mm:ss times', () {
    final w = WorkingHour.fromJson({
      'dayOfWeek': 3,
      'startTime': '09:00:00',
      'endTime': '17:30:00',
    });
    expect(w.dayOfWeek, 3);
    expect(w.start, const TimeOfDay(hour: 9, minute: 0));
    expect(w.end, const TimeOfDay(hour: 17, minute: 30));
  });

  test('serialises to the backend shape (HH:mm:00)', () {
    final json = const WorkingHour(
      dayOfWeek: 1,
      start: TimeOfDay(hour: 8, minute: 5),
      end: TimeOfDay(hour: 16, minute: 0),
    ).toJson();
    expect(json['dayOfWeek'], 1);
    expect(json['startTime'], '08:05:00');
    expect(json['endTime'], '16:00:00');
  });
}
