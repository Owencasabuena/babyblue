import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/features/lessons/data/models/lesson_detail.dart';

/// Loads and caches lesson data from the bundled JSON asset.
///
/// This keeps the data layer completely decoupled from the UI —
/// lessons can be added, removed, or edited by modifying
/// `assets/data/lessons.json` without touching any Dart code.
class LessonRepository {
  List<LessonDetail>? _cache;

  /// Returns all lessons from the JSON catalogue.
  Future<List<LessonDetail>> getAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/data/lessons.json');
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;

    _cache = decoded
        .map((e) => LessonDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cache!;
  }

  /// Returns a single lesson by its [id], or `null` if not found.
  Future<LessonDetail?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((l) => l.id == id);
    } on StateError {
      return null;
    }
  }
}

/// Singleton repository instance shared across providers.
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository();
});
