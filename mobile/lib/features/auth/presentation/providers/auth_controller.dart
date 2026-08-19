import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/models/login_request.dart';
import '../../data/models/user_model.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../notifications/data/push_registration.dart';

class AuthState {
  final bool loading;
  final UserModel? user;
  final String? error;

  const AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, UserModel? user, String? error}) =>
      AuthState(
        loading: loading ?? this.loading,
        user: user ?? this.user,
        error: error,
      );
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repo;
  late final TokenStorage _tokens;

  @override
  AuthState build() {
    _repo = ref.watch(authRepositoryProvider);
    _tokens = ref.watch(tokenStorageProvider);
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await _repo.login(
        LoginRequest(email: email.trim(), password: password),
      );
      await _tokens.saveTokens(result.accessToken, result.refreshToken);
      // Register this device for push once authenticated (fail-soft, off the
      // critical path so it never blocks or fails sign-in).
      unawaited(ref.read(pushRegistrationProvider).registerCurrentDevice());
      state = AuthState(user: result.user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _tokens.clear();
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
