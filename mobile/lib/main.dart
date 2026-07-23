import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';

Future<void> main() async {
  await SentryFlutter.init((options) {
    options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    options.environment = const String.fromEnvironment(
      'SENTRY_ENV',
      defaultValue: 'local',
    );
    options.tracesSampleRate = 0.1;
  }, appRunner: () => runApp(const ProviderScope(child: GiggoApp())));
}
