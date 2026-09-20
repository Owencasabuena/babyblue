import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/features/lessons/data/lesson_catalogue.dart';
import 'package:babyblue/features/lessons/data/models/lesson.dart';
import 'package:babyblue/features/mood_tracker/presentation/providers/mood_provider.dart';

/// Provides a list of [Lesson]s suggested for the user's current mood.
///
/// Watches [todayMoodProvider]:
/// - If a mood is logged today → returns lessons matching that score.
/// - If no mood logged → returns the default wellness set (score 3).
final suggestedLessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  final todayMood = await ref.watch(todayMoodProvider.future);

  if (todayMood != null) {
    return LessonCatalogue.forMoodScore(todayMood.moodScore);
  }

  return LessonCatalogue.defaults;
});
