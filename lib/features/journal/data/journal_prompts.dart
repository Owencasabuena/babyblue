import 'package:babyblue/features/journal/data/models/journal_mood.dart';

/// Static catalogue of gentle micro-prompts grouped by mood.
///
/// When the user selects a mood, the app surfaces a tailored prompt
/// from this catalogue. Selection rotates via day-of-year index
/// so the prompt feels fresh without random jitter.
class JournalPrompts {
  JournalPrompts._();

  /// Prompts keyed by mood label.
  static const Map<String, List<String>> _byMood = {
    'Calm': [
      'One thing that made me exhale today...',
      'A quiet moment I want to remember...',
      'Something that felt still and good...',
      'I felt at ease when...',
    ],
    'Frazzled': [
      'Right now I need...',
      'The thing pulling at me most is...',
      'If I could hand off one task right now, it would be...',
      'A small way I can give myself a break...',
    ],
    'Running on Empty': [
      'If I could wave a wand and get one hour of...',
      'The hardest part of today was...',
      'What would recharge me right now...',
      'I am running low but I showed up by...',
    ],
    'Tearful': [
      'I am allowed to feel this way because...',
      'What I wish someone would say to me right now...',
      'The tears are about...',
      'A gentle thing I can do for myself in the next 5 minutes...',
    ],
    'Exhausted but Peaceful': [
      'Even though I am tired, I feel okay because...',
      'A small win I did not give myself credit for...',
      'Something my body did today that I am grateful for...',
      'The tiredness feels different today because...',
    ],
    'Hopeful': [
      'Something I am looking forward to, even if it is small...',
      'A sign that things are getting easier...',
      'Today I noticed...',
      'I am beginning to believe...',
    ],
    'Grateful': [
      'Three things: a warm drink, 10 min quiet, and...',
      'Someone who showed up for me recently...',
      'A tiny luxury I gave myself today...',
      'I am thankful for my body because...',
    ],
    'Overwhelmed': [
      'The biggest thing on my plate right now is...',
      'One thing I can let go of today...',
      'I need to hear that...',
      'If I focus on just one thing, it would be...',
    ],
  };

  /// Fallback prompts when no mood-specific match exists.
  static const List<String> _defaults = [
    'What gave you a moment of comfort today?',
    'One thing on your mind right now...',
    'A tiny moment that felt like yours today...',
    'Something you noticed about your baby today...',
  ];

  /// Returns a prompt for the given [mood], rotating by day-of-year.
  static String forMood(JournalMood mood) {
    final prompts = _byMood[mood.label] ?? _defaults;
    final dayIndex = DateTime.now().difference(DateTime(2026)).inDays;
    return prompts[dayIndex.abs() % prompts.length];
  }

  /// Returns a default prompt (no mood context).
  static String get defaultPrompt {
    final dayIndex = DateTime.now().difference(DateTime(2026)).inDays;
    return _defaults[dayIndex.abs() % _defaults.length];
  }
}
