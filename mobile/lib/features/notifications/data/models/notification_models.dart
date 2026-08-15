/// An in-app notification (P8). Named AppNotification to avoid clashing with
/// Flutter's own Notification widget class.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? bookingId;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.bookingId,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        bookingId: json['bookingId'] as String?,
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}
