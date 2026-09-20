import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/features/lessons/data/lesson_repository.dart';
import 'package:babyblue/features/lessons/data/models/lesson_detail.dart';

/// Provides the full list of lessons loaded from JSON.
final allLessonsProvider = FutureProvider<List<LessonDetail>>((ref) {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getAll();
});

/// Provides a single [LessonDetail] looked up by its [id].
///
/// Returns `null` if the ID does not match any entry in the catalogue.
final lessonDetailProvider =
    FutureProvider.family<LessonDetail?, String>((ref, id) {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getById(id);
});
