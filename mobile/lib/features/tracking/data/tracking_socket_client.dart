import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'models/provider_location.dart';

enum SocketStatus { disconnected, connecting, connected }

/// STOMP-over-WebSocket client for live job tracking (the mobile side of P5.1).
///
/// - Authenticates the CONNECT frame with the JWT (same token as the REST API).
/// - Exposes a [ProviderLocation] stream per job and lets a provider push updates.
/// - Reconnects automatically with exponential backoff and re-subscribes every
///   active job topic once the connection is restored.
class TrackingSocketClient {
  TrackingSocketClient({required this.wsUrl, required this.getToken});

  /// e.g. ws://10.0.2.2:8080/ws
  final String wsUrl;
  final Future<String?> Function() getToken;

  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 30);

  StompClient? _client;
  int _attempt = 0;
  bool _stopped = false;
  bool _connecting = false;
  Timer? _reconnectTimer;

  final StreamController<SocketStatus> _statusController =
      StreamController<SocketStatus>.broadcast();
  final Map<String, StreamController<ProviderLocation>> _jobStreams = {};
  final Map<String, StompUnsubscribe> _jobUnsub = {};

  Stream<SocketStatus> get status => _statusController.stream;
  bool get isConnected => _client?.connected ?? false;

  /// Idempotent — safe to call whenever a screen needs tracking.
  Future<void> connect() async {
    _stopped = false;
    if (_connecting || isConnected) return;
    await _open();
  }

  Future<void> _open() async {
    _connecting = true;
    _emit(SocketStatus.connecting);
    final token = await getToken();
    final headers = {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        reconnectDelay: Duration.zero, // we manage backoff ourselves
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onConnect: _onConnect,
        onWebSocketError: (_) => _onDrop(),
        onDisconnect: (_) => _onDrop(),
        onStompError: (_) => _onDrop(),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _connecting = false;
    _attempt = 0;
    _emit(SocketStatus.connected);
    _jobUnsub.clear();
    for (final jobId in _jobStreams.keys) {
      _subscribeJob(jobId);
    }
  }

  void _onDrop() {
    _connecting = false;
    _emit(SocketStatus.disconnected);
    if (_stopped) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final ms = math.min(
      _baseDelay.inMilliseconds * math.pow(2, _attempt).toInt(),
      _maxDelay.inMilliseconds,
    );
    _attempt++;
    _reconnectTimer = Timer(Duration(milliseconds: ms), _open);
  }

  /// Live positions for [jobId]. Subscribing lazily (re)connects the socket.
  Stream<ProviderLocation> locationStream(String jobId) {
    final controller = _jobStreams.putIfAbsent(
      jobId,
      () => StreamController<ProviderLocation>.broadcast(),
    );
    connect();
    _subscribeJob(jobId);
    return controller.stream;
  }

  void _subscribeJob(String jobId) {
    if (!isConnected || _jobUnsub.containsKey(jobId)) return;
    _jobUnsub[jobId] = _client!.subscribe(
      destination: '/topic/jobs/$jobId/location',
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final loc = ProviderLocation.fromJson(jsonDecode(body) as Map<String, dynamic>);
          _jobStreams[jobId]?.add(loc);
        } catch (_) {
          // Ignore malformed frames rather than crash the stream.
        }
      },
    );
  }

  /// Provider side: push a GPS ping for [jobId].
  void sendLocation(String jobId, Map<String, dynamic> update) {
    if (!isConnected) return;
    _client!.send(
      destination: '/app/jobs/$jobId/location',
      body: jsonEncode(update),
      headers: {'content-type': 'application/json'},
    );
  }

  void stopTracking(String jobId) {
    _jobUnsub.remove(jobId)?.call();
    _jobStreams.remove(jobId)?.close();
  }

  void disconnect() {
    _stopped = true;
    _reconnectTimer?.cancel();
    for (final unsub in _jobUnsub.values) {
      unsub();
    }
    _jobUnsub.clear();
    _client?.deactivate();
    _emit(SocketStatus.disconnected);
  }

  void dispose() {
    disconnect();
    for (final c in _jobStreams.values) {
      c.close();
    }
    _jobStreams.clear();
    _statusController.close();
  }

  void _emit(SocketStatus s) {
    if (!_statusController.isClosed) _statusController.add(s);
  }
}
