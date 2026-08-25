import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/presentation/screens/verify_email_screen.dart';

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo() : super(Dio());
  final calls = <String>[];

  @override
  Future<void> verifyEmail(String email, String code) async {
    calls.add('verify:$email:$code');
  }

  @override
  Future<void> resendCode(String email) async {
    calls.add('resend:$email');
  }
}

GoRouter _router() => GoRouter(
  initialLocation: '/verify-email',
  routes: [
    GoRoute(
      path: '/verify-email',
      builder: (c, s) => const VerifyEmailScreen(email: 'ann@example.com'),
    ),
    GoRoute(
      path: '/login',
      builder: (c, s) => const Scaffold(body: Text('LOGIN')),
    ),
  ],
);

void main() {
  testWidgets('shows the email, a disabled Verify and the resend cooldown', (
    tester,
  ) async {
    final fake = _FakeAuthRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(routerConfig: _router()),
      ),
    );
    await tester.pump();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('ann@example.com'), findsOneWidget);
    expect(find.textContaining('Resend in'), findsOneWidget);

    final btn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Verify'),
    );
    expect(btn.onPressed, isNull); // no code entered yet

    // Dispose to cancel the cooldown timer before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('entering all 6 digits verifies and navigates to login', (
    tester,
  ) async {
    final fake = _FakeAuthRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(routerConfig: _router()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump(); // onChanged -> _verify() future
    await tester.pump(const Duration(milliseconds: 50)); // navigation

    expect(fake.calls, contains('verify:ann@example.com:123456'));
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
