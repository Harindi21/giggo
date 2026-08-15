import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/data/profile_repository.dart';
import '../../../tracking/presentation/screens/track_launcher_screen.dart';
import 'provider_jobs_screen.dart';

/// The Tasks tab is role-aware: providers manage their jobs (P4.10) while
/// customers get the interim tracking launcher (replaced by the bookings
/// dashboard in P4.11). Falls back to the customer view if the role is unknown.
class TasksTabScreen extends ConsumerWidget {
  const TasksTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(profileProvider);
    return meAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const TrackLauncherScreen(),
      data: (me) => me.role == 'PROVIDER'
          ? const ProviderJobsScreen()
          : const TrackLauncherScreen(),
    );
  }
}
