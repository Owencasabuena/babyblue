/// A single educational lesson available in the app.
///
/// Each lesson is tagged with the mood scores it is most relevant to,
/// allowing the home screen to display adaptive suggestions based on
/// the user's current emotional state.
class Lesson {
  /// Unique identifier.
  final String id;

  /// Short lesson title.
  final String title;

  /// One-line description shown on the card.
  final String subtitle;

  /// Emoji glyph used as the card icon.
  final String emoji;

  /// Estimated duration in minutes.
  final int durationMinutes;

  /// Which mood scores (1–5) this lesson is relevant to.
  /// A lesson may appear for multiple mood levels.
  final List<int> moodScores;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.durationMinutes,
    required this.moodScores,
  });
}
