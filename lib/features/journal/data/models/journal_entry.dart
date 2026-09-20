import 'dart:convert';

import 'package:babyblue/features/journal/data/models/journal_mood.dart';

/// A single journal entry recorded by the user.
///
/// Stored locally in SQLite for full offline capability.
/// Gratitude items are serialised as a JSON-encoded list of strings.
class JournalEntry {
  /// Unique identifier (UUID v4).
  final String id;

  /// When the entry was created.
  final DateTime createdAt;

  /// The mood the user selected when journaling.
  final JournalMood mood;

  /// The micro-prompt shown to the user (may be empty if free-form).
  final String promptUsed;

  /// The journal content (1–3 sentences, typed or voice-transcribed).
  final String content;

  /// Optional gratitude items (up to 3 short phrases).
  final List<String> gratitude;

  /// How the entry was captured: `'text'` or `'voice'`.
  final String inputType;

  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.mood,
    this.promptUsed = '',
    required this.content,
    this.gratitude = const [],
    this.inputType = 'text',
  });

  // ── SQLite Serialisation ────────────────────────────────────────

  /// Converts this entry to a map suitable for `sqflite` insert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'mood_label': mood.label,
      'mood_icon': mood.icon,
      'prompt_used': promptUsed,
      'content': content,
      'gratitude': json.encode(gratitude),
      'input_type': inputType,
    };
  }

  /// Reconstructs a [JournalEntry] from a database row.
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      mood: JournalMood(
        label: map['mood_label'] as String,
        icon: map['mood_icon'] as String,
      ),
      promptUsed: (map['prompt_used'] as String?) ?? '',
      content: map['content'] as String,
      gratitude: _parseGratitude(map['gratitude'] as String?),
      inputType: (map['input_type'] as String?) ?? 'text',
    );
  }

  /// Decodes a JSON string into a list of gratitude strings.
  static List<String> _parseGratitude(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) return decoded.cast<String>();
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  String toString() =>
      'JournalEntry(id: $id, mood: ${mood.icon}, time: $createdAt)';
}
