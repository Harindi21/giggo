import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/discovery/presentation/screens/home_screen.dart';
import '../../features/discovery/presentation/screens/provider_detail_screen.dart';
import '../../features/discovery/presentation/screens/provider_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/coming_soon_screen.dart';
import '../widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/login',
  routes: [
    // ---- Auth (outside the shell) ----
    GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/role', name: 'role', builder: (c, s) => const RoleSelectionScreen()),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (c, s) => RegisterScreen(role: s.uri.queryParameters['role'] ?? 'CUSTOMER'),
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (c, s) => VerifyEmailScreen(email: s.uri.queryParameters['email'] ?? ''),
    ),

    // ---- Main app (bottom-nav shell) ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
      branches: [
        // Home / discovery
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (c, s) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'category/:categoryId',
                  name: 'category',
                  builder: (c, s) => ProviderListScreen(
                    categoryId: s.pathParameters['categoryId'],
                    categoryName: s.uri.queryParameters['name'],
                  ),
                ),
                GoRoute(
                  path: 'search',
                  name: 'search',
                  builder: (c, s) => ProviderListScreen(initialQuery: s.uri.queryParameters['q']),
                ),
                GoRoute(
                  path: 'provider/:providerId',
                  name: 'provider',
                  builder: (c, s) => ProviderDetailScreen(providerId: s.pathParameters['providerId']!),
                ),
              ],
            ),
          ],
        ),
        // Shop (Tool Marketplace — P10)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              name: 'shop',
              builder: (c, s) => const ComingSoonScreen(
                title: 'Tool Marketplace',
                icon: Icons.shopping_bag_outlined,
                message: 'Curated tools for professionals — coming soon.',
              ),
            ),
          ],
        ),
        // Tasks (Bookings / Job lifecycle — P4)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (c, s) => const ComingSoonScreen(
                title: 'My Tasks',
                icon: Icons.list_alt_rounded,
                message: 'Your bookings and job tracking arrive in the next update.',
              ),
            ),
          ],
        ),
        // Profile
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', name: 'profile', builder: (c, s) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);
