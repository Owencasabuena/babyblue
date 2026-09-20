import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/core/constants.dart';

/// Provides the [AuthLocalSource] singleton via Riverpod.
final authLocalSourceProvider = Provider<AuthLocalSource>((ref) {
  return AuthLocalSource();
});

/// Wraps [FlutterSecureStorage] for encrypted persistence of the
/// authentication token and user display name.
///
/// On Android this uses the Android Keystore; on iOS the Keychain.
class AuthLocalSource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ── Token ───────────────────────────────────────────────────────

  /// Persist the session token after a successful login.
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Retrieve the saved token, or `null` if none exists.
  Future<String?> getToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  /// Delete the token on logout.
  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  /// Quick check: does a session token exist?
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── User Name ───────────────────────────────────────────────────

  /// Save the user's display name alongside the token.
  Future<void> saveUserName(String name) async {
    await _storage.write(key: AppConstants.userNameKey, value: name);
  }

  /// Read the stored display name.
  Future<String?> getUserName() async {
    return _storage.read(key: AppConstants.userNameKey);
  }

  // ── Clear All ───────────────────────────────────────────────────

  /// Wipe all secure-storage keys (full logout).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
