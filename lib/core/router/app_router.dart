import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:babyblue/features/auth/domain/auth_state.dart';
import 'package:babyblue/features/auth/presentation/providers/auth_provider.dart';
import 'package:babyblue/features/auth/presentation/screens/login_screen.dart';
import 'package:babyblue/features/auth/presentation/screens/splash_screen.dart';
import 'package:babyblue/features/journal/presentation/screens/journal_screen.dart';
import 'package:babyblue/features/lessons/presentation/screens/lessons_screen.dart';
import 'package:babyblue/features/lessons/presentation/screens/lesson_detail_screen.dart';
import 'package:babyblue/features/mood_tracker/presentation/screens/mood_tracker_screen.dart';
import 'package:babyblue/shared/widgets/main_shell.dart';

// ── Router Notifier ──────────────────────────────────────────────

/// Bridges Riverpod's [authProvider] to GoRouter's [Listenable]-based
/// refresh mechanism. Calls [notifyListeners] whenever auth state changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthStatus>>(authProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

// ── GoRouter Provider ────────────────────────────────────────────

/// The application's declarative router.
///
/// Redirect rules:
/// - While auth state is loading → stay on `/splash`.
/// - If unauthenticated → go to `/login`.
/// - If authenticated and on `/splash` or `/login` → go to `/home`.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // ── Auth redirect guard ──────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Still loading → keep user on splash.
      if (authState.isLoading || !authState.hasValue) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthenticated = authState.value == AuthStatus.authenticated;

      // Not authenticated → send to login (unless already there).
      if (!isAuthenticated) {
        return location == '/login' ? null : '/login';
      }

      // Authenticated but on splash or login → send to dashboard.
      if (location == '/splash' || location == '/login') {
        return '/home';
      }

      // No redirect needed.
      return null;
    },

    // ── Routes ───────────────────────────────────────────────
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),

      // Main dashboard with bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const MoodTrackerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lessons',
                builder: (_, _) => const LessonsScreen(),
                routes: [
                  GoRoute(
                    path: ':lessonId',
                    builder: (_, state) => LessonDetailScreen(
                      lessonId: state.pathParameters['lessonId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (_, _) => const JournalScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
