/// Centralised constants for the Baby Blues application.
///
/// All magic strings, keys, and lookup tables live here to avoid
/// duplication and make future changes trivial.
library;

class AppConstants {
  AppConstants._(); // Prevent instantiation.

  // ── App Identity ────────────────────────────────────────────────
  static const String appName = 'Baby Blues';
  static const String appTagline = 'Your gentle companion';

  // ── Secure-Storage Keys ─────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userNameKey = 'user_display_name';

  // ── Mood Scale ──────────────────────────────────────────────────
  /// Emoji glyphs mapped to mood scores 1 → 5.
  static const List<String> moodEmojis = ['😞', '😔', '😐', '🙂', '😊'];

  /// Human-readable labels for each score.
  static const List<String> moodLabels = [
    'Very Low',
    'Low',
    'Okay',
    'Good',
    'Great',
  ];

  // ── SQLite ──────────────────────────────────────────────────────
  static const String dbName = 'babyblue.db';
  static const String moodTable = 'mood_entries';
  static const int dbVersion = 1;
}
