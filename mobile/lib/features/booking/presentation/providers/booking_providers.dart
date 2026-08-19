import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/booking_repository.dart';
import '../../data/models/booking_models.dart';
import '../../data/models/payment_models.dart';
import '../../data/models/receipt_models.dart';

/// All bookings the signed-in user is part of (customer or provider).
final myBookingsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).listMine();
});

/// A single booking the signed-in user is part of.
final bookingDetailProvider = FutureProvider.family<Booking, String>((ref, id) {
  return ref.watch(bookingRepositoryProvider).getBooking(id);
});

/// Ordered status history for a booking.
final bookingTimelineProvider =
    FutureProvider.family<List<StatusEvent>, String>((ref, id) {
      return ref.watch(bookingRepositoryProvider).getTimeline(id);
    });

/// Current payment for a booking (null until one is started).
final bookingPaymentProvider = FutureProvider.family<Payment?, String>((
  ref,
  bookingId,
) {
  return ref.watch(bookingRepositoryProvider).getPayment(bookingId);
});

/// Receipt for a booking (null until the payment is captured).
final bookingReceiptProvider = FutureProvider.family<Receipt?, String>((
  ref,
  bookingId,
) {
  return ref.watch(bookingRepositoryProvider).getReceipt(bookingId);
});
