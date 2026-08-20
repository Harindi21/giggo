import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../booking/data/models/payment_models.dart';
import '../../data/earnings_repository.dart';
import '../../data/models/earnings.dart';

final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) {
  return ref.watch(earningsRepositoryProvider).getSummary();
});

final myPayoutsProvider = FutureProvider<List<Payout>>((ref) {
  return ref.watch(earningsRepositoryProvider).getMyPayouts();
});

final earningsHistoryProvider = FutureProvider<List<Payment>>((ref) {
  return ref.watch(earningsRepositoryProvider).getHistory();
});
