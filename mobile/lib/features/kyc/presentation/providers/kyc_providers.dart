import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/kyc_repository.dart';
import '../../data/models/kyc_models.dart';

/// The signed-in provider's current KYC submission (null if none yet).
final myKycProvider = FutureProvider<KycSubmission?>((ref) {
  return ref.watch(kycRepositoryProvider).getMine();
});
