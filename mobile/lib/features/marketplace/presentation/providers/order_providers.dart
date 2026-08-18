import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_models.dart';
import '../../data/order_repository.dart';

/// The signed-in user's tool orders, newest first (P10.4).
final myOrdersProvider = FutureProvider<List<ToolOrder>>((ref) {
  return ref.watch(orderRepositoryProvider).list();
});
