/// A mood tag attached to a journal entry.
///
/// Represents the user's emotional state at the time of journaling.
/// Each mood has a human-readable [label] and an [icon] emoji.
class JournalMood {
  final String label;
  final String icon;

  const JournalMood({required this.label, required this.icon});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalMood &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          icon == other.icon;

  @override
  int get hashCode => label.hashCode ^ icon.hashCode;

  @override
  String toString() => '$icon $label';
}

/// Predefined moods tailored to the postpartum context.
///
/// Designed for quick one-tap selection — each label validates
/// the mother's experience without clinical jargon.
class JournalMoods {
  JournalMoods._();

  static const calm = JournalMood(label: 'Calm', icon: '🌿');
  static const frazzled = JournalMood(label: 'Frazzled', icon: '⚡');
  static const runningOnEmpty =
      JournalMood(label: 'Running on Empty', icon: '😴');
  static const tearful = JournalMood(label: 'Tearful', icon: '💧');
  static const exhaustedButPeaceful =
      JournalMood(label: 'Exhausted but Peaceful', icon: '🌙');
  static const hopeful = JournalMood(label: 'Hopeful', icon: '🌸');
  static const grateful = JournalMood(label: 'Grateful', icon: '💜');
  static const overwhelmed = JournalMood(label: 'Overwhelmed', icon: '🔥');

  /// All available moods in display order.
  static const List<JournalMood> all = [
    calm,
    frazzled,
    runningOnEmpty,
    tearful,
    exhaustedButPeaceful,
    hopeful,
    grateful,
    overwhelmed,
  ];

  /// Look up a mood by its label, or fall back to [calm].
  static JournalMood fromLabel(String label) {
    return all.firstWhere(
      (m) => m.label == label,
      orElse: () => calm,
    );
  }
}
