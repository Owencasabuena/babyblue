import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/features/auth/data/auth_local_source.dart';
import 'package:babyblue/features/auth/data/mock_auth_service.dart';
import 'package:babyblue/features/auth/domain/auth_state.dart';

/// Global auth state provider.
///
/// The [GoRouter] redirect guard watches this to decide whether to
/// show the login screen or the main dashboard.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);

/// Manages authentication state throughout the app lifecycle.
///
/// On initialisation ([build]), reads secure storage to determine
/// whether a valid session already exists. Exposes [login] and
/// [logout] actions that update state reactively.
class AuthNotifier extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    // Small delay so the splash screen has time to render its animation.
    await Future.delayed(const Duration(milliseconds: 1500));

    final localSource = ref.read(authLocalSourceProvider);
    final loggedIn = await localSource.isLoggedIn();
    return loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Perform a sign-in with the mock auth service.
  ///
  /// On success, persists the token + display name in secure storage
  /// and updates state to [AuthStatus.authenticated].
  Future<void> login({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final mockAuth = ref.read(mockAuthServiceProvider);
      final token = await mockAuth.signIn(email: email, password: password);

      final localSource = ref.read(authLocalSourceProvider);
      await localSource.saveToken(token);

      // Derive a display name from the email if none provided.
      final name = displayName ?? email.split('@').first;
      await localSource.saveUserName(name);

      return AuthStatus.authenticated;
    });
  }

  /// Clear the session and return to unauthenticated state.
  Future<void> logout() async {
    final localSource = ref.read(authLocalSourceProvider);
    await localSource.clearAll();
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}

/// Convenience provider that exposes the stored display name.
final userNameProvider = FutureProvider<String>((ref) async {
  final localSource = ref.read(authLocalSourceProvider);
  return await localSource.getUserName() ?? 'there';
});
