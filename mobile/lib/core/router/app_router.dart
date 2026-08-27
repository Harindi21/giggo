import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_code_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/set_new_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/admin/presentation/screens/audit_log_screen.dart';
import '../../features/admin/presentation/screens/disputes_queue_screen.dart';
import '../../features/admin/presentation/screens/reviews_queue_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_form_screen.dart';
import '../../features/booking/presentation/screens/payment_screen.dart';
import '../../features/booking/presentation/screens/receipt_screen.dart';
import '../../features/booking/presentation/screens/tasks_tab_screen.dart';
import '../../features/discovery/presentation/screens/home_screen.dart';
import '../../features/discovery/presentation/screens/provider_detail_screen.dart';
import '../../features/discovery/presentation/screens/provider_list_screen.dart';
import '../../features/knowledge/presentation/screens/article_detail_screen.dart';
import '../../features/knowledge/presentation/screens/articles_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/marketplace/presentation/screens/checkout_screen.dart';
import '../../features/marketplace/presentation/screens/orders_screen.dart';
import '../../features/marketplace/presentation/screens/shop_screen.dart';
import '../../features/marketplace/presentation/screens/tool_detail_screen.dart';
import '../../features/marketplace/presentation/screens/wishlist_screen.dart';
import '../../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/provider/presentation/screens/availability_screen.dart';
import '../../features/provider/presentation/screens/demand_screen.dart';
import '../../features/provider/presentation/screens/earnings_screen.dart';
import '../../features/provider/presentation/screens/provider_profile_screen.dart';
import '../../features/reviews/presentation/screens/rate_review_screen.dart';
import '../../features/tracking/presentation/screens/tracking_screen.dart';
import '../widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  routes: [
    // ---- Auth (outside the shell) ----
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (c, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (c, s) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (c, s) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role',
      name: 'role',
      builder: (c, s) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (c, s) =>
          RegisterScreen(role: s.uri.queryParameters['role'] ?? 'CUSTOMER'),
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (c, s) =>
          VerifyEmailScreen(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (c, s) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-code',
      name: 'reset-code',
      builder: (c, s) =>
          ResetCodeScreen(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/set-new-password',
      name: 'set-new-password',
      builder: (c, s) =>
          SetNewPasswordScreen(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/track/:jobId',
      name: 'track',
      builder: (c, s) => TrackingScreen(
        jobId: s.pathParameters['jobId']!,
        destLat: double.tryParse(s.uri.queryParameters['destLat'] ?? ''),
        destLng: double.tryParse(s.uri.queryParameters['destLng'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/review/:bookingId',
      name: 'review',
      builder: (c, s) =>
          RateReviewScreen(bookingId: s.pathParameters['bookingId']!),
    ),
    GoRoute(
      path: '/book/:providerId',
      name: 'book',
      builder: (c, s) => BookingFormScreen(
        providerId: s.pathParameters['providerId']!,
        skillId: s.uri.queryParameters['skillId'],
      ),
    ),
    GoRoute(
      path: '/booking/:bookingId',
      name: 'booking',
      builder: (c, s) =>
          BookingDetailScreen(bookingId: s.pathParameters['bookingId']!),
    ),
    GoRoute(
      path: '/payment/:bookingId',
      name: 'payment',
      builder: (c, s) =>
          PaymentScreen(bookingId: s.pathParameters['bookingId']!),
    ),
    GoRoute(
      path: '/receipt/:bookingId',
      name: 'receipt',
      builder: (c, s) =>
          ReceiptScreen(bookingId: s.pathParameters['bookingId']!),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (c, s) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notifications/preferences',
      name: 'notification-preferences',
      builder: (c, s) => const NotificationPreferencesScreen(),
    ),
    GoRoute(path: '/kyc', name: 'kyc', builder: (c, s) => const KycScreen()),
    GoRoute(
      path: '/provider-profile',
      name: 'provider-profile',
      builder: (c, s) => const ProviderProfileScreen(),
    ),
    GoRoute(
      path: '/earnings',
      name: 'earnings',
      builder: (c, s) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/availability',
      name: 'availability',
      builder: (c, s) => const AvailabilityScreen(),
    ),
    GoRoute(
      path: '/demand',
      name: 'demand',
      builder: (c, s) => const DemandScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (c, s) => const AdminScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      name: 'admin-dashboard',
      builder: (c, s) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/audit-log',
      name: 'admin-audit-log',
      builder: (c, s) => const AuditLogScreen(),
    ),
    GoRoute(
      path: '/admin/disputes',
      name: 'admin-disputes',
      builder: (c, s) => const DisputesQueueScreen(),
    ),
    GoRoute(
      path: '/admin/reviews',
      name: 'admin-reviews',
      builder: (c, s) => const ReviewsQueueScreen(),
    ),
    GoRoute(
      path: '/articles',
      name: 'articles',
      builder: (c, s) => const ArticlesScreen(),
    ),
    GoRoute(
      path: '/articles/:slug',
      name: 'article',
      builder: (c, s) => ArticleDetailScreen(slug: s.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/tools/:slug',
      name: 'tool',
      builder: (c, s) => ToolDetailScreen(slug: s.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/checkout/:slug',
      name: 'checkout',
      builder: (c, s) => CheckoutScreen(slug: s.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (c, s) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      name: 'wishlist',
      builder: (c, s) => const WishlistScreen(),
    ),

    // ---- Main app (bottom-nav shell) ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
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
                  builder: (c, s) => ProviderListScreen(
                    initialQuery: s.uri.queryParameters['q'],
                  ),
                ),
                GoRoute(
                  path: 'provider/:providerId',
                  name: 'provider',
                  builder: (c, s) => ProviderDetailScreen(
                    providerId: s.pathParameters['providerId']!,
                  ),
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
              builder: (c, s) => const ShopScreen(),
            ),
          ],
        ),
        // Tasks (Bookings / Job lifecycle — P4)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (c, s) => const TasksTabScreen(),
            ),
          ],
        ),
        // Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (c, s) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
