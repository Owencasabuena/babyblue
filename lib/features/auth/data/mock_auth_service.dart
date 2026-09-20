import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [MockAuthService] singleton via Riverpod.
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

/// Simulates a remote authentication server.
///
/// In production this would be replaced with a real HTTP/Firebase auth
/// service. The mock always succeeds after a realistic delay.
class MockAuthService {
  /// Simulates signing in with email + password.
  ///
  /// Returns a mock JWT-style token string on success.
  /// Always succeeds — replace with real validation later.
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network latency.
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate a deterministic mock token from the email.
    final tokenPayload = email.hashCode.toRadixString(16);
    return 'mock_jwt_$tokenPayload';
  }

  /// Simulates new-user registration.
  ///
  /// For this MVP stage, registration and sign-in behave identically.
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Same behaviour as sign-in for now.
    return signIn(email: email, password: password);
  }
}
