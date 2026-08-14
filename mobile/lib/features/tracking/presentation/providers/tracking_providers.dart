import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/eta_info.dart';
import '../../data/models/provider_location.dart';
import '../../data/tracking_repository.dart';
import '../../data/tracking_socket_client.dart';

/// Destination for an ETA query (the customer's location the provider is heading to).
typedef EtaQuery = ({String jobId, double destLat, double destLng});

/// Single shared tracking socket for the app.
final trackingSocketClientProvider = Provider<TrackingSocketClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  // http://host:8080 -> ws://host:8080/ws  (https -> wss)
  final wsUrl = '${ApiConfig.baseUrl.replaceFirst('http', 'ws')}/ws';
  final client = TrackingSocketClient(
    wsUrl: wsUrl,
    getToken: tokenStorage.readAccessToken,
  );
  ref.onDispose(client.dispose);
  return client;
});

/// Connection status (connecting / connected / disconnected) for status banners.
final socketStatusProvider = StreamProvider<SocketStatus>((ref) {
  return ref.watch(trackingSocketClientProvider).status;
});

/// Live provider position for a job; subscribing (re)connects the socket.
final jobLocationProvider = StreamProvider.family<ProviderLocation, String>((
  ref,
  jobId,
) {
  final client = ref.watch(trackingSocketClientProvider);
  ref.onDispose(() => client.stopTracking(jobId));
  return client.locationStream(jobId);
});

/// ETA to the destination (P5.4). Refetch by invalidating when a new position arrives.
final etaProvider = FutureProvider.family<EtaInfo, EtaQuery>((ref, q) {
  return ref
      .watch(trackingRepositoryProvider)
      .getEta(q.jobId, q.destLat, q.destLng);
});
