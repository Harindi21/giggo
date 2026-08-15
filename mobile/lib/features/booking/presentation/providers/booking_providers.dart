import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';

/// A single booking the signed-in user is part of.
final bookingDetailProvider = FutureProvider.family<Booking, String>((ref, id) {
  return ref.watch(bookingRepositoryProvider).getBooking(id);
});

/// Ordered status history for a booking.
final bookingTimelineProvider =
    FutureProvider.family<List<StatusEvent>, String>((ref, id) {
      return ref.watch(bookingRepositoryProvider).getTimeline(id);
    });
