import 'package:babyblue/features/lessons/data/models/lesson.dart';

/// Static catalogue of educational lessons for the Baby Blues app.
///
/// Each lesson is tagged with mood scores so the home screen can
/// dynamically suggest content based on the user's current state.
/// Lessons are intentionally duplicated across mood levels when
/// they serve multiple emotional contexts.
class LessonCatalogue {
  LessonCatalogue._();

  static const List<Lesson> all = [
    // ── Very Low (score 1) ─────────────────────────────────────────
    Lesson(
      id: 'grounding-techniques',
      title: 'Grounding Techniques',
      subtitle: 'Simple exercises to anchor yourself in the present moment',
      emoji: '🌿',
      durationMinutes: 5,
      moodScores: [1, 2],
    ),
    Lesson(
      id: 'reach-out-for-support',
      title: 'Reach Out for Support',
      subtitle: 'How and when to ask for help — you don\'t have to do this alone',
      emoji: '🤝',
      durationMinutes: 4,
      moodScores: [1],
    ),
    Lesson(
      id: 'gentle-self-care',
      title: 'Gentle Self-Care',
      subtitle: 'Tiny acts of kindness you can give yourself right now',
      emoji: '🛁',
      durationMinutes: 3,
      moodScores: [1, 2],
    ),

    // ── Low (score 2) ──────────────────────────────────────────────
    Lesson(
      id: 'understanding-baby-blues',
      title: 'Understanding Baby Blues',
      subtitle: 'What\'s happening in your body and mind after birth',
      emoji: '📖',
      durationMinutes: 6,
      moodScores: [1, 2],
    ),
    Lesson(
      id: 'breathing-exercises',
      title: 'Breathing Exercises',
      subtitle: 'Calm your nervous system with guided breathing patterns',
      emoji: '🌬️',
      durationMinutes: 5,
      moodScores: [1, 2, 3],
    ),
    Lesson(
      id: 'sleep-hygiene',
      title: 'Sleep Hygiene',
      subtitle: 'Tips for better rest when sleep feels impossible',
      emoji: '🌙',
      durationMinutes: 4,
      moodScores: [2],
    ),

    // ── Okay (score 3) ─────────────────────────────────────────────
    Lesson(
      id: 'mindful-moments',
      title: 'Mindful Moments',
      subtitle: 'Short mindfulness practices for busy new parents',
      emoji: '🧘',
      durationMinutes: 5,
      moodScores: [3],
    ),
    Lesson(
      id: 'bonding-activities',
      title: 'Bonding Activities',
      subtitle: 'Simple ways to strengthen your connection with baby',
      emoji: '👶',
      durationMinutes: 7,
      moodScores: [3, 4],
    ),
    Lesson(
      id: 'journaling-prompts',
      title: 'Journaling Prompts',
      subtitle: 'Guided prompts to process your feelings and experiences',
      emoji: '📝',
      durationMinutes: 5,
      moodScores: [2, 3],
    ),

    // ── Good (score 4) ─────────────────────────────────────────────
    Lesson(
      id: 'positive-affirmations',
      title: 'Positive Affirmations',
      subtitle: 'Encouraging words to carry with you through the day',
      emoji: '✨',
      durationMinutes: 3,
      moodScores: [4, 5],
    ),
    Lesson(
      id: 'building-routines',
      title: 'Building Routines',
      subtitle: 'Create gentle daily rhythms that work for your family',
      emoji: '📋',
      durationMinutes: 6,
      moodScores: [3, 4],
    ),
    Lesson(
      id: 'partner-communication',
      title: 'Partner Communication',
      subtitle: 'Tools for open, supportive conversations with your partner',
      emoji: '💬',
      durationMinutes: 5,
      moodScores: [4],
    ),

    // ── Great (score 5) ────────────────────────────────────────────
    Lesson(
      id: 'celebrate-small-wins',
      title: 'Celebrate Small Wins',
      subtitle: 'Recognise and honour the little victories of parenthood',
      emoji: '🎉',
      durationMinutes: 3,
      moodScores: [5],
    ),
    Lesson(
      id: 'future-planning',
      title: 'Future Planning',
      subtitle: 'Set gentle goals and dream about what\'s ahead',
      emoji: '🗺️',
      durationMinutes: 5,
      moodScores: [4, 5],
    ),
    Lesson(
      id: 'gratitude-practice',
      title: 'Gratitude Practice',
      subtitle: 'A guided exercise to notice the good in your day',
      emoji: '🙏',
      durationMinutes: 4,
      moodScores: [5],
    ),
  ];

  /// Returns lessons relevant to the given mood score (1–5).
  static List<Lesson> forMoodScore(int score) {
    return all.where((l) => l.moodScores.contains(score)).toList();
  }

  /// Default lessons shown when no mood is logged (general wellness).
  static List<Lesson> get defaults => forMoodScore(3);
}
