/// Represents the user's authentication status throughout the app.
///
/// The router redirect guard reads this value to decide whether to
/// show the login screen, the splash screen, or the main dashboard.
enum AuthStatus {
  /// Initial state — session check has not completed yet.
  unknown,

  /// User has a valid persistent session token.
  authenticated,

  /// No session token found; user needs to sign in.
  unauthenticated,
}
