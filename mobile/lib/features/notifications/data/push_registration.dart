import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'notification_repository.dart';

/// The backend's DevicePlatform tag for the current runtime.
String platformTag() {
  if (kIsWeb) return 'WEB';
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'IOS';
    case TargetPlatform.android:
      return 'ANDROID';
    default:
      return 'ANDROID';
  }
}

/// A stable, install-scoped push token. Without a real FCM/APNs SDK we mint a
/// random opaque token (prefixed so it is obviously a stub); the registration
/// flow and the backend push seam are otherwise exercised end to end.
String generatePushToken() {
  final rnd = Random.secure();
  final bytes = List<int>.generate(24, (_) => rnd.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return 'stub-$hex';
}

/// Registers this device's push token with the backend after sign-in (P8.1).
/// A single token is persisted per install and reused across sessions.
class PushRegistration {
  static const _tokenKey = 'device_push_token';

  final NotificationRepository _repo;
  final FlutterSecureStorage _storage;

  PushRegistration(this._repo, this._storage);

  /// Best-effort: never throws, so a push-registration hiccup can't block login.
  Future<void> registerCurrentDevice() async {
    try {
      final token = await _getOrCreateToken();
      await _repo.registerDeviceToken(token, platformTag());
    } catch (_) {
      // fail-soft
    }
  }

  Future<String> _getOrCreateToken() async {
    final existing = await _storage.read(key: _tokenKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final token = generatePushToken();
    await _storage.write(key: _tokenKey, value: token);
    return token;
  }
}

final pushRegistrationProvider = Provider<PushRegistration>((ref) {
  return PushRegistration(
    ref.watch(notificationRepositoryProvider),
    const FlutterSecureStorage(),
  );
});
