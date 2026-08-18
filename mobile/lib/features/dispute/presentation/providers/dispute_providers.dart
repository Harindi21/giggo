import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dispute_repository.dart';
import '../../data/models/dispute_models.dart';

/// The dispute on a booking (null if none yet).
final bookingDisputeProvider = FutureProvider.family<Dispute?, String>((
  ref,
  bookingId,
) {
  return ref.watch(disputeRepositoryProvider).getForBooking(bookingId);
});

/// Open disputes awaiting admin resolution (P4.7).
final openDisputesProvider = FutureProvider<List<Dispute>>((ref) {
  return ref.watch(disputeRepositoryProvider).listByStatus('OPEN');
});
