import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_models.dart';
import '../../data/models/notification_preference.dart';
import '../../data/notification_repository.dart';

/// The signed-in user's recent notifications.
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).list();
});

/// Unread notification count for the bell badge.
final unreadCountProvider = FutureProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).unreadCount();
});

/// Per-category push preferences (P8.5).
final notificationPreferencesProvider =
    FutureProvider<List<NotificationPreference>>((ref) {
      return ref.watch(notificationRepositoryProvider).getPreferences();
    });
