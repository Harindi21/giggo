import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/provider_location.dart';
import '../../data/tracking_socket_client.dart';

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
