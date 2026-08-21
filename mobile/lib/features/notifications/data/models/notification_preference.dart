/// A user's push preference for one notification category (mirrors backend).
class NotificationPreference {
  final String category; // BOOKINGS | PAYMENTS | REVIEWS | SYSTEM
  final bool pushEnabled;

  const NotificationPreference({
    required this.category,
    required this.pushEnabled,
  });

  /// Human label for the category.
  String get label => switch (category) {
    'BOOKINGS' => 'Bookings',
    'PAYMENTS' => 'Payments',
    'REVIEWS' => 'Reviews',
    'SYSTEM' => 'Account & system',
    _ => category,
  };

  String get description => switch (category) {
    'BOOKINGS' => 'Requests, acceptances and job status updates',
    'PAYMENTS' => 'Escrow, payouts and payment updates',
    'REVIEWS' => 'When you receive a new review',
    'SYSTEM' => 'Verification and account notices',
    _ => '',
  };

  NotificationPreference copyWith({bool? pushEnabled}) =>
      NotificationPreference(
        category: category,
        pushEnabled: pushEnabled ?? this.pushEnabled,
      );

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        category: json['category'] as String,
        pushEnabled: json['pushEnabled'] as bool? ?? true,
      );
}
