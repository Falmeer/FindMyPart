import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/share_card.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/salvaged_vehicles/presentation/screens/vehicles_screen.dart';
import '../../features/salvaged_vehicles/presentation/screens/vehicle_detail_screen.dart';
import '../../features/salvaged_vehicles/presentation/screens/add_vehicle_screen.dart';
import '../../features/spare_parts/presentation/screens/spare_parts_screen.dart';
import '../../features/spare_parts/presentation/screens/spare_part_detail_screen.dart';
import '../../features/spare_parts/presentation/screens/add_spare_part_screen.dart';
import '../../features/garages/presentation/screens/garages_screen.dart';
import '../../features/garages/presentation/screens/garage_detail_screen.dart';
import '../../features/garages/presentation/screens/post_issue_screen.dart';
import '../../features/scrapyards/presentation/screens/scrapyard_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/issues/presentation/screens/my_issues_screen.dart';
import '../../features/issues/presentation/screens/open_issues_screen.dart';
import '../../features/issues/presentation/screens/issue_detail_screen.dart';
import '../../features/issues/presentation/screens/issues_feed_screen.dart';
import '../../features/ai_detection/presentation/screens/warning_light_screen.dart';
import '../../features/ai_detection/presentation/screens/ai_chatbot_screen.dart';
import '../../features/phone_verification/presentation/screens/phone_verification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;
      final onSplash = location == '/splash';

      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isAuthRoute = location.startsWith('/auth');

      if (onSplash) return isLoggedIn ? '/' : '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';

      // Phone verification gate — customers after register, business accounts on first login
      final onPhoneVerify = location == '/phone-verify';
      if (isLoggedIn && authState.value?.phoneVerified == false && !onPhoneVerify) {
        return '/phone-verify';
      }
      if (isLoggedIn && authState.value?.phoneVerified == true && onPhoneVerify) {
        return '/';
      }

      // Must-change-password gate — only after phone is verified (business accounts)
      final onChangePass = location == '/profile/change-password';
      if (isLoggedIn &&
          authState.value?.phoneVerified == true &&
          authState.value?.mustChangePassword == true &&
          !onChangePass) {
        return '/profile/change-password';
      }

      // Routes that require authentication
      const authRequired = [
        '/vehicles/add',
        '/parts/add',
        '/garages/post-issue',
        '/favorites',
        '/conversations',
        '/profile',
        '/my-issues',
        '/open-issues',
        '/notifications',
      ];

      if (!isLoggedIn) {
        final needsAuth = authRequired.any((r) => location == r || location.startsWith('$r/'));
        if (needsAuth) return '/auth/login';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(
            path: '/vehicles',
            builder: (c, s) => VehiclesScreen(
              initialSearch: s.uri.queryParameters['q'],
            ),
          ),
          GoRoute(path: '/parts', builder: (c, s) => const SparePartsScreen()),
          GoRoute(path: '/garages', builder: (c, s) => const GaragesScreen()),
          GoRoute(path: '/issues', builder: (c, s) => const IssuesFeedScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        path: '/vehicles/add',
        builder: (c, s) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/vehicles/:id',
        builder: (c, s) => VehicleDetailScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/parts/add',
        builder: (c, s) => const AddSparePartScreen(),
      ),
      GoRoute(
        path: '/parts/:id',
        builder: (c, s) => SparePartDetailScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/garages/post-issue',
        builder: (c, s) => const PostIssueScreen(),
      ),
      GoRoute(
        path: '/garages/:id',
        builder: (c, s) => GarageDetailScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/scrapyards/:id',
        builder: (c, s) => ScrapyardDetailScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (c, s) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (c, s) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (c, s) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (c, s) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/conversations/:id',
        builder: (c, s) => ChatScreen(
          conversationId: int.parse(s.pathParameters['id']!),
          participantName: s.uri.queryParameters['name'] ?? 'Chat',
          pendingCard: s.extra as ShareCard?,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/my-issues',
        builder: (c, s) => const MyIssuesScreen(),
      ),
      GoRoute(
        path: '/open-issues',
        builder: (c, s) => const OpenIssuesScreen(),
      ),
      GoRoute(
        path: '/issues/:id',
        builder: (c, s) => IssueDetailScreen(issueId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/phone-verify',
        builder: (c, s) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/ai-scan',
        builder: (c, s) => const WarningLightScreen(),
      ),
      GoRoute(
        path: '/ai-chatbot',
        builder: (c, s) => const AiChatbotScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (c, s) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (c, s) => const ForgotPasswordScreen(),
      ),
    ],
  );

  ref.listen(authStateProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
