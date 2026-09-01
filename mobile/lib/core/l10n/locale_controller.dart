import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the chosen app language across launches.
class LocaleStorage {
  static const _key = 'app_locale';

  final FlutterSecureStorage _storage;
  LocaleStorage(this._storage);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> write(String? languageCode) async {
    if (languageCode == null) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: languageCode);
    }
  }
}

final localeStorageProvider = Provider<LocaleStorage>((ref) {
  return LocaleStorage(const FlutterSecureStorage());
});

/// Holds the app's selected [Locale]. `null` means "follow the device", which
/// resolves to the first supported locale. The choice is loaded from storage on
/// start and saved whenever it changes.
class LocaleController extends Notifier<Locale?> {
  late final LocaleStorage _storage;

  @override
  Locale? build() {
    _storage = ref.watch(localeStorageProvider);
    _load();
    return null;
  }

  Future<void> _load() async {
    final code = await _storage.read();
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _storage.write(locale?.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
