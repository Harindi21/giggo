import 'package:flutter/material.dart' show TimeOfDay;

/// A provider's working interval for one weekday (mirrors WorkingHourResponse).
/// dayOfWeek follows DateTime/DayOfWeek: 1 = Monday … 7 = Sunday.
class WorkingHour {
  final int dayOfWeek;
  final TimeOfDay start;
  final TimeOfDay end;

  const WorkingHour({
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });

  static TimeOfDay parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  factory WorkingHour.fromJson(Map<String, dynamic> json) => WorkingHour(
    dayOfWeek: (json['dayOfWeek'] as num).toInt(),
    start: parseTime(json['startTime'] as String),
    end: parseTime(json['endTime'] as String),
  );

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': formatTime(start),
    'endTime': formatTime(end),
  };
}
