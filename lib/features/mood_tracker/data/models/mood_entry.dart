/// A single mood-log entry recorded by the user.
///
/// Stored locally in SQLite for full offline capability.
/// [moodScore] ranges from 1 (Very Low) to 5 (Great).
class MoodEntry {
  /// Unique identifier (UUID v4).
  final String id;

  /// When the mood was logged.
  final DateTime timestamp;

  /// Mood rating on a 1–5 scale.
  final int moodScore;

  /// Optional free-text note.
  final String note;

  /// Optional tags for categorisation (e.g., "sleep", "exercise").
  final List<String> tags;

  const MoodEntry({
    required this.id,
    required this.timestamp,
    required this.moodScore,
    this.note = '',
    this.tags = const [],
  });

  // ── SQLite Serialisation ────────────────────────────────────────

  /// Converts this entry to a map suitable for `sqflite` insert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mood_score': moodScore,
      'note': note,
      'tags': tags.join(','),
    };
  }

  /// Reconstructs a [MoodEntry] from a database row.
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      moodScore: map['mood_score'] as int,
      note: (map['note'] as String?) ?? '',
      tags: _parseTags(map['tags'] as String?),
    );
  }

  /// Splits a comma-separated tag string, filtering empty values.
  static List<String> _parseTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  @override
  String toString() =>
      'MoodEntry(id: $id, score: $moodScore, time: $timestamp)';
}
